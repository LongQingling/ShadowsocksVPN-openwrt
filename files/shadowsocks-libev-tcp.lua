local fs = require "nixio.fs"
local conffile = "/etc/ssvpn/tcp.json" 

f = SimpleForm("TCP翻墙", translate("Shadowsocks - TCP翻墙"), translate("可以在这里设置走kcptun的连接加速，系统会同时启动socks5代理1080端口，http代理1083端口"))

t = f:field(TextValue, "conf")
t.rmempty = true
t.rows = 10
function t.cfgvalue()
	return fs.readfile(conffile) or ""
end

function f.handle(self, state, data)
	if state == FORM_VALID then
		if data.conf then
			fs.writefile(conffile, data.conf:gsub("\r\n", "\n"))
			luci.sys.call("/etc/init.d/ssvpn restart")
		end
	end
	return true
end

return f
