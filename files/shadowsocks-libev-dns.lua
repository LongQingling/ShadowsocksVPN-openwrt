local fs = require "nixio.fs"
local conffile = "/etc/shadowsocks/dns.json" 

f = SimpleForm("DNS翻墙", translate("Shadowsocks - DNS翻墙"), translate("这里配置用于DNS翻墙的服务，服务器需要支持UDP转发才行"))

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
