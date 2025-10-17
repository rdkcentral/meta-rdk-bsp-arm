inherit extrausers

EXTRA_USERS_PARAMS += "\
    groupadd -g 2000 dobbyapp      ; \
"

EXTRA_USERS_PARAMS += "\
    useradd -u 2000 -g dobbyapp -M -r -s /bin/nologin dobbyapp; \
    useradd -u 2001 -g dobbyapp -M -r -s /bin/nologin cobalt; \
"


