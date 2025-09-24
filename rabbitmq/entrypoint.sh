#!/bin/bash
set -euo pipefail

# Ensure MQTT (and optional web MQTT) plugins are enabled before boot
rabbitmq-plugins enable --offline rabbitmq_mqtt rabbitmq_web_mqtt >/dev/null

exec docker-entrypoint.sh "$@"
