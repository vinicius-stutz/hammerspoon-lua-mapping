-- config.lua: Configurações globais e constantes

local config = {}

-- Códigos de teclas
config.KEY = {
    LEFT = 123,
    RIGHT = 124,
    UP = 126,
    DOWN = 125,
    ESC = 53,
    ENTER = 36,
    F2 = 120,
    HOME = 115,
    END = 119,
    FORWARD_DELETE = 117
}

-- Mapeamento de códigos para nomes de teclas
config.keyMapping = {
    [config.KEY.LEFT] = "left",
    [config.KEY.RIGHT] = "right",
    [config.KEY.UP] = "up",
    [config.KEY.DOWN] = "down"
}

config.alertStyle = {
    strokeWidth  = 0.12,
    strokeColor = { white = 1, alpha = 1 },
    fillColor   = { white = 0.12, alpha = 0.8 },
    textColor = { white = 1, alpha = 1 },
    textFont  = ".AppleSystemUIFont",
    textSize  = 13,
    radius = 6,
    atScreenEdge = 0,
    fadeInDuration = 0.15,
    fadeOutDuration = 0.15,
    padding = 16,
}

-- Configurações de performance
config.keyboardEventDelay = 0 -- Delay mínimo para eventos de teclado

config.userName = hs.execute("whoami"):gsub("\n", "")

return config