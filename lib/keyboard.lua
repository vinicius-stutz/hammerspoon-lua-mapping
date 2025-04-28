--[[
--Copyright (c) 2025 vinici.us.com. All Rights Reserved.
--Licensed under the MIT license.
--]]

-- keyboard.lua: Funções relacionadas a eventos de teclado

local keyboard = {}
local config = require("config")
local types = hs.eventtap.event.types
local ctrlArrowWatcher = nil

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

    -- Abrir Apple Mail com Ctrl+A seguido de Ctrl+M
    hs.hotkey.bind({ config.Key.CTRL }, "a", function()
        hs.hotkey.bind({ config.Key.CTRL }, "m", function()
            hs.execute("open -a 'Mail.app'")
        end):enable()
    end, function()
        hs.hotkey.disableAll({ config.Key.CTRL }, "m")
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
        { { config.Key.CTRL, config.Key.SHIFT }, "v", { "cmd", "shift" }, "v" }  -- Colar sem formatação
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

-- Configurar monitoramento de Ctrl+setas
function keyboard.setupCtrlArrowWatcher()
    ctrlArrowWatcher = hs.eventtap.new({ types.keyDown }, function(event)
        local keyCode = event:getKeyCode()
        local flags = event:getFlags()

        -- Verifica se é Ctrl+seta
        if (keyCode == config.KeyCode.LEFT or keyCode == config.KeyCode.RIGHT) and flags.cmd then
            -- Prepara modificadores
            local newModifiers = { "alt" }
            if flags.shift then table.insert(newModifiers, "shift") end

            -- Dispara tecla com Alt em vez de Ctrl
            fastKeyStroke(newModifiers, config.KeyMapping[keyCode], 0)
            return true
        end

        return false
    end)

    ctrlArrowWatcher:start()

    -- Armazenar referência global
    _G.ctrlArrowWatcher = ctrlArrowWatcher

    return ctrlArrowWatcher
end

return keyboard
