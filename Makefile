runtime   := ruby2.5
name      := brutalismbot
version   := $(shell ruby -e 'puts Gem::Specification::load("$(name).gemspec").version')
build     := $(shell git describe --tags --always)

# Docker Build
image   := brutalismbot/gem
iidfile := .docker/$(build)
digest   = $(shell cat $(iidfile))

$(name)-$(version).gem: Gemfile.lock
	docker run --rm $(digest) cat /var/task/$@ > $@

Gemfile.lock: $(iidfile)
	docker run --rm $(digest) cat /var/task/$@ > $@

$(iidfile): | .docker
	docker build \
	--build-arg RUNTIME=$(runtime) \
	--iidfile $@ \
	--tag $(image):$(build) .

.docker:
	mkdir -p $@

.PHONY: shell clean

shell: $(iidfile)
	docker container run --rm -it $(digest) /bin/bash

clean:
	docker image rm -f $(image) $(shell sed G .docker/*)
	rm -rf .docker .rspec_status Gemfile.lock *.gem
