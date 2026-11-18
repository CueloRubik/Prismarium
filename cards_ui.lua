local Progress = require('progression')
local Fonts = require('font_helper')

local CardsUI = {
    openState = false,
    tab = 1,
    scroll = 0,
    inspect = nil,
    selectedSlot = 1,
    buttons = {},
    images = {},
    fonts = {},
    flipped = {},
    flipTime = {},
    hover = nil
}

local function loadImage(path)
    if love.filesystem.getInfo(path) then
        local img = love.graphics.newImage(path)
        img:setFilter('linear', 'linear')
        return img
    end
    return nil
end

local function image(path)
    CardsUI.images[path] = CardsUI.images[path] or loadImage(path)
    return CardsUI.images[path]
end

local function text(value, x, y, size, color)
    love.graphics.setFont(size or CardsUI.fonts.medium)
    local c = color or {0.96,0.96,1,1}
    love.graphics.setColor(0.05,0.07,0.12,(c[4] or 1)*0.8)
    love.graphics.print(tostring(value), x+1, y+1)
    love.graphics.setColor(c)
    love.graphics.print(tostring(value), x, y)
end

local function center(value, cx, y, size, color)
    love.graphics.setFont(size or CardsUI.fonts.medium)
    local w = love.graphics.getFont():getWidth(tostring(value))
    text(value, cx - w/2, y, size, color)
end

local function paragraph(value, x, y, w, size, color, align)
    love.graphics.setFont(size or CardsUI.fonts.small)
    local c = color or {0.90,0.93,1,1}
    love.graphics.setColor(0.05,0.07,0.12,(c[4] or 1)*0.76)
    love.graphics.printf(tostring(value), x+1, y+1, w, align or 'left')
    love.graphics.setColor(c)
    love.graphics.printf(tostring(value), x, y, w, align or 'left')
end

local function drawImage(img, x, y, w, h, alpha)
    if not img then return end
    love.graphics.setColor(1,1,1,alpha or 1)
    love.graphics.draw(img, x, y, 0, w / img:getWidth(), h / img:getHeight())
end

local function button(id, label, x, y, w, h, active, enabled, icon)
    local img = image('assets/ui/lab_button' .. (active and '_active' or '') .. '.png')
    drawImage(img, x, y, w, h, enabled == false and 0.45 or 1)
    if icon then
        local ic = image('assets/ui/icon_' .. icon .. '.png')
        if ic then drawImage(ic, x + 10, y + 6, 18, 18, enabled == false and 0.55 or 1) end
    end
    center(label, x + w/2 + (icon and 8 or 0), y + 8, CardsUI.fonts.small, enabled == false and {0.55,0.62,0.72,1} or {0.93,0.95,1,1})
    CardsUI.buttons[#CardsUI.buttons+1] = {id=id,x=x,y=y,w=w,h=h,enabled=enabled~=false}
end

local function panel(kind, x, y, w, h, alpha)
    local img = image('assets/ui/' .. kind .. '.png')
    drawImage(img, x, y, w, h, alpha or 1)
end

local function rarityColor(r)
    if r=='legendary' then return {1.00,0.83,0.42,1}
    elseif r=='epic' then return {0.92,0.64,1.00,1}
    elseif r=='rare' then return {0.56,1.00,0.76,1}
    end
    return {0.68,0.88,1.00,1}
end

function CardsUI.load()
    CardsUI.fonts = {
        tiny = Fonts.get(10),
        small = Fonts.get(12),
        medium = Fonts.get(14),
        heading = Fonts.get(18),
        title = Fonts.get(24)
    }
    image('assets/ui/lab_atmosphere.jpg')
    image('assets/ui/lab_backplate.png')
    image('assets/ui/lab_modal.png')
    image('assets/ui/lab_card_frame.png')
    image('assets/ui/lab_album_frame.png')
    image('assets/ui/lab_skin_frame.png')
    image('assets/ui/lab_chip.png')
    image('assets/ui/overlay_scrim.png')
    image('assets/ui/top_banner.png')
    image('assets/ui/tab_small.png')
    image('assets/ui/tab_small_active.png')
    image('assets/cards/back.png')
    image('assets/cards/starter_pack.png')
    image('assets/cards/grand_pack.png')
    image('assets/cards/giant_pack.png')
    for _,id in ipairs(Progress.skinOrder) do
        image('assets/cards/' .. id .. '.png')
        image('assets/entities/player_' .. id .. '.png')
    end
end

function CardsUI.open()
    CardsUI.openState = true
    CardsUI.tab = 1
    CardsUI.scroll = 0
    CardsUI.inspect = nil
    CardsUI.selectedSlot = 1
    CardsUI.flipped = {}
    CardsUI.flipTime = {}
end

function CardsUI.update(dt)
    CardsUI.hover = nil
    for i,v in pairs(CardsUI.flipTime) do
        CardsUI.flipTime[i] = math.min(1, v + dt * 1.8)
    end
end

function CardsUI.wheelmoved(_, y)
    if CardsUI.tab == 2 and not CardsUI.inspect then
        CardsUI.scroll = math.max(0, CardsUI.scroll - y * 48)
    end
end

local function drawHeader()
    drawImage(CardsUI.images['assets/ui/lab_atmosphere.jpg'], 0, 0, 800, 600)
    drawImage(CardsUI.images['assets/ui/lab_backplate.png'], 18, 18, 764, 564)
    text('LABORATORIO PRISMÁTICO', 58, 48, CardsUI.fonts.title)
    text('Sobres, colección y carga táctica', 58, 86, CardsUI.fonts.small, {0.74,0.84,0.98,1})
    panel('lab_chip', 572, 40, 128, 30)
    center(tostring(Progress.coins) .. ' MONEDAS', 636, 48, CardsUI.fonts.small, {1,0.82,0.46,1})
    button('close', 'SALIR', 706, 38, 58, 28, false, true, 'back')
    local tabs={'SOBRES','COLECCIÓN','HABILIDADES'}
    for i,label in ipairs(tabs) do button('tab:'..i,label,58+(i-1)*180,118,152,34,CardsUI.tab==i,true) end
end

local function newAt(index)
    local id = Progress.pending[index]
    return id and Progress.getCardCount(id) == 1
end

local function drawPacks()
    if #Progress.pending > 0 then
        center('Toca cada carta para revelarla.', 400, 165, CardsUI.fonts.medium, {0.90,0.95,1,1})
        local n = #Progress.pending
        local cols = math.min(4,n)
        local gap = 18
        local cardW, cardH = n > 4 and 110 or 120, n > 4 and 114 or 154
        for i,id in ipairs(Progress.pending) do
            local row = math.floor((i-1)/4)
            local col = (i-1)%4
            local rowCount = math.min(cols,n-row*4)
            local startX = 400 - (rowCount * cardW + (rowCount - 1) * gap) / 2
            local x = startX + col * (cardW + gap)
            local y = n > 4 and (194 + row * 174) or 231
            panel('lab_card_frame', x-8, y-8, cardW+16, cardH+16)
            local t = CardsUI.flipTime[i] or 0
            local flipped = CardsUI.flipped[i] and t >= 0.5
            local narrow = CardsUI.flipped[i] and math.max(0.08, math.abs(math.cos(t * math.pi))) or 1
            local rw = cardW * narrow
            drawImage(CardsUI.images[flipped and ('assets/cards/'..id..'.png') or 'assets/cards/back.png'], x + (cardW-rw)/2, y, rw, cardH)
            if not CardsUI.flipped[i] then
                button('flip:'..i,'ABRIR',x+(cardW-80)/2,y+cardH+10,80,26,false,true)
            else
                center(Progress.skins[id].name, x + cardW/2, y + cardH + 12, CardsUI.fonts.tiny)
                center(newAt(i) and 'NUEVA' or ('COPIA x'..Progress.getCardCount(id)), x + cardW/2, y + cardH + 28, CardsUI.fonts.tiny, newAt(i) and {0.56,1,0.74,1} or {1,0.82,0.46,1})
            end
        end
        local ready = true
        for i=1,n do if not CardsUI.flipped[i] or (CardsUI.flipTime[i] or 0) < 1 then ready = false end end
        button('claim', ready and 'CONTINUAR' or 'REVELA TODAS', 289, 535, 222, 34, ready, true)
        return
    end

    center('Abre sobres para conseguir nuevas máquinas del hangar.', 400, 174, CardsUI.fonts.medium, {0.80,0.90,1,1})
    local defs = {
        {id='starter_pack', name='SOBRE PEQUEÑO', count=2, cost=18},
        {id='grand_pack', name='SOBRE GRANDE', count=5, cost=42},
        {id='giant_pack', name='SOBRE GIGANTE', count=8, cost=72}
    }
    for i,p in ipairs(defs) do
        local x = 46 + (i-1)*235
        panel('lab_card_frame', x, 203, 208, 290)
        drawImage(CardsUI.images['assets/cards/'..p.id..'.png'], x+42, 222, 124, 154)
        center(p.name, x+104, 388, CardsUI.fonts.medium)
        center(p.count .. ' cartas de hangar', x+104, 414, CardsUI.fonts.small, {0.78,0.87,1,1})
        center(p.cost .. ' monedas', x+104, 438, CardsUI.fonts.small, {1,0.80,0.42,1})
        button('buy:'..p.id, 'ABRIR', x+20, 456, 168, 32, false, Progress.coins >= p.cost)
    end
end

local function drawCollection()
    local areaX, areaY, areaW, areaH = 56, 154, 688, 390
    panel('lab_chip', 56, 545, 688, 24)
    center('Rueda del mouse para desplazar. Cada carta representa una skin/vehículo del hangar.', 400, 549, CardsUI.fonts.tiny, {0.76,0.86,1,1})

    local cols, cardW, cardH, gap = 4, 156, 202, 16
    local rows = math.ceil(#Progress.skinOrder / cols)
    local totalH = rows * (cardH + gap) - gap
    local maxScroll = math.max(0, totalH - areaH)
    CardsUI.scroll = math.max(0, math.min(maxScroll, CardsUI.scroll))

    love.graphics.setScissor(areaX, areaY, areaW, areaH)
    for i,id in ipairs(Progress.skinOrder) do
        local row = math.floor((i-1)/cols)
        local col = (i-1)%cols
        local x = areaX + col * (cardW + gap)
        local y = areaY + row * (cardH + gap) - CardsUI.scroll
        if y > areaY - cardH and y < areaY + areaH then
            panel('lab_album_frame', x, y, cardW, cardH)
            local owned = Progress.skinsOwned[id]
            drawImage(CardsUI.images['assets/cards/'..id..'.png'], x+14, y+10, 128, 154, owned and 1 or 0.35)
            center(Progress.skins[id].name, x + cardW/2, y + 164, CardsUI.fonts.tiny)
            local lvl = Progress.getSkinLevel(id)
            local rarity = Progress.skins[id].rarity
            center(owned and ('NV. ' .. math.max(1,lvl) .. '/5') or 'BLOQUEADA', x + cardW/2, y + 180, CardsUI.fonts.tiny, owned and rarityColor(rarity) or {0.64,0.68,0.76,1})
            center('x'..Progress.getCardCount(id), x + cardW - 18, y + 14, CardsUI.fonts.tiny, {1,0.86,0.50,1})
            if Progress.equippedSkin == id then paragraph('EN USO', x+44, y+14, 68, CardsUI.fonts.tiny, {0.55,1.00,0.76,1}, 'center') end
            CardsUI.buttons[#CardsUI.buttons+1] = {id='card:'..id, x=x, y=y, w=cardW, h=cardH, enabled=true}
        end
    end
    love.graphics.setScissor()

    if maxScroll > 0 then
        drawImage(image('assets/ui/lab_chip.png'), 750, areaY, 19, areaH, 0.85)
        local knobH = math.max(36, areaH * (areaH / totalH))
        local progress = CardsUI.scroll / maxScroll
        drawImage(image('assets/ui/lab_button_active.png'), 750, areaY + (areaH - knobH) * progress, 19, knobH)
    end
end

local function statLine(label, value, x, y, color)
    text(label, x, y, CardsUI.fonts.small, {0.84,0.90,1,1})
    drawImage(image('assets/ui/enemy_hp_back.png'), x+82, y+4, 120, 10)
    local fill = image('assets/ui/progress_fill.png')
    if fill then
        love.graphics.setColor(color)
        love.graphics.draw(fill, x+82, y+4, 0, math.max(0,math.min(120,value*18))/fill:getWidth(), 10/fill:getHeight())
    end
end

local function drawInspect()
    local id = CardsUI.inspect
    if not id then return end
    local def = Progress.skins[id]
    local stats = Progress.getSkinStats(id)
    drawImage(CardsUI.images['assets/ui/overlay_scrim.png'], 0, 0, 800, 600, 0.84)
    drawImage(CardsUI.images['assets/ui/lab_modal.png'], 98, 82, 604, 436)
    drawImage(CardsUI.images['assets/cards/'..id..'.png'], 128, 130, 200, 250, Progress.skinsOwned[id] and 1 or 0.4)
    text(def.name, 356, 130, CardsUI.fonts.heading)
    paragraph(def.desc, 356, 160, 294, CardsUI.fonts.small, {0.78,0.86,1,1})
    text('RAREZA: ' .. string.upper(def.rarity), 356, 198, CardsUI.fonts.small, rarityColor(def.rarity))
    text('COPIAS: ' .. Progress.getCardCount(id) .. '    NIVEL: ' .. math.max(1, Progress.getSkinLevel(id)) .. '/5', 356, 224, CardsUI.fonts.small, {1,0.82,0.44,1})
    statLine('VELOCIDAD', stats.speed, 356, 266, {0.46,0.92,1,1})
    statLine('ATAQUE', stats.attack, 356, 292, {1,0.67,0.44,1})
    statLine('TECNOLOGÍA', stats.tech, 356, 318, {0.68,0.98,0.70,1})
    statLine('DEFENSA', stats.guard, 356, 344, {0.94,0.66,1,1})
    paragraph('La onda usa el atributo de ataque para ampliar radio y daño al jefe. La velocidad mejora movilidad y dash; tecnología mejora consumo y defensa aumenta energía total.', 128, 392, 520, CardsUI.fonts.tiny, {0.77,0.84,0.96,1})
    button('closeinspect', 'CERRAR', 366, 455, 104, 32, false, true)
    if Progress.skinsOwned[id] then
        button('equip:'..id, Progress.equippedSkin == id and 'EN USO' or 'EQUIPAR', 482, 455, 118, 32, Progress.equippedSkin == id, true)
    end
end

local function drawSkills()
    text('RANURAS ACTIVAS', 60, 166, CardsUI.fonts.small, {0.90,0.95,1,1})
    local equipped = Progress.getEquippedSecondary()
    for i=1,3 do
        local active = i <= Progress.secondarySlots
        local x = 60 + (i-1)*116
        panel('lab_chip', x, 192, 96, 52, active and 1 or 0.35)
        local id = equipped[i]
        local icon = id and Progress.secondaryDefs[id].icon or 'grid'
        local ic = image('assets/ui/icon_' .. icon .. '.png')
        if ic then drawImage(ic, x+8, 206, 24, 24, active and 1 or 0.35) end
        paragraph(active and (id and Progress.secondaryDefs[id].name or 'Vacía') or 'Bloqueada', x+36, 202, 52, CardsUI.fonts.tiny, active and {0.92,0.96,1,1} or {0.56,0.60,0.68,1}, 'center')
        button('slot:'..i, i==CardsUI.selectedSlot and 'SELEC.' or ('R'..i), x+10, 250, 76, 26, i==CardsUI.selectedSlot, active)
    end
    local slotCost = Progress.getSecondarySlotCost()
    if slotCost then button('buy_slot', '+ RANURA ('..slotCost..')', 428, 203, 160, 30, false, Progress.coins >= slotCost) end
    button('clear_slot', 'LIMPIAR', 598, 203, 118, 30, false, equipped[CardsUI.selectedSlot] and true or false)

    local skillW, skillH = 316, 92
    for i,id in ipairs(Progress.secondaryOrder) do
        local row = math.floor((i-1)/2)
        local col = (i-1)%2
        local x = 58 + col*336
        local y = 282 + row*82
        panel('lab_core_frame', x, y, skillW, 78)
        local def = Progress.secondaryDefs[id]
        local ic = image('assets/ui/icon_' .. def.icon .. '.png')
        if ic then drawImage(ic, x+18, y+18, 34, 34) end
        text(def.name, x+64, y+15, CardsUI.fonts.medium)
        paragraph(def.desc, x+64, y+38, 166, CardsUI.fonts.tiny, {0.74,0.84,0.98,1})
        text(def.cost .. ' monedas', x+240, y+16, CardsUI.fonts.tiny, {1,0.82,0.44,1})
        local owned = Progress.isSecondaryOwned(id)
        local equippedSomewhere = false
        for s=1,Progress.secondarySlots do if equipped[s] == id then equippedSomewhere = true end end
        if not owned then
            button('buy_skill:'..id, 'COMPRAR', x+230, y+48, 72, 28, false, Progress.coins >= def.cost)
        else
            button('equip_skill:'..id, equippedSomewhere and 'EQUIPADA' or 'EQUIPAR', x+222, y+48, 88, 28, equippedSomewhere, CardsUI.selectedSlot <= Progress.secondarySlots)
        end
    end
    paragraph('Solo hay dos acciones principales en batalla: Onda (clic izquierdo / S) y Dash (clic derecho / ESPACIO). Las demás habilidades se compran aquí y se equipan a tus ranuras secundarias.', 60, 548, 680, CardsUI.fonts.tiny, {0.78,0.86,1,1}, 'center')
end

function CardsUI.draw()
    CardsUI.buttons = {}
    drawHeader()
    if CardsUI.tab == 1 then drawPacks()
    elseif CardsUI.tab == 2 then drawCollection()
    else drawSkills() end
    if CardsUI.inspect then drawInspect() end
end

function CardsUI.click(x, y)
    for i=#CardsUI.buttons,1,-1 do
        local b = CardsUI.buttons[i]
        if b.enabled and x >= b.x and x <= b.x+b.w and y >= b.y and y <= b.y+b.h then
            local id = b.id
            if CardsUI.inspect and id ~= 'closeinspect' and not id:match('^equip:') then return nil end
            if id == 'close' then return 'close' end
            if id == 'closeinspect' then CardsUI.inspect = nil return nil end
            if id:match('^tab:') then CardsUI.tab = tonumber(id:sub(5)) or 1; CardsUI.inspect=nil; return nil end
            if id:match('^buy:') then local ok,msg = Progress.buyPack(id:sub(5)); return msg end
            if id:match('^flip:') then local n = tonumber(id:sub(6)); CardsUI.flipped[n] = true; CardsUI.flipTime[n] = 0; return nil end
            if id == 'claim' then
                local ready = true
                for i=1,#Progress.pending do if not CardsUI.flipped[i] or (CardsUI.flipTime[i] or 0) < 1 then ready = false end end
                if not ready then for i=1,#Progress.pending do CardsUI.flipped[i]=true; CardsUI.flipTime[i]=1 end return nil end
                if Progress.claimPending() then CardsUI.flipped={};CardsUI.flipTime={} end
                return 'SOBRE REVELADO'
            end
            if id:match('^card:') then
                if CardsUI.inspect or CardsUI.tab ~= 2 or y < 154 or y > 544 then return nil end
                CardsUI.inspect = id:sub(6)
                return nil
            end
            if id:match('^equip:') then local _,msg = Progress.equipSkin(id:sub(7)); return msg end
            if id:match('^slot:') then local slot = tonumber(id:sub(6)); if slot and slot <= Progress.secondarySlots then CardsUI.selectedSlot = slot end return nil end
            if id == 'buy_slot' then local _,msg = Progress.buySlot(); return msg end
            if id == 'clear_slot' then local _,msg = Progress.equipSecondary(CardsUI.selectedSlot, false); return msg end
            if id:match('^buy_skill:') then local _,msg = Progress.buySecondary(id:sub(11)); return msg end
            if id:match('^equip_skill:') then local _,msg = Progress.equipSecondary(CardsUI.selectedSlot, id:sub(13)); return msg end
        end
    end
    return nil
end

return CardsUI
