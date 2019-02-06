GOPATH ?= $(shell go env GOPATH)

# Ensure GOPATH is set before running build process.
ifeq "$(GOPATH)" ""
  $(error Please set the environment variable GOPATH before running `make`)
endif

GOOS       := $(shell go env GOOS)
GOARCH     := $(shell go env GOARCH)
PKGS       := $(shell go list ./... | grep -v vendor)


# NOTE: '-race' requires cgo; enable cgo by setting CGO_ENABLED=1
#BUILD_FLAG := -race
GOBUILD    := CGO_ENABLED=0 GOOS=${GOOS} GOARCH=${GOARCH} go build $(BUILD_FLAG)

LDFLAGS += -X "github.com/moooofly/harborctl/utils.ClientVersion=$(shell cat VERSION)"
LDFLAGS += -X "github.com/moooofly/harborctl/utils.GoVersion=$(shell go version)"
LDFLAGS += -X "github.com/moooofly/harborctl/utils.UTCBuildTime=$(shell date -u '+%Y-%m-%d %I:%M:%S')"
LDFLAGS += -X "github.com/moooofly/harborctl/utils.GitBranch=$(shell git rev-parse --abbrev-ref HEAD)"
LDFLAGS += -X "github.com/moooofly/harborctl/utils.GitTag=$(shell git describe --tags)"
LDFLAGS += -X "github.com/moooofly/harborctl/utils.GitHash=$(shell git rev-parse HEAD)"

.PHONY: all build install lint test pack docker misspell shellcheck clean

all: lint build test

build:
	@echo "==> Building ..."
	$(GOBUILD) -o harborctl_${GOOS}_${GOARCH} -ldflags '$(LDFLAGS)' ./
	@echo ""

install:
	@echo "==> Installing ..."
	go install -x ${SRC}
	@echo ""

lint:
	@# gometalinter - Concurrently run Go lint tools and normalise their output
	@# - go get -u github.com/alecthomas/gometalinter  (Install from HEAD)
	@# - gometalinter --install  (Install all known linters)
	@echo "==> Running gometalinter ..."
	gometalinter --exclude=vendor --disable-all --enable=golint --enable=vet --enable=gofmt --enable=misspell
	find . -name '*.go' -not -path "./vendor/*" | xargs gofmt -w -s
	@echo ""

test:
	@echo "==> Testing ..."
	go test -short -race $(PKGS)
	@echo ""

deps:
	@echo "===> Tidy Dependencies ..."
	go mod tidy && go mod vendor
	@echo ""

build_linux:
	CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build $(BUILD_FLAG) -o harborctl_linux_amd64 -ldflags '$(LDFLAGS)' ./

build_darwin:
	CGO_ENABLED=0 GOOS=darwin GOARCH=amd64 go build $(BUILD_FLAG) -o harborctl_darwin_amd64 -ldflags '$(LDFLAGS)' ./

pack: build_linux build_darwin
	@echo "==> Packing ..."
	@tar czvf harborctl-$(shell cat VERSION).linux-amd64.tar.gz harborctl_linux_amd64 conf/*.yaml
	@echo ""
	@tar czvf harborctl-$(shell cat VERSION).darwin-amd64.tar.gz harborctl_darwin_amd64 conf/*.yaml
	@echo ""
	@rm harborctl_linux_amd64
	@rm harborctl_darwin_amd64

misspell:
	@# misspell - Correct commonly misspelled English words in source files
	@#    go get -u github.com/client9/misspell/cmd/misspell
	@echo "==> Runnig misspell ..."
	find . -name '*.go' -not -path './vendor/*' -not -path './_repos/*' | xargs misspell -error
	@echo ""

clean:
	@echo "==> Cleaning ..."
	go clean -x -i ${SRC}
	rm -f harborctl_*
	rm -rf *.out
	rm -rf *.tar.gz
	@echo ""

