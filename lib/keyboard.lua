--[[
--Copyright (c) 2025 vinici.us.com. All Rights Reserved.
--Licensed under the MIT license.
--]]

-- keyboard.lua: Funções relacionadas a eventos de teclado

local keyboard = {}
local config = require("config")
local window = require("lib.window")
local types = hs.eventtap.event.types
local keysWatcher = nil

-- Cache da função de keyStroke para melhorar performance
local fastKeyStroke = hs.eventtap.keyStroke

-- Configurar performance de teclado
function keyboard.setupPerformanceSettings()
    -- Reduzir delays ao mínimo
    hs.eventtap.keyRepeatInterval(0.01) -- Menor intervalo de repetição
    hs.eventtap.keyRepeatDelay(0.10)    -- Menor delay inicial
end

-- Configurar atalhos de sistema
function keyboard.setupSystemShortcuts()
    -- Fechar aplicação
    hs.hotkey.bind({ config.Key.ALT }, config.Key.F4, nil, function()
        local app = hs.application.frontmostApplication()
        if app then app:kill() end
    end)

    -- Fechar aba/janela
    hs.hotkey.bind({ config.Key.CTRL }, config.Key.F4, nil, function()
        local win = hs.window.focusedWindow()
        if not win then return end

        local app = win:application()
        local appName = app:name()

        -- Lista de aplicativos que sabemos usar abas
        local tabApps = {
            ["Google Chrome"] = true,
            ["Safari"] = true,
            ["Firefox"] = true,
            ["Finder"] = true,
            ["Terminal"] = true,
            ["iTerm2"] = true,
            ["Visual Studio Code"] = true,
            ["Sublime Text"] = true
        }

        -- Lista de aplicativos onde precisamos ser cuidadosos
        local sensitiveApps = {
            ["TextEdit"] = true,
            ["Microsoft Word"] = true
        }

        if tabApps[appName] then
            -- Para navegadores e aplicativos que sabemos que usam abas
            hs.eventtap.keyStroke({ "cmd" }, "w")
        elseif sensitiveApps[appName] then
            -- Para aplicativos sensíveis, perguntamos antes
            local button = hs.dialog.blockAlert(
                "Fechar aba/documento",
                "Deseja fechar este documento em " .. appName .. "?",
                "Cancelar", "Fechar"
            )
            if button == "Fechar" then
                hs.eventtap.keyStroke({ "cmd" }, "w")
            end
        else
            win:close()
        end
    end)

    -- Abrir Gerenciador de Tarefas
    hs.hotkey.bind({ config.Key.CTRL, config.Key.SHIFT }, config.KeyCode.ESC, function()
        hs.execute("open -a 'Activity Monitor.app'")
    end)

    -- Abrir Finder
    hs.hotkey.bind({ config.Key.START }, "f", function()
        hs.execute("open -a 'Finder.app'")
    end)

    -- Mostrar desktop
    hs.hotkey.bind({ config.Key.START }, "d", nil, function()
        local allWindows = hs.window.visibleWindows()
        for _, win in ipairs(allWindows) do
            win:minimize()
        end
        hs.alert.show("Mostrando área de trabalho…", config.AlertStyle, 2)
    end)

    -- Foco no menu principal
    hs.hotkey.bind({ config.Key.ALT }, config.Key.ESC, function()
        local currentApp = hs.application.frontmostApplication()
        if currentApp then
            local menuItems = currentApp:getMenuItems()
            if menuItems and #menuItems > 0 then
                currentApp:selectMenuItem({ menuItems[1].AXTitle })
            end
        end
    end)
end

-- Criar todos os atalhos de teclado
function keyboard.createShortcuts()
    keyboard.setupSystemShortcuts()

    -- Teclas a desabilitar
    local disableKeys = {
        { { "cmd" }, "q" }
    }

    -- Combinações para casos especiais
    local specialCases = {
        { { config.Key.CTRL },                   "y", { "cmd", "shift" }, "z" }, -- Refazer
        { { config.Key.START },                  "l", { "cmd", "ctrl" },  "q" }, -- Bloquear tela
        { { config.Key.CTRL, config.Key.SHIFT }, "v", { "cmd", "shift" }, "v" }, -- Colar sem formatação
        { { config.Key.ALT, config.Key.SHIFT },  "d", { "cmd", "ctrl" },  "d" }  -- Definição de palavra
    }

    -- Desabilitar teclas
    for _, key in ipairs(disableKeys) do
        hs.hotkey.bind(key[1], key[2], nil, function() return true end)
    end

    -- Casos especiais
    for _, map in ipairs(specialCases) do
        hs.hotkey.bind(map[1], map[2], nil, function()
            fastKeyStroke(map[3], map[4], config.keyboardEventDelay)
        end)
    end
end

-- Navegação (códigos de tecla -> atalhos Mac)
function keyboard.createNavigationsShortcuts()
    local navigationKeys = {
        { config.KeyCode.HOME,                   { "ctrl" },          "a" },                                      -- Home
        { { config.Key.SHIFT },                  config.KeyCode.HOME, { "ctrl", "shift" }, "a" },                 -- Shift+Home
        { config.KeyCode.END,                    { "ctrl" },          "e" },                                      -- End
        { { config.Key.SHIFT },                  config.KeyCode.END,  { "ctrl", "shift" }, "e" },                 -- Shift+End
        { { config.Key.CTRL },                   config.KeyCode.HOME, { "cmd" },           config.KeyCode.UP },   -- Ctrl+Home
        { { config.Key.CTRL },                   config.KeyCode.END,  { "cmd" },           config.KeyCode.DOWN }, -- Ctrl+End
        { { config.Key.CTRL, config.Key.SHIFT }, config.KeyCode.HOME, { "cmd", "shift" },  config.KeyCode.UP },   -- Ctrl+Shift+Home
        { { config.Key.CTRL, config.Key.SHIFT }, config.KeyCode.END,  { "cmd", "shift" },  config.KeyCode.DOWN }  -- Ctrl+Shift+End
    }

    -- Teclas de navegação
    for _, nav in ipairs(navigationKeys) do
        if type(nav[1]) == "table" then
            -- Com modificadores (shift)
            hs.hotkey.bind(nav[1], nav[2], nil, function()
                fastKeyStroke(nav[3], nav[4], config.keyboardEventDelay)
            end)
        else
            -- Sem modificadores
            hs.hotkey.bind({}, nav[1], nil, function()
                fastKeyStroke(nav[2], nav[3], config.keyboardEventDelay)
            end)
        end
    end
end

-- Configurar monitoramento das teclas em geral
function keyboard.setupKeysWatcher()
    keysWatcher = hs.eventtap.new({ types.keyDown }, function(event)
        local keyCode = event:getKeyCode()
        local flags = event:getFlags()

        -- Verifica se é Ctrl+Seta
        if (keyCode == config.KeyCode.LEFT or keyCode == config.KeyCode.RIGHT) and flags.cmd then
            if flags.shift then
                fastKeyStroke({ "alt", "shift" }, config.KeyMapping[keyCode], 0)
            else
                fastKeyStroke({ "alt" }, config.KeyMapping[keyCode], 0)
            end
            return true
        end

        -- Verifica se é Ctrl+Tab
        if keyCode == hs.keycodes.map["tab"] and flags.cmd and not flags.alt and not flags.ctrl then
            -- Verifica se é Ctrl+Shift+Tab
            if flags.shift then
                fastKeyStroke({ "ctrl", "shift" }, "tab", 0)
            else
                fastKeyStroke({ "ctrl" }, "tab", 0)
            end
            return true
        end

        -- Para cada configuração de atalho
        for _, bind in ipairs(window.Bindings) do
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
                window.move(bind[3])
                return true
            end

            ::continue::
        end

        return false
    end)

    keysWatcher:start()

    -- Armazenar referência global
    _G.keysWatcher = keysWatcher

    return keysWatcher
end

return keyboard
