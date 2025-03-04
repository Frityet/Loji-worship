-- Copyright (C) 2025 Amrit Bhogal
--
-- This file is part of Loji-worship.
--
-- Loji-worship is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- Loji-worship is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with Loji-worship.  If not, see <https://www.gnu.org/licenses/>.

local utf8 = require("utf8")
local xml_gen = require("xml-generator")
local html = xml_gen.xml

---@param input file*
---@param sanitize boolean?
---@return fun(): string?, string
local function parse_localisation(input, sanitize)
    return coroutine.wrap(function()
        -- local result = {}
        for line in input:lines() do
            local trimmed = line:match("^%s*(.-)%s*$")
            if trimmed ~= "" and not trimmed:match("^#") then
                ---@type string, string
                local key, value = trimmed:match('^(.-)%s*:%s*"(.*)"%s*$')
                if key and value then
                    -- result[key] = value
                    if sanitize then
                        value = value
                            -- :gsub("§t", "")
                            -- :gsub("§1", "")
                            -- :gsub("§L", "")
                            -- :gsub("§R", "")
                            -- :gsub("§Y", "")
                            -- :gsub("§C", "")
                            -- :gsub("§G", "")
                            -- :gsub("§!", "")
                            :gsub("\\n", "<br/><br/>")
                    end
                    coroutine.yield(key, value)
                end
            end
        end
    end)
    -- return result
end

local f = assert(io.open("localisation.yml", "r+b"))

local colourise = xml_gen.component(function (args)
    ---@type string
    local txt = assert(args.text)

    local COLOUR_MAP = {
        ["C"] = "rgb(35,206,255)", -- cyan
        ["L"] = "rgb(195,176,145)", -- dirty orange-gray (lilac)
        ["W"] = "rgb(255,255,255)", -- white
        ["B"] = "rgb(0,0,255)", -- blue
        ["G"] = "rgb(0,159,3)", -- green
        ["R"] = "rgb(255,50,50)", -- red
        ["b"] = "rgb(0,0,0)", -- black
        ["g"] = "rgb(176,176,176)", -- light gray
        ["Y"] = "rgb(255,189,0)", -- yellow
        ["H"] = "rgb(255,189,0)", -- yellow (same as Y)
        ["T"] = "rgb(255,255,255)", -- white (same as W)
        ["O"] = "rgb(255,112,25)", -- orange
        ["0"] = "rgb(203,0,203)", -- purple
        ["1"] = "rgb(128,120,211)", -- lilac
        ["2"] = "rgb(81,112,243)", -- blue
        ["3"] = "rgb(81,143,220)", -- gray-blue
        ["4"] = "rgb(90,190,231)", -- light blue
        ["5"] = "rgb(63,181,194)", -- dull cyan
        ["6"] = "rgb(119,204,186)", -- turquoise
        ["7"] = "rgb(153,209,153)", -- light green
        ["8"] = "rgb(204,163,51)", -- orange-yellow
        ["9"] = "rgb(252,169,125)", -- white-orange
        ["t"] = "rgb(255,76,77)", -- vivid red
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
                        html.span(xml_gen.raw(segment)) {class="dark:text-stone-500"}
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
                html.span(xml_gen.raw(segment)) {class="dark:text-stone-400"}
            )
        end
    end
end)

local doc = html.html { charset = "utf-8" } {
    html.head {
        html.title "Loji Worship",
        html.meta { name = "viewport", content = "width=device-width, initial-scale=1.0" },
        html.script { src = "https://unpkg.com/@tailwindcss/browser@4" },
    },

    html.body { class = "min-h-screen bg-gray-100 dark:bg-gray-900" } {
        html.h1 "The Bible of Sister Loji" { class = "text-center text-4xl font-bold my-8 text-gray-900 dark:text-white" },
        html.div { class = "grid grid-cols-1 gap-6 px-4" } {
            function()
                for k, v in parse_localisation(f, true) do
                    local lk, lv = k:lower(), v:lower()
                    if lk:find("loji") or lk:find("long_march") or lv:find("loji") or lv:find("long march") then
                        coroutine.yield(
                            html.div {class="bg-white dark:bg-gray-800 shadow-md rounded-lg"} {
                                html.h2 (k:gsub("%.", " "):gsub("_", " "):gsub("desc", "")) {class="text-center text-2xl font-bold my-8 text-red-700"};
                                html.div { id = k:gsub("%.", "-"), class = "p-4" } {
                                    colourise { text = v }
                                }
                            }
                        )
                    end
                end
            end
        }
    }
}


print("<!DOCTYPE html>")
print(tostring(doc))

-- local out_f = assert(io.open("out.lua", "w+b"))
-- out_f:write "return {\n"
-- local i = 0
-- for k, v in parse_localisation(f, true) do
--     i = i + 1
--     io.stdout:write(string.format("\rParsed %d localisations...", i))
--     io.stdout:flush()
--     local lk, lv = k:lower(), v:lower()
--     if lk:find("loji") or lk:find("long march") or lv:find("loji") or lv:find("long march") then
--         -- relevant_localisations[k] = v
--         out_f:write(string.format("    [\"%s\"] = [=[%s]=];\n", k, v))
--     end
-- end
-- out_f:write "}\n"
-- out_f:close()
-- f:close()
