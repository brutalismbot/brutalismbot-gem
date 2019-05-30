# Project
runtime := ruby2.5
name    := brutalismbot
release := $(shell git describe --tags --always)
build   := $(name)-$(release)

# Docker Build
image := brutalismbot/$(name)
digest = $(shell cat tmp/$(build).build)

pkg/$(build).gem: | Gemfile.lock pkg
	docker run --rm $(digest) cat /var/task/$@ > $@

Gemfile.lock: $(name).gemspec | tmp/$(build).build
	docker run --rm $(digest) cat /var/task/$@ > $@

tmp/$(build).build: | tmp
	docker build \
	--build-arg GEMSPEC_VERSION=$(release) \
	--build-arg RUNTIME=$(runtime) \
	--iidfile $@ \
	--tag $(image):$(release) .

%:
	mkdir -p $@

.PHONY: shell clean

shell:
	docker container run --rm -it $(digest) /bin/bash

clean:
	docker image rm -f $(image) $$(sed G tmp/*.build)
	rm -rf pkg tmp

# ruby -e 'print Gem::Specification::load("$(name).gemspec").version'
