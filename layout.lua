local xml_gen = require("xml-generator")
local xml = xml_gen.xml

---@param children XML.Node
---@return XML.Node
return function(children)
    return xml.html { lang="en" } {
        xml.head {
            xml.title "Loji worship database",
            xml.meta { charset="utf-8" },
            xml.meta { name="viewport", content="width=device-width, initial-scale=1" },
            xml.link { rel="stylesheet", href="/static/tailwind.css" },

            xml.style [[
                @layer utilities {
                    .neon-red {
                        @apply text-red-500 drop-shadow-[0_0_8px_#ff4d4f] drop-shadow-[0_0_16px_#ff4d4f];
                    }
                    .glow-border {
                        position: relative;
                    }
                    .glow-border::before {
                        content: '';
                        position: absolute;
                        inset: 0;
                        border-radius: 0.75rem; /* rounded-xl */
                        padding: 2px;
                        background: conic-gradient(from 180deg at 50% 50%, #ff4d4f, #7a0000, #ff4d4f);
                        mask: linear-gradient(#0000 0 0) content-box, linear-gradient(#0000 0 0);
                        -webkit-mask: linear-gradient(#0000 0 0) content-box, linear-gradient(#0000 0 0);
                        mask-composite: exclude;
                        -webkit-mask-composite: xor;
                        animation: spin 6s linear infinite;
                    }
                    @keyframes spin {
                        100% {
                            transform: rotate(360deg);
                        }
                    }
                }
            ]]
        },
        xml.body { class = "min-h-screen bg-black text-gray-200 tracking-wide font-sans" } {
            xml.main(children) { class = "max-w-5xl mx-auto px-6 space-y-16" },
        }
    }
end
