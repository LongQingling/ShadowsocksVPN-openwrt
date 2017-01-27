ShadowsocksVPN for OpenWrt   
===

简介  
---

 现在已经有很多介绍怎么样使用 Shadowsocks 的项目了，为什么又做一个？

 现在大部分的项目都只是简单的教你怎么用 Shadowsocks 上网，也就是说，怎么浏览网页、看youtube、上Facebook，这些基本上都是局限于HTTP或者说TCP访问。可是如果我不只是要浏览网页，我有更多的需求，比如 我要打游戏、大型端游（使用 UDP 而不是 TCP），我用 IRC 聊天，用 ICQ， 或者各种其它不是基于 HTTP 的应用，怎么办？

 大部分教程都是教你怎么“访问网页”，只是把 Shadowsocks 作为一个“代理”使用，这基本上就是把Shadowsocks阉割了来用。

 本项目是把 Shadowsocks 最完整的一面展现出来，我们不只是浏览网页，我们还需要游戏、聊天、...各种不单纯是网页的应用，这就要求我们的翻墙网络不是只能浏览网页这么简单，我们需要一个“全功能翻墙”的网络，类似VPN一样，只要接入了所有的应用都可以跑，不用在乎是什么协议，不管什么协议的应用都能跑。我们的项目叫 ShadowsocksVPN，意思就是把 Shadowsocks 配置成一个完美的VPN，和VPN一样完全透明的网络，让你不止浏览网页爽，翻墙打游戏以及各种别的应用一样爽。

 
 本项目是 [shadowsocks-libev][1] 在 OpenWrt 上的完整移植，包括TCP、UDP协议都能完全透明翻墙，并且支持DNS防污染，整个实现了一个完整的VPN功能，可以用于替代任何现有的VPN来工作（现有的VPN技术被封杀的太厉害了，几乎不能用了）。
   
 当前版本: 2.5.6-2 采用 shadowsocks-libev 2.5.6 版本制作而成
  
 [预编译 OpenWrt Chaos Calmer 15.05 ipk 下载][R]


软件截图 (OpenWrt Luci 界面) 
---

软件支持对 TCP、UDP、DNS 翻墙分别独立设置

**为什么要 3个 独立设置嘞？**

TCP 设置走 KCPTUN 加速，用过的人就知道多爽了

UDP 设置走UDP服务器转发（KCPTUN 只能加速 TCP，不能加速 UDP，所以 UDP 没法走KCPTUN）

DNS 我喜欢走别的DNS服务器

**好麻烦，我只想用一个设置就好-**----（你当然可以把3个设置成一样的，我这里只是提供给你分别设置的可能性，等你真的遇到这样的需求你就会发现这个分开独立设置非常有价值）


 - 翻墙设置
![1](https://github.com/qiang-yu/ShadowsocksVPN-openwrt/blob/master/misc/1.jpg)

 - 翻墙设置
![2](https://github.com/qiang-yu/ShadowsocksVPN-openwrt/blob/master/misc/2.jpg)

 - 翻墙设置
![3](https://github.com/qiang-yu/ShadowsocksVPN-openwrt/blob/master/misc/3.jpg)


特性  
---

可编译 两种客户端版本 和 一种服务器端版本。


   > 集成gfwlist的一键安装版客户端，带luci界面  
   
   > 可执行文件 `ss-{redir,rules,tunnel}`  
   > 默认启动:  
   > `ss-redir` 提供透明代理  
   > `ss-tunnel` 提供 UDP 转发, 用于 DNS 查询。  
   > `ss-watchdog` 守护进程，每10分钟检查一次 www.google.com.hk 的联通情况。
   
   > 安装方法：  
     >> shadowsocks-libev-gfwlist_2.4.5-3.ipk 使用openssl加密库 完整安装需要约 5.0M 空间  
     >> shadowsocks-libev-gfwlist-polarssl_2.4.5-3.ipk 使用polarssl加密库 完整安装需要约 3.5M 空间  
     >> 用 winscp 把对应平台的 shadowsocks-libev-gfwlist_2.4.5-3.ipk 上传到路由器 /tmp 目录  
     >> 带上--force-overwrite 选项运行 opkg install
     >> ```bash
     >> opkg --force-overwrite install /tmp/shadowsocks-libev-gfwlist_2.4.5-3_*.ipk  
     >> ```
     >> 安装结束时会提示一条错误信息，这是升级dnsmasq-full时的配置文件残留造成的，可以忽略。  

 - shadowsocks-libev-server

   > 官方原版服务器端  
   
   > 可执行文件 `ss-server`  
   > 默认启动:  
   > `ss-server` 提供 shadowsocks 服务  

编译  
---

 - 从 OpenWrt 的 [SDK][S] 编译

   ```bash
   # 以 OpenWrt Chaos Calmer 15.05 ar71xx 平台为例
   wget https://downloads.openwrt.org/chaos_calmer/15.05/ar71xx/generic/OpenWrt-SDK-15.05-ar71xx-generic_gcc-4.8-linaro_uClibc-0.9.33.2.Linux-x86_64.tar.bz2
   tar xjf OpenWrt-SDK-15.05-ar71xx-generic_gcc-4.8-linaro_uClibc-0.9.33.2.Linux-x86_64.tar.bz2
   cd OpenWrt-SDK-15.05-ar71xx-*
   # 获取 Makefile
   git clone https://github.com/bettermanbao/openwrt-shadowsocks-libev-full.git package/shadowsocks-libev-full
   # 选择要编译的包 Network -> shadowsocks-libev
   make menuconfig
   # 开始编译
   make package/shadowsocks-libev-full/compile V=s
   ```

配置  
---

 - shadowsocks-libev 配置文件: `/etc/shadowsocks.json`

 - shadowsocks-libev-gfwlist 配置文件: `/etc/shadowsocks.json`

 - shadowsocks-libev-server 配置文件: `/etc/shadowsocks-server.json`


----------


  [1]: https://github.com/shadowsocks/shadowsocks-libev
  [R]: https://github.com/bettermanbao/openwrt-shadowsocks-libev-full/releases
  [S]: http://wiki.openwrt.org/doc/howto/obtain.firmware.sdk
