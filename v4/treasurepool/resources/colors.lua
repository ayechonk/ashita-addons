local Colors = T {}

Colors.Basic = {
    -- Base Colors
    WHITE = {1.00, 1.00, 1.00, 1.0},
    RED = {1.00, 0.00, 0.00, 1.0},
    GREEN = {0.00, 1.00, 0.00, 1.0},
    BLUE = {0.00, 0.00, 1.00, 1.0},
    ORANGE = {0.90, 0.60, 0.00, 1.0},
    YELLOW = {0.90, 1.00, 0.00, 1.0},
    BR_GREEN = {0.20, 1.00, 0.00, 1.0},
    PURPLE = {0.70, 0.20, 1.00, 1.0},
    DIM = {0.50, 0.50, 0.50, 1.0},
    INACTIVE = {0.14, 0.14, 0.14, 1.0},
    MOB = {0.60, 0.60, 0.60, 1.0},
    -- Elements
    LIGHT = {1.0, 1.0, 1.0, 1.0},
    DARK = {0.9, 0.0, 1.0, 1.0},
    FIRE = {1.0, 0.0, 0.0, 1.0},
    ICE = {0.0, 0.7, 1.0, 1.0},
    WIND = {0.0, 1.0, 0.0, 1.0},
    EARTH = {0.7, 0.5, 0.0, 1.0},
    THUNDER = {0.7, 0.2, 1.0, 1.0},
    WATER = {0.3, 0.5, 0.8, 1.0}
}

Colors.Elements = {
    [0] = Colors.Basic.FIRE,
    [1] = Colors.Basic.ICE,
    [2] = Colors.Basic.WIND,
    [3] = Colors.Basic.EARTH,
    [4] = Colors.Basic.THUNDER,
    [5] = Colors.Basic.WATER,
    [6] = Colors.Basic.LIGHT,
    [7] = Colors.Basic.DARK
}

Colors.Avatars = {
    Carbuncle = Colors.Basic.LIGHT,
    Fenrir = Colors.Basic.DARK,
    Diabolos = Colors.Basic.DARK,
    Ifrit = Colors.Basic.FIRE,
    Shiva = Colors.Basic.ICE,
    Garuda = Colors.Basic.WIND,
    Titan = Colors.Basic.EARTH,
    Ramuh = Colors.Basic.THUNDER,
    Leviathan = Colors.Basic.WATER
}

Colors.Jobs = T {
    [0] = {0.40, 0.40, 0.40, 1.0}, -- NON
    [1] = {0.90, 0.00, 0.00, 1.0}, -- WAR
    [2] = {0.96, 0.77, 0.01, 1.0}, -- MNK
    [3] = {1.00, 1.00, 1.00, 1.0}, -- WHM
    [4] = {0.65, 0.52, 0.74, 1.0}, -- BLM
    [5] = {0.91, 0.39, 0.40, 1.0}, -- RDM
    [6] = {0.03, 0.76, 0.11, 1.0}, -- THF
    [7] = {0.90, 0.98, 0.09, 1.0}, -- PLD
    [8] = {0.90, 0.00, 1.00, 1.0}, -- DRK
    [9] = {0.80, 0.73, 0.47, 1.0}, -- BST
    [10] = {0.97, 0.64, 0.91, 1.0}, -- BRD
    [11] = {0.43, 0.77, 0.35, 1.0}, -- RNG
    [12] = {0.99, 0.43, 0.01, 1.0}, -- SAM
    [13] = {0.96, 0.19, 0.00, 1.0}, -- NIN
    [14] = {0.70, 0.29, 0.98, 1.0}, -- DRG
    [15] = {0.44, 0.99, 0.71, 1.0}, -- SMN
    [16] = {0.30, 0.56, 0.83, 1.0}, -- BLU
    [17] = {0.79, 0.46, 0.34, 1.0}, -- COR
    [18] = {0.51, 0.48, 0.67, 1.0}, -- PUP
    [19] = {0.00, 0.00, 0.00, 1.0}, -- DNC
    [20] = {0.00, 0.00, 0.00, 1.0}, -- SCH
    [21] = {0.00, 0.00, 0.00, 1.0}, -- GEO
    [22] = {0.00, 0.00, 0.00, 1.0} -- RUN
}

Colors.XP = T {
    [1] = {0.83, 0.65, 0.31, 1.0}, -- Experience
    [2] = {0.30, 0.56, 0.83, 1.0} -- Limit
}

return Colors;