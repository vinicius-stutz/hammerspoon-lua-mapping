--[[
--Copyright (c) 2025 vinici.us.com. All Rights Reserved.
--Licensed under the MIT license.
--]]

-- window.lua: Funções relacionadas a janelas

local config = require("config")
local window = {}

-- Configurações de atalhos para janelas
window.Bindings = {
    { { config.Key.START },                   "left",  "half-left" },
    { { config.Key.START },                   "right", "half-right" },
    { { config.Key.START },                   "up",    "maximize" },
    { { config.Key.START },                   "down",  "minimize" },
    { { config.Key.START, config.Key.SHIFT }, "left",  "move-left" },
    { { config.Key.START, config.Key.SHIFT }, "right", "move-right" }
}

-- Função para movimentar janelas
function window.move(action)
    local win = hs.window.focusedWindow()
    if not win then return end

    local screen = win:screen()
    local frame = screen:frame()

    -- Tabela de ações
    local actions = {
        ["half-left"] = function()
            win:setFrame({ x = frame.x, y = frame.y, w = frame.w / 2, h = frame.h })
        end,
        ["half-right"] = function()
            win:setFrame({ x = frame.x + frame.w / 2, y = frame.y, w = frame.w / 2, h = frame.h })
        end,
        ["maximize"] = function()
            win:maximize()
        end,
        ["minimize"] = function()
            win:minimize()
        end,
        ["move-left"] = function()
            if screen:toWest() then win:moveToScreen(screen:toWest()) end
        end,
        ["move-right"] = function()
            if screen:toEast() then win:moveToScreen(screen:toEast()) end
        end
    }

    -- Execute a ação se existir
    if actions[action] then actions[action]() end
end

return window
