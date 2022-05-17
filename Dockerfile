FROM alpine:latest

LABEL maintainer="m3chd09 <m3chd09@protonmail.com>"

ADD run.sh /run.sh
RUN chmod +x /run.sh && /run.sh && rm -f /run.sh

CMD /usr/local/bin/xray -config /usr/local/etc/xray/config.json
