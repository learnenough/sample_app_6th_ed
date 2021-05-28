################################################################################
# Configuration
################################################################################
# Load .env from Makefile
ifneq (,$(wildcard ./.env))
	include .env
	export
endif
# Load the value of the ruby version beign used as an environment variable
RUBY_VERSION=`cat .ruby-version`
# Set the current working dir
PWD=`pwd`
################################################################################
# Target: clear
# Clear the terminal.
################################################################################
.PHONY: clear
clear:
	clear
################################################################################
# Target: build
# Build a new version of the project image. It will be tagged with the current
# version of the project. The base image will use the version of Ruby defined
# on the `.ruby-version` file at the root of this project.
################################################################################
.PHONY: build
build: clear
	@DOCKER_BUILDKIT=1 docker build -t ${ORGANIZATION}/${PROJECT_NAME}:${PROJECT_VERSION} \
		--build-arg RUBY_VERSION=${RUBY_VERSION} \
		--build-arg ALPINE_VERSION=${ALPINE_VERSION} \
		--build-arg USER=${USER} \
		--build-arg UID=${UID} \
		--build-arg GID=${GID} \
		--build-arg SECRET_KEY_BASE=${SECRET_KEY_BASE} \
		.
################################################################################
# Target: test
# Run the tests inside a new version of the image. It will be tagged with the
# current version of the project. The base image will use the version of Ruby
# defined on the `.ruby-version` file at the root of this project.
################################################################################
.PHONY: test
test: clear
	@DOCKER_BUILDKIT=1 docker build -t ${ORGANIZATION}/${PROJECT_NAME}:${PROJECT_VERSION} \
		--target=test \
		--build-arg RUBY_VERSION=${RUBY_VERSION} \
		--build-arg ALPINE_VERSION=${ALPINE_VERSION} \
		--build-arg USER=${USER} \
		--build-arg UID=${UID} \
		--build-arg GID=${GID} \
		.
################################################################################
# Target: scan
# Scan the image for known vulnerabilities. Should be run after each build.
################################################################################
.PHONY: scan
scan: clear
	docker scan ${ORGANIZATION}/${PROJECT_NAME}:${PROJECT_VERSION}
################################################################################
# Target: postgres
# Helper function to boot up just the PostgreSQL database defined in the
# docker-compose file.
################################################################################
.PHONY: postgres
postgres: clear
	docker compose up -d --no-build postgres
	@sleep 30
################################################################################
# Target: db-migrate
# Run the `rake db:migrate` task from the built image.
################################################################################
.PHONY: db-migrate
db-migrate: clear
	docker run -it --rm \
		--network ${PROJECT_NAME} \
		--name rails-db-migrate \
		--env-file ./.env \
		${ORGANIZATION}/${PROJECT_NAME}:${PROJECT_VERSION} \
		bundle exec rake db:migrate
################################################################################
# Target: db-seed
# Run the `rake db:seed` task from the built image.
################################################################################
.PHONY: db-seed
db-seed: clear
	docker run -it --rm \
		--network ${PROJECT_NAME} \
		--name rails-db-seed \
		--env-file ./.env \
		${ORGANIZATION}/${PROJECT_NAME}:${PROJECT_VERSION} \
		bundle exec rake db:seed
################################################################################
# Target: exec
# Runs a container from the created image and executes into it.
# Can be used to troubleshoot problems inside the image.
################################################################################
.PHONY: exec
exec: clear
	docker run -it --rm \
		--name rails-db-exec \
		--env-file ./.env \
		${ORGANIZATION}/${PROJECT_NAME}:${PROJECT_VERSION} \
		/bin/sh
################################################################################
# Target: setup
# Starts up a PostgreSQL, Redis, and App container to test the application
# locally.
################################################################################
.PHONY: setup
setup: clear postgres db-migrate db-seed up
################################################################################
# Target: up
# Runs docker-compose up
################################################################################
.PHONY: up
up: clear
	docker compose up -d --no-build
################################################################################
# Target: down
# Runs docker-compose down
################################################################################
.PHONY: down
down: clear
	docker compose down
################################################################################
# Target: teardown
# Destroys the running Docker Compose instance, deleting all networks and
# volumes.
################################################################################
.PHONY: teardown
teardown: clear
	docker compose down -v
################################################################################
# Target: certificates folder
# Creates the `./certificates` folder.
################################################################################
.PHONY: certificates-folder
certificates-folder:
	mkdir -p ./certificates
################################################################################
# Target: ca
# Creates a local CA.
# To use this CA in your system, you need to add them to your OS and configure
# to be trusted by your system. Please refer to your OS's documentation to see
# how to do this.
################################################################################
.PHONY: ca
ca: clear certificates-folder
	openssl req \
		-x509 \
		-nodes \
		-new \
		-sha256 \
		-days 1024 \
		-newkey rsa:2048 \
		-keyout ./certificates/ca.key \
		-out ./certificates/ca.pem \
		-subj "/C=US/CN=Localhost_CA"
	openssl x509 -outform pem -in ./certificates/ca.pem -out ./certificates/ca.crt
################################################################################
# Target: certificates
# Creates a local certificate validated by the CA created with the `make ca`
# task. The certificate will be valid for the domain configured on the
# environment variable `DOMAIN` and for `localhost`.
################################################################################
define DOMAINS_EXT
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = @alt_names
[alt_names]
DNS.1 = localhost
DNS.2 = ${DOMAIN}
endef
export DOMAINS_EXT
.PHONY: certificates
certificates: clear certificates-folder
	echo "$$DOMAINS_EXT" > ./certificates/domains.ext
	openssl req \
		-new \
		-nodes \
		-newkey rsa:2048 \
		-keyout ./certificates/localhost.key \
		-out ./certificates/localhost.csr \
		-subj "/C=UY/ST=Montevideo/L=Montevideo/O=Localhost-Certificates/CN=localhost.local"
	openssl x509 \
		-req \
		-sha256 \
		-days 1024 \
		-in ./certificates/localhost.csr \
		-CA ./certificates/ca.pem \
		-CAkey ./certificates/ca.key \
		-CAcreateserial \
		-extfile ./certificates/domains.ext \
		-out ./certificates/localhost.crt
