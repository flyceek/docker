FROM golang:alpine3.9
WORKDIR $GOPATH
ARG GOPROXY_VERSION=master
RUN apk update; apk upgrade; \
    apk add --no-cache ca-certificates git; \
    cd /go/src/; \
    mkdir -p github.com/snail007; \
    cd github.com/snail007; \
    git clone --depth=1 https://github.com/snail007/goproxy.git; \
	cd goproxy; \
    git checkout ${GOPROXY_VERSION}; \
    CGO_ENABLED=0 GOOS=linux go build -ldflags "-s -w" -a -installsuffix cgo -o proxy; \
    chmod 0777 proxy