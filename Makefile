# Project
runtime   := ruby2.5
name      := brutalismbot
release   := $(shell git describe --tags --always)
build     := $(name)-$(release)
buildfile := tmp/$(build).build
pkgfile   := pkg/$(build).gem

# Docker Build
image := brutalismbot/$(name)
digest = $(shell cat tmp/$(build).build)

$(pkgfile): | Gemfile.lock pkg
	docker run --rm $(digest) cat /var/task/release.gem > $@

Gemfile.lock: $(name).gemspec | $(buildfile)
	docker run --rm $(digest) cat /var/task/$@ > $@

$(buildfile): | tmp
	docker build \
	--build-arg GEMSPEC_VERSION=$(release) \
	--build-arg RUNTIME=$(runtime) \
	--iidfile $@ \
	--tag $(image):$(release) .

%:
	mkdir -p $@

.PHONY: shell clean

shell: $(buildfile)
	docker container run --rm -it $(digest) /bin/bash

clean:
	docker image rm -f $(image) $(shell sed G tmp/*.build)
	rm -rf pkg tmp

# ruby -e 'print Gem::Specification::load("$(name).gemspec").version'
