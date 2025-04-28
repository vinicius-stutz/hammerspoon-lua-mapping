--[[
--Copyright (c) 2025 vinici.us.com. All Rights Reserved.
--Licensed under the MIT license.
--]]

-- config.lua: Configurações globais e constantes

local config = {}

-- Se você tiver invertido nas configurações conforme arquivo README
config.Key = {
    CTRL = "cmd",
    START = "ctrl",
    ALT = "alt",
    SHIFT = "shift",
    ESC = "escape",
    F1 = "f1",
    F2 = "f2",
    F3 = "f3",
    F4 = "f4",
    F5 = "f5",
    F6 = "f6",
    F7 = "f7",
    F8 = "f8",
    F9 = "f9",
    F10 = "f10",
    F11 = "f11",
    F12 = "f12",
    TAB = "tab",
}

-- Códigos de teclas
config.KeyCode = {
    LEFT = 123,
    RIGHT = 124,
    UP = 126,
    DOWN = 125,
    ESC = 53,
    ENTER = 36,
    F1 = 122,
    F2 = 120,
    F3 = 99,
    F4 = 118,
    F5 = 96,
    F6 = 97,
    F7 = 98,
    F8 = 100,
    F9 = 101,
    F10 = 109,
    F11 = 103,
    F12 = 111,
    HOME = 115,
    END = 119,
    FORWARD_DELETE = 117,
    PAGEUP = 116,
    PAGEDOWN = 121
}

-- Mapeamento de códigos para nomes de teclas
config.KeyMapping = {
    [config.KeyCode.LEFT] = "left",
    [config.KeyCode.RIGHT] = "right",
    [config.KeyCode.UP] = "up",
    [config.KeyCode.DOWN] = "down"
}

config.AlertStyle = {
    strokeWidth     = 0.12,
    strokeColor     = { white = 1, alpha = 1 },
    fillColor       = { white = 0.12, alpha = 0.8 },
    textColor       = { white = 1, alpha = 1 },
    textFont        = ".AppleSystemUIFont",
    textSize        = 13,
    radius          = 6,
    atScreenEdge    = 0,
    fadeInDuration  = 0.15,
    fadeOutDuration = 0.15,
    padding         = 16,
}

-- Configurações de performance
config.keyboardEventDelay = 0 -- Delay mínimo para eventos de teclado

config.userName = hs.execute("whoami"):gsub("\n", "")

return config
