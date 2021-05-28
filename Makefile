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
################################################################################
.PHONY: clear
clear:
	clear
################################################################################
# Target: build
################################################################################
.PHONY: build
build: clear
	docker build -t ${ORGANIZATION}/${PROJECT_NAME}:${PROJECT_VERSION} \
		--build-arg RUBY_VERSION=${RUBY_VERSION} \
		--build-arg ALPINE_VERSION=${ALPINE_VERSION} \
		--build-arg USER=${USER} \
		--build-arg UID=${UID} \
		--build-arg GID=${GID} \
		--build-arg SECRET_KEY_BASE=${SECRET_KEY_BASE} \
		.
################################################################################
# Target: scan
################################################################################
.PHONY: scan
scan: clear
	docker scan ${ORGANIZATION}/${PROJECT_NAME}:${PROJECT_VERSION}
################################################################################
# Target: postgres
################################################################################
.PHONY: postgres
postgres: clear
	docker compose up -d --no-build postgres
	@sleep 30
################################################################################
# Target: db-migrate
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
################################################################################
.PHONY: exec
exec: clear
	docker run -it --rm \
		--network ${PROJECT_NAME} \
		--name rails-db-exec \
		--env-file ./.env \
		${ORGANIZATION}/${PROJECT_NAME}:${PROJECT_VERSION} \
		/bin/sh
################################################################################
# Target: dev
################################################################################
.PHONY: setup
setup: clear postgres db-migrate db-seed up
################################################################################
# Target: up
################################################################################
.PHONY: up
up: clear
	docker compose up -d --no-build
################################################################################
# Target: down
################################################################################
.PHONY: down
down: clear
	docker compose down
################################################################################
# Target: teardown
################################################################################
.PHONY: teardown
teardown: clear
	docker compose down -v
################################################################################
# Target: certificates folder
################################################################################
.PHONY: certificates-folder
certificates-folder:
	mkdir -p ./certificates
################################################################################
# Target: ca
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
################################################################################
define DOMAINS_EXT
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = @alt_names
[alt_names]
DNS.1 = localhost
DNS.2 = sample-app.127.0.0.1.nip.io
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
