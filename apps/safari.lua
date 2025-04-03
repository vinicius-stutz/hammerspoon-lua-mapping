-- safari.lua: Configurações específicas para o Safari

local safari = {}
local config = require("config")

-- Processa eventos do Safari
function safari.handleSafariEvents(appName, eventType, app, state)
    if eventType == hs.application.watcher.activated then
        safari.setupSafariHotkeys(app, state)
    elseif eventType == hs.application.watcher.deactivated then
        safari.clearSafariHotkeys(state)
    end
end

-- Configurar atalhos do Safari
function safari.setupSafariHotkeys(app, state)
    if not state.safariHotkeys or #state.safariHotkeys == 0 then
        state.safariHotkeys = {
            -- Atalhos de tradução
            hs.hotkey.bind({"cmd", "shift"}, "p", function()
                app:selectMenuItem({"Visualizar", "Tradução", "Traduzir para Português"})
                hs.alert.show("Tradução PT-BR em andamento…", config.alertStyle, 1)
            end),
            
            hs.hotkey.bind({"cmd", "shift"}, "o", function()
                app:selectMenuItem({"Visualizar", "Tradução", "Ver Original"})
                hs.alert.show("Voltando ao idioma original…", config.alertStyle, 1)
            end),
            
            -- Atalhos de desenvolvedor
            hs.hotkey.bind({"ctrl"}, "u", function()
                hs.eventtap.keyStroke({"alt", "cmd"}, "u", 0)
            end),
            
            hs.hotkey.bind({"ctrl", "shift"}, "i", function()
                hs.eventtap.keyStroke({"alt", "cmd"}, "i", 0)
            end),
            
            hs.hotkey.bind({}, "f12", function()
                hs.eventtap.keyStroke({"alt", "cmd"}, "c", 0)
            end),
            
            -- Atalhos de atualização
            hs.hotkey.bind({}, "f5", function()
                hs.eventtap.keyStroke({"cmd"}, "r", 0)
            end),
            
            hs.hotkey.bind({"ctrl"}, "r", function()
                hs.eventtap.keyStroke({"cmd"}, "r", 0)
            end),
            
            -- Atualização forçada (limpa cache)
            hs.hotkey.bind({"ctrl"}, "f5", function()
                hs.eventtap.keyStroke({"alt", "cmd"}, "e", 0)
                hs.eventtap.keyStroke({"cmd"}, "r", 0)
            end),
            
            hs.hotkey.bind({"ctrl", "shift"}, "r", function()
                hs.eventtap.keyStroke({"alt", "cmd"}, "e", 0)
                hs.eventtap.keyStroke({"cmd"}, "r", 0)
            end)
        }
    end
end

-- Limpar atalhos do Safari
function safari.clearSafariHotkeys(state)
    if state.safariHotkeys then
        for _, hotkey in pairs(state.safariHotkeys) do
            if hotkey and type(hotkey.delete) == "function" then
                pcall(function() hotkey:delete() end)
            end
        end
        state.safariHotkeys = {}
    end
end

return safari