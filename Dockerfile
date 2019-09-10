FROM alpine:latest

WORKDIR /tmp/build

ENV JQ_URL "https://github.com/mikefarah/yq/releases/download/2.4.0/yq_linux_amd64"

RUN apk --no-cache add bash curl git openssh jq; \
    curl -L -o /usr/local/bin/yq ${JQ_URL}; \
    chmod +x /usr/local/bin/yq

ADD check /opt/resource/check
ADD in /opt/resource/in
ADD out /opt/resource/out
ADD tools /opt/resource/tools

RUN chmod -R +x /opt/resource/

CMD /bin/bash
