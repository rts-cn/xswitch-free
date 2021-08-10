# FreeSWITCH Config

最小化的支持Docker的配置，让我们从这里开始。

From: https://github.com/os11k/freeswitch_minimal_with_perf_settings

* 环境变量在.env里配置
* 可以工作在Docker网络NAT模式或Host模式
* NAT模式少仅支持少量RTP端口映射，大量端口需要iptables


## Minimal FreeSWITCH Configuration with minimal performance settings

The default "vanilla" configuration that comes with FreeSWITCH has
been designed as a showcase of the configurability of the myriad of
features that FreeSWITCH comes with out of the box. While it is very
helpful in tinkering with FreeSWITCH, it has a lot of extraneous stuff
enabled/configured for use in a production system. This configuration
aims to take the reverse stance -- it attempts to be a starting point
for configuring a new system by "adding" required features (instead of
removing them as one would do if one starts with the default
configuration).

This folder also includes the corresponding `modules.conf` that lists
the modules that are required to get this configuration working.

### Test

This configuration was tested by sending an INVITE (without
registration) using the `siprtp` example program that comes with
PJSIP, and verifying that the info dump is produced on the FreeSWITCH
console.

    $ ./siprtp -q -p 1234 "sip:stub@$(my_ip):5080"

### Upstream

The configuration in this folder comes from
[mx4492/freeswitch-minimal-conf](https://github.com/mx4492/freeswitch-minimal-conf/commit/270941d6f2dca279f1bb8762d072940273d5ae11).

### Other Minimal Configurations

* [voxserv/freeswitch_conf_minimal](https://github.com/voxserv/freeswitch_conf_minimal)
