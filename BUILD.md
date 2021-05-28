# Build

## Image

The image for the project is based on the [oficial Ruby image](https://hub.docker.com/_/ruby)
following security best practices.

We added a companion `docker-compose` file to test the built
image against a PostgreSQL and Redis database. You can use it to run any environment
by modifying the appropiate environment variables. Bear in mind that trusted SSL certificates are required to run the
production environment (at least locally.)
Check the SSL section of this document to see how to create your certificates.

## Environment Variables

We modified part of the project configuration to accept environment variables. Each
user should create a file at the root of their project folder called `.env` , where
you should set all the variables. Git will not push this file
to the repository, and it makes `make` tasks work as intended.

Here is a template of the `.env` file that you should create:

```ini
###############################################################################
# Project Variables
###############################################################################
ORGANIZATION=
PROJECT_NAME=sample_app
PROJECT_VERSION=1.0.0
INTERFACE=0.0.0.0
HTTP_PORT=8080
HTTPS_PORT=8443
PIDFILE=tmp/server.pid
WEB_CONCURRENCY=2
DOMAIN=sample-app.127.0.0.1.nip.io
HOST=https://sample-app.127.0.0.1.nip.io:8443
INTERFACE=0.0.0.0
SSL_CRT=/usr/src/myapp/certificates/localhost.crt
SSL_KEY=/usr/src/myapp/certificates/localhost.key

###############################################################################
# Docker Variables
###############################################################################
USER=rails
ALPINE_VERSION=3.13
UID=1000
GID=1000

###############################################################################
# Node Variables
###############################################################################
NODE_ENV=production

###############################################################################
# Rails Variables
###############################################################################
RAILS_ENV=production
RAILS_MAX_THREADS=2
RAILS_MIN_THREADS=1
RAILS_SERVE_STATIC_FILES=true
RAILS_LOG_TO_STDOUT=true
SECRET_KEY_BASE=secret

###############################################################################
# Rack Variables
###############################################################################
RACK_ENV=production

###############################################################################
# AWS Variables
###############################################################################
AWS_ACCESS_KEY_ID=
AWS_SECRET_ACCESS_KEY=
AWS_REGION=
AWS_BUCKET=

###############################################################################
# Database Variables
###############################################################################
DATABASE_ENCODING=unicode
DATABASE_URL=postgresql://postgres/
DATABASE_NAME=sample_app_production
DATABASE_USERNAME=sample_app
DATABASE_PASSWORD=sample_app_password

###############################################################################
# SMTP Variables
###############################################################################
SMTP_ADDRESS=email-smtp.us-east-1.amazonaws.com
SMTP_PORT=587
SMTP_AUTHENTICATION=login
SMTP_USERNAME=
SMTP_PASSWORD=
SMTP_DOMAIN=
SMTP_FROM=

###############################################################################
# Redis Variables
###############################################################################
REDIS_URL=redis://redis:6379/1
```

Handle the filled values with care. The empty ones
are secret and should be kept that way.

## Logging

We modified the project logs to send them to `stdout`. This practice is recommended when handling containers. Especially, if they are going to be deployed
on a Kubernetes cluster.

## SMTP

The project was initially configured to use `SendGrid` as an SMTP server. This configuration
was modified to allow the use of any SMTP server, like SES from
AWS.

## Database

We also modified the production database configuration to accommodate any kind of
PostgreSQL database, not only those defined inside Heroku. Besides the user's credentials that Rails should use, you must provide the database's URL pointing to
the correct instance. For example: `postgresql://postgres/`.

## Make Tasks

We added a `Makefile` to the project to simplify the build process and other tasks.
We recommend running any `docker` related task using `make` because it
is configured to read the environment variables from the `.env` file and have the
proper configurations to run each command correctly.

We added some troubleshooting tasks like: `make exec`. This task creates an instance of the built image and executes into it so you can troubleshoot the image
result.

Please refer to the Makefile for a list of all available tasks.

### Testing

A `test` task was added that will run the all the tests inside a container image
based on the final production image. This assures that the resulting image complies
with the project requirements.

### SSL

Two tasks exist on the `Makefile` to simplify the creation of a local Certificate
Authority, and a certificate signed by it. You can add your local CA to your system
and use these certificates to test the app using HTTPS. The example provided on the
`Environment Variables` section provides the values that should be used for the
`SSL_CRT` and `SSL_KEY` variables when using these tasks.