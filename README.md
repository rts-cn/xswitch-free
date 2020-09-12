# xswitch-free

`xswitch-free`是一个Docker镜象，与<https://xswitch.cn>同款，有删减。本镜象一般都基于FreeSWITCH最新的版本，有一些我们自己的补丁。我们绝大多数的补丁都已经合并到了上游的FreeSWITCH仓库中，其它的一些补丁也会逐步开源出来。

很多朋友想试用FreeSWITCH，但是从源代码安装比较复杂。FreeSWITCH虽然有相应的安装包，但用起来也不那么方便。

现在，Docker已经成了事实上的部署方式，我们xswitch.cn早已采用Docker容器化部署。为了大家更容易使用，我们做了这一镜象，希望对大家有用。

# 环境准备

首先，你要有一个Docker，如果安装Docker超出了本文的范围，请参阅相关资料。

Docker Compose也需要安装，但不是必须的，只是下面的命令都依赖于Docker Compose。

本镜象支持在Linux、Mac、Windows宿主机上运行。

# 快速上手

很简单，先看命令：

```
git clone https://github.com/rts-cn/xswitch-free.git
cd xswitch-free
make setup # 可选，生成.env，修改生成的.env里的环境变量
make start
```

首先，Clone本项目，然后进入`xswitch-free`目录，`make setup`会生成`.env`，里面是相关的环境变量，可以根据情况修改。最后`make start`会以NAT方式启动容器。

启动后，你就可以用你称手的软电话注册到FreeSWITCH的IP上（默认端口5060），用户名密码任意，打电话可以看到日志，注册两个不同的号码可以互拨，试一把看爽不爽。

如果想进入控制台，可以打开另一个终端，执行`make cli`。

# 环境变量

以下环境变量，有相关的默认值

* `SIP_PORT`：默认SIP端口
* `SIP_TLS_PORT`：SIP TLS端口
* `SIP_PUBLIC_PORT` SIP `public` Profile端口
* `SIP_PUBLIC_TLS_PORT`：SIP `public` Profile TLS端口
* `RTP_START`：起始RTP端口
* `RTP_END`：结束RTP端口
* `EXT_IP`：宿主机IP，或公网IP，默认SIP Profile中的`ext-sip-ip`及`ext-rtp-ip`会用到它。
* `FREESWITCH_DOMAIN`：默认的FreeSWITCH域

# 配置

本镜象没有使用FreeSWITCH的默认配置，FreeSWITCH的默认配置为了展示FreeSWITCH各种强大的功能设计，复杂且初学者难以理解，所以，我们使用了最小化的配置，目标是让使用者快速上手，并进一步细化打造自己的镜像和容器。


以下配置接受任何注册和打电话。也就是说，你可以用软电话。

```xml
<param name="accept-blind-reg" value="true"/>
<param name="accept-blind-auth" value="true"/>
```

如果没有配置`EXT_IP`环境变最，需要将配置中如下内容注释掉。

```xml
<param name="ext-rtp-ip" value="$${ext_rtp_ip}"/>
<param name="ext-sip-ip" value="$${ext_sip_ip}"/>
```

# 常用命令

常用命令都在Makefile中，看起来也很直观。如果你的环境中没有`make`，也可以直接运行相关的命令。

* `make setup`：初始化环境，如果`.env`不存在，会从`env.example`复制。
* `make start`：启动镜象。
* `make run`：启动镜象并进入后台模式。
* `make cli`：进入容器并进入`fs_cli`。
* `make bash`：进入容器并进入`bash` Shell环境。可以进一步执行`fs_cli`等。
* `make stop`：停止容器。

# 修改配置

可以直接进入容器修改配置，并在终端上`reload xml`或重载相关模块使之生效。但在容器重启后修改会丢失。

如果想保持自己的修改，那就需要把配置文件放到宿主机上。通过以下命令可以生成默认的配置文件。

`make eject`

然后修改`docker-compose.yml`，取消掉以下行的注释：

```yaml
    volumes:
      - conf/:/usr/local/freeswitch/conf:cached
```

修改重需要重启镜像：

```bash
make stop
make start
```

# `host`模式网络

典型的Docker容器运行方式是NAT型的网络，有时候，使用`host`模式网络会比较方便（因为少了一层NAT）。本镜像不需要特殊的配置就可以使用`host`网络，只需要在`docker-compose.yml`中启用即可。

如果环境变量中没有`EXT_IP`，则可能无法启动Sofia Profile，请禁掉`default.xml`和`public.xml`中的`ext-sip-ip`和`ext-rtp-ip`参数。

# 制作自己的镜像

你可以根据本镜像制作自己的镜像。ToDo

# 报告问题

如果你发现有任何问题，请给我们提一个Issue。

欢迎的Pull Request。

# 关于我们

我们是<https://xswitch.cn>背后的团队。

# FAQ

* Q：本镜像是否适合在生产使用？
* A：我们就是在生产上使用的，所以，没有任何问题。只是，我们默认的配置是为了帮助大家学习和入门，在生产上使用，推荐使用我们有商业技术支持的版本。

* Q：我可以安装其它软件吗？
* A：本镜像基于Debian Buster制作，你可以使用`apt-get update`以及`apt-get install xxxx`安装任何其它软件。
