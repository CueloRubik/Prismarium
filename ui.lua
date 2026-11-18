local Sprites = require('sprites')
local Progress = require('progression')
local Fonts = require('font_helper')

local UI = {
    buttons = {}, hoveredId = nil, showUpgrades = false,
    gridVisible = false, fonts = {}, notice = '', noticeTime = 0,
    noticeColor = {0.2, 0.6, 0.4}, assets = nil
}

local COLORS = {
    ink = {0.98, 0.95, 1},
    muted = {0.84, 0.78, 0.90},
    border = {0.93, 0.80, 0.55},
    orange = {1.00, 0.76, 0.36},
    green = {0.55, 0.98, 0.82},
    red = {1.00, 0.56, 0.82},
    cyan = {0.62, 0.90, 1.00},
    purple = {0.92, 0.70, 1.00}
}

local descriptions = {
    play = 'Comenzar partida', quit = 'Salir del juego',
    pause = 'Pausar (ESC o P)', resume = 'Continuar partida',
    upgrades = 'Abrir mejoras de expedicion (U)', restart = 'Reiniciar partida',
    menu = 'Volver al menu principal', close_upg = 'Cerrar la tienda (U)',
    dash = 'DASH  •  clic derecho o ESPACIO',
    pulse = 'ONDA  •  clic izquierdo o S',
    secondary1 = 'Habilidad secundaria de la ranura 1',
    secondary2 = 'Habilidad secundaria de la ranura 2',
    secondary3 = 'Habilidad secundaria de la ranura 3',
    upg_speed = 'Velocidad y dash mas rapidos',
    upg_magnet = 'Aumenta el radio de atraccion',
    upg_eff = 'Reduce el consumo de energia'
}

local function inside(mx, my, b)
    return mx >= b.x and mx <= b.x + b.w and my >= b.y and my <= b.y + b.h
end

local function loadImage(path)
    if love.filesystem.getInfo(path) then
        local img = love.graphics.newImage(path)
        img:setFilter('linear', 'linear')
        return img
    end
    return nil
end

local function ensureAssets()
    if UI.assets then return end
    local base = 'assets/ui/'
    UI.assets = {
        button_large = loadImage(base .. 'button_large.png'),
        button_menu = loadImage(base .. 'button_menu.png'),
        button_help = loadImage(base .. 'button_help.png'),
        button_quit = loadImage(base .. 'button_quit.png'),
        button_small = loadImage(base .. 'button_small.png'),
        button_pause = loadImage(base .. 'button_pause.png'),
        button_ability = loadImage(base .. 'button_ability.png'),
        button_upgrade = loadImage(base .. 'button_upgrade.png'),
        panel_overlay = loadImage(base .. 'panel_overlay.png'),
        panel_result = loadImage(base .. 'panel_result.png'),
        hud_frame = loadImage(base .. 'hud_frame.png'),
        bottom_bar = loadImage(base .. 'bottom_bar.png'),
        boss_frame = loadImage(base .. 'boss_frame.png'),
        arena_frame = loadImage(base .. 'arena_frame.png'),
        menu_footer = loadImage(base .. 'menu_footer.png'),
        energy_fill = loadImage(base .. 'energy_fill.png'),
        energy_fill_green = loadImage(base .. 'energy_fill_green.png'),
        energy_fill_red = loadImage(base .. 'energy_fill_red.png'),
        progress_fill = loadImage(base .. 'progress_fill.png'),
        boss_fill = loadImage(base .. 'boss_fill.png'),
        overlay_scrim = loadImage(base .. 'overlay_scrim.png'),
        tutorial_panel = loadImage(base .. 'tutorial_panel.png'),
        info_bar = loadImage(base .. 'info_bar.png'),
        enemy_hp_back = loadImage(base .. 'enemy_hp_back.png'),
        enemy_hp_fill_blue = loadImage(base .. 'enemy_hp_fill_blue.png'),
        enemy_hp_fill_green = loadImage(base .. 'enemy_hp_fill_green.png'),
        reticle = loadImage(base .. 'reticle.png'),
        ornate_energy = loadImage(base .. 'ornate_energy.png'),
        ornate_currency = loadImage(base .. 'ornate_currency.png'),
        ornate_progress = loadImage(base .. 'ornate_progress.png'),
        ornate_boss = loadImage(base .. 'ornate_boss.png'),
        ornate_message = loadImage(base .. 'ornate_message.png'),
        ornate_victory = loadImage(base .. 'ornate_victory.png'),
        ornate_defeat = loadImage(base .. 'ornate_defeat.png'),
        ornate_abilities = loadImage(base .. 'ornate_abilities.png'),
        ornate_medal = loadImage(base .. 'ornate_medal.png'),
        ornate_crystal = loadImage(base .. 'ornate_crystal.png'),
        icons = {}
    }
    local iconNames = {
        'play','pause','restart','home','quit','grid','upgrades','dash','polarity','pulse',
        'singularity','overdrive','counter','beacon','mine','shield','lab','help','back'
    }
    for _, name in ipairs(iconNames) do
        UI.assets.icons[name] = loadImage(base .. 'icon_' .. name .. '.png')
    end
end

local function textAt(value, x, y, font, color)
    love.graphics.setFont(font or UI.fonts.medium)
    local c = color or COLORS.ink
    local a = c[4] or 1
    love.graphics.setColor(0.03, 0.03, 0.08, a * 0.76)
    love.graphics.print(tostring(value), x + 1, y + 1)
    love.graphics.setColor(c[1], c[2], c[3], a)
    love.graphics.print(tostring(value), x, y)
end

local function centered(value, centerX, y, font, color)
    love.graphics.setFont(font or UI.fonts.medium)
    local c = color or COLORS.ink
    local a = c[4] or 1
    local px = centerX - love.graphics.getFont():getWidth(tostring(value)) / 2
    love.graphics.setColor(0.03, 0.03, 0.08, a * 0.76)
    love.graphics.print(tostring(value), px + 1, y + 1)
    love.graphics.setColor(c[1], c[2], c[3], a)
    love.graphics.print(tostring(value), px, y)
end

local function drawScaled(img, x, y, w, h, alpha)
    if not img then return end
    love.graphics.setColor(1, 1, 1, alpha or 1)
    love.graphics.draw(img, x, y, 0, w / img:getWidth(), h / img:getHeight())
end

local function drawIcon(name, cx, cy, size, color)
    ensureAssets()
    local img = UI.assets.icons[name]
    if img then
        local s = (size or 24) / img:getWidth()
        local c = color or COLORS.cyan
        love.graphics.setColor(c[1], c[2], c[3], c[4] or 1)
        love.graphics.draw(img, cx, cy, 0, s, s, img:getWidth() / 2, img:getHeight() / 2)
    end
end

local function buttonSkin(b)
    if b.skin then return UI.assets[b.skin] end
    if b.id == 'pause' then return UI.assets.button_pause end
    if b.id == 'play' and b.w > 90 then return UI.assets.button_large end
    if b.id == 'resume' then return UI.assets.button_large end
    if b.h > 70 then return UI.assets.button_upgrade end
    if b.y >= 540 or b.id == 'shield_buy' then return UI.assets.button_ability end
    return UI.assets.button_small
end

function UI.init()
    ensureAssets()
    UI.fonts = {
        tiny = Fonts.get(10),
        small = Fonts.get(12),
        medium = Fonts.get(14),
        heading = Fonts.get(22),
        title = Fonts.get(42)
    }
end

function UI.toast(value, r, g, b)
    UI.notice = value
    UI.noticeTime = 1.65
    UI.noticeColor = {r or 0.25, g or 0.90, b or 0.65}
end

function UI.buildMenuButtons()
    UI.buttons = {
        {id = 'play', x = 350, y = 432, w = 100, h = 44, icon = 'play', color = COLORS.orange},
        {id = 'grid', x = 294, y = 438, w = 36, h = 34, icon = 'grid', color = COLORS.green},
        {id = 'quit', x = 470, y = 438, w = 36, h = 34, icon = 'quit', color = COLORS.red}
    }
end

function UI.buildPlayingButtons()
    UI.buttons = {
        {id = 'pause', x = 739, y = 12, w = 31, h = 31, icon = 'pause', color = COLORS.muted},
        {id = 'restart', x = 702, y = 12, w = 31, h = 31, icon = 'restart', color = COLORS.red},
        {id = 'secondary1', x = 44, y = 515, w = 52, h = 46, icon = 'grid', color = COLORS.cyan, skin='button_ability'},
        {id = 'secondary2', x = 102, y = 490, w = 52, h = 46, icon = 'grid', color = COLORS.green, skin='button_ability'},
        {id = 'secondary3', x = 160, y = 465, w = 52, h = 46, icon = 'grid', color = COLORS.purple, skin='button_ability'},
        {id = 'pulse', x = 642, y = 512, w = 56, h = 48, icon = 'pulse', color = COLORS.orange, skin='button_ability'},
        {id = 'dash', x = 705, y = 458, w = 56, h = 48, icon = 'dash', color = COLORS.cyan, skin='button_ability'}
    }
    local equipped = Progress.getEquippedSecondary()
    local colorMap = {shield=COLORS.green, magnet=COLORS.green, overdrive=COLORS.red, counter=COLORS.cyan, beacon={0.58,0.88,0.98}, mine=COLORS.purple}
    local iconMap = {shield='shield', magnet='singularity', overdrive='overdrive', counter='counter', beacon='beacon', mine='mine'}
    for i=1,3 do
        local b = UI.buttons[2 + i]
        local ab = equipped[i]
        b.ability = ab
        b.enabled = i <= Progress.secondarySlots and ab and true or false
        if ab then
            b.icon = iconMap[ab] or 'grid'
            b.color = colorMap[ab] or COLORS.cyan
        end
    end
end

function UI.buildPauseButtons()
    UI.buttons = {
        {id = 'resume', x = 286, y = 280, w = 68, h = 50, icon = 'play', color = COLORS.green, label = 'SEGUIR', skin='button_small'},
        {id = 'restart', x = 366, y = 280, w = 68, h = 50, icon = 'restart', color = COLORS.orange, label = 'REINICIAR', skin='button_small'},
        {id = 'menu', x = 446, y = 280, w = 68, h = 50, icon = 'home', color = COLORS.red, label = 'MENU', skin='button_small'}
    }
end

function UI.buildUpgradeButtons()
    UI.buttons = {
        {id = 'upg_speed', x = 260, y = 249, w = 80, h = 93, icon = 'dash', color = COLORS.orange},
        {id = 'upg_magnet', x = 360, y = 249, w = 80, h = 93, icon = 'singularity', color = COLORS.green},
        {id = 'upg_eff', x = 460, y = 249, w = 80, h = 93, icon = 'shield', color = {0.83, 0.63, 0.12}},
        {id = 'close_upg', x = 376, y = 375, w = 48, h = 32, icon = 'quit', color = COLORS.red}
    }
end

function UI.buildGameOverButtons()
    UI.buttons = {
        {id = 'restart', x = 330, y = 410, w = 64, h = 50, icon = 'restart', color = COLORS.orange, skin='button_small'},
        {id = 'menu', x = 406, y = 410, w = 64, h = 50, icon = 'home', color = COLORS.muted, skin='button_small'}
    }
end

function UI.buildVictoryButtons()
    UI.buttons = {
        {id = 'restart', x = 330, y = 410, w = 64, h = 50, icon = 'restart', color = COLORS.green, skin='button_small'},
        {id = 'menu', x = 406, y = 410, w = 64, h = 50, icon = 'home', color = COLORS.muted, skin='button_small'}
    }
end

function UI.update(mx, my, dt)
    UI.hoveredId = nil
    UI.noticeTime = math.max(0, UI.noticeTime - (dt or 0))
    for _, b in ipairs(UI.buttons) do
        if inside(mx, my, b) then
            UI.hoveredId = b.id
            break
        end
    end
end

function UI.mousepressed(mx, my, button)
    if button ~= 1 then return nil end
    for _, b in ipairs(UI.buttons) do
        if inside(mx, my, b) then return b.id end
    end
    return nil
end

local function status(id, player, world)
    if not player or not world then return false, 0 end
    local cost, cooldown, maximum
    local skin = player.skinStats or {}
    if id == 'dash' then
        cost, cooldown, maximum = skin.dashCost or 10, player.dashCooldown, player.dashMaxCooldown
    elseif id == 'pulse' then
        cost, cooldown, maximum = skin.pulseCost or 18, player.pulseCooldown, player.pulseMaxCooldown
    elseif id == 'secondary1' or id == 'secondary2' or id == 'secondary3' then
        local slot = tonumber(id:sub(-1))
        local ability = Progress.getEquippedSecondary()[slot]
        if not ability or slot > Progress.secondarySlots then return true, 0 end
        if ability == 'shield' then return player.hasShield or player.energy < 12, 0 end
        if ability == 'magnet' then cost, cooldown, maximum = 15, player.singularityCooldown, player.singularityMaxCooldown end
        if ability == 'overdrive' then cost, cooldown, maximum = 25, player.overdriveCooldown, player.overdriveMaxCooldown end
        if ability == 'counter' then cost, cooldown, maximum = 7, player.counterCooldown, 2.6 end
        if ability == 'beacon' then cost, cooldown, maximum = 20, player.beaconCooldown, 9 end
        if ability == 'mine' then cost, cooldown, maximum = 17, player.mineCooldown, 5.5 end
    end
    if cooldown then return cooldown > 0 or player.energy < (cost or 0), math.min(1, cooldown / math.max(0.01, maximum or 1)) end
    local levels = { upg_speed = player.speedUpgrade, upg_magnet = player.magnetUpgrade, upg_eff = player.efficiencyUpgrade }
    if levels[id] then return levels[id] >= 3 or world.coinsCount < 4, 0 end
    return false, 0
end

function UI.drawButtons(player, world)
    ensureAssets()
    for _, b in ipairs(UI.buttons) do
        local hovered = UI.hoveredId == b.id
        local disabled, cooldown = status(b.id, player, world)
        local lift = hovered and -2 or 0
        local alpha = disabled and 0.68 or 1
        local skin = buttonSkin(b)

        drawScaled(skin, b.x, b.y + lift, b.w, b.h, alpha)
        if hovered and UI.assets.info_bar then
            drawScaled(UI.assets.info_bar, b.x + 2, b.y + lift + 2, math.max(12, b.w - 4), math.max(8, math.floor(b.h * 0.34)), 0.34)
        end

        local c = disabled and {0.46, 0.54, 0.62} or b.color
        local iconY = b.y + lift + b.h / 2
        if b.y >= 540 or b.h > 70 then iconY = b.y + lift + 18 + (b.h > 70 and 13 or 0) end
        local iconX = b.id == 'play' and b.w > 80 and b.x + 26 or b.x + b.w / 2
        drawIcon(b.icon, iconX, iconY, b.h > 70 and 28 or 20, c)

        if b.skin == 'button_ability' or b.y >= 540 then
            local keys = {dash = 'RMB', pulse = 'LMB', secondary1='1', secondary2='2', secondary3='3'}
            centered(keys[b.id] or '', b.x + b.w / 2, b.y + lift + 25, UI.fonts.tiny, disabled and COLORS.muted or COLORS.ink)
        elseif b.h > 70 then
            local names = {upg_speed = 'MOTOR', upg_magnet = 'IMAN', upg_eff = 'AHORRO'}
            local level = {upg_speed = player and player.speedUpgrade or 0, upg_magnet = player and player.magnetUpgrade or 0, upg_eff = player and player.efficiencyUpgrade or 0}
            centered(names[b.id] or '', b.x + b.w / 2, b.y + 57, UI.fonts.tiny, COLORS.ink)
            centered('NV. ' .. (level[b.id] or 0) .. '/3', b.x + b.w / 2, b.y + 74, UI.fonts.tiny, COLORS.muted)
        elseif b.id == 'play' and b.w > 80 then
            textAt('JUGAR', b.x + 46, b.y + 14, UI.fonts.small, COLORS.ink)
        elseif b.label then
            centered(b.label, b.x + b.w / 2, b.y + b.h + 6, UI.fonts.tiny, COLORS.muted)
        end

        if cooldown > 0 then
            local fill = b.h * cooldown
            drawScaled(UI.assets.overlay_scrim, b.x + 3, b.y + lift + b.h - fill, math.max(4, b.w - 6), math.max(2, fill), 0.40)
        end
    end
end

function UI.drawHUD(player, world)
    ensureAssets()
    -- Decorative illustrated HUD sprites. Keep controls at the far right unobstructed.
    drawScaled(UI.assets.ornate_energy or UI.assets.hud_frame, 12, 2, 219, 56)
    drawScaled(UI.assets.ornate_currency or UI.assets.hud_frame, 223, 2, 193, 56)
    drawScaled(UI.assets.ornate_progress or UI.assets.hud_frame, 411, 2, 219, 56)

    local energy = math.max(0, math.min(1, player.energy / math.max(1, player.maxEnergy)))
    textAt('ENERGIA', 82, 12, UI.fonts.tiny, COLORS.ink)
    textAt(math.ceil(math.max(0, player.energy)) .. '/' .. player.maxEnergy, 148, 12, UI.fonts.tiny, COLORS.ink)
    -- A small dynamic resource fill sits inside the illustrated energy frame.
    drawScaled(UI.assets.enemy_hp_back, 85, 36, 116, 6)
    local fillImg = player.overdriveTimer > 0 and UI.assets.energy_fill_red or
        (player.polarity == 1 and UI.assets.energy_fill or UI.assets.energy_fill_green)
    if energy > 0 then drawScaled(fillImg, 85, 36, 116 * energy, 6) end

    textAt('PRISMAS ' .. tostring(world.coinsCount or 0), 279, 16, UI.fonts.small, COLORS.ink)
    textAt('PUNTOS ' .. tostring(world.score or 0), 279, 31, UI.fonts.tiny, COLORS.muted)
    local isTutorial = world.tutorialMode
    textAt(isTutorial and 'TUTORIAL' or ('MAPA ' .. tostring(world.level or 1) .. '/' .. #require('maps').list), 479, 14, UI.fonts.small, COLORS.ink)
    textAt('SKIN ' .. tostring((Progress.skins and Progress.skins[Progress.equippedSkin] and Progress.skins[Progress.equippedSkin].name) or '---'), 478, 30, UI.fonts.tiny, COLORS.muted)
    if not world.boss then
        local total = math.max(1, world.levelTargetScore or 1)
        local done = math.max(0, math.min(1, (world.levelProgress or 0) / total))
        drawScaled(UI.assets.enemy_hp_back, 487, 37, 108, 7)
        if done > 0 then drawScaled(UI.assets.progress_fill, 487, 37, 108 * done, 7) end
    else
        textAt('JEFE ACTIVO', 480, 33, UI.fonts.tiny, COLORS.orange)
    end
end

function UI.drawBossHUD(world)
    local b = world.boss
    if not b then return end
    ensureAssets()
    drawScaled(UI.assets.ornate_boss or UI.assets.boss_frame, 125, 55, 548, 83)
    local portrait = Sprites.getBossPortrait(b.kind)
    if portrait then
        local factor = 58 / math.max(portrait:getWidth(), portrait:getHeight())
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(portrait, 181, 101, 0, factor, factor, portrait:getWidth() / 2, portrait:getHeight() / 2)
    end
    textAt(b.name or 'JEFE', 236, 79, UI.fonts.medium, COLORS.ink)
    textAt('FASE ' .. tostring(b.phase or 1), 583, 79, UI.fonts.tiny, COLORS.orange)
    drawScaled(UI.assets.enemy_hp_back, 238, 105, 389, 9)
    local ratio = math.max(0, math.min(1, b.hp / math.max(1, b.maxHp)))
    if ratio > 0 then drawScaled(UI.assets.boss_fill, 238, 105, 389 * ratio, 9) end
end

function UI.drawArenaBorder()
    ensureAssets()
    drawScaled(UI.assets.arena_frame, 24, 58, 752, 480)
end

function UI.drawBottomBar(audioEnabled)
    ensureAssets()
    drawScaled(UI.assets.bottom_bar, 18, 542, 764, 52)
    -- Small illustrated emblems at both ends keep the gameplay buttons clear.
    drawScaled(UI.assets.ornate_crystal, 21, 547, 43, 42)
    drawScaled(UI.assets.ornate_medal, 738, 549, 38, 39)
end

function UI.drawOverlayPanel(w, h, style)
    ensureAssets()
    drawScaled(UI.assets.overlay_scrim, 0, 0, 800, 600, 0.78)
    local x, y = (800 - w) / 2, (600 - h) / 2
    local img = style == 'victory' and UI.assets.ornate_victory or
                (style == 'defeat' and UI.assets.ornate_defeat or UI.assets.panel_overlay)
    drawScaled(img or UI.assets.panel_overlay, x, y, w, h)
end

function UI.drawUpgradeInfo(player, world)
    centered('MEJORAS', 400, 192, UI.fonts.heading, COLORS.ink)
    centered('Prismas de partida: ' .. world.coinsCount, 400, 222, UI.fonts.small, COLORS.muted)
    for _, x in ipairs({300, 400, 500}) do centered('4', x, 347, UI.fonts.small, COLORS.muted) end
    centered('U o ESC para cerrar', 400, 412, UI.fonts.tiny, COLORS.muted)
end

function UI.drawPauseInfo()
    centered('EN PAUSA', 400, 227, UI.fonts.heading, {0.95, 0.97, 1})
    centered('Pulsa P o ESC para continuar', 400, 362, UI.fonts.small, {0.7, 0.86, 1})
end

function UI.drawMenuInfo(bestScore)
    centered('PRISMARIUM', 400, 77, UI.fonts.title, COLORS.ink)
    centered('Una expedición prismática.', 400, 154, UI.fonts.small, COLORS.muted)
    centered('RECORD  ' .. bestScore, 400, 498, UI.fonts.small, COLORS.muted)
end

function UI.drawResultInfo(victory, world, bestScore)
    centered(victory and '¡VICTORIA!' or 'FIN DE LA PARTIDA', 400, 102, UI.fonts.heading, victory and COLORS.green or COLORS.red)
    centered('PUNTUACION: ' .. world.score, 400, 327, UI.fonts.heading, COLORS.ink)
    centered('RECORD: ' .. bestScore .. '   |   NIVEL: ' .. world.level, 400, 360, UI.fonts.small, COLORS.muted)
    centered('REINICIAR        MENU', 400, 469, UI.fonts.small, COLORS.muted)
end

function UI.drawFloatingFeedback(player, world)
    ensureAssets()
    if UI.noticeTime > 0 then
        local c = UI.noticeColor
        local alpha = math.min(1, UI.noticeTime * 1.8)
        local y = player and 461 or 507
        drawScaled(UI.assets.ornate_message or UI.assets.menu_footer, 214, y, 372, 55, alpha)
        centered(UI.notice, 400, y + 20, UI.fonts.small, {c[1], c[2], c[3], alpha})
    end
    if player and UI.noticeTime <= 0 and UI.hoveredId and descriptions[UI.hoveredId] then
        local str = descriptions[UI.hoveredId]
        if UI.hoveredId:match('^secondary') then
            local slot = tonumber(UI.hoveredId:sub(-1))
            local ability = Progress.getEquippedSecondary()[slot]
            if ability and Progress.secondaryDefs[ability] then str = Progress.secondaryDefs[ability].name .. '  •  ' .. Progress.secondaryDefs[ability].desc end
        end
        local disabled, cooldown = status(UI.hoveredId, player, world)
        if cooldown > 0 then
            local lengths = {dash = player.dashMaxCooldown, pulse = player.pulseMaxCooldown,
                singularity = player.singularityMaxCooldown, overdrive = player.overdriveMaxCooldown}
            str = str .. '  ' .. string.format('%.1fs', cooldown * (lengths[UI.hoveredId] or 1))
        end
        if disabled and cooldown <= 0 then str = str .. '  NO DISPONIBLE' end
        drawScaled(UI.assets.ornate_message or UI.assets.menu_footer, 155, 495, 490, 45)
        centered(str, 400, 510, UI.fonts.tiny, COLORS.ink)
    end
end


function UI.drawAimReticle(x, y, player)
    ensureAssets()
    if not x or not y then return end
    local c = player and (player.polarity == 1 and {1, 0.72, 0.28} or {0.35, 0.96, 0.72}) or {0.7, 0.9, 1}
    if player and player.overdriveTimer > 0 then c = {1, 0.42, 0.3} end
    local img = UI.assets.reticle
    if img then
        local s = 40 / img:getWidth()
        love.graphics.setColor(c[1], c[2], c[3], 0.98)
        love.graphics.draw(img, x, y, 0, s, s, img:getWidth() / 2, img:getHeight() / 2)
    end
end

return UI
