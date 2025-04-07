--[[
--Copyright (c) 2025 vinici.us.com. All Rights Reserved.
--Licensed under the MIT license.
--]]

-- finder.lua: Configurações específicas para o Finder

local finder = {}
local config = require("config")
local types = hs.eventtap.event.types

-- Processa eventos do Finder
function finder.handleFinderEvents(appName, eventType, app, state)
    if eventType == hs.application.watcher.activated then
        -- Verificar se o appName é "Finder" e se há uma janela do Finder em primeiro plano
        if appName == "Finder" and app:focusedWindow() then
            -- Iniciar watcher de teclado do Finder
            finder.setupFinderKeyboardWatcher(app, state)
        end
    elseif eventType == hs.application.watcher.deactivated then
        -- Parar watcher quando o Finder é desativado
        if state.keyboardWatcher then
            state.keyboardWatcher:stop()
            state.keyboardWatcher = nil
        end
        state.isRenaming = false
    end
end

-- Configurar monitoramento de teclado no Finder
function finder.setupFinderKeyboardWatcher(app, state)
    if not state.keyboardWatcher then
        state.keyboardWatcher = hs.eventtap.new({ types.keyDown }, function(event)
            local keyCode = event:getKeyCode()

            if keyCode == config.KEY.F2 then -- F2 (Renomear)
                state.isRenaming = true
                app:selectMenuItem({ "Arquivo", "Renomear" })
                return true
            elseif keyCode == config.KEY.ENTER then -- ENTER/RETURN
                if not state.isRenaming then
                    hs.eventtap.keyStroke({ "cmd" }, "o", 0)
                    return true
                else
                    state.isRenaming = false
                    return false
                end
            elseif keyCode == config.KEY.FORWARD_DELETE then -- DELETE
                if not state.isRenaming then
                    hs.eventtap.keyStroke({ "cmd" }, "delete", 0)
                    return true
                else
                    return false
                end
            end
            return false
        end)
        state.keyboardWatcher:start()
    end
end

return finder
