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
  
 [预编译 OpenWrt Chaos Calmer 15.05.1 ipk 下载][R]

 
 **注意：**  大部分人都是直接购买的 SS 帐号，这种帐号 90% 都只支持TCP浏览网页，不支持 **UDP转发**  ，问清楚你购买帐号的服务商，如果你的服务器不支持UDP转发，TCP只能浏览网页，不能打网游，不能做任何基于UDP的服务（**不能做VPN**），你就安安静静的上上网页就好了，别的就不折腾了。
 
 
 由于要实现 UDP透明转发 功能，所以要求你的 Openwrt 固件必须有几个模块，用下面的方式检查
 
   ```bash
   # 检查必须的内核模块
   opkg list-installed | grep tproxy
   # 输出应该显示下面的2个模块
   iptables-mod-tproxy
   kmod-ipt-tproxy
   # 如果你没有这2个模块，用下面的命令安装
   opkg update
   opkg install iptables-mod-tproxy kmod-ipt-tproxy
   ```
 
 如果你的固件本身不带这2个必备的模块，很不幸，你的固件无法使用 ShadowsocksVPN 。
 
 **注意：**  现在很多固件自带了 Shadowsocks、ShadowsocksR 功能，请停用甚至卸载这些程序，不然可能会发生冲突。
 
 
 如果你使用的是 L有大雕 的 Gargoyle-1.9.1-R5-x64-Professional-Edition 固件，里面有自带的 ShadowsocksR Pro 程序，默认不启动，不会冲突，只要你别开启它就行。ShadowsocksVPN 可以直接在 L有大雕 的 R5固件 上完美使用。
 

软件截图 (OpenWrt Luci 界面) 
---

软件支持对 TCP、UDP、DNS 翻墙分别独立设置

**为什么要 3个 独立设置嘞？**

TCP 设置走 KCPTUN 加速，用过的人就知道多爽了

UDP 设置走UDP服务器转发（KCPTUN 只能加速 TCP，不能加速 UDP，所以 UDP 没法走KCPTUN）

DNS 我喜欢走别的DNS服务器

**好麻烦，我只想用一个设置就好-**----（你当然可以把3个设置成一样的，我这里只是提供给你分别设置的可能性，等你真的遇到这样的需求你就会发现这个分开独立设置非常有价值）


 - OpenWrt菜单

	你能看到一个菜单 ShadowsocksVPN，从这里进去就能看到软件的所有设置

![1](https://github.com/qiang-yu/ShadowsocksVPN-openwrt/blob/master/misc/1.jpg)


 - TCP翻墙
 
	在这里填入你的 Shadowsocks 的配置，用于 TCP 翻墙。 喜欢用 KCPTUN 的也就是在这里填入你的 KCPTUN 地址。关于 KCPTUN 的使用请自己查找 KCPTUN 官方的介绍，我们这里不讨论。

![2](https://github.com/qiang-yu/ShadowsocksVPN-openwrt/blob/master/misc/2.jpg)


 - UDP翻墙
 
	这里是 UDP 翻墙的 Shadowsocks 配置。 KCPTUN 只能用于加速 TCP ，不能加速 UDP，所以你不能把 KCPTUN 的地址填写在这里。 UDP翻墙 基于的是 shadowsocks-libev 的UDP转发功能实现的，所以你需要在服务器端开启UDP转发才行。 如果服务器安装的也是 shadowsocks-libev 并且开启了 -u 参数，则你自动具备UDP转发功能。

	注意：如果你的服务器没有 UDP 转发功能，很不幸，你的UDP没法翻墙

	UDP翻墙 有什么卵用？

	大部分网游都是走的UDP协议，大量的聊天工具走的也是UDP协议，很多视频、语音聊天工具也是走UDP协议，如果你的UDP不能翻墙，这些你都用不了，你说有什么卵用嘞？

	现在市面上 95% 的 shadowsocks 配置教程都是教你配置好 TCP翻墙，然后就没有然后了，根本不提UDP翻墙的问题，这些教程都是把 Shadowsocks 阉割了用，而那些配置也只是让你可以 浏览网页 完事，其它的应用压根就没法用，想玩PS4、战地之类游戏没有UDP翻墙根本不行。 

![3](https://github.com/qiang-yu/ShadowsocksVPN-openwrt/blob/master/misc/3.jpg)


 - DNS翻墙
 
	需要翻墙的网站同样也需要翻墙解析DNS，这里一般和前面的UDP翻墙一样的设置就可以了。
	
	**注意：** 2.5.6-3 版本取消了DNS翻墙的单独设置，新版本自带 pdnsd 走TCP做DNS解析，不能单独设置。如果需要自己设置DNS的，请使用 2.5.6-2 版本。

![4](https://github.com/qiang-yu/ShadowsocksVPN-openwrt/blob/master/misc/4.jpg)


 - GFWList
 
	软件缺省提供了一份翻墙网站的域名列表，基本上被墙的网站都在里面了，你直接用就可以了。

![5](https://github.com/qiang-yu/ShadowsocksVPN-openwrt/blob/master/misc/5.jpg)

 - 自定义域名
 
	如果你要翻墙的网站不在上面的 GFWList 里面怎么办嘞？ 在这里自己添加就可以了，你要什么网站自己加上，这个网站就会被带着翻墙。在这里把游戏服务器的域名加上，你的UDP也就可以翻墙了，游戏畅通无阻。

![6](https://github.com/qiang-yu/ShadowsocksVPN-openwrt/blob/master/misc/6.jpg)



 - IP直通
 
	如果我要翻墙的只有一个IP没有域名怎么办嘞？（只提供了一个游戏服务器的IP地址）你在这里填上要翻墙的网站或者游戏服务器的IP地址，shadowsocksVPN 会自动对这个IP做翻墙，TCP、UDP都畅通。

![7](https://github.com/qiang-yu/ShadowsocksVPN-openwrt/blob/master/misc/7.jpg)


 - Watchdog
 
	ShadowsocksVPN 默认启动了watchdog 监控，每10分钟检查一次，如果网络故障会自动重启，这里是监控日志。

![8](https://github.com/qiang-yu/ShadowsocksVPN-openwrt/blob/master/misc/8.jpg)


常见问题  
---


**我怎么知道我的UDP真的也成功翻墙了嘞？**

玩游戏的人都知道用 [NAT测试工具][D] 可以测试UDP的连通情况，如下图所示。 你把测试的域名 **stun.ekiga.net** 填写到 “自定义域名” 里面，让这个域名可以翻墙，然后你用测试工具测试，看看下面 Public end 显示的 IP 地址是不是你翻墙之后的IP。 只要显示的是你翻墙之后的IP，就说明UDP成功翻墙出去了。

![10](https://github.com/qiang-yu/ShadowsocksVPN-openwrt/blob/master/misc/10.jpg)


**为什么 Chrome浏览器 用了你这个 ShadowsocksVPN 之后，我看 youtube 反而慢了嘞？**

Chrome默认开启了 QUIC 支持，访问网站优先采用 QUIC 协议，而不是传统的 HTTP 协议。 QUIC 走的是 UDP， 之前你的翻墙网络只有 TCP能翻墙，所以 QUIC不会启动， 现在 ShadowsocksVPN 会让UDP也翻墙了，所以 Chrome默认就采用 QUIC协议看youtube了，结果就是反而看youtube更慢了，解决方法就是把 Chrome的QUIC禁用，如下图：


![9](https://github.com/qiang-yu/ShadowsocksVPN-openwrt/blob/master/misc/9.jpg)


这种情况在开启了 KCPTUN 的情况下更明显， 禁用QUIC 速度比 启用QUIC 能快一倍以上。 这是 Chrome的QUIC 的问题，不是翻墙的问题，和翻墙无关。 


编译软件包  
---


 - 从 OpenWrt 的 [SDK][S] 编译

   ```bash
   # 以 OpenWrt Chaos Calmer 15.05.1 ar71xx 平台为例
   wget https://downloads.openwrt.org/chaos_calmer/15.05.1/ar71xx/generic/OpenWrt-SDK-15.05.1-ar71xx-generic_gcc-4.8-linaro_uClibc-0.9.33.2.Linux-x86_64.tar.bz2
   tar xjf OpenWrt-SDK-15.05.1-ar71xx-generic_gcc-4.8-linaro_uClibc-0.9.33.2.Linux-x86_64.tar.bz2
   cd OpenWrt-SDK-15.05.1-ar71xx-*
   # 更新 feeds 信息
   ./scripts/feeds update -a
   # 安装依赖包
   ./scripts/feeds install libpcre
   # 获取 ShadowsocksVPN 代码，你也可以下载 release 里面的压缩包
   git clone https://github.com/qiang-yu/ShadowsocksVPN-openwrt.git  package/ShadowsocksVPN-openwrt
   # 开始编译
   make package/ShadowsocksVPN-openwrt/compile V=s
   # 取得编译好的 ipk 包
   cd bin/... 
   ```

配置文件  
---

 - 安装之后配置文件都在: `/etc/shadowsocks` 目录下，里面文件一看就清楚


推荐搭配  
---

服务器使用 Debian8 x64 + shadowsocks-libev 默认开启 UDP 转发功能（你也可以用 ShadowsocksR 服务器，采用 shadowsocks原始 协议即可）


客户端使用 Gargoyle石像鬼 路由器 + ShadowsocksVPN 自动透明翻墙（TCP、UDP完全翻墙）


路由器自动翻墙，网络内部的任何设备（电脑、手机、平板、...）都可以透明翻墙，任何网页，任何游戏都可以畅通。比你在自己电脑上开一个纸飞机小程序，然后折腾各种代理程序要方便多了。


**什么样的路由器可以自动翻墙嘞？**


自己去 恩山论坛 找，一堆一堆的，有条件的建议上 X64 软路由，性能强大用起来爽，我用的就是 X64的软路由。


关于使用 ShadowsocksR  
---

如果你买的服务是 ShadowsocksR 带混肴的那种，不是原版的 Shadowsocks协议 ，首先你要确定你的服务是支持 UDP转发 的，如果你的服务器不支持 UDP转发，那你就没法实现 VPN一样 的功能，因为 VPN一样 的功能是要实现 TCP、UDP 两种协议都畅通。现在，假设你的 ShadowsocksR 服务器是支持UDP转发的，接下来你需要找到 [shadowsocksr-libev][2] 的编译好的文件（各大论坛自己去下载），用这个文件来替换 ShadowsocksVPN 自带的文件。


假如你用的是 L有大雕 的 Gargoyle-1.9.1-R5-x64-Professional-Edition-squashfs 固件，那么这个固件自带有 [shadowsocksr-libev][2] 已经编译好的可执行文件，你可以用下面的方式来替换，实现 ShadowsocksVPN 使用 ShadowsocksR 带混肴的协议。

   ```bash
   # Gargoyle-1.9.1-R5-x64-Professional-Edition-squashfs 固件
   # 自带了 ShadowsocksR-libev 的可执行文件，在 /usr/bin 目录下，有 ssr-redir, ssr-tunnel
   # 你也可以自己去别的地方下载别人编译好的 ssr-redir, ssr-tunnel 文件
   # 用下面的方式替换 ShadowsocksVPN 自带的文件
   cp -f ssr-redir   /usr/bin/ss-redir-tcp
   cp -f ssr-redir   /usr/bin/ss-redir-udp
   # 如果你用的是 2.5.6-3 版本，到这里就为止了
   # 如果你用的是 2.5.6-2，你还需要做下面的替换
   cp -f ssr-tunnel  /usr/bin/ss-tunnel
   ```

你只需要替换 ShadowsocksVPN 自带的 3个文件 `/usr/bin/ss-redir-tcp`  `/usr/bin/ss-redir-udp` `/usr/bin/ss-tunnel` 然后你就可以使用 ShadowsocksR 了，当然，请注意 Luci 界面配置 TCP翻墙、UDP翻墙、DNS翻墙 的时候请使用  **ShadowsocksR 格式**  的配置文件。


联系我  
---

如果你在 L有大雕 的 Gargoyle 石像鬼固件大群 里面，联系 孤狼吠月 就可以了。


如果你不在固件群里面，就 github 发 issue 吧。



----------


  [1]: https://github.com/shadowsocks/shadowsocks-libev
  [2]: https://github.com/shadowsocksr/shadowsocksr-libev
  [R]: https://github.com/qiang-yu/ShadowsocksVPN-openwrt/releases
  [S]: http://wiki.openwrt.org/doc/howto/obtain.firmware.sdk
  [D]: https://github.com/qiang-yu/ShadowsocksVPN-openwrt/raw/master/misc/NAT%E7%B1%BB%E5%9E%8B%E6%B5%8B%E8%AF%95%E5%B7%A5%E5%85%B7.zip
