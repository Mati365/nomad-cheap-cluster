FROM elasticsearch:7.17.2

USER root

COPY ./docker/docker-es-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-es-entrypoint.sh

EXPOSE 9200 9300
ENTRYPOINT [ "/usr/local/bin/docker-es-entrypoint.sh" ]
