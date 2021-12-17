SHELL = /bin/bash

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
	docker logs -f --tail=100 xswitch-free

stop:
	docker stop xswitch-free

pull:
	docker pull ccr.ccs.tencentyun.com/xswitch/xswitch-free

.PHONY conf:
	docker cp xswitch-free:/usr/local/freeswitch/conf .

eject: conf
	echo conf copied to local dir, please edit docker-compose.yml to use it

get-sounds:
	wget -O sounds.zip https://xswitch.cn/download/sounds.zip
	unzip sounds.zip
	echo "edit docker-compose.yml to use it"
