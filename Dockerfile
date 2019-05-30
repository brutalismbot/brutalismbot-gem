ARG RUNTIME=ruby2.5

FROM lambci/lambda:build-${RUNTIME} AS install
COPY *.gemspec Gemfile /var/task/
ARG GEMSPEC_VERSION
ENV BUNDLE_SILENCE_ROOT_WARNING 1
RUN bundle install

FROM install AS build
COPY . .
ARG GEMSPEC_VERSION
RUN bundle exec rake
RUN bundle exec gem build *.gemspec --output release.gem
