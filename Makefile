#
# Copyright (C) 2015 OpenWrt-dist
#
# This is free software, licensed under the GNU General Public License v3.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=ShadowsocksVPN
PKG_VERSION:=2.5.6
PKG_RELEASE:=5

PKG_LICENSE:=GPLv3
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=QiangYu <secrect@secrect>

MY_BASE_DIR:=$(BUILD_DIR)/$(PKG_NAME)/$(PKG_VERSION)
MY_BUILD_DIR_LIBEV=$(MY_BASE_DIR)/libev
MY_BUILD_DIR_LIBEVSSR=$(MY_BASE_DIR)/libevssr
MY_BUILD_DIR_PDNSD=$(MY_BASE_DIR)/pdnsd
MY_BUILD_DIR_VPN=$(MY_BASE_DIR)/vpn
MY_BUILD_DIR_RVPN=$(MY_BASE_DIR)/rvpn

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
Package/libevssr = $(call Package/ShadowsocksVPN/Default,libevssr,(libevssr), +libopenssl +libpcre +libpthread +dnsmasq-full +ipset +iptables +wget)
Package/pdnsd = $(call Package/ShadowsocksVPN/Default,pdnsd,(pdnsd), +libpthread)
Package/ShadowsocksVPN = $(call Package/ShadowsocksVPN/Default,vpn,(vpn), +libopenssl +libpcre +libpthread +dnsmasq-full +ipset +iptables +wget)
Package/ShadowsocksRVPN = $(call Package/ShadowsocksVPN/Default,rvpn,(rvpn), +libopenssl +libpcre +libpthread +dnsmasq-full +ipset +iptables +wget)

define Package/ShadowsocksVPN/description
ShadowsocksVPN is a lightweight secured socks5 proxy for embedded devices and low end boxes.
https://github.com/mengskysama/pdnsd/archive/1.2.9a.tar.gz
https://github.com/shadowsocks/openwrt-shadowsocks/releases/download/v2.5.6/shadowsocks-libev-2.5.6.tar.gz
https://github.com/shadowsocksr/shadowsocksr-libev
endef

Package/libev/description = $(Package/ShadowsocksVPN/description)
Package/libevssr/description = $(Package/ShadowsocksVPN/description)
Package/pdnsd/description = $(Package/ShadowsocksVPN/description)
Package/ShadowsocksRVPN/description = $(Package/ShadowsocksVPN/description)


define Package/ShadowsocksVPN/conffiles
endef


ifeq ($(BUILD_VARIANT),libev)
	CONFIGURE_ARGS += --disable-ssp --disable-documentation --disable-assert
endif

ifeq ($(BUILD_VARIANT),libevssr)
	CONFIGURE_ARGS += --disable-ssp --disable-documentation --disable-assert
endif

ifeq ($(BUILD_VARIANT),pdnsd)
	TARGET_CFLAGS += -I$(STAGING_DIR)/usr/include
	CONFIGURE_ARGS += --with-cachedir=/var/pdnsd
endif


define Build/Prepare		
	rm -rf $(MY_BUILD_DIR_PDNSD)
	mkdir -p $(MY_BUILD_DIR_PDNSD)
	tar zxf ./code/pdnsd-1.2.9a.tar.gz -C $(MY_BUILD_DIR_PDNSD)
		
	rm -rf $(MY_BUILD_DIR_LIBEV)
	mkdir -p $(MY_BUILD_DIR_LIBEV)	
	tar zxf ./code/shadowsocks-libev-2.5.6.tar.gz -C $(MY_BUILD_DIR_LIBEV)
	
	rm -rf $(MY_BUILD_DIR_LIBEVSSR)
	mkdir -p $(MY_BUILD_DIR_LIBEVSSR)	
	tar zxf ./code/shadowsocksr-libev-3bb23c23ee071a4a7930015e8c7fef5c8a1de806.tar.gz -C $(MY_BUILD_DIR_LIBEVSSR)
		
	rm -rf $(MY_BUILD_DIR_VPN)
	mkdir -p $(MY_BUILD_DIR_VPN)
	echo "install:;" > $(MY_BUILD_DIR_VPN)/Makefile
	
	rm -rf $(MY_BUILD_DIR_RVPN)
	mkdir -p $(MY_BUILD_DIR_RVPN)
	echo "install:;" > $(MY_BUILD_DIR_RVPN)/Makefile
endef

define Package/pdnsd/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/pdnsd $(1)/usr/bin	
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/pdnsd-ctl/pdnsd-ctl $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/pdnsd $(MY_BASE_DIR)/ss-pdnsd
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/pdnsd-ctl/pdnsd-ctl $(MY_BASE_DIR)/ss-pdnsd-ctl
endef

define Package/libev/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/ss-{local,redir,tunnel} $(1)/usr/bin	
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/ss-{local,redir,tunnel} $(MY_BASE_DIR)
endef

define Package/libevssr/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/ss-local $(1)/usr/bin/ssr-local
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/ss-redir $(1)/usr/bin/ssr-redir
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/ss-tunnel $(1)/usr/bin/ssr-tunnel	
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/ss-redir $(MY_BASE_DIR)/ssr-redir
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/ss-local $(MY_BASE_DIR)/ssr-local
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/ss-tunnel $(MY_BASE_DIR)/ssr-tunnel
endef

define Package/ShadowsocksVPN/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(MY_BASE_DIR)/ss-pdnsd $(1)/usr/bin
	$(INSTALL_BIN) $(MY_BASE_DIR)/ss-local $(1)/usr/bin/ss-local
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
	$(INSTALL_BIN) ./files/update-gfwlist $(1)/etc/shadowsocks/update-gfwlist	
	$(INSTALL_CONF) ./files/dnsmasq_list.conf $(1)/etc/shadowsocks/shadowsocks_gfwlist.conf
	$(INSTALL_CONF) ./files/custom_list.conf $(1)/etc/shadowsocks/shadowsocks_custom.conf	
	
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/controller
	$(INSTALL_CONF) ./files/shadowsocks-libev.lua $(1)/usr/lib/lua/luci/controller/shadowsocks-libev.lua
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/model/cbi/shadowsocks-libev
	$(INSTALL_CONF) ./files/shadowsocks-libev-tcp.lua $(1)/usr/lib/lua/luci/model/cbi/shadowsocks-libev/shadowsocks-libev-tcp.lua
	$(INSTALL_CONF) ./files/shadowsocks-libev-udp.lua $(1)/usr/lib/lua/luci/model/cbi/shadowsocks-libev/shadowsocks-libev-udp.lua
	$(INSTALL_CONF) ./files/shadowsocks-libev-ip.lua $(1)/usr/lib/lua/luci/model/cbi/shadowsocks-libev/shadowsocks-libev-ip.lua
	$(INSTALL_CONF) ./files/shadowsocks-libev-custom.lua $(1)/usr/lib/lua/luci/model/cbi/shadowsocks-libev/shadowsocks-libev-custom.lua
	$(INSTALL_CONF) ./files/shadowsocks-libev-gfwlist.lua $(1)/usr/lib/lua/luci/model/cbi/shadowsocks-libev/shadowsocks-libev-gfwlist.lua
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/view/shadowsocks-libev
	$(INSTALL_CONF) ./files/gfwlist.htm $(1)/usr/lib/lua/luci/view/shadowsocks-libev/gfwlist.htm
	$(INSTALL_CONF) ./files/watchdog.htm $(1)/usr/lib/lua/luci/view/shadowsocks-libev/watchdog.htm	
endef

define Package/ShadowsocksRVPN/install
	$(INSTALL_DIR) $(1)/usr/bin	
	$(INSTALL_BIN) $(MY_BASE_DIR)/ss-pdnsd $(1)/usr/bin
	$(INSTALL_BIN) $(MY_BASE_DIR)/ssr-local $(1)/usr/bin/ss-local
	$(INSTALL_BIN) $(MY_BASE_DIR)/ssr-redir $(1)/usr/bin/ss-redir-tcp
	$(INSTALL_BIN) $(MY_BASE_DIR)/ssr-redir $(1)/usr/bin/ss-redir-udp
	$(INSTALL_DIR) $(1)/etc/shadowsocks
	$(INSTALL_CONF) ./files/shadowsocksr.json $(1)/etc/shadowsocks/tcp.json
	$(INSTALL_CONF) ./files/shadowsocksr.json $(1)/etc/shadowsocks/udp.json	
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/shadowsocks $(1)/etc/init.d/shadowsocks
	$(INSTALL_CONF) ./files/pdnsd.conf $(1)/etc/shadowsocks/pdnsd.conf	
	$(INSTALL_CONF) ./files/ip.txt $(1)/etc/shadowsocks/ip.txt
	$(INSTALL_BIN) ./files/ss-watchdog $(1)/etc/shadowsocks/ss-watchdog	
	$(INSTALL_BIN) ./files/update-gfwlist $(1)/etc/shadowsocks/update-gfwlist	
	$(INSTALL_CONF) ./files/dnsmasq_list.conf $(1)/etc/shadowsocks/shadowsocks_gfwlist.conf
	$(INSTALL_CONF) ./files/custom_list.conf $(1)/etc/shadowsocks/shadowsocks_custom.conf		
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/controller
	$(INSTALL_CONF) ./files/shadowsocks-libev.lua $(1)/usr/lib/lua/luci/controller/shadowsocks-libev.lua
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/model/cbi/shadowsocks-libev
	$(INSTALL_CONF) ./files/shadowsocks-libev-tcp.lua $(1)/usr/lib/lua/luci/model/cbi/shadowsocks-libev/shadowsocks-libev-tcp.lua
	$(INSTALL_CONF) ./files/shadowsocks-libev-udp.lua $(1)/usr/lib/lua/luci/model/cbi/shadowsocks-libev/shadowsocks-libev-udp.lua
	$(INSTALL_CONF) ./files/shadowsocks-libev-ip.lua $(1)/usr/lib/lua/luci/model/cbi/shadowsocks-libev/shadowsocks-libev-ip.lua
	$(INSTALL_CONF) ./files/shadowsocks-libev-custom.lua $(1)/usr/lib/lua/luci/model/cbi/shadowsocks-libev/shadowsocks-libev-custom.lua
	$(INSTALL_CONF) ./files/shadowsocks-libev-gfwlist.lua $(1)/usr/lib/lua/luci/model/cbi/shadowsocks-libev/shadowsocks-libev-gfwlist.lua
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/view/shadowsocks-libev
	$(INSTALL_CONF) ./files/gfwlist.htm $(1)/usr/lib/lua/luci/view/shadowsocks-libev/gfwlist.htm
	$(INSTALL_CONF) ./files/watchdog.htm $(1)/usr/lib/lua/luci/view/shadowsocks-libev/watchdog.htm	
endef

## package would build in the order of their name,  so  libev is build before pdnsd
## because l < p

$(eval $(call BuildPackage,pdnsd))
$(eval $(call BuildPackage,libev))
$(eval $(call BuildPackage,libevssr))

$(eval $(call BuildPackage,ShadowsocksVPN))
$(eval $(call BuildPackage,ShadowsocksRVPN))
