--[[
--Copyright (c) 2025 vinici.us.com. All Rights Reserved.
--Licensed under the MIT license.
--]]

-- window.lua: Funções relacionadas a janelas

local config = require("config")
local window = {}

-- Configurações de atalhos para janelas
local windowBindings = {
    { { config.Key.START },                   "left",  "half-left" },
    { { config.Key.START },                   "right", "half-right" },
    { { config.Key.START },                   "up",    "maximize" },
    { { config.Key.START },                   "down",  "minimize" },
    { { config.Key.START, config.Key.SHIFT }, "left",  "move-left" },
    { { config.Key.START, config.Key.SHIFT }, "right", "move-right" }
}

-- Mostrar desktop
function window.setupDesktopShortcut()
    print("-- Configurando atalho para mostrar área de trabalho…")
    hs.hotkey.bind({ config.Key.START }, "d", nil, function()
        local allWindows = hs.window.visibleWindows()
        for _, win in ipairs(allWindows) do
            win:minimize()
        end
        hs.alert.show("Mostrando área de trabalho…", config.AlertStyle, 2)
    end)
end

-- Configurar atalho para alternar entre abas como CTRL+TAB
function window.setupCtrlTab()
    local cmdTabWatcher = hs.eventtap.new({ hs.eventtap.event.types.keyDown }, function(event)
        local keyCode = event:getKeyCode()
        local mods = event:getFlags()

        if keyCode == hs.keycodes.map["tab"] and mods.cmd and not mods.alt and not mods.ctrl and not mods.shift then
            hs.eventtap.keyStroke({ "ctrl" }, "tab", 0)
            return true -- tenta bloquear, mas pode não funcionar com CMD+TAB
        end
        return false
    end)

    cmdTabWatcher:start()
end

-- Função para movimentar janelas
function window.moveWindow(action)
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

-- Configurar atalhos de janela
function window.setupWindowBindings()
    window.setupDesktopShortcut()

    -- Parar qualquer eventtap anterior se existir
    if window.keyWatcher then
        window.keyWatcher:stop()
    end

    -- Criar um eventtap para capturar todas as teclas de seta
    window.keyWatcher = hs.eventtap.new({ hs.eventtap.event.types.keyDown }, function(event)
        local keyCode = event:getKeyCode()
        local flags = event:getFlags()

        -- Para cada configuração de atalho
        for _, bind in ipairs(windowBindings) do
            -- Obter nome da tecla atual
            local currentKey = nil
            for name, code in pairs(hs.keycodes.map) do
                if code == keyCode then
                    currentKey = name
                    break
                end
            end

            -- Se não é uma tecla de seta que estamos monitorando, ignore
            if currentKey ~= bind[2] then
                goto continue
            end

            -- Verificar os modificadores
            local modifiersMatch = true

            if hs.fnutils.contains(bind[1], config.Key.START) then
                if not flags.ctrl then
                    modifiersMatch = false
                end
            else
                if flags.ctrl then
                    modifiersMatch = false
                end
            end

            if hs.fnutils.contains(bind[1], config.Key.SHIFT) then
                if not flags.shift then
                    modifiersMatch = false
                end
            else
                if flags.shift then
                    modifiersMatch = false
                end
            end

            if modifiersMatch then
                window.moveWindow(bind[3])
                return true
            end

            ::continue::
        end

        return false
    end)

    -- Iniciar o watcher
    window.keyWatcher:start()
end

return window
