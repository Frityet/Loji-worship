local utf8 = require("utf8")
local xml_gen = require("xml-generator")
local html = xml_gen.xml

---@param input file*
---@param sanitize boolean?
---@return fun(): string?, string
local function parse_localisation(input, sanitize)
    return coroutine.wrap(function()
        for line in input:lines() do
            local trimmed = line:match("^%s*(.-)%s*$")
            if trimmed ~= "" and not trimmed:match("^#") then
                ---@type string, string
                local key, value = trimmed:match('^(.-)%s*:%s*"(.*)"%s*$')
                if key and value then
                    if sanitize then
                        value = value:gsub("\\n", "<br/>")
                    end
                    coroutine.yield(key, value)
                end
            end
        end
    end)
end

local f = assert(io.open("localisation.yml", "r+b"))

local colourise = xml_gen.component(function (args)
    ---@type string
    local txt = assert(args.text)

    local COLOUR_MAP = {
        ["C"] = "#23ceff", -- cyan
        ["L"] = "#c3b091", -- dirty orange-gray (lilac)
        ["W"] = "#ffffff", -- white
        ["B"] = "#0000ff", -- blue
        ["G"] = "#009f03", -- green
        ["R"] = "#ff3232", -- red
        ["b"] = "#000000", -- black
        ["g"] = "#b0b0b0", -- light gray
        ["Y"] = "#ffbd00", -- yellow
        ["H"] = "#ffbd00", -- yellow (same as Y)
        ["T"] = "#ffffff", -- white (same as W)
        ["O"] = "#ff7019", -- orange
        ["0"] = "#cb00cb", -- purple
        ["1"] = "#8078d3", -- lilac
        ["2"] = "#5170f3", -- blue
        ["3"] = "#518fdc", -- gray-blue
        ["4"] = "#5abee7", -- light blue
        ["5"] = "#3fb5c2", -- dull cyan
        ["6"] = "#77ccba", -- turquoise
        ["7"] = "#99d199", -- light green
        ["8"] = "#cca333", -- orange-yellow
        ["9"] = "#fca97d", -- white-orange
        ["t"] = "#ff4c4d", -- vivid red
    }

    ---@type string[]
    local chars = {}

    for char in txt:gmatch(utf8.charpattern) do
        chars[#chars+1] = char
    end

    local curPosition = 1
    local curColour = nil

    local i = 1
    while i <= #chars do
        if chars[i] == "§" and i < #chars then
            -- Process text before this code if any
            if i > curPosition then
                local segment = table.concat(chars, "", curPosition, i - 1)
                if curColour then
                    coroutine.yield(
                        html.span(xml_gen.raw(segment)) {style="color: "..COLOUR_MAP[curColour]}
                    )
                else
                    coroutine.yield(
                        html.span(xml_gen.raw(segment)) {}
                    )
                end
                curPosition = i
            end

            local code = chars[i+1]

            if code == "!" then
                -- End formatting
                curColour = nil
                curPosition = i + 2 -- Skip the §! sequence
                i = i + 2 -- Skip both § and ! characters
            elseif COLOUR_MAP[code] then
                -- Start new color formatting
                curColour = code
                curPosition = i + 2 -- Skip the §X sequence 
                i = i + 2 -- Skip both § and color code characters
            else
                -- If the code isn't recognized, just add the "§" normally
                i = i + 1
            end
        else
            i = i + 1
        end
    end

    -- Process any remaining text
    if curPosition <= #chars then
        local segment = table.concat(chars, "", curPosition, #chars)
        if curColour then
            coroutine.yield(
                html.span(xml_gen.raw(segment)) {style="color: "..COLOUR_MAP[curColour]}
            )
        else
            coroutine.yield(
                html.span(xml_gen.raw(segment)) {}
            )
        end
    end
end)

local doc = html.html { charset = "utf-8" } {
    html.head {
        html.title "Terminal - Loji Worship",
        html.meta { name = "viewport", content = "width=device-width, initial-scale=1.0" },
        html.script { src = "https://cdnjs.cloudflare.com/ajax/libs/tailwindcss/2.2.19/tailwind.min.js" },
        html.style [[
            @import url('https://fonts.googleapis.com/css2?family=Fira+Code:wght@400;500;600&display=swap');
            body {
                font-family: 'Fira Code', monospace;
                background-color: #0d1117;
                color: #e6edf3;
            }
            .terminal {
                background-color: #0d1117;
                border: 1px solid #30363d;
                border-radius: 6px;
                box-shadow: 0 0 20px rgba(0, 0, 0, 0.4);
                overflow: hidden;
            }
            .terminal-header {
                background-color: #161b22;
                padding: 8px 12px;
                border-bottom: 1px solid #30363d;
                display: flex;
                align-items: center;
            }
            .terminal-button {
                width: 12px;
                height: 12px;
                border-radius: 50%;
                margin-right: 6px;
            }
            .terminal-close { background-color: #ff5f56; }
            .terminal-minimize { background-color: #ffbd2e; }
            .terminal-maximize { background-color: #27c93f; }
            .terminal-title {
                margin-left: 8px;
                font-size: 14px;
                color: #8b949e;
            }
            .terminal-body {
                padding: 16px;
                overflow-y: auto;
                max-height: 85vh;
            }
            .prompt {
                color: #7ee787;
                font-weight: 600;
            }
            .prompt-path {
                color: #58a6ff;
            }
            .command {
                color: #e6edf3;
            }
            .entry {
                margin-bottom: 24px;
                border-bottom: 1px dashed #30363d;
                padding-bottom: 16px;
            }
            .entry-content {
                margin-top: 8px;
                margin-left: 16px;
                padding: 12px;
                background-color: #161b22;
                border-radius: 4px;
                border-left: 3px solid #f97583;
            }
            .blink {
                animation: blink-animation 1s steps(5, start) infinite;
            }
            @keyframes blink-animation {
                to { visibility: hidden; }
            }
            .entry-title {
                color: #f97583;
                font-weight: 500;
                margin-bottom: 10px;
                padding-bottom: 6px;
                border-bottom: 1px solid #30363d;
            }
        ]]
    },

    html.body {
        html.div { class = "p-4 md:p-8" } {
            html.div { class = "terminal max-w-6xl mx-auto" } {
                html.div { class = "terminal-header" } {
                    html.div { class = "terminal-button terminal-close" },
                    html.div { class = "terminal-button terminal-minimize" },
                    html.div { class = "terminal-button terminal-maximize" },
                    html.div { class = "terminal-title" } "loji@worship-terminal: ~/sacred_texts"
                },
                html.div { class = "terminal-body" } {
                    html.div { class = "mb-6" } {
                        html.div { class = "flex items-center" } {
                            html.span { class = "prompt" } "loji@worship-terminal:",
                            html.span { class = "prompt-path" } "~/sacred_texts$ ",
                            html.span { class = "command" } "cat TFR_country_localisation_PRC_l_english.yml | grep -i 'loji\\|long_march' | ./parse_scripture.sh"
                        },
                    },
                    html.div { class = "grid grid-cols-1 gap-6" } {
                        function()
                            for k, v in parse_localisation(f, true) do
                                local lk, lv = k:lower(), v:lower()
                                if lk:find("loji") or lk:find("long_march") or lv:find("loji") or lv:find("long march") then
                                    coroutine.yield(
                                        html.div { class = "entry" } {
                                            html.div { class = "flex items-center" } {
                                                html.span { class = "prompt" } "loji@worship-terminal:",
                                                html.span { class = "prompt-path" } "~/sacred_texts$ ",
                                                html.span { class = "command" } ("locate \"" .. k .. "\"")
                                            },
                                            html.div { class = "entry-content" } {
                                                html.div { class = "entry-title" } (k:gsub("%.", " "):gsub("_", " "):gsub("desc", "")),
                                                html.div { id = k:gsub("%.", "-"), class = "mt-2" } {
                                                    colourise { text = v }
                                                }
                                            }
                                        }
                                    )
                                end
                            end
                        end
                    },
                    html.div { class = "mt-6 flex items-center" } {
                        html.span { class = "prompt" } "loji@worship-terminal:",
                        html.span { class = "prompt-path" } "~/sacred_texts$ ",
                        html.span { class = "command blink" } "█"
                    }
                }
            }
        }
    }
}

print("<!DOCTYPE html>")
print(tostring(doc))
