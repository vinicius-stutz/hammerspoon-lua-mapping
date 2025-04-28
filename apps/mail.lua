--[[
--Copyright (c) 2025 vinici.us.com. All Rights Reserved.
--Licensed under the MIT license.
--]]

-- mail.lua: Configurações específicas para o Mail

local config = require("config")
local mail = {}

-- Processa eventos do Mail
function mail.handleEvents(appName, eventType, app, state)
    if eventType == hs.application.watcher.activated then
        print("-- Configurando atalhos de teclado do " .. appName)
        mail.setupHotkeys(app, state)
    elseif eventType == hs.application.watcher.deactivated then
        print("-- O " .. appName .. " foi desativado")
        mail.clearHotkeys(state)
    end
end

-- Configurar atalhos do Mail
function mail.setupHotkeys(app, state)
    state.appleMailHotkeys = {
        hs.hotkey.bind({ config.Key.CTRL }, "m", function()
            app:selectMenuItem({ "Mensagem", "Mover para" })

            -- Sequência otimizada de navegação
            local keys = {
                "m", "m", "m", "right",
                "down", "down", "down", "down", "down", "down"
            }

            -- Executar sequência com intervalo pequeno
            for _, key in ipairs(keys) do
                hs.eventtap.keyStroke({}, key, 0.2)
            end
        end),

        hs.hotkey.bind({ config.Key.CTRL }, "space", function()
            hs.eventtap.keyStroke({ "shift", "cmd" }, "u", 0)
        end)
    }
end

-- Limpar atalhos do Mail
function mail.clearHotkeys(state)
    if state.appleMailHotkeys then
        for _, hotkey in pairs(state.appleMailHotkeys) do
            if hotkey and type(hotkey.delete) == "function" then
                pcall(function() hotkey:delete() end)
            end
        end
        state.appleMailHotkeys = {}
    end
end

return mail
