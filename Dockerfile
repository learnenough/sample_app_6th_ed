ARG RUBY_VERSION
ARG ALPINE_VERSION=3.13

###############################################################################
# Stage 1 - Base Image
###############################################################################
FROM ruby:$RUBY_VERSION-alpine$ALPINE_VERSION AS base

# Fix vulnerability of version  of the apk-tools package
RUN apk add --update apk-tools=2.12.5-r0

# Installed dependencies used in the build and production image
RUN apk add --update \
  postgresql-client \
  tzdata \
  nodejs \
  yarn

# Install specific version of bundler
RUN gem install bundler -v 2.2.17

ARG USER=rails
ARG UID=1000
ARG GID=1000

RUN addgroup -g $GID $USER && adduser -D -u $UID -G $USER $USER

ARG USER=rails
USER $USER
###############################################################################
# Stage 2 - Test Image
###############################################################################
FROM base AS test

USER root

RUN apk add --update \
  postgresql-dev \
  sqlite \
  sqlite-dev \
  build-base

WORKDIR /usr/src/myapp

COPY . .
RUN bundle _2.2.17_ config set with 'test'
RUN bundle _2.2.17_ install --jobs=4 --retry=3
RUN RAILS_ENV=test RAKE_ENV=test bundle _2.2.17_ exec rake -T test

ARG USER=rails
USER $USER
###############################################################################
# Stage 3 - Build Image
###############################################################################
FROM base AS build

USER root

RUN apk add --update \
  postgresql-dev \
  build-base

COPY Gemfile Gemfile.lock ./
RUN bundle _2.2.17_ config set without 'development test'
RUN bundle _2.2.17_ install --jobs=4 --retry=3

COPY package.json yarn.lock ./
RUN yarn install --production

ARG USER=rails
USER $USER
###############################################################################
# Stage 4 - Final Image
###############################################################################
FROM base

USER root

ARG SECRET_KEY_BASE
ENV SECRET_KEY_BASE=$SECRET_KEY_BASE

WORKDIR /usr/src/myapp

COPY --from=build /usr/local/bundle/ /usr/local/bundle/
COPY --from=build /node_modules /usr/src/myapp/node_modules

COPY . .

# Install assets
RUN RAILS_ENV=production bundle _2.2.17_ exec rake assets:precompile

ARG USER=rails
ARG UID=1000
ARG GID=1000
RUN chown -R ${UID}:${GID} .
USER $USER

CMD ["bundle", "_2.2.17_", "exec", "puma", "-C", "./config/puma.rb"]