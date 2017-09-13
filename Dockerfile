FROM ruby:2.3.1-slim

MAINTAINER Max Lund <lundmax@gmail.com>

RUN apt-get update && apt-get install -qq -y build-essential libpq-dev postgresql-client-9.4 git-all --fix-missing --no-install-recommends

ENV INSTALL_PATH /app
RUN mkdir -p $INSTALL_PATH

WORKDIR $INSTALL_PATH

COPY Gemfile Gemfile
RUN bundle install

COPY . .

CMD bundle exec puma -C config/puma.rb
