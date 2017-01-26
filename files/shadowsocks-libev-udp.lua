local fs = require "nixio.fs"
local conffile = "/etc/shadowsocks/udp.json" 

f = SimpleForm("UDP", translate("Shadowsocks  - UDP Settings"), translate("This is used for UDP, you should have TProxy support"))

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
