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
    -- Fechar aplicação (Alt+F4 -> Cmd+F4)
    hs.hotkey.bind({"cmd"}, "f4", nil, function()
        local app = hs.application.frontmostApplication()
        if app then app:kill() end
    end)
    
    -- Fechar aba/janela (Ctrl+F4)
    hs.hotkey.bind({"ctrl"}, "f4", nil, function()
        local win = hs.window.focusedWindow()
        if win then win:close() end
    end)
    
    -- Abrir Launchpad (Ctrl+Esc)
    hs.hotkey.bind({"ctrl"}, config.KEY.ESC, function() 
        hs.execute("open -a 'Launchpad'") 
    end)
    
    -- Abrir Gerenciador de Tarefas (Ctrl+Shift+Esc)
    hs.hotkey.bind({"ctrl", "shift"}, config.KEY.ESC, function() 
        hs.execute("open -a 'Activity Monitor.app'") 
    end)
    
    -- Alternar entre aplicações (Alt+Tab)
    hs.hotkey.bind({"alt"}, "tab", function() 
        hs.execute("open -a 'Mission Control'") 
    end)
    
    -- Abrir Finder (Alt+F)
    hs.hotkey.bind({"alt"}, "f", function() 
        hs.execute("open -a 'Finder.app'") 
    end)
    
    -- Foco no menu principal (Alt+Space)
    hs.hotkey.bind({"alt"}, "space", function()
        local currentApp = hs.application.frontmostApplication()
        if currentApp then
            local menuItems = currentApp:getMenuItems()
            if menuItems and #menuItems > 0 then
                currentApp:selectMenuItem({menuItems[1].AXTitle})
            end
        end
    end)
end

-- Criar todos os atalhos de teclado
function keyboard.createShortcuts()
    keyboard.setupSystemShortcuts()
    
    -- Teclas a desabilitar
    local disableKeys = {
        {{"cmd"}, "q"},
        {{"cmd"}, "w"}
    }

    -- Remapeamento Ctrl para Cmd
    local ctrlToCmd = {
        "z", "x", "v", "c", "o", "s", "f", "a", "p", "l", "t"
    }

    -- Casos especiais
    local specialCases = {
        {{"ctrl"}, "y", {"cmd", "shift"}, "z"},          -- Refazer
        {{"ctrl", "shift"}, "t", {"cmd", "shift"}, "t"}, -- Restaurar aba
        {{"alt"}, "l", {"cmd", "ctrl"}, "q"},            -- Bloquear tela
        {{"ctrl"}, "d", {"cmd", "shift"}, "d"},          -- Duplicar linha
        {{"ctrl", "shift"}, "v", {"cmd", "shift"}, "v"}  -- Colar sem formatação
    }

    -- Navegação (códigos de tecla -> atalhos Mac)
    local navigationKeys = {
        {config.KEY.HOME, {"cmd"}, config.KEY.LEFT},                              -- Home
        {{"shift"}, config.KEY.HOME, {"cmd", "shift"}, config.KEY.LEFT},          -- Shift+Home
        {config.KEY.END, {"cmd"}, config.KEY.RIGHT},                              -- End
        {{"shift"}, config.KEY.END, {"cmd", "shift"}, config.KEY.RIGHT},          -- Shift+End
        {{"ctrl"}, config.KEY.HOME, {"cmd"}, config.KEY.UP},                      -- Ctrl+Home
        {{"ctrl"}, config.KEY.END, {"cmd"}, config.KEY.DOWN},                     -- Ctrl+End
        {{"ctrl", "shift"}, config.KEY.HOME, {"cmd", "shift"}, config.KEY.UP},    -- Ctrl+Shift+Home
        {{"ctrl", "shift"}, config.KEY.END, {"cmd", "shift"}, config.KEY.DOWN}    -- Ctrl+Shift+End
    }

    -- 1. Desabilitar teclas
    for _, key in ipairs(disableKeys) do 
        hs.hotkey.bind(key[1], key[2], nil, function() return true end)
    end

    -- 2. Remapear Ctrl para Cmd
    for _, key in ipairs(ctrlToCmd) do 
        hs.hotkey.bind({"ctrl"}, key, nil, function() 
            fastKeyStroke({"cmd"}, key, config.keyboardEventDelay) 
        end)
    end

    -- 3. Casos especiais
    for _, map in ipairs(specialCases) do 
        hs.hotkey.bind(map[1], map[2], nil, function() 
            fastKeyStroke(map[3], map[4], config.keyboardEventDelay) 
        end)
    end

    -- 4. Teclas de navegação
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
    ctrlArrowWatcher = hs.eventtap.new({types.keyDown}, function(event)
        local keyCode = event:getKeyCode()
        local flags = event:getFlags()
        
        -- Verifica se é Ctrl+seta
        if (keyCode == config.KEY.LEFT or keyCode == config.KEY.RIGHT) and flags.ctrl then
            -- Prepara modificadores
            local newModifiers = {"alt"}
            if flags.shift then table.insert(newModifiers, "shift") end
            
            -- Dispara tecla com Alt em vez de Ctrl
            fastKeyStroke(newModifiers, config.keyMapping[keyCode], 0)
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