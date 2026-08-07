#!/bin/sh

MAX_WAIT=120
COUNT=0

is_raspberrypi() {
    grep -qi "raspberry pi" /proc/device-tree/model 2>/dev/null
}

get_phy_count() {
    iw dev 2>/dev/null | grep '^phy#' | wc -l
}

has_netgear_usb() {
    for usbdev in /sys/bus/usb/devices/*; do
        [ -f "$usbdev/idVendor" ] || continue
        [ -f "$usbdev/idProduct" ] || continue

        VENDOR=$(cat "$usbdev/idVendor" 2>/dev/null)

        if [ "$VENDOR" = "0846" ]; then
            return 0
        fi
    done

    return 1
}

echo "Checking WiFi initialization..."

# Non-Raspberry Pi platforms

if ! is_raspberrypi; then
    echo "Non-Raspberry Pi platform detected."
    touch /tmp/wifi_driver_initialized
    exit 0
fi

# Raspberry Pi

NETGEAR_USB=0

if has_netgear_usb; then
    REQUIRED_PHYS=2
    NETGEAR_USB=1
    echo "Netgear USB WiFi detected. Waiting for $REQUIRED_PHYS PHYs..."
else
    REQUIRED_PHYS=1
    echo "Using onboard WiFi. Waiting for $REQUIRED_PHYS PHY..."
fi

# Wait for required PHY count

while [ $COUNT -lt $MAX_WAIT ]
do
    PHY_COUNT=$(get_phy_count)

    echo "Attempt $COUNT : PHY count = $PHY_COUNT"

    if [ "$PHY_COUNT" -ge "$REQUIRED_PHYS" ]; then
        echo "WiFi PHY initialization completed."
        touch /tmp/wifi_driver_initialized
        exit 0
    fi

    sleep 1
    COUNT=$((COUNT + 1))
done

# Timeout handling

echo "WiFi PHY initialization timed out."

# Netgear USB detected but second PHY is not available.
# Continue with available onboard WiFi.

if [ "$NETGEAR_USB" -eq 1 ]; then

    PHY_COUNT=$(get_phy_count)

    if [ "$PHY_COUNT" -ge 1 ]; then
        echo "Continuing with available PHY count: $PHY_COUNT"
        touch /tmp/wifi_driver_initialized
        exit 0
    fi
fi

echo "No WiFi PHY available."
exit 1
