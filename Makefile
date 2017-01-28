#
# Copyright (C) 2015 OpenWrt-dist
#
# This is free software, licensed under the GNU General Public License v3.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=ShadowsocksVPN
PKG_VERSION:=2.5.6
PKG_RELEASE:=3

PKG_LICENSE:=GPLv3
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=QiangYu <secrect@secrect>

MY_BASE_DIR:=$(BUILD_DIR)/$(PKG_NAME)/$(PKG_VERSION)
MY_BUILD_DIR_LIBEV=$(MY_BASE_DIR)/libev
MY_BUILD_DIR_PDNSD=$(MY_BASE_DIR)/pdnsd
MY_BUILD_DIR_VPN=$(MY_BASE_DIR)/vpn

PKG_BUILD_DIR:=$(MY_BASE_DIR)/$(BUILD_VARIANT)


PKG_INSTALL:=1
PKG_FIXUP:=autoreconf
PKG_USE_MIPS16:=0
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/ShadowsocksVPN/Default
	SECTION:=net
	CATEGORY:=Network
	TITLE:=Lightweight Secured Socks5 Proxy work like VPN $(2)
	URL:=https://github.com/qiang-yu/ShadowsocksVPN-openwrt
	VARIANT:=$(1)
	DEPENDS:=$(3)
endef

Package/libev = $(call Package/ShadowsocksVPN/Default,libev,(libev), +libopenssl +libpcre +libpthread +dnsmasq-full +ipset +iptables +wget)
Package/pdnsd = $(call Package/ShadowsocksVPN/Default,pdnsd,(pdnsd), +libpthread)
Package/ShadowsocksVPN = $(call Package/ShadowsocksVPN/Default,vpn,(vpn), +libopenssl +libpcre +libpthread +dnsmasq-full +ipset +iptables +wget)

define Package/ShadowsocksVPN/description
ShadowsocksVPN is a lightweight secured socks5 proxy for embedded devices and low end boxes.
endef

Package/libev/description = $(Package/ShadowsocksVPN/description)
Package/pdnsd/description = $(Package/ShadowsocksVPN/description)


define Package/ShadowsocksVPN/conffiles
/etc/shadowsocks/tcp.json
/etc/shadowsocks/udp.json
endef


ifeq ($(BUILD_VARIANT),libev)
	CONFIGURE_ARGS += --disable-ssp --disable-documentation --disable-assert
endif

ifeq ($(BUILD_VARIANT),pdnsd)
	TARGET_CFLAGS += -I$(STAGING_DIR)/usr/include
	CONFIGURE_ARGS += --with-cachedir=/var/pdnsd
endif


define Build/Prepare		
	rm -rf $(MY_BUILD_DIR_PDNSD)
	mkdir -p $(MY_BUILD_DIR_PDNSD)
	wget -4 --no-check-certificate -O $(MY_BUILD_DIR_PDNSD)/pdnsd.tar.gz  https://github.com/mengskysama/pdnsd/archive/1.2.9a.tar.gz
	tar zxf $(MY_BUILD_DIR_PDNSD)/pdnsd.tar.gz -C $(MY_BUILD_DIR_PDNSD)
	mv $(MY_BUILD_DIR_PDNSD)/pdnsd-1.2.9a/*  $(MY_BUILD_DIR_PDNSD) 
	
	rm -rf $(MY_BUILD_DIR_LIBEV)
	mkdir -p $(MY_BUILD_DIR_LIBEV)
	wget -4 --no-check-certificate -O $(MY_BUILD_DIR_LIBEV)/shadowsocks-libev.tar.gz  https://github.com/shadowsocks/openwrt-shadowsocks/releases/download/v2.5.6/shadowsocks-libev-2.5.6.tar.gz
	tar zxf $(MY_BUILD_DIR_LIBEV)/shadowsocks-libev.tar.gz -C $(MY_BUILD_DIR_LIBEV)
	mv $(MY_BUILD_DIR_LIBEV)/shadowsocks-libev-2.5.6/*  $(MY_BUILD_DIR_LIBEV) 
	
	rm -rf $(MY_BUILD_DIR_VPN)
	mkdir -p $(MY_BUILD_DIR_VPN)
	echo "install:;" > $(MY_BUILD_DIR_VPN)/Makefile
endef


define Package/libev/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/ss-{local,redir,tunnel} $(1)/usr/bin	
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/ss-{local,redir,tunnel} $(MY_BASE_DIR)
endef

define Package/pdnsd/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/pdnsd $(1)/usr/bin	
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/pdnsd $(MY_BASE_DIR)/ss-pdnsd
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/pdnsd-ctl/pdnsd-ctl $(MY_BASE_DIR)/ss-pdnsd-ctl
endef

define Package/ShadowsocksVPN/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(MY_BASE_DIR)/ss-{local,redir,tunnel,pdnsd} $(1)/usr/bin
	$(INSTALL_BIN) $(MY_BASE_DIR)/ss-redir $(1)/usr/bin/ss-redir-tcp
	$(INSTALL_BIN) $(MY_BASE_DIR)/ss-redir $(1)/usr/bin/ss-redir-udp
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/shadowsocks $(1)/etc/init.d/shadowsocks
	$(INSTALL_DIR) $(1)/etc/shadowsocks
	$(INSTALL_CONF) ./files/shadowsocks.json $(1)/etc/shadowsocks/tcp.json
	$(INSTALL_CONF) ./files/shadowsocks.json $(1)/etc/shadowsocks/udp.json
	$(INSTALL_CONF) ./files/pdnsd.conf $(1)/etc/shadowsocks/pdnsd.conf	
	$(INSTALL_CONF) ./files/ip.txt $(1)/etc/shadowsocks/ip.txt
	$(INSTALL_BIN) ./files/ss-watchdog $(1)/etc/shadowsocks/ss-watchdog	
	$(INSTALL_CONF) ./files/dnsmasq_list.conf $(1)/etc/shadowsocks/shadowsocks_gfwlist.conf
	$(INSTALL_CONF) ./files/custom_list.conf $(1)/etc/shadowsocks/shadowsocks_custom.conf	
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/controller
	$(INSTALL_CONF) ./files/shadowsocks-libev.lua $(1)/usr/lib/lua/luci/controller/shadowsocks-libev.lua
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/model/cbi/shadowsocks-libev
	$(INSTALL_CONF) ./files/shadowsocks-libev-tcp.lua $(1)/usr/lib/lua/luci/model/cbi/shadowsocks-libev/shadowsocks-libev-tcp.lua
	$(INSTALL_CONF) ./files/shadowsocks-libev-udp.lua $(1)/usr/lib/lua/luci/model/cbi/shadowsocks-libev/shadowsocks-libev-udp.lua
	$(INSTALL_CONF) ./files/shadowsocks-libev-ip.lua $(1)/usr/lib/lua/luci/model/cbi/shadowsocks-libev/shadowsocks-libev-ip.lua
	$(INSTALL_CONF) ./files/shadowsocks-libev-custom.lua $(1)/usr/lib/lua/luci/model/cbi/shadowsocks-libev/shadowsocks-libev-custom.lua
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/view/shadowsocks-libev
	$(INSTALL_CONF) ./files/gfwlist.htm $(1)/usr/lib/lua/luci/view/shadowsocks-libev/gfwlist.htm
	$(INSTALL_CONF) ./files/watchdog.htm $(1)/usr/lib/lua/luci/view/shadowsocks-libev/watchdog.htm	
endef

$(eval $(call BuildPackage,pdnsd))
$(eval $(call BuildPackage,libev))
$(eval $(call BuildPackage,ShadowsocksVPN))
