FROM debian:13

RUN apt-get update
RUN apt-get install -y git
RUN addgroup mkdocs -gid 2000
RUN adduser mkdocs -uid 2000 -gid 2000 --home /home/mkdocs --shell /bin/bash
COPY ./updater-script.sh /updater-script.sh
RUN chmod +x /updater-script.sh
RUN chown -Rc 2000:2000 /updater-script.sh
RUN mkdir -p /mkdocs/data
RUN chown -Rc 2000:2000 /mkdocs
USER mkdocs
WORKDIR /home/mkdocs

CMD ["/bin/bash", "-c", ". /updater-script.sh"]
