ARG RUNTIME=ruby2.5

FROM lambci/lambda:build-${RUNTIME}
COPY . .
ENV BUNDLE_SILENCE_ROOT_WARNING 1
RUN bundle install
RUN bundle exec rake
RUN bundle exec gem build *.gemspec --output release.gem
