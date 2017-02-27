IMAGE    ?= steigr/java
VERSION  ?= $(shell git branch | grep \* | cut -d ' ' -f2)
BASE     ?= anapsix/alpine-java:8_server-jre_unlimited

all: image
	@true

image:
	sed 's#^FROM .*#FROM $(BASE)#' Dockerfile > Dockerfile.build
	docker pull $$(grep ^FROM Dockerfile.build | awk '{print $$2}')
	docker build --tag=$(IMAGE):$(VERSION) --file=Dockerfile.build .
	rm Dockerfile.build

run: image
	docker run --rm --env=TRACE --name=$(shell basename $(IMAGE)) $(IMAGE):$(VERSION)
