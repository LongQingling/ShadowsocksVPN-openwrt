local fs = require "nixio.fs"
local conffile = "/etc/shadowsocks/pdnsd.conf" 

f = SimpleForm("DNS翻墙", translate("Shadowsocks - DNS翻墙"), translate("这里配置用于DNS翻墙的服务，采用pdnsd转发DNS查询，不懂请不要随便更改，改错会导致无法上网"))

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
			luci.sys.call("/etc/init.d/shadowsocks restart")
		end
	end
	return true
end

return f
