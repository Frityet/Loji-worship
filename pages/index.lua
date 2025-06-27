local xml_gen = require("xml-generator")
local xml = xml_gen.xml
local utilities = require("common.utilities")

---@param req lapis.Request
---@return XML.Node
return function (req)
    return {
--[[
      <!-- Section 1 -->
      <section class="grid md:grid-cols-2 gap-10 items-center">
        <div class="flex flex-col justify-center order-2 md:order-1">
          <h2 class="text-3xl font-semibold neon-red mb-4">Cyber‑Manufactorium</h2>
          <p class="text-gray-300">
            Beneath crimson neon, quantum‑guided assembly lines birth miracles of steel &amp; silicon, forging a
            future where labour is liberation.
          </p>
        </div>
        <div class="order-1 md:order-2 glow-border p-1 rounded-xl">
          <img src="factory.jpg" alt="Cyber Factory" class="rounded-lg object-cover" />
        </div>
      </section>
]]
        xml.section { class="grid md:grid-cols-2 gap-10 items-center" } {
            xml.div { class="flex flex-col justify-center order-2 md:order-1" } {
                xml.h2 { class="text-3xl font-semibold neon-red mb-4" } "Test",
                xml.p { class="text-gray-300" } {
                    
                }
            }
        }
    }
end
