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

Package/shadowsocks-libev-gfwlist = $(call Package/shadowsocks-libev/Default,openssl,(OpenSSL), +libopenssl +libpcre +libpthread +dnsmasq-full +ipset +iptables +wget)

define Package/shadowsocks-libev/description
Shadowsocks-libev is a lightweight secured socks5 proxy for embedded devices and low end boxes.
endef

Package/shadowsocks-libev-gfwlist/description = $(Package/shadowsocks-libev/description)


define Package/shadowsocks-libev-gfwlist/conffiles
/etc/shadowsocks/tcp.json
/etc/shadowsocks/udp.json
/etc/shadowsocks/dns.json
/etc/shadowsocks/shadowsocks_gfwlist.conf
/etc/shadowsocks/shadowsocks_custom.conf
endef

define Package/shadowsocks-libev-gfwlist/preinst
#!/bin/sh
if [ ! -f /etc/dnsmasq.d/custom_list.conf ]; then
	
	echo "cache-size=5000" >> /etc/dnsmasq.conf
	echo "min-cache-ttl=1800" >> /etc/dnsmasq.conf
		
	echo "*/10 * * * * /etc/shadowsocks/ss-watchdog >> /var/log/shadowsocks_watchdog.log 2>&1" >> /etc/crontabs/root
	echo "0 1 * * 0 echo \"\" > /var/log/shadowsocks_watchdog.log" >> /etc/crontabs/root
fi
exit 0
endef

define Package/shadowsocks-libev-gfwlist/postinst
#!/bin/sh
/etc/init.d/dnsmasq restart
/etc/init.d/cron restart
/etc/init.d/shadowsocks restart
exit 0
endef

define Package/shadowsocks-libev-gfwlist/postrm
#!/bin/sh
sed -i '/cache-size=5000/d' /etc/dnsmasq.conf
sed -i '/min-cache-ttl=1800/d' /etc/dnsmasq.conf
/etc/init.d/dnsmasq restart

sed -i '/shadowsocks_watchdog.log/d' /etc/crontabs/root
/etc/init.d/cron restart

exit 0
endef

CONFIGURE_ARGS += --disable-ssp

ifeq ($(BUILD_VARIANT),polarssl)
	CONFIGURE_ARGS += --with-crypto-library=polarssl
endif

define Package/shadowsocks-libev-gfwlist/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/ss-{local,redir,tunnel} $(1)/usr/bin
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/shadowsocks $(1)/etc/init.d/shadowsocks
	$(INSTALL_DIR) $(1)/etc/shadowsocks
	$(INSTALL_CONF) ./files/shadowsocks.json $(1)/etc/shadowsocks/tcp.json
	$(INSTALL_CONF) ./files/shadowsocks.json $(1)/etc/shadowsocks/udp.json
	$(INSTALL_CONF) ./files/shadowsocks.json $(1)/etc/shadowsocks/dns.json	
	$(INSTALL_BIN) ./files/ss-watchdog $(1)/etc/shadowsocks/ss-watchdog	
	$(INSTALL_CONF) ./files/dnsmasq_list.conf $(1)/etc/shadowsocks/shadowsocks_gfwlist.conf
	$(INSTALL_CONF) ./files/custom_list.conf $(1)/etc/shadowsocks/shadowsocks_custom.conf	
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/controller
	$(INSTALL_CONF) ./files/shadowsocks-libev.lua $(1)/usr/lib/lua/luci/controller/shadowsocks-libev.lua
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/model/cbi/shadowsocks-libev
	$(INSTALL_CONF) ./files/shadowsocks-libev-general.lua $(1)/usr/lib/lua/luci/model/cbi/shadowsocks-libev/shadowsocks-libev-general.lua
	$(INSTALL_CONF) ./files/shadowsocks-libev-custom.lua $(1)/usr/lib/lua/luci/model/cbi/shadowsocks-libev/shadowsocks-libev-custom.lua
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/view/shadowsocks-libev
	$(INSTALL_CONF) ./files/gfwlist.htm $(1)/usr/lib/lua/luci/view/shadowsocks-libev/gfwlist.htm
	$(INSTALL_CONF) ./files/watchdog.htm $(1)/usr/lib/lua/luci/view/shadowsocks-libev/watchdog.htm
endef

$(eval $(call BuildPackage,shadowsocks-libev-gfwlist))
