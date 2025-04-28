--[[
--Copyright (c) 2025 vinici.us.com. All Rights Reserved.
--Licensed under the MIT license.
--]]

-- safari.lua: Configurações específicas para o Safari

local safari = {}
local config = require("config")

-- Processa eventos do Safari
function safari.handleEvents(appName, eventType, app, state)
    if eventType == hs.application.watcher.activated then
        print("-- Configurando atalhos de teclado do " .. appName)
        safari.setupHotkeys(app, state)
    elseif eventType == hs.application.watcher.deactivated then
        print("-- O " .. appName .. " foi desativado")
        safari.clearHotkeys(state)
    end
end

-- Configurar atalhos do Safari
function safari.setupHotkeys(app, state)
    if not state.safariHotkeys or #state.safariHotkeys == 0 then
        state.safariHotkeys = {
            -- Atalhos de tradução
            hs.hotkey.bind({ config.Key.ALT, config.Key.SHIFT }, "p", function()
                app:selectMenuItem({ "Visualizar", "Tradução", "Traduzir para Português" })
                hs.alert.show("Tradução PT-BR em andamento…", config.AlertStyle, 1)
            end),

            hs.hotkey.bind({ config.Key.ALT, config.Key.SHIFT }, "o", function()
                app:selectMenuItem({ "Visualizar", "Tradução", "Ver Original" })
                hs.alert.show("Voltando ao idioma original…", config.AlertStyle, 1)
            end),

            -- Atalhos de desenvolvedor
            hs.hotkey.bind({ config.Key.CTRL }, "u", function()
                hs.eventtap.keyStroke({ "alt", "cmd" }, "u", 0)
            end),

            hs.hotkey.bind({ config.Key.CTRL, config.Key.SHIFT }, "i", function()
                hs.eventtap.keyStroke({ "alt", "cmd" }, "i", 0)
            end),

            hs.hotkey.bind({}, "f12", function()
                hs.eventtap.keyStroke({ "alt", "cmd" }, "c", 0)
            end),

            -- Atalhos de atualização
            hs.hotkey.bind({}, "f5", function()
                hs.eventtap.keyStroke({ "cmd" }, "r", 0)
            end),

            -- Atualização forçada (limpa cache)
            hs.hotkey.bind({ config.Key.CTRL }, "f5", function()
                hs.eventtap.keyStroke({ "alt", "cmd" }, "e", 0)
                hs.eventtap.keyStroke({ "cmd" }, "r", 0)
            end),

            hs.hotkey.bind({ config.Key.CTRL, config.Key.SHIFT }, "r", function()
                hs.eventtap.keyStroke({ "alt", "cmd" }, "e", 0)
                hs.eventtap.keyStroke({ "cmd" }, "r", 0)
            end),

            -- Salva favorito diretamente no Raindrop.io
            hs.hotkey.bind({ "cmd" }, "d", function()
                hs.eventtap.keyStroke({ "shift", "cmd" }, "s", 0)
            end),

            hs.hotkey.bind({ config.Key.CTRL, config.Key.SHIFT }, "c", function()
                -- Salva o conteúdo atual da área de transferência para restaurar depois
                local originalClipboard = hs.pasteboard.getContents()

                -- Limpa a área de transferência para garantir que saberemos se a cópia funcionou
                hs.pasteboard.clearContents()

                -- Pequena pausa após limpar
                hs.timer.usleep(100000) -- 100ms

                -- Copia o texto selecionado
                hs.eventtap.keyStroke({ "cmd" }, "c")
                hs.timer.usleep(50000) -- 50ms
                hs.eventtap.keyStroke({ "cmd" }, "c")

                -- Espera um pouco mais para garantir que o conteúdo foi copiado
                hs.timer.doAfter(0.5, function()
                    -- Verifica se algo foi copiado
                    local copiedLink = hs.pasteboard.getContents()

                    if copiedLink and copiedLink ~= "" then
                        -- Abre uma nova aba
                        hs.eventtap.keyStroke({ "cmd" }, "t")

                        -- Espera a nova aba abrir
                        hs.timer.doAfter(0.5, function()
                            -- Cola explicitamente o link copiado
                            hs.pasteboard.setContents(copiedLink)
                            hs.timer.usleep(100000) -- 100ms
                            hs.eventtap.keyStroke({ "cmd" }, "v")

                            -- Espera o conteúdo ser colado
                            hs.timer.doAfter(0.3, function()
                                -- Pressiona Enter para navegar até o link
                                hs.eventtap.keyStroke({}, "return")

                                -- Restaura o conteúdo original da área de transferência
                                hs.timer.doAfter(0.3, function()
                                    if originalClipboard then
                                        hs.pasteboard.setContents(originalClipboard)
                                    end
                                end)
                            end)
                        end)
                    else
                        -- Notifica o usuário se nada foi copiado
                        hs.alert.show("Nenhum conteúdo selecionado")
                        -- Restaura o conteúdo original
                        if originalClipboard then
                            hs.pasteboard.setContents(originalClipboard)
                        end
                    end
                end)
            end)
        }
    end
end

-- Limpar atalhos do Safari
function safari.clearHotkeys(state)
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
