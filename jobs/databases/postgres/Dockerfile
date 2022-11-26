FROM postgres:15.1

COPY ./docker/docker-env-file-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-env-file-entrypoint.sh

EXPOSE 5432
ENTRYPOINT ["/usr/local/bin/docker-env-file-entrypoint.sh"]
CMD ["postgres"]
