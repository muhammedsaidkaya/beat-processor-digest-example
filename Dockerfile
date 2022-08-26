ARG BEATS_VERSION=8.2.0
ARG GO_VERSION=1.18.2
ARG GO_PLATFORM=linux-amd64
ARG BEAT_NAME=filebeat
FROM golang:${GO_VERSION} as builder

ARG BEATS_VERSION

WORKDIR /app

COPY . .
RUN go mod download

RUN go build -buildmode=plugin  -o processor-myplugin-linux.so


FROM docker.elastic.co/beats/filebeat:${BEATS_VERSION}

USER root
RUN mkdir -p /usr/local/plugins/
COPY --from=builder /app/processor-myplugin-linux.so /usr/local/plugins/
RUN chown -R filebeat:filebeat /usr/local/plugins/
USER filebeat
RUN cat /usr/local/bin/docker-entrypoint

CMD ["filebeat", "-e", "--plugin", "/usr/local/plugins/processor-myplugin-linux.so", "-v"]