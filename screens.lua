local Fonts = require('font_helper')

local Screens = {tab = 1, buttons = {}, time = 0, fonts = {}, images = {}, assets = nil, lastPack = nil}

local function font(size)
    if not Screens.fonts[size] then Screens.fonts[size] = Fonts.get(size) end
    return Screens.fonts[size]
end

local function text(t, x, y, size, c)
    love.graphics.setFont(font(size or 14))
    local col = c or {0.98, 0.95, 1}
    local a = col[4] or 1
    love.graphics.setColor(0.03, 0.03, 0.08, a * 0.72)
    love.graphics.print(tostring(t), x + 1, y + 1)
    love.graphics.setColor(col[1], col[2], col[3], a)
    love.graphics.print(tostring(t), x, y)
end

local function centered(t, cx, y, size, c)
    love.graphics.setFont(font(size or 14))
    local w = love.graphics.getFont():getWidth(tostring(t))
    text(t, cx - w / 2, y, size, c)
end

local function hit(x, y, b)
    return x >= b.x and x <= b.x + b.w and y >= b.y and y <= b.y + b.h
end

local function loadImage(path)
    if love.filesystem.getInfo(path) then
        local img = love.graphics.newImage(path)
        img:setFilter('linear', 'linear')
        return img
    end
end

local function ensureAssets()
    if Screens.assets then return end
    local ui = 'assets/ui/'
    Screens.assets = {
        button_large = loadImage(ui .. 'button_large.png'),
        button_menu = loadImage(ui .. 'button_menu.png'),
        button_help = loadImage(ui .. 'button_help.png'),
        button_quit = loadImage(ui .. 'button_quit.png'),
        top_banner = loadImage(ui .. 'top_banner.png'),
        menu_footer = loadImage(ui .. 'menu_footer.png'),
        map_frame = loadImage(ui .. 'map_frame.png'),
        shop_card = loadImage(ui .. 'shop_card.png'),
        panel_overlay = loadImage(ui .. 'panel_overlay.png'),
        arrow_left = loadImage(ui .. 'arrow_left.png'),
        arrow_right = loadImage(ui .. 'arrow_right.png'),
        overlay_scrim = loadImage(ui .. 'overlay_scrim.png'),
        map_info_panel = loadImage(ui .. 'map_info_panel.png'),
        shop_icon_slot = loadImage(ui .. 'shop_icon_slot.png'),
        tab_small = loadImage(ui .. 'tab_small.png'),
        tab_small_active = loadImage(ui .. 'tab_small_active.png'),
        info_bar = loadImage(ui .. 'info_bar.png'),
        icons = {},
        bossPortraits = {}
    }
    for _, name in ipairs({'play','lab','help','quit','back','shield','dash','singularity','restart'}) do
        Screens.assets.icons[name] = loadImage(ui .. 'icon_' .. name .. '.png')
    end
    local ent = 'assets/entities/'
    for i = 1, 4 do Screens.assets.bossPortraits[i] = loadImage(ent .. 'boss' .. math.min(i,4) .. '.png') end
end

local function drawScaled(img, x, y, w, h, alpha, tint)
    if not img then return end
    local col = tint or {1, 1, 1}
    love.graphics.setColor(col[1], col[2], col[3], alpha or 1)
    love.graphics.draw(img, x, y, 0, w / img:getWidth(), h / img:getHeight())
end

local function drawIcon(name, cx, cy, size, color)
    local img = Screens.assets.icons[name]
    if not img then return end
    local s = (size or 28) / img:getWidth()
    local c = color or {0.98, 0.89, 1}
    love.graphics.setColor(c[1], c[2], c[3], c[4] or 1)
    love.graphics.draw(img, cx, cy, 0, s, s, img:getWidth() / 2, img:getHeight() / 2)
end

local function backdrop(i)
    local im = Screens.images[i]
    if im then
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(im, 0, 0, 0, 800 / im:getWidth(), 600 / im:getHeight())
    else
        love.graphics.clear(0.05, 0.07, 0.13)
    end
end

local function button(id, x, y, w, h, title, accent, enabled, icon, skin)
    local mx, my = love.mouse.getPosition()
    local hovered = hit(mx, my, {x = x, y = y, w = w, h = h})
    local img = Screens.assets[skin or 'button_menu'] or Screens.assets.button_menu
    drawScaled(img, x, y + (hovered and -2 or 0), w, h, enabled == false and 0.55 or 1)
    if hovered and Screens.assets.info_bar then
        drawScaled(Screens.assets.info_bar, x + 4, y + 4, math.max(16, w - 8), math.max(8, math.floor(h * 0.30)), 0.30)
    end
    local tCol = enabled == false and {0.48, 0.54, 0.62} or {0.95, 0.97, 1}
    if icon then drawIcon(icon, x + 22, y + h / 2, 20, accent or {0.4, 0.9, 1}) end
    if title and title ~= '' then centered(title, x + w / 2 + (icon and 8 or 0), y + h / 2 - 9, 15, tCol) end
    Screens.buttons[#Screens.buttons + 1] = {id = id, x = x, y = y, w = w, h = h}
end

function Screens.load()
    ensureAssets()
    local paths = {main = 'assets/scenes/main.jpg'}
    local Maps=require('maps')
    for i = 1, #Maps.list do paths['preview' .. i] = 'assets/scenes/preview' .. i .. '.jpg' end
    for key, path in pairs(paths) do
        if love.filesystem.getInfo(path) then
            Screens.images[key] = love.graphics.newImage(path)
            Screens.images[key]:setFilter('linear', 'linear')
        end
    end
end

function Screens.update(dt) Screens.time = Screens.time + dt end

function Screens.drawMain(progress, best)
    ensureAssets()
    Screens.buttons = {}
    backdrop('main')
    drawScaled(Screens.assets.overlay_scrim, 0, 0, 800, 600, 0.38)

    drawScaled(Screens.assets.panel_overlay, 46, 56, 328, 420)
    text('PRISMARIUM', 70, 133, 37, {0.96, 0.97, 1})
    text('Explora, combate y colecciona.', 72, 222, 13, {0.76, 0.82, 0.92})

    button('play', 72, 278, 276, 48, 'JUGAR', {0.52, 0.84, 0.96}, true, 'play', 'button_large')
    button('laboratory', 72, 336, 276, 42, 'LABORATORIO', {0.68, 0.80, 0.92}, true, 'lab', 'button_menu')
    button('help', 72, 388, 276, 42, 'COMO JUGAR', {0.68, 0.80, 0.92}, true, 'help', 'button_help')
    button('quit', 72, 440, 276, 42, 'SALIR', {0.80, 0.67, 0.74}, true, 'quit', 'button_quit')

    drawScaled(Screens.assets.menu_footer, 52, 516, 696, 48)
    text('RECORD ' .. best, 70, 531, 14)
    text('MONEDAS ' .. progress.coins, 250, 531, 14, {1, 0.83, 0.42})
    text('MAPAS ' .. progress.unlocked .. '/' .. #require('maps').list, 430, 531, 14, {0.72, 0.88, 1})
    text(progress.tutorialDone and 'Tutorial completado' or 'La primera expedicion incluye tutorial', 560, 531, 13, {0.75, 0.83, 0.93})
end

function Screens.drawMap(progress, selected)
    ensureAssets()
    local Maps = require('maps')
    local m = Maps.list[selected]
    Screens.buttons = {}
    backdrop('preview' .. selected)
    drawScaled(Screens.assets.overlay_scrim, 0, 0, 800, 600, 0.76)

    drawScaled(Screens.assets.top_banner, 0, 0, 800, 92)
    text('EXPEDICIONES', 58, 26, 28)
    text('Cada mapa otorga monedas al completarlo.', 58, 59, 13, {0.86, 0.80, 0.94})
    button('back', 16, 28, 34, 34, '', {0.68, 0.80, 0.92}, true, 'back', 'button_help')

    drawScaled(Screens.assets.map_frame, 112, 116, 576, 286)
    local im = Screens.images['preview' .. selected]
    if im then
        love.graphics.setColor(1, 1, 1, selected <= progress.unlocked and 1 or 0.4)
        love.graphics.draw(im, 120, 124, 0, 560 / im:getWidth(), 270 / im:getHeight())
    end
    drawScaled(Screens.assets.map_info_panel, 120, 330, 560, 63)
    text(string.format('%02d / %s', selected, m.name), 138, 340, 20)
    text(m.subtitle, 138, 366, 13, {0.88, 0.82, 0.96})

    drawScaled(Screens.assets.arrow_left, 38, 222, 54, 76)
    drawScaled(Screens.assets.arrow_right, 708, 222, 54, 76)
    Screens.buttons[#Screens.buttons + 1] = {id = 'prev', x = 38, y = 222, w = 54, h = 76}
    Screens.buttons[#Screens.buttons + 1] = {id = 'next', x = 708, y = 222, w = 54, h = 76}

    local hint = m.mechanic == 'roots' and 'Los sellos verdes ralentizan: controla la zona.' or
        m.mechanic == 'press' and 'Las prensas activas pegan fuerte: observa su ritmo.' or
        m.mechanic == 'ice' and 'El hielo resbala y crea confusiones.' or
        m.mechanic == 'portal' and 'Los portales te mueven si entras sin cuidado.' or
        m.mechanic == 'storm' and 'La tormenta drena energia si te quedas en los sellos.' or
        'La luz solar recarga energia dentro de sus coronas.'
    local available = selected <= progress.unlocked
    centered('BOSS / ' .. m.boss, 400, 433, 20, available and {1, 0.82, 0.60} or {0.80, 0.62, 0.65})
    centered(hint, 400, 463, 13, {0.90, 0.84, 0.96})
    button('tutorial', 116, 516, 124, 40, 'TUTORIAL', {0.56, 0.90, 0.84}, true, 'help', 'button_help')
    button('start', 258, 516, 284, 48, available and 'INICIAR EXPEDICION' or 'BLOQUEADO', {0.56, 0.83, 0.97}, available, 'play', 'button_large')
    text('El tutorial es una misión independiente.', 274, 566, 12, {0.90, 0.84, 0.96})
end

local function drawCardBox(x, y, w, h, title, subtitle, accent)
    drawScaled(Screens.assets.shop_card, x, y, w, h)
    drawScaled(Screens.assets.shop_icon_slot, x + 10, y + 10, 58, h - 20)
    text(title, x + 82, y + 15, 15)
    text(subtitle, x + 82, y + 38, 12, {0.73, 0.80, 0.90})
end

function Screens.drawShop(progress, player, menuMode)
    ensureAssets()
    Screens.buttons = {}
    backdrop('preview2')
    drawScaled(Screens.assets.overlay_scrim, 0, 0, 800, 600, 0.86)
    drawScaled(Screens.assets.panel_overlay, 76, 85, 648, 430)
    text('LABORATORIO PRISMÁTICO', 138, 152, 25)
    text('Las mejoras secundarias se administran desde el laboratorio.', 138, 218, 14, {0.82,0.88,1})
    text('Hay dos acciones principales: ONDA y DASH.', 138, 268, 14, {0.88,0.94,1})
    text('Hasta tres ranuras de apoyo se equipan antes de iniciar.', 138, 300, 14, {0.88,0.94,1})
    button('close', 302, 432, 196, 40, 'CERRAR', {0.58,0.84,0.96}, true, 'back', 'button_help')
end

function Screens.drawHelp()
    ensureAssets()
    Screens.buttons = {}
    backdrop('main')
    drawScaled(Screens.assets.overlay_scrim, 0, 0, 800, 600, 0.88)
    drawScaled(Screens.assets.panel_overlay, 84, 66, 632, 468)
    text('COMO JUGAR', 114, 92, 25)
    local lines = {
        'Recolecta cristales para recargar energia y activar al jefe del mapa.',
        'RATON: apunta y dirige el movimiento del vehículo.',
        'CLIC IZQUIERDO o S: ONDA prismatica que convierte enemigos en prismas.',
        'CLIC DERECHO o ESPACIO: DASH para escapar o atravesar zonas peligrosas.',
        'Las habilidades avanzadas no salen en el HUD principal: se compran en laboratorio.',
        'Cada partida empieza con una sola ranura secundaria; luego puedes comprar hasta 3.',
        'Monedas: se obtienen al completar mapas; sirven para sobres y habilidades.',
        'Sobres: contienen cartas-skin únicas del hangar, con copias para subir nivel.'
    }
    for i, l in ipairs(lines) do text(l, 114, 150 + (i - 1) * 34, 14, {0.82, 0.90, 1}) end
    button('back', 328, 486, 144, 36, 'VOLVER', {0.58, 0.84, 0.96}, true, 'back', 'button_help')
end

function Screens.click(x, y)
    for i = #Screens.buttons, 1, -1 do
        local b = Screens.buttons[i]
        if hit(x, y, b) then return b.id end
    end
end

return Screens
