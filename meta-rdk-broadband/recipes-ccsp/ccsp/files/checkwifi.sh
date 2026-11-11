#!/bin/sh

MAX_WAIT=120
COUNT=0

is_raspberrypi() {
    grep -qi "raspberry pi" /proc/device-tree/model 2>/dev/null
}

has_netgear_usb() {
    for usbdev in /sys/bus/usb/devices/*; do
        [ -f "$usbdev/idVendor" ] || continue
        VENDOR=$(cat "$usbdev/idVendor" 2>/dev/null)
        if [ "$VENDOR" = "0846" ]; then
            return 0
        fi
    done

    return 1
}

get_wifi_phy_count_udev() {
    ls /sys/class/ieee80211/ 2>/dev/null | wc -l
}

echo "Checking WiFi initialization using udev..."

if ! is_raspberrypi; then
    echo "Non-Raspberry Pi platform detected. Skipping WiFi PHY wait."
    exit 0
fi

REQUIRED_PHYS=1
NETGEAR_USB=0

if has_netgear_usb; then
    REQUIRED_PHYS=2
    NETGEAR_USB=1
    echo "Netgear USB WiFi detected. Waiting for $REQUIRED_PHYS PHYs..."
else
    REQUIRED_PHYS=1
    NETGEAR_USB=0
    echo "Using onboard WiFi. Waiting for $REQUIRED_PHYS PHY..."
fi

while [ $COUNT -lt $MAX_WAIT ]; do
    if [ "$NETGEAR_USB" -eq 0 ] && has_netgear_usb; then
        NETGEAR_USB=1
        REQUIRED_PHYS=2
        echo "Netgear USB WiFi detected during wait. Waiting for $REQUIRED_PHYS PHYs..."
    fi

    PHY_COUNT=$(get_wifi_phy_count_udev)
    echo "Attempt $COUNT: PHY count = $PHY_COUNT, required = $REQUIRED_PHYS"

    if [ "$PHY_COUNT" -ge "$REQUIRED_PHYS" ]; then
        echo "WiFi PHY initialization completed."
        exit 0
    fi

    sleep 1
    COUNT=$((COUNT + 1))
done

echo "WiFi PHY initialization timed out."

if [ "$NETGEAR_USB" -eq 1 ]; then
    PHY_COUNT=$(get_wifi_phy_count_udev)
    if [ "$PHY_COUNT" -ge 1 ]; then
        echo "Continuing with available PHY count: $PHY_COUNT"
        exit 0
    fi
fi

echo "No WiFi PHY available."
exit 1
