local xml_gen = require("xml-generator")

local export = {}

---@param msg string
---@return XML.Node
function export.comment(msg)
    return xml_gen.raw("<!--", msg, "-->")
end

return export
