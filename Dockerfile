ARG RUBY_VERSION
ARG ALPINE_VERSION=3.13

###############################################################################
# Stage 0 - Base Image
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

###############################################################################
# Stage 1 - Build Image
###############################################################################
FROM base AS build

RUN apk add --update \
  postgresql-dev \
  build-base
RUN gem install bundler -v 2.2.17

COPY package.json yarn.lock ./
RUN yarn install --production

COPY Gemfile Gemfile.lock ./
RUN bundle _2.2.17_ config set without 'development test'
RUN bundle _2.2.17_ install --jobs=4 --retry=3

###############################################################################
# Stage 0 - Final Image
###############################################################################
FROM base

ARG USER=rails
ARG UID=1000
ARG GID=1000
ARG SECRET_KEY_BASE

ENV SECRET_KEY_BASE=$SECRET_KEY_BASE

WORKDIR /usr/src/myapp

COPY --from=build /usr/local/bundle/ /usr/local/bundle/
COPY --from=build /node_modules /usr/src/myapp/node_modules

RUN addgroup -g $GID $USER \
  && adduser -D -u $UID -G $USER $USER

COPY . .

RUN chown -R ${UID}:${GID} .
USER rails

# Install assets
RUN RAILS_ENV=production bundle exec rake assets:precompile

CMD ["bundle", "exec", "puma", "-C", "./config/puma.rb"]