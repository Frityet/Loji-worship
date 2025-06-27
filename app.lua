local lapis = require("lapis")
local cfg = require("lapis.config").get()
local xml_gen = require("xml-generator")
local xml = xml_gen.xml
local layout = require("layout")
local app = lapis.Application()


app:get("/info", function()
    -- return "Welcome to Lapis "..require("lapis.version").." running on ".._VERSION.." ("..jit.version..", "")"
    -- return string.format("Praise Loji! Lapis %s running on %s (%s, %s %s. Nginx %s). Lua is the best programming language",  require("lapis.version"), _VERSION, jit.version, jit.arch, jit.os, ngx.config.nginx_version)
    return tostring(xml.body {
        xml.h1 "Praise Loji!";
        xml.p { "Lapis ", require("lapis.version"), " running on ", _VERSION, " (", jit.version, ", ", jit.arch, " ", jit.os, ". Nginx ", ngx.config.nginx_version, ")" };
        xml.p "Lua is the best programming language";
    })
end)

app:get("/", function(req) return tostring(layout(require("pages.index")(req))) end)
app:get("/favicon.ico", function() return { status = 404 } end)
app:get("/static/:path", function(req)
    local path = req.params.path
    if path:match("^%.%./") then
        return { status = 403, "Forbidden" }
    end
    return { root = cfg.static_root, path = path }
end)
app:get("/:path", function (req) return tostring(layout(require("pages."..req.params.path)(req))) end)

return app
