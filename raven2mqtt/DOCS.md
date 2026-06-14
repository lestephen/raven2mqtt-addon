# RAVEn to MQTT

Runs [raven2mqtt](https://github.com/lestephen/raven2mqtt) as a Home Assistant
add-on. It reads the Rainforest RAVEn / EMU-2 serial stream and publishes
normalized readings over MQTT with Home Assistant discovery.

## Requirements

- The RAVEn USB device plugged into the machine running Home Assistant.
- An MQTT broker. The Mosquitto add-on is auto-discovered; leave the MQTT fields
  blank to use it.

## Options

| Option | Description |
| --- | --- |
| `serial_device` | Path to the RAVEn serial device. Prefer the stable by-id path, for example `/dev/serial/by-id/usb-Rainforest_Automation_..._-if00` (the `/dev/ttyACM*` number can change between reboots, and other USB dongles can take `/dev/ttyACM0`). |
| `device_id` / `device_name` | Identifiers used for the Home Assistant device. |
| `base_topic` | MQTT base topic for state and discovery. |
| `discovery_prefix` | Home Assistant MQTT discovery prefix (default `homeassistant`). |
| `default_entity_prefix` | Entity ID prefix for the created sensors. |
| `mqtt_host` / `mqtt_port` / `mqtt_username` / `mqtt_password` / `mqtt_tls` | Optional manual broker settings. Leave `mqtt_host` blank to auto-discover the Mosquitto add-on. |

## Notes

- The add-on owns the serial port continuously, so Home Assistant restarts and
  upgrades do not disturb the RAVEn session.
- Last-known state is persisted to the add-on's `/data` directory.

## Troubleshooting

- **Log says `Serial device ... not found` even though the RAVEn is plugged in.**
  The add-on maps host serial devices via `uart: true` + `udev: true`. This works
  on a standard Home Assistant OS install where the RAVEn is attached directly to
  the machine. On virtualized installs (Home Assistant OS running in a VM with USB
  passthrough), the Supervisor may not map the passed-through device into the
  add-on container. If you hit this, please open an issue with your platform
  (bare-metal vs VM/hypervisor) and the add-on log; that feedback is actively
  wanted. As a workaround, the standalone
  [raven2mqtt](https://github.com/lestephen/raven2mqtt) service (run as a
  container or systemd unit on the host that owns the USB) does not depend on
  Supervisor device mapping.
- **No entities appear.** Confirm an MQTT broker is reachable (the Mosquitto
  add-on is auto-discovered) and that MQTT discovery is enabled in Home Assistant.
