#!/usr/bin/with-contenv bashio
set -e

# Escape a value for use inside a TOML basic (double-quoted) string.
toml_escape() {
    printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'
}

CONFIG_PATH=/tmp/raven2mqtt.toml

SERIAL_DEVICE=$(bashio::config 'serial_device')
DEVICE_ID=$(bashio::config 'device_id')
DEVICE_NAME=$(bashio::config 'device_name')
BASE_TOPIC=$(bashio::config 'base_topic')
DISCOVERY_PREFIX=$(bashio::config 'discovery_prefix')
ENTITY_PREFIX=$(bashio::config 'default_entity_prefix')
MQTT_TLS=$(bashio::config 'mqtt_tls')

# Resolve the MQTT broker: an explicit host in options wins; otherwise use the
# Supervisor MQTT service if available.
if bashio::config.has_value 'mqtt_host'; then
    MQTT_HOST=$(bashio::config 'mqtt_host')
    MQTT_PORT=$(bashio::config 'mqtt_port')
    MQTT_USERNAME=$(bashio::config 'mqtt_username')
    MQTT_PASSWORD=$(bashio::config 'mqtt_password')
    bashio::log.info "Using MQTT broker from add-on options: ${MQTT_HOST}:${MQTT_PORT}"
elif bashio::services.available 'mqtt'; then
    MQTT_HOST=$(bashio::services 'mqtt' 'host')
    MQTT_PORT=$(bashio::services 'mqtt' 'port')
    MQTT_USERNAME=$(bashio::services 'mqtt' 'username')
    MQTT_PASSWORD=$(bashio::services 'mqtt' 'password')
    bashio::log.info "Using auto-discovered MQTT broker: ${MQTT_HOST}:${MQTT_PORT}"
else
    bashio::exit.nok "No MQTT broker configured and none discovered. Install the Mosquitto add-on or set mqtt_host in the options."
fi

# bashio returns the literal string "null" for unset optional values; treat that
# as empty so an unauthenticated broker is not given username/password "null".
[ "${MQTT_USERNAME}" = "null" ] && MQTT_USERNAME=""
[ "${MQTT_PASSWORD}" = "null" ] && MQTT_PASSWORD=""

if ! bashio::fs.device_exists "${SERIAL_DEVICE}"; then
    bashio::exit.nok "Serial device ${SERIAL_DEVICE} not found. Plug in the RAVEn and set serial_device to the correct path."
fi

# Render the raven2mqtt TOML config. Every user-supplied string is run through
# toml_escape so a value containing a quote or backslash cannot produce invalid
# TOML. Numeric/boolean values (port, tls_enabled) are emitted unquoted.
{
    echo "[serial]"
    echo "device = \"$(toml_escape "${SERIAL_DEVICE}")\""
    echo ""
    echo "[mqtt]"
    echo "host = \"$(toml_escape "${MQTT_HOST}")\""
    echo "port = ${MQTT_PORT}"
    echo "username = \"$(toml_escape "${MQTT_USERNAME}")\""
    echo "password = \"$(toml_escape "${MQTT_PASSWORD}")\""
    echo "base_topic = \"$(toml_escape "${BASE_TOPIC}")\""
    echo "discovery_prefix = \"$(toml_escape "${DISCOVERY_PREFIX}")\""
    echo "tls_enabled = ${MQTT_TLS}"
    echo ""
    echo "[service]"
    echo "state_file = \"/data/state.json\""
    echo ""
    echo "[device]"
    echo "id = \"$(toml_escape "${DEVICE_ID}")\""
    echo "name = \"$(toml_escape "${DEVICE_NAME}")\""
    echo "default_entity_prefix = \"$(toml_escape "${ENTITY_PREFIX}")\""
} > "${CONFIG_PATH}"

bashio::log.info "Starting raven2mqtt"
exec raven2mqtt --config "${CONFIG_PATH}" run
