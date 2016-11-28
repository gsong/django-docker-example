.DEFAULT_GOAL := test

LOCAL_IN = requirements/local.in
LOCAL_TXT = requirements/local.txt


install-dev-requirements:
	## Install requirements for local development environment
	pip install -q pip-tools
	pip-sync requirements/*.txt


pip-compile:
	## Update requirements/*.txt with latest packages from requirements/*.in
	pip install -q pip-tools
	pip-compile -U requirements/app.in
ifneq (, $(wildcard $(LOCAL_IN)))
	pip-compile -U $(LOCAL_IN)
endif


prod-compose:
	@env $$(cat .env.docker.prod | xargs) docker-compose \
		-f docker-compose.yml \
		-f docker-compose.override.prod.yml \
		$(c)


open-local-browser:
	$(eval url ?= http://localhost:8000)
	@until $$(curl -o /dev/null --silent --head --fail $(url)); do\
		sleep 1;\
	done
	open $(url)


dev-up: prod-down
	docker-compose up -d
	@$(MAKE) open-local-browser


dev-down:
	docker-compose down


prod-up: prod-down
	@$(MAKE) c="up -d" prod-compose
	@$(MAKE) url=http://localhost open-local-browser


prod-down:
	@$(MAKE) c="down" prod-compose
