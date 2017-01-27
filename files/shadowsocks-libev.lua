module("luci.controller.shadowsocks-libev", package.seeall)

function index()
	if not nixio.fs.access("/etc/shadowsocks/tcp.json") then
		return
	end

	entry({"admin", "services", "shadowsocks-libev"},
		alias("admin", "services", "shadowsocks-libev", "tcp"),
		_("ShadowsocksVPN"), 10)

	entry({"admin", "services", "shadowsocks-libev", "tcp"},
		cbi("shadowsocks-libev/shadowsocks-libev-tcp"),
		_("TCP翻墙"), 10).leaf = true
		
	entry({"admin", "services", "shadowsocks-libev", "udp"},
		cbi("shadowsocks-libev/shadowsocks-libev-udp"),
		_("UDP翻墙"), 20).leaf = true		
		
	entry({"admin", "services", "shadowsocks-libev", "dns"},
		cbi("shadowsocks-libev/shadowsocks-libev-dns"),
		_("DNS翻墙"), 30).leaf = true				

	entry({"admin", "services", "shadowsocks-libev", "gfwlist"},
		call("action_gfwlist"),
		_("GFWList"), 40).leaf = true

	entry({"admin", "services", "shadowsocks-libev", "custom"},
		cbi("shadowsocks-libev/shadowsocks-libev-custom"),
		_("自定义域名"), 50).leaf = true
		
	entry({"admin", "services", "shadowsocks-libev", "ip"},
		cbi("shadowsocks-libev/shadowsocks-libev-ip"),
		_("IP直通"), 60).leaf = true			

	entry({"admin", "services", "shadowsocks-libev", "watchdog"},
		call("action_watchdog"),
		_("Watchdog Log"), 70).leaf = true
end

function action_gfwlist()
	local fs = require "nixio.fs"
	local conffile = "/etc/shadowsocks/shadowsocks_gfwlist.conf" 
	local gfwlist = fs.readfile(conffile) or ""
	luci.template.render("shadowsocks-libev/gfwlist", {gfwlist=gfwlist})
end

function action_watchdog()
	local fs = require "nixio.fs"
	local conffile = "/var/log/shadowsocks_watchdog.log" 
	local watchdog = fs.readfile(conffile) or ""
	luci.template.render("shadowsocks-libev/watchdog", {watchdog=watchdog})
end
