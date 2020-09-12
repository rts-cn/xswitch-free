all:
	echo Hi

setup:
	if [[ ! -f .env ]]; then \
		cp env.example .env; \
	fi

run:
	docker-compose up -d

start:
	docker-compose up

bash:
	docker exec -it xswitch-free bash

cli:
	docker exec -it xswitch-free fs_cli

logs:
	docker logs xswitch-free

stop:
	docker stop xswitch-free

.PHONY conf:
	docker cp xswitch-free:/usr/local/freeswitch/conf conf

eject: conf
	echo conf copied to local dir, please edit docker-compose.yml to use it
