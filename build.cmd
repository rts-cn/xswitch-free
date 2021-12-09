@echo off
setlocal

if ""%1"" == ""setup"" goto doSetup
if ""%1"" == ""run"" goto doRun
if ""%1"" == ""start"" goto doStart
if ""%1"" == ""bash"" goto doBash
if ""%1"" == ""cli"" goto docli
if ""%1"" == ""logs"" goto doLogs
if ""%1"" == ""stop"" goto doStop
if ""%1"" == ""pull"" goto doPull
if ""%1"" == ""PHONY"" goto doPHONY
if ""%1"" == ""eject"" goto doEject

echo Usage: build ( commands ...)
echo commands:
echo setup          make  .env file from the env.example  if it not exist
echo run            use docker-compose command to start the xswitch-free container with detached running
echo start          use docker-compose command to start the xswitch-free container with foreground running
echo bash           go into the xswitch-free container with bash
echo cli            go into the xswitch-free container with fs_cli
echo logs           catch  the xswitch-free container  logs
echo stop           stop xswitch-free container
echo pull           get the xswitch-free image 
echo PHONY          get the xswitch-free container's config
echo eject          tips
goto end 

:doSetup
    if not exist .env (
        copy env.example .env
    )
    goto end
:doRun
	docker-compose up -d
    goto end

:doStart
	docker-compose up
    goto end

:doBash
	docker exec -it xswitch-free bash
    goto end

:docli
	docker exec -it xswitch-free fs_cli
    goto end

:doLogs
	docker logs -f --tail=100 xswitch-free
    goto end

:doStop
	docker stop xswitch-free
    goto end

:doPull
	docker pull ccr.ccs.tencentyun.com/xswitch/xswitch-free
    goto end

:doPHONY
	docker cp xswitch-free:/usr/local/freeswitch/conf .
    goto end

:doEject
	echo conf copied to local dir, please edit docker-compose.yml to use it
    goto end
:end