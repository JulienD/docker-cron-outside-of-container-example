FROM gliderlabs/alpine:3.4

MAINTAINER "Julien Dubreuil"

COPY crontab /tmp/crontab

COPY run-crond.sh /run-crond.sh
RUN chmod -v +x /run-crond.sh

RUN mkdir -p /var/log/cron && touch /var/log/cron/cron.log

CMD ["/run-crond.sh"]
