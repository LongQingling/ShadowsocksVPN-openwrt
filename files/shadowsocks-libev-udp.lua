local fs = require "nixio.fs"
local conffile = "/etc/ssvpn/udp.json" 

f = SimpleForm("UDP翻墙", translate("Shadowsocks - UDP翻墙"), translate("配置UDP翻墙，从此游戏不再愁，需要你的翻墙服务器支持UDP转发才行"))

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
