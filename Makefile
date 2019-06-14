name    := brutalismbot
runtime := ruby2.5
build   := $(shell git describe --tags --always)
version := $(shell ruby -e 'puts Gem::Specification::load("$(name).gemspec").version')
digest   = $(shell cat .docker/$(build))

.PHONY: all clean shell

all: Gemfile.lock $(name)-$(version).gem

.docker:
	mkdir -p $@

.docker/$(build): | .docker
	docker build \
	--build-arg RUNTIME=$(runtime) \
	--iidfile $@ \
	--tag brutalismbot/gem:$(build) .

Gemfile.lock $(name)-$(version).gem: .docker/$(build)
	docker run --rm $(digest) cat /var/task/$@ > $@

clean:
	-docker image rm -f $(shell awk {print} .docker/*)
	-rm -rf .docker .rspec_status Gemfile.lock *.gem *.zip

shell: .docker/$(build) .env
	docker run --rm -it --env-file .env $(digest) /bin/bash
