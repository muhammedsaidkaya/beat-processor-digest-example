ARG BEATS_VERSION=6.4.2
ARG GO_VERSION=1.10.3
ARG GO_PLATFORM=linux-amd64
ARG BEAT_NAME=filebeat
FROM golang:${GO_VERSION} as builder

ARG BEATS_VERSION

WORKDIR /go/src/github.com/muhammedsaidkaya/beats-processor-myplugin

RUN go get github.com/elastic/beats || true
RUN cd /go/src/github.com/elastic/beats && git checkout v${BEATS_VERSION}
COPY . .
RUN go get -d ./...

RUN go build -buildmode=plugin  -o processor-myplugin-linux.so


FROM docker.elastic.co/beats/filebeat:${BEATS_VERSION}

USER root
RUN mkdir -p /usr/local/plugins/
COPY --from=builder /go/src/github.com/muhammedsaidkaya/beats-processor-myplugin/processor-myplugin-linux.so /usr/local/plugins/
RUN chown -R filebeat:filebeat /usr/local/plugins/
USER filebeat
RUN cat /usr/local/bin/docker-entrypoint

CMD ["filebeat", "-e", "--plugin", "/usr/local/plugins/processor-myplugin-linux.so", "-v"]