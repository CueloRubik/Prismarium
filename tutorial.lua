local UI = require('ui')
local Fonts = require('font_helper')

local Tutorial = {
    active = false,
    step = 1,
    hand = nil,
    fonts = {},
    finished = false,
    dashUsed = false,
    pulseUsed = false,
    waitTimer = 0,
    previousCrystals = 0,
    previousHazards = 0,
    enemy1Spawned = false,
    enemy2Spawned = false,
    completedMessage = false,
    bob = 0
}

local steps = {
    [1] = {title = 'Recolectar energia', body = 'Toca el cristal brillante. Los cristales recuperan energia y son la base de cada expedicion.'},
    [2] = {title = 'Movimiento rapido', body = 'Usa DASH con clic derecho, ESPACIO o W para moverte con rapidez.'},
    [3] = {title = 'Onda prismatica', body = 'Usa la ONDA con clic izquierdo, F o S cuando un enemigo este cerca para convertir amenazas en prismas.'},
    [4] = {title = 'Primer combate', body = 'Destruye al enemigo de prueba. Puedes usar dash o onda cuando se acerque.'},
    [5] = {title = 'Segundo ejemplo', body = 'Este enemigo ataca distinto. Esquiva su peligro y responde con tus habilidades.'},
    [6] = {title = 'Laboratorio', body = 'Las habilidades secundarias se compran en laboratorio y se equipan por ranuras.'},
    [7] = {title = 'Listo', body = 'Tutorial completado. Ya puedes entrar a las expediciones normales.'}
}

local tutorialPanel

local function loadImage(path)
    if love.filesystem.getInfo(path) then
        local img = love.graphics.newImage(path)
        img:setFilter('linear', 'linear')
        return img
    end
end

local function ensureFonts()
    for _, size in ipairs({11, 12, 14, 18}) do
        if not Tutorial.fonts[size] then Tutorial.fonts[size] = Fonts.get(size) end
    end
end

function Tutorial.load()
    ensureFonts()
    if not Tutorial.hand then Tutorial.hand = loadImage('assets/ui/pointer_hand.png') end
    if not tutorialPanel then tutorialPanel = loadImage('assets/ui/ornate_tutorial.png') end
end

local function setupIntro(world)
    world.crystals = {}
    world.hazards = {}
    world.coins = {}
    world.powerups = {}
    world.beacons = {}
    world.mines = {}
    world.boss = nil
    world.isVictory = false
    world.levelProgress = 0
    world.levelTargetScore = 999999
    world.maxHazards = 0
    world.maxCrystals = 3
    world.tutorialMode = true
    world.addCrystal(540, 300, true)
end

function Tutorial.start(world)
    Tutorial.load()
    Tutorial.active = true
    Tutorial.finished = false
    Tutorial.step = 1
    Tutorial.dashUsed = false
    Tutorial.pulseUsed = false
    Tutorial.enemy1Spawned = false
    Tutorial.enemy2Spawned = false
    Tutorial.completedMessage = false
    Tutorial.waitTimer = 0
    Tutorial.bob = 0
    setupIntro(world)
    Tutorial.previousCrystals = #(world.crystals or {})
    Tutorial.previousHazards = #(world.hazards or {})
end

function Tutorial.stop(world)
    Tutorial.active = false
    Tutorial.finished = true
    if world then world.tutorialMode = false end
end

function Tutorial.isActive() return Tutorial.active end

function Tutorial.onAbility(id)
    if not Tutorial.active then return end
    if id == 'dash' then Tutorial.dashUsed = true end
    if id == 'pulse' then Tutorial.pulseUsed = true end
end

local function spawnEnemyOne(world)
    world.hazards = {}
    world.addEnemy('seeker', 586, 284)
    Tutorial.enemy1Spawned = true
end

local function spawnEnemyTwo(world)
    world.hazards = {}
    world.addEnemy('turret', 580, 250)
    world.addEnemy('star', 610, 350)
    Tutorial.enemy2Spawned = true
end

function Tutorial.update(dt, world, player)
    if not Tutorial.active then return end
    Tutorial.bob = Tutorial.bob + dt * 3
    Tutorial.waitTimer = math.max(0, Tutorial.waitTimer - dt)

    local crystals = #(world.crystals or {})
    local hazards = #(world.hazards or {})

    if Tutorial.step == 1 then
        if crystals < Tutorial.previousCrystals then
            Tutorial.step = 2
            world.addCrystal(620, 240, false)
        end
    elseif Tutorial.step == 2 then
        if Tutorial.dashUsed then
            Tutorial.step = 3
            spawnEnemyOne(world)
        end
    elseif Tutorial.step == 3 then
        if Tutorial.pulseUsed then
            Tutorial.step = 4
        end
    elseif Tutorial.step == 4 then
        if not Tutorial.enemy1Spawned then spawnEnemyOne(world) end
        if hazards == 0 then
            Tutorial.step = 5
            spawnEnemyTwo(world)
        end
    elseif Tutorial.step == 5 then
        if hazards == 0 then
            Tutorial.step = 6
            Tutorial.waitTimer = 0.6
        end
    elseif Tutorial.step == 6 then
        if Tutorial.waitTimer <= 0 then
            Tutorial.step = 7
            Tutorial.waitTimer = 0.8
            Tutorial.completedMessage = true
        end
    elseif Tutorial.step == 7 then
        if Tutorial.waitTimer <= 0 then
            world.isVictory = true
        end
    end

    Tutorial.previousCrystals = crystals
    Tutorial.previousHazards = hazards
end

local function pointerForCurrentStep(world)
    if Tutorial.step == 1 then
        local crystal = world.crystals and world.crystals[1]
        if crystal then return crystal.x, crystal.y end
    elseif Tutorial.step == 2 or Tutorial.step == 3 then
        local targetId = Tutorial.step == 2 and 'dash' or 'pulse'
        for _, b in ipairs(UI.buttons or {}) do
            if b.id == targetId then return b.x + b.w / 2, b.y + b.h / 2 end
        end
    elseif Tutorial.step == 4 or Tutorial.step == 5 then
        local enemy = world.hazards and world.hazards[1]
        if enemy then return enemy.x, enemy.y - 40 end
    end
    return nil
end

function Tutorial.draw(world)
    if not Tutorial.active then return end
    ensureFonts()
    local step = steps[Tutorial.step] or steps[1]
    local previousFont = love.graphics.getFont and love.graphics.getFont() or nil
    if tutorialPanel then
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(tutorialPanel, 23, 63, 0, 415 / tutorialPanel:getWidth(), 176 / tutorialPanel:getHeight())
    end
    love.graphics.setFont(Tutorial.fonts[11])
    love.graphics.setColor(0.34, 0.22, 0.19, 1)
    love.graphics.print('TUTORIAL  ' .. Tutorial.step .. '/7', 134, 83)
    love.graphics.setFont(Tutorial.fonts[18])
    love.graphics.setColor(0.23, 0.15, 0.25, 1)
    love.graphics.print(step.title, 132, 103)
    love.graphics.setFont(Tutorial.fonts[14])
    love.graphics.setColor(0.27, 0.20, 0.25, 1)
    love.graphics.printf(step.body, 132, 136, 279, 'left')

    local px, py = pointerForCurrentStep(world)
    if px and py and Tutorial.hand then
        local offset = math.sin(Tutorial.bob) * 5
        love.graphics.setColor(1, 1, 1, 0.98)
        love.graphics.draw(Tutorial.hand, px - 8, py - 34 + offset, 0, 0.58, 0.58)
    end
    if previousFont then love.graphics.setFont(previousFont) end
end

return Tutorial
