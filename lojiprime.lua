local utf8 = require("utf8")
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

    local curPosition = 1
    local curColour = nil

    local i = 1
    while i <= #chars do
        if chars[i] == "§" and i < #chars then
            if i > curPosition then
                local segment = table.concat(chars, "", curPosition, i - 1)
                if curColour then
                    coroutine.yield(
                        html.span(xml_gen.raw(segment)) { style = "color: "..COLOUR_MAP[curColour], class = "typewriter-text" }
                    )
                else
                    coroutine.yield(
                        html.span(xml_gen.raw(segment)) { class = "typewriter-text" }
                    )
                end
                curPosition = i
            end

            local code = chars[i + 1]

            if code == "!" then
                curColour = nil
                curPosition = i + 2
                i = i + 2
            elseif COLOUR_MAP[code] then
                curColour = code
                curPosition = i + 2
                i = i + 2
            else
                i = i + 1
            end
        else
            i = i + 1
        end
    end


    if curPosition <= #chars then
        local segment = table.concat(chars, "", curPosition, #chars)
        if curColour then
            coroutine.yield(
                html.span(xml_gen.raw(segment)) { style = "color: "..COLOUR_MAP[curColour], class = "typewriter-text" }
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
        html.title "The Long March Archive",
        html.meta { name = "viewport", content = "width=device-width, initial-scale=1.0" },
        html.script { src = "https://cdnjs.cloudflare.com/ajax/libs/tailwindcss/2.2.19/tailwind.min.js" },
        html.link { rel = "stylesheet", href = "retro-terminal.css" },
        html.script { src = "retro-terminal.js", defer = true }
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
            html.div { class = "grid grid-cols-1 gap-4 entries-container" } {
                function()
                    --TODO: This fucking sucks!
                    ---@type boolean, {[1]: string, [2]: string}[]?
                    local ok, quotes = pcall(require, "lojiquotes")
                    if ok and quotes then
                        for i, quote in ipairs(quotes) do
                            local k, v = quote[1], quote[2]
                            coroutine.yield(
                                html.div { class = "entry" } {
                                    html.div { class = "command-prompt typewriter-container" } {
                                        html.span("ACCESS RECORDS/"..k.." -a -decrypt") { class = "typewriter-text" }
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
                    else
                        io.stderr:write("return {\n")
                        local i = 0
                        local f = assert(io.open("localisation.yml", "r+b"))
                        for k, v in parse_localisation(f) do
                            local lk, lv = k:lower(), v:lower()
                            if lk:find("loji") or lk:find("long_march") or lv:find("loji") or lv:find("long march") then
                                i = i + 1
                                io.stderr:write(string.format("    { [=[%s]=], [=[%s]=] };\n", k, v))
                                coroutine.yield(
                                    html.div { class = "entry" } {
                                        html.div { class = "command-prompt typewriter-container" } {
                                            html.span("ACCESS RECORDS/"..k.." -a -decrypt") { class = "typewriter-text" }
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
