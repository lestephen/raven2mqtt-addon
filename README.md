# raven2mqtt Home Assistant add-on

A Home Assistant add-on that runs [raven2mqtt](https://github.com/lestephen/raven2mqtt),
bridging a Rainforest RAVEn / EMU-2 serial device to MQTT with Home Assistant
discovery.

## Install

1. In Home Assistant: Settings -> Add-ons -> Add-on Store -> the three-dot menu
   -> Repositories, and add `https://github.com/lestephen/raven2mqtt-addon`.
2. Install the "RAVEn to MQTT" add-on.
3. Plug the RAVEn into the Home Assistant machine. Leave the MQTT fields blank to
   auto-discover the Mosquitto add-on, set `serial_device` if it is not
   `/dev/ttyACM0`, then start the add-on.

Requires the RAVEn USB device attached to the Home Assistant host and an MQTT
broker (such as the Mosquitto add-on). See the add-on's Documentation tab for
details.
