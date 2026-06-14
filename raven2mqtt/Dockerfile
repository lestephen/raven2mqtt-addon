ARG BUILD_FROM
FROM $BUILD_FROM

# Pin the raven2mqtt release this add-on version ships.
ARG RAVEN2MQTT_VERSION=0.1.0
RUN pip install --no-cache-dir "raven2mqtt==${RAVEN2MQTT_VERSION}"

COPY run.sh /
RUN chmod a+x /run.sh

CMD [ "/run.sh" ]
