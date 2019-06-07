ARG RUNTIME=ruby2.5

FROM lambci/lambda:build-${RUNTIME}

COPY . .

ARG BUNDLE_SILENCE_ROOT_WARNING=1

RUN bundle install
RUN bundle exec rake
RUN bundle exec gem build *.gemspec
RUN gem install *.gem --install-dir /opt/ruby/lib/
