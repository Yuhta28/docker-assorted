FROM ubuntu:18.04

# Configure ENTRYPOINT
COPY docker-entrypoint.sh /
RUN chmod 755 /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["-n", "1"]
