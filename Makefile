APP=$(shell basename $(shell git remote get-url origin))
REGISTRY := quay.io
NAME := istanko
TAG=$(shell git describe --tags --abbrev=0)
VERSION=$(shell dpkg --print-architecture)
TARGETOS=linux
TARGETARCH=arm64
BINARY_NAME := ${GOOS}

SRC := main.go
ifeq (${TARGETOS},darwin)
    ifeq (${TARGETARCH},arm64)
        BINARY_NAME := kbot_mac_arm
    else
        BINARY_NAME := kbot
    endif
else
    BINARY_NAME := kbot
endif

format:
	gofmt -s -w ./

lint:
	golint

test:
	go test -v

get:
	go get

build: format get
	CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -v -o kbot -ldflags "-X="github.com/i-stanko/kbot/cmd.appVersion=${VERSION}

image:
	docker build -t ${REGISTRY}/${NAME}:${VERSION} .

linux:
	make image APP=linux

windows:
	make image APP=windows

mac:
	make image APP=mac

arm:
	make image APP=arm

push:
	docker push docker push ${REGISTRY}/${NAME}:${TAG}

clean:
	rm -rf kbot
	docker rmi -f ${REGISTRY}/${NAME}:${TAG}
