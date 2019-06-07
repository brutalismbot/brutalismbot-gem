runtime := ruby2.5
name    := brutalismbot
version := $(shell ruby -e 'puts Gem::Specification::load("$(name).gemspec").version')
build   := $(shell git describe --tags --always)

# Docker Build
image   := brutalismbot/gem
iidfile := .docker/$(build)
digest   = $(shell cat $(iidfile))

layer.zip: $(name)-$(version).gem
	docker run --rm -w /opt/ $(digest) zip -r - ruby > $@

$(name)-$(version).gem: Gemfile.lock
	docker run --rm $(digest) cat /var/task/$@ > $@

Gemfile.lock: $(iidfile)
	docker run --rm $(digest) cat /var/task/$@ > $@

$(iidfile): Gemfile | .docker
	docker build \
	--build-arg RUNTIME=$(runtime) \
	--iidfile $@ \
	--tag $(image):$(build) .

.%:
	mkdir -p $@

.PHONY: shell clean

shell: $(iidfile) .env
	docker container run --rm -it --env-file .env $(digest) /bin/bash

clean:
	docker image rm -f $(image) $(shell sed G .docker/*)
	rm -rf .docker .rspec_status Gemfile.lock *.gem *.zip
