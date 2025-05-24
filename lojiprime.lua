-- local utf8 = require("utf8")
if not utf8 then
    utf8 = require("utf8")
end
local xml_gen = require("xml-generator")
local html = xml_gen.xml

---@param input file*
---@return fun(): string?, string
local function parse_localisation(input)
    return coroutine.wrap(function()
        for line in input:lines() do
            local trimmed = line:match("^%s*(.-)%s*$")
            if trimmed ~= "" and not trimmed:match("^#") then
                ---@type string, string
                local key, value = trimmed:match('^(.-)%s*:%s*"(.*)"%s*$')
                if key and value then
                    value = value:gsub("\\n", "<br/>")
                    coroutine.yield(key, value)
                end
            end
        end
    end)
end

local colourise = xml_gen.component(function(args)
    ---@type string
    local txt = assert(args.text)


    local COLOUR_MAP = {
        ["C"] = "#00ffff",
        ["L"] = "#e8c070",
        ["W"] = "#ffffff",
        ["B"] = "#5555ff",
        ["G"] = "#00ff00",
        ["R"] = "#ff5555",
        ["b"] = "#000000",
        ["g"] = "#aaaaaa",
        ["Y"] = "#ffff55",
        ["H"] = "#ffff55",
        ["T"] = "#ffffff",
        ["O"] = "#ff9955",
        ["0"] = "#aa55aa",
        ["1"] = "#aa9ddc",
        ["2"] = "#5577ff",
        ["3"] = "#55aaff",
        ["4"] = "#55ffff",
        ["5"] = "#55ffaa",
        ["6"] = "#55ff55",
        ["7"] = "#aaff55",
        ["8"] = "#ffaa55",
        ["9"] = "#ffff55",
        ["t"] = "#ff5555",
    }

    ---@type string[]
    local chars = {}

    for char in txt:gmatch(utf8.charpattern) do
        chars[#chars + 1] = char
    end

    local curpos = 1
    local curcolour = nil

    local i = 1
    while i <= #chars do
        if chars[i] == "§" and i < #chars then
            if i > curpos then
                local segment = table.concat(chars, "", curpos, i - 1)
                if curcolour then
                    coroutine.yield(
                        html.span(xml_gen.raw(segment)) { style = "color: "..COLOUR_MAP[curcolour], class = "typewriter-text" }
                    )
                else
                    coroutine.yield(
                        html.span(xml_gen.raw(segment)) { class = "typewriter-text" }
                    )
                end
                curpos = i
            end

            local code = chars[i + 1]

            if code == "!" then
                curcolour = nil
                curpos = i + 2
                i = i + 2
            elseif COLOUR_MAP[code] then
                curcolour = code
                curpos = i + 2
                i = i + 2
            else
                i = i + 1
            end
        else
            i = i + 1
        end
    end


    if curpos <= #chars then
        local segment = table.concat(chars, "", curpos, #chars)
        if curcolour then
            coroutine.yield(
                html.span(xml_gen.raw(segment)) { style = "color: "..COLOUR_MAP[curcolour], class = "typewriter-text" }
            )
        else
            coroutine.yield(
                html.span(xml_gen.raw(segment)) { class = "typewriter-text" }
            )
        end
    end
end)


local doc = html.html { charset = "utf-8" } {
    html.head {
        html.title "The Long March Archive - Interactive LOJI Database",
        html.meta { name = "viewport", content = "width=device-width, initial-scale=1.0" },
        html.script { src = "https://cdnjs.cloudflare.com/ajax/libs/tailwindcss/2.2.19/tailwind.min.js" },
        html.link { rel = "stylesheet", href = "retro-terminal.css" },
        html.script { src = "retro-terminal.js", defer = true },
        html.style(xml_gen.raw([[
            .section { margin-bottom: 2rem; }
            .section.hidden { display: none; }
            .priority-high { border-left: 4px solid #00ff00; }
            .priority-entry { background: rgba(0, 255, 0, 0.05); border: 1px solid rgba(0, 255, 0, 0.2); }
            .priority-text { background: rgba(0, 255, 255, 0.03); }
            .nav-btn { 
                background: rgba(0, 255, 0, 0.1); 
                border: 1px solid #00ff00; 
                padding: 0.5rem; 
                cursor: pointer; 
                transition: all 0.3s;
            }
            .nav-btn:hover { 
                background: rgba(0, 255, 0, 0.2); 
                box-shadow: 0 0 10px rgba(0, 255, 0, 0.3);
            }
            .section-header { 
                background: linear-gradient(90deg, rgba(0,255,0,0.1) 0%, rgba(0,255,255,0.1) 50%, rgba(255,255,0,0.1) 100%);
                padding: 1rem;
                border: 1px solid rgba(0, 255, 0, 0.3);
                margin-bottom: 1rem;
            }
            .evolution-section { border-color: #00ff00; }
            .dialogue-section { border-color: #00ffff; }
            .stories-section { border-color: #ffff00; }
            .entry-header { 
                background: rgba(0, 0, 0, 0.3); 
                padding: 0.5rem; 
                border-bottom: 1px solid rgba(255, 255, 255, 0.1);
            }
            .legacy-entry { opacity: 0.7; }
            .error-section { 
                background: rgba(255, 0, 0, 0.1); 
                border: 1px solid #ff5555; 
                padding: 1rem; 
                margin: 1rem 0;
            }
            @keyframes glow { 
                0%, 100% { text-shadow: 0 0 5px currentColor; }
                50% { text-shadow: 0 0 20px currentColor, 0 0 30px currentColor; }
            }
            .priority-high .entry-title { animation: glow 2s ease-in-out infinite; }
        ]]))
    },

    html.body {
        html.div { class = "scanline" },
        html.div { class = "terminal turn-on" } {
            html.div { class = "terminal-header typewriter-container" } {
                html.div { class = "text-2xl typewriter-text" } "SYSTM://TERMINAL#4221 [CLASSIFIED]",
                html.div { class = "text-sm typewriter-text" } "LONG MARCH RECORD DATABASE - RESTRICTED ACCESS"
            },
            html.div { class = "boot-sequence typewriter-container" } {
                html.div { class = "typewriter-text" } "BOOTING TERMINAL OS v3.77.16...",
                html.div { class = "typewriter-text" } "INITIALIZING MEMORY BANKS... OK",
                html.div { class = "typewriter-text" } "CHECKING FILE SYSTEM INTEGRITY... OK",
                html.div { class = "typewriter-text" } "ESTABLISHING QUANTUM-LINK CONNECTION... OK",
                html.div { class = "typewriter-text" } "AUTHENTICATION: APPROVED",
                html.div { class = "typewriter-text" } "SECURITY LEVEL: ALPHA-CLEARANCE",
                html.div { class = "typewriter-text" } "LOADING RESTRICTED FILES...100%",
                html.div { class = "mt-4 typewriter-text" } "===== LOJI WORSHIP DATABASE ACCESSED ====="
            },
            -- Navigation Menu
            html.div { class = "navigation-menu mb-6" } {
                html.div { class = "command-prompt typewriter-container mb-4" } {
                    html.span("NAVIGATE SECTIONS") { class = "typewriter-text text-yellow-400" }
                },
                html.div { class = "nav-buttons grid grid-cols-2 md:grid-cols-3 gap-2" } {
                    html.button { class = "nav-btn typewriter-text", onclick = "showSection('evolution')" } "§G>> EVOLUTION PHASES §!",
                    html.button { class = "nav-btn typewriter-text", onclick = "showSection('dialogue')" } "§C>> DIALOGUE SYSTEMS §!",
                    html.button { class = "nav-btn typewriter-text", onclick = "showSection('stories')" } "§Y>> NARRATIVE ARCHIVES §!",
                    html.button { class = "nav-btn typewriter-text", onclick = "showSection('lore')" } "§L>> LORE DATABASE §!",
                    html.button { class = "nav-btn typewriter-text", onclick = "showSection('projects')" } "§B>> PROJECT FILES §!",
                    html.button { class = "nav-btn typewriter-text", onclick = "showSection('all')" } "§R>> SHOW ALL §!"
                }
            },

            -- Main Content Container
            html.div { class = "sections-container" } {
                function()
                    ---@type boolean, table?
                    local ok, quotes = pcall(require, "lojiquotes")
                    if ok and quotes then
                        -- Define section priorities and styling
                        local sections = {
                            {
                                key = "evolution_phases",
                                title = "EVOLUTION PHASES",
                                subtitle = "LOJI'S TRANSCENDENCE PROTOCOLS",
                                class = "evolution-section priority-high",
                                icon = "§G◆§!",
                                color = "green"
                            },
                            {
                                key = "dialogue",
                                title = "DIALOGUE SYSTEMS",
                                subtitle = "INTERACTIVE COMMUNICATION MATRICES",
                                class = "dialogue-section priority-high",
                                icon = "§C◇§!",
                                color = "cyan"
                            },
                            {
                                key = "stories",
                                title = "NARRATIVE ARCHIVES",
                                subtitle = "RECORDED EVENTS & CHRONICLES",
                                class = "stories-section priority-high",
                                icon = "§Y★§!",
                                color = "yellow"
                            },
                            {
                                key = "lore",
                                title = "LORE DATABASE",
                                subtitle = "FOUNDATIONAL KNOWLEDGE",
                                class = "lore-section priority-normal",
                                icon = "§L◈§!",
                                color = "orange"
                            },
                            {
                                key = "projects",
                                title = "PROJECT FILES",
                                subtitle = "DEVELOPMENT SPECIFICATIONS",
                                class = "projects-section priority-normal",
                                icon = "§B▲§!",
                                color = "blue"
                            },
                            {
                                key = "ui_elements",
                                title = "INTERFACE COMPONENTS",
                                subtitle = "USER INTERFACE DEFINITIONS",
                                class = "ui-section priority-low",
                                icon = "§g□§!",
                                color = "gray"
                            },
                            {
                                key = "endings",
                                title = "CONCLUSION PROTOCOLS",
                                subtitle = "VICTORY CONDITIONS & ENDINGS",
                                class = "endings-section priority-normal",
                                icon = "§R♦§!",
                                color = "red"
                            }
                        }

                        for _, section in ipairs(sections) do
                            if quotes[section.key] then
                                -- Section Header
                                coroutine.yield(
                                    html.div { class = "section "..section.class, id = "section-"..section.key } {
                                        html.div { class = "section-header typewriter-container mb-4" } {
                                            html.div { class = "command-prompt" } {
                                                html.span("ACCESSING "..section.title.." DATABASE...") { class = "typewriter-text text-"..section.color.."-400" }
                                            },
                                            html.div { class = "section-title-container" } {
                                                html.div { class = "text-3xl font-bold typewriter-text mb-2" } (section.icon.." "..section.title),
                                                html.div { class = "text-lg typewriter-text text-gray-300" } (section.subtitle),
                                                html.div { class = "section-stats typewriter-text text-sm mt-2" } {
                                                    "ENTRIES: "..(quotes[section.key] and #quotes[section.key] or 0),
                                                     " | CLASSIFICATION: "..section.class:upper():gsub("-", "_"),
                                                     " | PRIORITY: "..(section.class:find("priority%-high") and "MAXIMUM" or section.class:find("priority%-normal") and "STANDARD" or "LOW")
                                                }
                                            }
                                        },

                                        -- Section Content
                                        html.div { class = "section-content grid gap-4" } {
                                            function()
                                                if quotes[section.key] then
                                                    for i, quote in ipairs(quotes[section.key]) do
                                                        local k, v = quote[1], quote[2]
                                                        local entry_class = "entry"
                                                        -- Special styling for priority sections
                                                        if section.class:find("priority%-high") then
                                                            entry_class = entry_class.." priority-entry"
                                                        end

                                                        coroutine.yield(
                                                            html.div { class = entry_class } {
                                                                html.div { class = "command-prompt typewriter-container" } {
                                                                    html.span("DECRYPT RECORD/"..section.key:upper().."/"..k.." --priority="..(section.class:find("priority%-high") and "MAX" or "STD")) { class = "typewriter-text" }
                                                                },
                                                                html.div { class = "entry-content" } {
                                                                    html.div { class = "entry-header" } {
                                                                        html.div { class = "entry-title typewriter-text" } (section.icon.." "..(k:gsub("%.", " "):gsub("_", " "):gsub("desc", ""))),
                                                                        html.div { class = "entry-meta typewriter-text text-sm" } {
                                                                            "RECORD_ID: "..section.key:upper().."-"..string.format("%03d", i),
                                                                            " | SECURITY: "..(section.class:find("priority%-high") and "ALPHA" or "BETA"),
                                                                            " | ACCESS_COUNT: "..math.random(12, 987)
                                                                        }
                                                                    },
                                                                    html.div {
                                                                        id = (section.key.."-"..k):gsub("%.", "-"),
                                                                        class = "entry-text mt-3 typewriter-container "..(section.class:find("priority%-high") and "priority-text" or "")
                                                                    } {
                                                                        colourise { text = v }
                                                                    }
                                                                }
                                                            }
                                                        )
                                                    end
                                                end
                                            end
                                        }
                                    }
                                )
                            end
                        end
                    else
                        -- Fallback to old localization parsing
                        coroutine.yield(
                            html.div { class = "error-section" } {
                                html.div { class = "command-prompt typewriter-container" } {
                                    html.span("ERROR: LOJIQUOTES MODULE NOT FOUND - FALLING BACK TO LOCALIZATION") { class = "typewriter-text text-red-400" }
                                }
                            }
                        )

                        io.stderr:write("return {\n")
                        local i = 0
                        local f = assert(io.open("localisation.yml", "r+b"))
                        for k, v in parse_localisation(f) do
                            local lk, lv = k:lower(), v:lower()
                            if lk:find("loji") or lk:find("long_march") or lv:find("loji") or lv:find("long march") then
                                i = i + 1
                                io.stderr:write(string.format("    { [=[%s]=], [=[%s]=] };\n", k, v))
                                coroutine.yield(
                                    html.div { class = "entry legacy-entry" } {
                                        html.div { class = "command-prompt typewriter-container" } {
                                            html.span("ACCESS LEGACY/"..k.." -a -decrypt") { class = "typewriter-text" }
                                        },
                                        html.div { class = "entry-content" } {
                                            html.div { class = "entry-title typewriter-text" } (k:gsub("%.", " "):gsub("_", " "):gsub("desc", "")),
                                            html.div { class = "my-2 typewriter-text" } ("FILE_ID: "..i.." | ENCRYPTION: NONE | ACCESS_COUNT: "..math.random(12, 987)),
                                            html.div { id = k:gsub("%.", "-"), class = "mt-2 typewriter-container" } {
                                                colourise { text = v }
                                            }
                                        }
                                    }
                                )
                            end
                        end
                        io.stderr:write("}\n")
                        f:close()
                    end
                end
            },
            html.div { class = "mt-10 command-prompt-final" } {
                html.span { class = "typewriter-text" } "READY",
                html.span { class = "cursor blink" } "█"
            }
        }
    }
}

print("<!DOCTYPE html>")
print(tostring(doc))
