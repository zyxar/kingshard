GO          = go
PRODUCT     = kingshard
GOARCH     := amd64
VERSION    := $(shell git describe --tags --always --dirty)
BUILD_TIME := $(shell date +%FT%T%z)
LDFLAGS     = -ldflags "-X main.Version=${VERSION} -X main.BuildTime=${BUILD_TIME}"


all: build

build: kingshard

bin/goyacc:
	$(GO) build -o ./bin/goyacc ./vendor/golang.org/x/tools/cmd/goyacc

sqlparser/sql.go: bin/goyacc
	bin/goyacc -o ./sqlparser/sql.go ./sqlparser/sql.y
	$(GO) fmt ./sqlparser/sql.go

kingshard: sqlparser/sql.go
	$(GO) build ${LDFLAGS} -v -o ./bin/kingshard ./cmd/kingshard

clean:
	@rm -rf bin
	@rm -f ./sqlparser/y.output ./sqlparser/sql.go

.PHONY: test
test:
	$(GO) test ./... -race
