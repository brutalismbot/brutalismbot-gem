name    := brutalismbot
runtime := ruby2.5
build   := $(shell git describe --tags --always)
version := $(shell ruby -e 'puts Gem::Specification::load("$(name).gemspec").version')

.PHONY: all clean shell

all: Gemfile.lock layer.zip $(name)-$(version).gem

.docker:
	mkdir -p $@

.docker/%: Gemfile | .docker
	docker build \
	--build-arg RUNTIME=$(runtime) \
	--iidfile $@ \
	--tag brutalismbot/gem:$(build) .

Gemfile.lock $(name)-$(version).gem: .docker/$(build)
	docker run --rm $(shell cat $<) cat /var/task/$@ > $@

layer.zip: .docker/$(build)
	docker run --rm -w /opt/ $(shell cat $<) zip -r - ruby > $@

shell: .docker/$(build) .env
	docker container run --rm -it --env-file .env $(shell cat $<) /bin/bash

clean:
	-docker image rm -f $(shell sed G .docker/*)
	-rm -rf .docker .rspec_status Gemfile.lock *.gem *.zip
