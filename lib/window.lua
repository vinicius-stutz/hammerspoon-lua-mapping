-- window.lua: Funções relacionadas a janelas

local config = require("config")
local window = {}

-- Configurações de atalhos para janelas
local windowBindings = {
    { {"alt"}, "left", "half-left" },
    { {"alt"}, "right", "half-right" },
    { {"alt"}, "up", "maximize" },
    { {"alt"}, "down", "minimize" },
    { {"alt", "cmd"}, "left", "move-left" },
    { {"alt", "cmd"}, "right", "move-right" }
}

-- Mostrar desktop
function window.setupDesktopShortcut()
    hs.hotkey.bind({"alt"}, "d", nil, function()
        local allWindows = hs.window.visibleWindows()
        for _, win in ipairs(allWindows) do
            win:minimize()
        end
        hs.alert.show("Mostrando área de trabalho…", config.alertStyle, 2)
    end)
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
            win:setFrame({x = frame.x, y = frame.y, w = frame.w / 2, h = frame.h})
        end,
        ["half-right"] = function() 
            win:setFrame({x = frame.x + frame.w / 2, y = frame.y, w = frame.w / 2, h = frame.h})
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
    
    -- Atalhos para movimentação e redimensionamento
    for _, bind in ipairs(windowBindings) do 
        hs.hotkey.bind(bind[1], bind[2], nil, function() 
            window.moveWindow(bind[3]) 
        end) 
    end
end

return window