#!/bin/bash

# This script is used to trigger a pipeline in the Traverse
# hosted mirror repo
# See:
# https://gitlab.com/traversetech/rdk/meta-rdk-bsp-arm
# https://gitlab.com/traversetech/rdk/traverse-rdk-build

# In November 2026, GitHub added extra security conditions around
# `pull_request_target`, so instead of communicating directly with
# GitLab (as we did before), an external "proxy" host now handles
# creation of the GitLab pipeline.

set -euo pipefail

COOKIE_JAR=$(mktemp)

cleanup() {
	rm -f "${COOKIE_JAR}"
	echo "GitHub Action cancelled"
	# Cancellations are now handled by the proxy
	# Once the GitHub action runner is terminated, a cancellation
	# request will be issued to GitLab
	exit 130
}

get_pipeline_status() {
	curl --fail --silent --show-error \
		-b "${COOKIE_JAR}" \
		-o pipelinestatus.json \
		-d "id=${NEW_PIPELINE_ID}" \
		-G "${PROXY_STATUS_URL}"
}

# Gets the test log for the first non-cancelled (or skipped) job in the pipeline
# The last job in the pipeline will be presented first in the list
# (Last in, first out), so we are iterating in descending order
# (example: test -> build -> .pre)
get_test_log() {
	if ! curl --fail --silent --show-error \
		-b "${COOKIE_JAR}" \
		-o testlog.txt \
		-d "id=${NEW_PIPELINE_ID}" \
		-G "${PROXY_LOG_URL}"; then
		echo "WARNING: Failed to retrieve pipeline test log" >&2
		return 1
	fi
	tail -n 2000 testlog.txt || return 1
}

trap 'cleanup' SIGINT

pull_data=$(
	jq -n \
		--arg organisation "${GITHUB_REPOSITORY_OWNER}" \
		--arg repository "${GITHUB_REPOSITORY_NAME}" \
		--argjson number "${GITHUB_PR_NUMBER}" \
		--arg sha "${GITHUB_PR_SHA}" \
		--arg gh_run_id "${GITHUB_ACTION_RUN_ID}" \
		--arg gh_run_attempt "${GITHUB_ACTION_RUN_ATTEMPT}" \
		'{organisation: $organisation, repository: $repository, number: $number, sha: $sha, gh_run_id: $gh_run_id, gh_run_attempt: $gh_run_attempt}'
)

# The "proxy" hook will pull the commit branch from GitHub and
# push it to GitLab using the credentials it holds
# (avoiding doing so in the GitHub actions runner, and also
# the need to use mechanisms such as pull_request_target)
# It will return the created pipeline data from GitLab verbatim
if ! (curl --fail --silent --request POST \
	-H "Content-Type: application/json" \
	--data "${pull_data}" \
	-o new_pipeline.json \
	-c "${COOKIE_JAR}" \
	"${PROXY_CREATE_PIPELINE_URL}"); then
	echo "ERROR: Failed to trigger GitLab pipeline"
	exit 1
fi

NEW_PIPELINE_ID=""

if ! NEW_PIPELINE_ID=$(jq -er '.id' new_pipeline.json); then
	echo "ERROR: GitLab trigger response did not contain a pipeline ID"
	exit 1
fi
export NEW_PIPELINE_ID

echo "Created pipeline ID: ${NEW_PIPELINE_ID}"
if ! PIPELINE_WEB_URL=$(jq -er '.web_url' new_pipeline.json); then
	echo "ERROR: no 'web_url' in pipeline data"
	exit 1
fi
export PIPELINE_WEB_URL
echo "GitLab CI URL: ${PIPELINE_WEB_URL}"

max_polls=100 # 100 * 120s is just above 3 hours
polls=0
EXITCODE=1
while true; do
	if ! (get_pipeline_status); then
		echo "ERROR: Failed to query pipeline status"
		exit 1
	fi
	CURRENT_PIPELINE_STATUS=$(cat pipelinestatus.json | jq -r .status)
	if [ "${CURRENT_PIPELINE_STATUS}" = "running" ] || [ "${CURRENT_PIPELINE_STATUS}" = "pending" ] || [ "${CURRENT_PIPELINE_STATUS}" = "created" ] || [ "${CURRENT_PIPELINE_STATUS}" = "waiting_for_resource" ] || [ "${CURRENT_PIPELINE_STATUS}" = "preparing" ] || [ "${CURRENT_PIPELINE_STATUS}" = "scheduled" ]; then
		echo "Current pipeline status: ${CURRENT_PIPELINE_STATUS}"
		polls=$((polls + 1))
		if [ "${polls}" -ge "${max_polls}" ]; then
			echo "ERROR: Timed out waiting for pipeline to finish"
			EXITCODE=1
			break
		fi
		sleep 120 &
		PID=$!
		# Wait in the background, so if the pipeline is cancelled, the SIGINT handler works
		wait $PID
		continue
	elif [ "${CURRENT_PIPELINE_STATUS}" = "success" ]; then
		echo "Pipeline successful"
		EXITCODE=0
		break
	elif [ "${CURRENT_PIPELINE_STATUS}" = "failed" ]; then
		echo "ERROR: Pipeline failed"
		break
	elif [ "${CURRENT_PIPELINE_STATUS}" = "canceled" ]; then
		echo "ERROR: Pipeline was cancelled from the GitLab side"
		break
	else
		# There are some others like skipped or manual which we do not expect
		# in usual operation, catch them here
		echo "ERROR: Unrecognized or unhandled status ${CURRENT_PIPELINE_STATUS}"
		break
	fi
done

if ! get_test_log; then
	echo "WARNING: Pipeline log retrieval failed; pipeline result is unchanged" >&2
fi

rm -f "${COOKIE_JAR}"

echo "Please go to ${PIPELINE_WEB_URL} to view the full pipeline details"
exit "${EXITCODE}"
