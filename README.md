# xswitch-free

`xswitch-free`是一个Docker镜像，与<https://xswitch.cn>同款，有删减。本镜像一般都基于FreeSWITCH最新的版本，有一些我们自己的补丁。我们绝大多数的补丁都已经合并到了上游的FreeSWITCH仓库中，其它的一些补丁也会逐步开源出来。

很多朋友想试用FreeSWITCH，但是从源代码安装比较复杂。FreeSWITCH虽然有相应的安装包，但用起来也不那么方便。

现在，Docker已经成了事实上的部署方式，我们xswitch.cn早已采用Docker容器化部署。为了大家更容易使用，我们做了这一镜像，希望对大家有用。

# 环境准备

首先，你要有一个Docker环境，如何安装Docker超出了本文的范围，您可以参阅以下链接，或自行查找相关资料安装。安装时注意有选择国内镜像站点的一些设置比较有用，在以后使用的时候可以节省一些下载镜像的时间。

* https://www.runoob.com/docker/windows-docker-install.html
* https://www.runoob.com/docker/ubuntu-docker-install.html
* https://www.runoob.com/docker/macos-docker-install.html
* https://yq.aliyun.com/articles/625403
* https://docs.microsoft.com/zh-cn/windows/wsl/tutorials/wsl-containers （WSL2上的Docker远程容器安装入门）

Docker Compose也需要安装，但不是必须的，只是安装了能更方便些，下面的命令大都依赖于Docker Compose。

本镜像支持在Linux、Mac、Windows宿主机上运行。

# 快速上手

很简单，先看命令：

```
git clone https://github.com/rts-cn/xswitch-free.git
cd xswitch-free
make setup # 可选，生成.env，修改生成的.env里的环境变量
make start
```

首先，Clone本项目，然后进入`xswitch-free`目录，`make setup`会生成`.env`，里面是相关的环境变量，可以根据情况修改（一般至少要将EXT_IP改为你自己宿主机的IP）。最后`make start`会以NAT方式启动容器。

启动后，你就可以用你称手的软电话注册到FreeSWITCH的IP上（默认端口5060），**用户名和密码任意**，打电话可以看到日志，注册两个不同的号码可以互拨，试一把看爽不爽。

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
* `LOCAL_NETWORK_ACL`：默认为`none`，在`host`网络模式下可以关闭。

# 配置

本镜像没有使用FreeSWITCH的默认配置。FreeSWITCH的默认配置为了展示FreeSWITCH各种强大的功能设计，复杂且初学者难以理解，所以，我们使用了最小化的配置，目标是让使用者快速上手，并进一步细化打造自己的镜像和容器。

以下配置接受任何注册和打电话。也就是说，你可以用软电话。

```xml
<param name="accept-blind-reg" value="true"/>
<param name="accept-blind-auth" value="true"/>
```

如果没有配置`EXT_IP`环境变量，需要将配置中如下内容注释掉。

```xml
<param name="ext-rtp-ip" value="$${ext_rtp_ip}"/>
<param name="ext-sip-ip" value="$${ext_sip_ip}"/>
```

# 常用命令

常用命令都在Makefile中，看起来也很直观。如果你的环境中没有`make`，也可以直接运行相关的命令。

* `make setup`：初始化环境，如果`.env`不存在，会从`env.example`复制。
* `make start`：启动镜像。
* `make run`：启动镜像并进入后台模式。
* `make cli`：进入容器并进入`fs_cli`。
* `make bash`：进入容器并进入`bash` Shell环境。可以进一步执行`fs_cli`等。
* `make stop`：停止容器。
* `make pull`：更新镜像，更新后可以用。
* `make get-sounds`：下载声音文件到本地，需要有`wget`工具。

如果没有安装Docker Compose，也可以直接使用Docker命令启动容器，如：

```bash
docker run --rm --name xswitch-free \
    -p 5060:5060/udp \
    -p 2000-2020:2000-2020/udp \
    -e ext_ip=192.168.7.7 \
    -e sip_port=5060 \
    -e sip_public_port=5080 \
    -e rtp_start=2000 \
    -e rtp_end=2010 \
    ccr.ccs.tencentyun.com/xswitch/xswitch-free
```

可以看出，这样需要输入很多参数，所以，还是使用Docker Compose比较方便。

# 修改配置

可以直接进入容器修改配置，并在终端上`reload xml`或重载相关模块使之生效。但在容器重启后修改会丢失。

如果想保持自己的修改，那就需要把配置文件放到宿主机上。通过以下命令可以生成默认的配置文件。

`make eject`

然后修改`docker-compose.yml`，取消掉以下行的注释：

```yaml
    volumes:
      - ./conf/:/usr/local/freeswitch/conf:cached
```

修改后需要重启镜像：

```bash
make stop
make start
```

# 增加声音文件

本镜像为了压缩空间，没有将声音文件打包到镜像内。如果需要挂载声音文件，可以先执行`make get-sounds`命令下载声音文件，然后修改`docker-compose.yml`的`volumes`配置，增加挂载：

```yaml
    volumes:
      - ./sounds/:/usr/local/freeswitch/sounds:cached
```

# `host`模式网络

典型的Docker容器运行方式是NAT型的网络，有时候，使用`host`模式网络会比较方便（因为少了一层NAT）。本镜像不需要特殊的配置就可以使用`host`网络，只需要在`docker-compose.yml`中启用即可。

如果环境变量中没有`EXT_IP`，则可能无法启动Sofia Profile，请禁掉`default.xml`和`public.xml`中的`ext-sip-ip`和`ext-rtp-ip`参数。

默认的配置是NAT模式，我们在Profile中启动了如下配置：

```xml
    <param name="local-network-acl" value="$${local_network_acl}"/>
```

注意，该环境变量默认为`none`，它实际上是一个不存在的ACL，所以FreeSWITCH对任何来源IP都会认为它在NAT后面。

如果在`host`网络模式下可以在`.env`中注释掉这个环境变量，让它使用默认的`localnet.auto`。

# 制作自己的镜像

你在本镜像的基础上制作自己的镜像。

# 测试号码

默认配置可以拨打如下测试号码：

```
9196 回音测试Echo
888  XSWITCH技术服务电话
3000 进入会议
其它号码，查找本地注册用户并桥接
```

# 报告问题

如果你发现有任何问题，请给我们提一个Issue。

欢迎提Pull Request。

# 关于我们

我们是<https://xswitch.cn>背后的团队。

# FAQ

* Q：本镜像是否适合在生产使用？
* A：我们就是在生产上使用的，所以，没有任何问题。只是，我们默认的配置是为了帮助大家学习和入门，没有过多考虑安全性，如果在生产上使用，需要仔细配置。另外，也强烈推荐使用我们有商业技术支持的版本，参见<https://xswitch.cn/pages/xswitch-install/> 。

* Q：我可以安装其它软件吗？
* A：本镜像基于Debian Buster制作，你可以使用`apt-get update`以及`apt-get install xxxx`安装任何其它软件。

* Q：在实际使用中，我们发现在Mac上，在使用UDP向FreeSWITCH注册的情况下，隔很短的时间注册就会失效，导致无法呼通终端，重新注册后能通。有什么好的解决方案吗？
* A：这可能跟Docker的NAT实现有关，使用TCP注册没有该问题。
