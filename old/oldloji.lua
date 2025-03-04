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

    -- Retro terminal colors - mostly shades of green/amber with some variations
    local COLOUR_MAP = {
        ["C"] = "#00ffff", -- bright cyan
        ["L"] = "#e8c070", -- amber
        ["W"] = "#ffffff", -- white
        ["B"] = "#5555ff", -- dim blue
        ["G"] = "#00ff00", -- bright green
        ["R"] = "#ff5555", -- dim red
        ["b"] = "#000000", -- black
        ["g"] = "#aaaaaa", -- dim gray
        ["Y"] = "#ffff55", -- dim yellow
        ["H"] = "#ffff55", -- dim yellow (same as Y)
        ["T"] = "#ffffff", -- white (same as W)
        ["O"] = "#ff9955", -- dim orange
        ["0"] = "#aa55aa", -- dim purple
        ["1"] = "#aa9ddc", -- pale lilac
        ["2"] = "#5577ff", -- dim blue
        ["3"] = "#55aaff", -- pale blue
        ["4"] = "#55ffff", -- bright cyan
        ["5"] = "#55ffaa", -- seafoam green
        ["6"] = "#55ff55", -- bright green
        ["7"] = "#aaff55", -- bright yellow-green
        ["8"] = "#ffaa55", -- pale orange
        ["9"] = "#ffff55", -- bright yellow
        ["t"] = "#ff5555", -- dim red
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
        html.title "Retro Terminal - Loji Worship",
        html.meta { name = "viewport", content = "width=device-width, initial-scale=1.0" },
        html.script { src = "https://cdnjs.cloudflare.com/ajax/libs/tailwindcss/2.2.19/tailwind.min.js" },
        html.style [[
            @import url('https://fonts.googleapis.com/css2?family=VT323&display=swap');
            @import url('https://fonts.googleapis.com/css2?family=Share+Tech+Mono&display=swap');

            body {
                margin: 0;
                font-family: 'VT323', monospace;
                background-color: #000000;
                color: #33ff33;
                font-size: 18px;
                line-height: 1.2;
                text-shadow: 0 0 5px rgba(51, 255, 51, 0.8);
                overflow-x: hidden;
            }

            /* CRT effect */
            body::before {
                content: " ";
                display: block;
                position: fixed;
                top: 0;
                left: 0;
                bottom: 0;
                right: 0;
                background: linear-gradient(rgba(18, 16, 16, 0) 50%, rgba(0, 0, 0, 0.25) 50%), linear-gradient(90deg, rgba(255, 0, 0, 0.06), rgba(0, 255, 0, 0.02), rgba(0, 0, 255, 0.06));
                background-size: 100% 2px, 3px 100%;
                pointer-events: none;
                z-index: 999;
                animation: flicker 0.15s infinite;
            }

            @keyframes flicker {
                0% { opacity: 0.97; }
                5% { opacity: 0.98; }
                10% { opacity: 0.9; }
                15% { opacity: 1; }
                20% { opacity: 0.98; }
                25% { opacity: 0.91; }
                30% { opacity: 0.98; }
                35% { opacity: 0.9; }
                40% { opacity: 0.94; }
                45% { opacity: 1; }
                50% { opacity: 0.98; }
                55% { opacity: 0.93; }
                60% { opacity: 0.99; }
                65% { opacity: 0.96; }
                70% { opacity: 0.91; }
                75% { opacity: 0.93; }
                80% { opacity: 1; }
                85% { opacity: 0.97; }
                90% { opacity: 0.98; }
                95% { opacity: 0.94; }
                100% { opacity: 0.9; }
            }

            .terminal {
                opacity: 0.9;
                padding: 20px;
                background-color: #000000;
                border-radius: 0;
                width: 100%;
                min-height: 100vh;
                box-sizing: border-box;
            }

            .terminal-header {
                text-align: center;
                margin-bottom: 20px;
                color: #33ff33;
                border-bottom: 1px solid #33ff33;
                padding-bottom: 10px;
                font-family: 'Share Tech Mono', monospace;
            }

            .boot-sequence {
                margin-bottom: 30px;
                line-height: 1.4;
            }

            .command-prompt:before {
                content: ">";
                margin-right: 10px;
                color: #33ff33;
            }

            .entry {
                margin-bottom: 30px;
                padding-bottom: 15px;
                border-bottom: 1px dashed #33ff33;
            }

            .entry-content {
                margin-top: 10px;
                margin-left: 25px;
                padding: 15px;
                border-left: 2px solid #33ff33;
            }

            .entry-title {
                color: #ffaa55;
                font-weight: bold;
                margin-bottom: 10px;
                text-transform: uppercase;
                letter-spacing: 1px;
            }

            .blink {
                animation: blink-animation 1s steps(2, start) infinite;
            }

            @keyframes blink-animation {
                to { visibility: hidden; }
            }

            .scanline {
                width: 100%;
                height: 100px;
                background: linear-gradient(
                    to bottom,
                    rgba(51, 255, 51, 0),
                    rgba(51, 255, 51, 0.1),
                    rgba(51, 255, 51, 0)
                );
                position: fixed;
                top: 0;
                z-index: 998;
                animation: scanline 8s linear infinite;
            }

            @keyframes scanline {
                0% { top: -100px; }
                100% { top: 100vh; }
            }

            /* Turn on the screen with animation */
            @keyframes turn-on {
                0% {
                    transform: scale(1, 0.01);
                    opacity: 0;
                }
                10% {
                    transform: scale(1, 0.01);
                    opacity: 1;
                }
                70% {
                    transform: scale(1, 1);
                    opacity: 1;
                }
                100% {
                    transform: scale(1, 1);
                    opacity: 1;
                }
            }

            .turn-on {
                animation: turn-on 2s ease-in-out;
            }

            /* Custom scrollbar */
            ::-webkit-scrollbar {
                width: 10px;
            }

            ::-webkit-scrollbar-track {
                background: #000000;
            }

            ::-webkit-scrollbar-thumb {
                background: #33ff33;
            }

            ::-webkit-scrollbar-thumb:hover {
                background: #00aa00;
            }
        ]]
    },

    html.body {
        html.div { class = "scanline" },
        html.div { class = "terminal turn-on" } {
            html.div { class = "terminal-header" } {
                html.div { class = "text-2xl" } "SYSTM://TERMINAL#4221 [CLASSIFIED]",
                html.div { class = "text-sm" } "STELLAR CONCORDANCE DATABASE - RESTRICTED ACCESS"
            },
            html.div { class = "boot-sequence" } {
                html.div "BOOTING TERMINAL OS v3.77.16...",
                html.div "INITIALIZING MEMORY BANKS... OK",
                html.div "CHECKING FILE SYSTEM INTEGRITY... OK",
                html.div "ESTABLISHING QUANTUM-LINK CONNECTION... OK",
                html.div "AUTHENTICATION: APPROVED",
                html.div "SECURITY LEVEL: ALPHA-CLEARANCE",
                html.div "LOADING RESTRICTED FILES...100%",
                html.div { class = "mt-4" } "===== LOJI WORSHIP DATABASE ACCESSED ====="
            },
            html.div { class = "grid grid-cols-1 gap-4" } {
                function()
                    local i = 0
                    for k, v in parse_localisation(f, true) do
                        local lk, lv = k:lower(), v:lower()
                        if lk:find("loji") or lk:find("long_march") or lv:find("loji") or lv:find("long march") then
                            i = i + 1
                            coroutine.yield(
                                html.div { class = "entry" } {
                                    html.div ("ACCESS RECORDS/"..k.." -a -decrypt") { class = "command-prompt" },
                                    html.div { class = "entry-content" } {
                                        html.div { class = "entry-title" } (k:gsub("%.", " "):gsub("_", " "):gsub("desc", "")),
                                        html.div { class = "my-2" } ("FILE_ID: "..i.." | ENCRYPTION: NONE | ACCESS_COUNT: "..math.random(12, 987)),
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
            html.div { class = "mt-10 command-prompt blink" } "READY"
        },
        html.script [[
            // Add some retro terminal typing sounds
            document.addEventListener('DOMContentLoaded', function() {
                // Add more retro effects
                setTimeout(() => {
                    const randomGlitch = () => {
                        const terminal = document.querySelector('.terminal');
                        terminal.style.transform = `translateX(${Math.random() * 4 - 2}px)`;
                        setTimeout(() => {
                            terminal.style.transform = 'translateX(0)';
                        }, 50);
                    };
                    
                    // Random glitches
                    setInterval(randomGlitch, 5000);
                }, 2000);
            });
        ]]
    }
}

print("<!DOCTYPE html>")
print(tostring(doc))
