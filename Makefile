#
# Copyright (C) 2015 OpenWrt-dist
#
# This is free software, licensed under the GNU General Public License v3.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=shadowsocks-libev
PKG_VERSION:=2.5.6
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/shadowsocks/openwrt-shadowsocks/releases/download/v$(PKG_VERSION)
PKG_MD5SUM:=bb99e090640c8af8d7da961a6230c70b

PKG_LICENSE:=GPLv3
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Max Lv <max.c.lv@gmail.com>

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)/$(BUILD_VARIANT)/$(PKG_NAME)-$(PKG_VERSION)

PKG_INSTALL:=1
PKG_FIXUP:=autoreconf
PKG_USE_MIPS16:=0
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/shadowsocks-libev/Default
	SECTION:=net
	CATEGORY:=Network
	TITLE:=Lightweight Secured Socks5 Proxy $(2)
	URL:=https://github.com/shadowsocks/shadowsocks-libev
	VARIANT:=$(1)
	DEPENDS:=$(3)
endef

Package/shadowsocks-libev = $(call Package/shadowsocks-libev/Default,openssl,(OpenSSL),+libopenssl +libpthread)
Package/shadowsocks-libev-gfwlist = $(call Package/shadowsocks-libev/Default,openssl,(OpenSSL), +libopenssl +libpthread +dnsmasq-full +ipset +iptables +wget)
Package/shadowsocks-libev-polarssl = $(call Package/shadowsocks-libev/Default,polarssl,(PolarSSL),+libpolarssl +libpthread)
Package/shadowsocks-libev-gfwlist-polarssl = $(call Package/shadowsocks-libev/Default,polarssl,(PolarSSL), +libpolarssl +libpthread +dnsmasq-full +ipset +iptables +wget-nossl)
Package/shadowsocks-libev-gfwlist-4M = $(call Package/shadowsocks-libev/Default,polarssl,(PolarSSL), +libpolarssl +libpthread +dnsmasq-full +ipset +iptables)

Package/shadowsocks-libev-server = $(call Package/shadowsocks-libev/Default,openssl,(OpenSSL),+libopenssl +libpthread)
Package/shadowsocks-libev-server-polarssl = $(call Package/shadowsocks-libev/Default,polarssl,(PolarSSL),+libpolarssl +libpthread)

define Package/shadowsocks-libev/description
Shadowsocks-libev is a lightweight secured socks5 proxy for embedded devices and low end boxes.
endef

Package/shadowsocks-libev-gfwlist/description = $(Package/shadowsocks-libev/description)
Package/shadowsocks-libev-polarssl/description = $(Package/shadowsocks-libev/description)
Package/shadowsocks-libev-gfwlist-polarssl/description = $(Package/shadowsocks-libev/description)
Package/shadowsocks-libev-gfwlist-4M/description = $(Package/shadowsocks-libev/description)

Package/shadowsocks-libev-server/description = $(Package/shadowsocks-libev/description)
Package/shadowsocks-libev-server-polarssl/description = $(Package/shadowsocks-libev/description)

define Package/shadowsocks-libev/conffiles
/etc/shadowsocks.json
endef

Package/shadowsocks-libev-polarssl/conffiles = $(Package/shadowsocks-libev/conffiles)

define Package/shadowsocks-libev-gfwlist/conffiles
/etc/shadowsocks.json
/etc/dnsmasq.d/custom_list.conf
endef

Package/shadowsocks-libev-gfwlist-polarssl/conffiles = $(Package/shadowsocks-libev-gfwlist/conffiles)
Package/shadowsocks-libev-gfwlist-4M/conffiles = $(Package/shadowsocks-libev-gfwlist/conffiles)

define Package/shadowsocks-libev-server/conffiles
/etc/shadowsocks-server.json
endef

Package/shadowsocks-libev-server-polarssl/conffiles = $(Package/shadowsocks-libev-server/conffiles)

define Package/shadowsocks-libev-gfwlist/preinst
#!/bin/sh
if [ ! -f /etc/dnsmasq.d/custom_list.conf ]; then
	echo "ipset -N gfwlist iphash" >> /etc/firewall.user
	echo "iptables -t nat -A PREROUTING -p tcp -m set --match-set gfwlist dst -j REDIRECT --to-port 1080" >> /etc/firewall.user
	echo "iptables -t nat -A OUTPUT -p tcp -m set --match-set gfwlist dst -j REDIRECT --to-port 1080" >> /etc/firewall.user
	
	echo "cache-size=5000" >> /etc/dnsmasq.conf
	echo "min-cache-ttl=1800" >> /etc/dnsmasq.conf
	echo "conf-dir=/etc/dnsmasq.d" >> /etc/dnsmasq.conf
	
	echo "*/10 * * * * /root/ss-watchdog >> /var/log/shadowsocks_watchdog.log 2>&1" >> /etc/crontabs/root
	echo "0 1 * * 0 echo \"\" > /var/log/shadowsocks_watchdog.log" >> /etc/crontabs/root
fi
exit 0
endef

define Package/shadowsocks-libev-gfwlist/postinst
#!/bin/sh
/etc/init.d/firewall restart
/etc/init.d/dnsmasq restart
/etc/init.d/cron restart
/etc/init.d/shadowsocks restart
exit 0
endef

define Package/shadowsocks-libev-gfwlist/postrm
#!/bin/sh
sed -i '/cache-size=5000/d' /etc/dnsmasq.conf
sed -i '/min-cache-ttl=1800/d' /etc/dnsmasq.conf
sed -i '/conf-dir=\/etc\/dnsmasq.d/d' /etc/dnsmasq.conf
rm -rf /etc/dnsmasq.d
/etc/init.d/dnsmasq restart

sed -i '/ipset -N gfwlist iphash/d' /etc/firewall.user
sed -i '/iptables -t nat -A PREROUTING -p tcp -m set --match-set gfwlist dst -j REDIRECT --to-port 1080/d' /etc/firewall.user
sed -i '/iptables -t nat -A OUTPUT -p tcp -m set --match-set gfwlist dst -j REDIRECT --to-port 1080/d' /etc/firewall.user
ipset flush gfwlist

sed -i '/shadowsocks_watchdog.log/d' /etc/crontabs/root
/etc/init.d/cron restart

exit 0
endef

Package/shadowsocks-libev-gfwlist-polarssl/preinst = $(Package/shadowsocks-libev-gfwlist/preinst)
Package/shadowsocks-libev-gfwlist-polarssl/postinst = $(Package/shadowsocks-libev-gfwlist/postinst)
Package/shadowsocks-libev-gfwlist-polarssl/postrm = $(Package/shadowsocks-libev-gfwlist/postrm)

CONFIGURE_ARGS += --disable-ssp

ifeq ($(BUILD_VARIANT),polarssl)
	CONFIGURE_ARGS += --with-crypto-library=polarssl
endif

define Package/shadowsocks-libev/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/ss-{local,redir,tunnel} $(1)/usr/bin
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_CONF) ./files/shadowsocks.json $(1)/etc/shadowsocks.json
	$(INSTALL_BIN) ./files/shadowsocks $(1)/etc/init.d/shadowsocks
endef

define Package/shadowsocks-libev-gfwlist/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/ss-{local,redir,tunnel} $(1)/usr/bin
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_CONF) ./files/shadowsocks.json $(1)/etc/shadowsocks.json
	$(INSTALL_BIN) ./files/shadowsocks $(1)/etc/init.d/shadowsocks
	$(INSTALL_DIR) $(1)/etc/dnsmasq.d
	$(INSTALL_CONF) ./files/dnsmasq_list.conf $(1)/etc/dnsmasq.d/dnsmasq_list.conf
	$(INSTALL_CONF) ./files/custom_list.conf $(1)/etc/dnsmasq.d/custom_list.conf
	$(INSTALL_DIR) $(1)/root
	$(INSTALL_BIN) ./files/ss-watchdog $(1)/root/ss-watchdog
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/controller
	$(INSTALL_CONF) ./files/shadowsocks-libev.lua $(1)/usr/lib/lua/luci/controller/shadowsocks-libev.lua
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/model/cbi/shadowsocks-libev
	$(INSTALL_CONF) ./files/shadowsocks-libev-general.lua $(1)/usr/lib/lua/luci/model/cbi/shadowsocks-libev/shadowsocks-libev-general.lua
	$(INSTALL_CONF) ./files/shadowsocks-libev-custom.lua $(1)/usr/lib/lua/luci/model/cbi/shadowsocks-libev/shadowsocks-libev-custom.lua
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/view/shadowsocks-libev
	$(INSTALL_CONF) ./files/gfwlist.htm $(1)/usr/lib/lua/luci/view/shadowsocks-libev/gfwlist.htm
	$(INSTALL_CONF) ./files/watchdog.htm $(1)/usr/lib/lua/luci/view/shadowsocks-libev/watchdog.htm
endef

Package/shadowsocks-libev-polarssl/install = $(Package/shadowsocks-libev/install)
Package/shadowsocks-libev-gfwlist-polarssl/install = $(Package/shadowsocks-libev-gfwlist/install)

define Package/shadowsocks-libev-gfwlist-4M/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/ss-{redir,tunnel} $(1)/usr/bin
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_CONF) ./files/shadowsocks.json $(1)/etc/shadowsocks.json
	$(INSTALL_BIN) ./files/shadowsocks-4M $(1)/etc/init.d/shadowsocks
	$(INSTALL_CONF) ./files/firewall.user-4M $(1)/etc/firewall.user
	$(INSTALL_CONF) ./files/dnsmasq.conf-4M $(1)/etc/dnsmasq.conf
	$(INSTALL_DIR) $(1)/etc/dnsmasq.d
	$(INSTALL_CONF) ./files/dnsmasq_list.conf $(1)/etc/dnsmasq.d/dnsmasq_list.conf
	$(INSTALL_CONF) ./files/custom_list.conf $(1)/etc/dnsmasq.d/custom_list.conf
	$(INSTALL_DIR) $(1)/root
	$(INSTALL_BIN) ./files/ss-watchdog-4M $(1)/root/ss-watchdog
	$(INSTALL_DIR) $(1)/etc/crontabs
	$(INSTALL_CONF) ./files/root-4M $(1)/etc/crontabs/root
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/controller
	$(INSTALL_CONF) ./files/shadowsocks-libev.lua $(1)/usr/lib/lua/luci/controller/shadowsocks-libev.lua
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/model/cbi/shadowsocks-libev
	$(INSTALL_CONF) ./files/shadowsocks-libev-general.lua $(1)/usr/lib/lua/luci/model/cbi/shadowsocks-libev/shadowsocks-libev-general.lua
	$(INSTALL_CONF) ./files/shadowsocks-libev-custom.lua $(1)/usr/lib/lua/luci/model/cbi/shadowsocks-libev/shadowsocks-libev-custom.lua
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/view/shadowsocks-libev
	$(INSTALL_CONF) ./files/gfwlist.htm $(1)/usr/lib/lua/luci/view/shadowsocks-libev/gfwlist.htm
	$(INSTALL_CONF) ./files/watchdog.htm $(1)/usr/lib/lua/luci/view/shadowsocks-libev/watchdog.htm
endef

define Package/shadowsocks-libev-server/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/ss-server $(1)/usr/bin
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_CONF) ./files/shadowsocks-server.json $(1)/etc/shadowsocks-server.json
	$(INSTALL_BIN) ./files/shadowsocks-server $(1)/etc/init.d/shadowsocks-server
endef

Package/shadowsocks-libev-server-polarssl/install = $(Package/shadowsocks-libev-server/install)

$(eval $(call BuildPackage,shadowsocks-libev-gfwlist))
