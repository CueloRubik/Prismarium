local Sprites = {images = nil, currentBiome = 1, ui = nil}

local function loadImage(path)
    if love.filesystem.getInfo(path) then
        local img = love.graphics.newImage(path)
        img:setFilter('linear', 'linear')
        return img
    end
    return nil
end

local function ensure()
    if Sprites.images then return end
    local e = 'assets/entities/'
    Sprites.images = {
        player = loadImage(e .. 'player.png'),
        player_verdia = loadImage(e .. 'player_verdia.png'),
        player_ascua = loadImage(e .. 'player_ascua.png'),
        player_boreal = loadImage(e .. 'player_boreal.png'),
        player_umbra = loadImage(e .. 'player_umbra.png'),
        crystal = loadImage(e .. 'crystal.png'),
        gold_crystal = loadImage(e .. 'gold_crystal.png'),
        coin = loadImage(e .. 'coin.png'),
        powerup_shield = loadImage(e .. 'powerup_shield.png'),
        powerup_surge = loadImage(e .. 'powerup_surge.png'),
        beacon = loadImage(e .. 'beacon.png'),
        mine = loadImage(e .. 'mine.png'),
        energy_orb = loadImage(e .. 'energy_orb.png'),
        proj_pulse = loadImage(e .. 'proj_pulse.png'),
        boss1 = loadImage(e .. 'boss1.png'),
        boss2 = loadImage(e .. 'boss2.png'),
        boss3 = loadImage(e .. 'boss3.png'),
        boss4 = loadImage(e .. 'boss4.png'),
        hazard_splitter = loadImage(e .. 'hazard_splitter.png'),
        hazard_seeker = loadImage(e .. 'hazard_seeker.png'),
        hazard_star = loadImage(e .. 'hazard_star.png'),
        hazard_turret = loadImage(e .. 'hazard_turret.png'),
        hazard_charger = loadImage(e .. 'hazard_charger.png'),
        hazard_orbiter = loadImage(e .. 'hazard_orbiter.png'),
        hazard_leech = loadImage(e .. 'hazard_leech.png'),
        hazard_armored = loadImage(e .. 'hazard_armored.png'),
        proj_bolt = loadImage(e .. 'proj_bolt.png'),
        proj_ember = loadImage(e .. 'proj_ember.png'),
        proj_thorn = loadImage(e .. 'proj_thorn.png'),
        proj_shard = loadImage(e .. 'proj_shard.png'),
        proj_void = loadImage(e .. 'proj_void.png')
    }

    local u = 'assets/ui/'
    Sprites.ui = {
        enemy_hp_back = loadImage(u .. 'enemy_hp_back.png'),
        enemy_hp_fill_blue = loadImage(u .. 'enemy_hp_fill_blue.png'),
        enemy_hp_fill_green = loadImage(u .. 'enemy_hp_fill_green.png')
    }

    for biome=0,4 do
        for _,kind in ipairs({'splitter','seeker','star','turret','charger','orbiter','leech','armored'}) do
            Sprites.images['hazard_'..kind..'_b'..biome] = loadImage(e .. 'hazard_' .. kind .. '_b' .. biome .. '.png')
        end
        for _,kind in ipairs({'bolt','ember','thorn','shard','void'}) do
            Sprites.images['proj_'..kind..'_b'..biome] = loadImage(e .. 'proj_' .. kind .. '_b' .. biome .. '.png')
        end
    end

    local ok, Progress = pcall(require, 'progression')
    if ok and Progress and Progress.skinOrder then
        for _,sid in ipairs(Progress.skinOrder) do
            local key='player_'..sid
            if Sprites.images[key]==nil then
                Sprites.images[key] = loadImage(e .. key .. '.png')
            end
        end
    end
end

local function drawCentered(img, x, y, angle, scaleX, scaleY, alpha, tint)
    if not img then return false end
    local sx = scaleX or 1
    local sy = scaleY or sx
    local t = tint or {1, 1, 1}
    love.graphics.setColor(t[1], t[2], t[3], alpha or 1)
    love.graphics.draw(img, x, y, angle or 0, sx, sy, img:getWidth() / 2, img:getHeight() / 2)
    return true
end

local hazardColors = {
    splitter = {1, 0.3, 0.24}, seeker = {0.86, 0.35, 1}, star = {1, 0.54, 0.25},
    turret = {1, 0.74, 0.32}, charger = {1, 0.22, 0.36}, orbiter = {0.3, 0.95, 0.98},
    leech = {0.53, 0.96, 0.45}, armored = {0.72, 0.76, 0.92}, bolt = {1, 0.5, 0.35},
    ember = {1, 0.36, 0.15}, thorn = {0.44, 1, 0.57}, shard = {0.48, 0.84, 1}, void = {0.8, 0.4, 1}
}

local function glowCircle(x, y, r, c, alpha)
    local img = Sprites.images and Sprites.images.energy_orb
    if img then
        local scale = math.max(1, r * 2) / math.max(1, img:getWidth())
        drawCentered(img, x, y, 0, scale, scale, alpha or 0.18, c)
    end
end

function Sprites.setBiome(index)
    Sprites.currentBiome = tonumber(index) or 1
end

function Sprites.drawPlayer(x, y, angle, scale, hasShield, isDashing, polarity, energyPercent, overdrive, skin, skinLevel)
    ensure()
    local palettes = {
        default = {base = {1,1,1}, auraPos = {1,0.73,0.28}, auraNeg = {0.35,1,0.71}},
        verdia = {base = {0.78,1,0.84}, auraPos = {0.76,0.95,0.48}, auraNeg = {0.42,0.92,0.62}},
        ascua = {base = {1,0.88,0.78}, auraPos = {1,0.62,0.28}, auraNeg = {0.96,0.74,0.46}},
        boreal = {base = {0.84,0.95,1}, auraPos = {0.68,0.82,1}, auraNeg = {0.54,0.92,1}},
        umbra = {base = {0.90,0.84,1}, auraPos = {0.90,0.62,1}, auraNeg = {0.65,0.56,1}},
        tempra = {base = {0.84,1,1}, auraPos = {0.48,0.98,1}, auraNeg = {0.58,1,0.92}},
        solis = {base = {1,0.97,0.82}, auraPos = {1,0.88,0.44}, auraNeg = {1,0.96,0.68}}
    }
    local family=(skin or 'default'):gsub('%d+$','')
    local palette = palettes[family] or palettes[skin or 'default'] or palettes.default
    local aura = overdrive and {1, 0.42, 0.27} or (polarity == 1 and palette.auraPos or palette.auraNeg)
    glowCircle(x, y, 26 * (scale or 1) + (isDashing and 14 or 8), aura, overdrive and 0.18 or 0.10)
    local playerImage = Sprites.images['player_' .. tostring(skin)] or Sprites.images.player
    local playerScale = playerImage and (66 / playerImage:getWidth()) * (scale or 1) or 0.72
    drawCentered(playerImage, x, y, angle or 0, playerScale, playerScale, 1, {1,1,1})

    local orb = Sprites.images.energy_orb
    local pulse = Sprites.images.proj_pulse
    local tm = (love.timer and love.timer.getTime and love.timer.getTime() or 0)
    if pulse then
        local strength = skinLevel and skinLevel > 1 and 0.14 + 0.03 * skinLevel or 0.12
        drawCentered(pulse, x, y, tm * 0.3, 0.30 * (scale or 1), nil, strength, aura)
    end
    if hasShield and orb then
        drawCentered(orb, x, y, -tm * 0.5, 0.75 * (scale or 1), nil, 0.37, {0.55, 1, 0.9})
    end
    if isDashing or overdrive then
        local a = angle or 0
        local k = (isDashing and 29 or 16) * (scale or 1)
        drawCentered(playerImage, x - math.cos(a) * k, y - math.sin(a) * k,
            a, playerScale * 0.88, playerScale * 0.88, 0.28, aura)
    end
end

function Sprites.drawAfterimage(x,y,angle,alpha,skin)
    ensure()
    local image = Sprites.images['player_' .. tostring(skin)] or Sprites.images.player
    local k = image and 64 / image:getWidth() or 0.68
    drawCentered(image,x,y,angle,k,k,(alpha or 0.4)*0.60)
end

function Sprites.drawCrystal(x, y, angle, scale, golden)
    ensure()
    local t = (love.timer and love.timer.getTime and love.timer.getTime() or 0)
    local pulse = 1 + math.sin(t * 3 + x * 0.02) * 0.05
    local tint = golden and {1, 0.98, 0.88} or {1, 1, 1}
    glowCircle(x, y, 16 * (scale or 1) * pulse, golden and {1, 0.88, 0.28} or {0.28, 1, 0.74}, golden and 0.22 or 0.14)
    drawCentered(golden and (Sprites.images.gold_crystal or Sprites.images.crystal) or Sprites.images.crystal, x, y, angle or 0, (scale or 1) * 0.56 * pulse, (scale or 1) * 0.56 * pulse, 1, tint)
    if golden and Sprites.images.energy_orb then
        drawCentered(Sprites.images.energy_orb, x, y, -(angle or 0), (scale or 1) * 0.24, (scale or 1) * 0.24, 0.38)
    end
end

function Sprites.drawCoin(x, y, angle)
    ensure()
    local tm = (love.timer and love.timer.getTime and love.timer.getTime() or 0)
    local pulse = 1 + math.sin(tm * 5 + x * 0.015) * 0.04
    glowCircle(x, y, 12, {1, 0.8, 0.28}, 0.16)
    drawCentered(Sprites.images.coin, x, y, angle or 0, 0.34 * pulse)
end

function Sprites.drawHazard(x, y, angle, scale, kind, hp, maxHp, state, windup)
    ensure()
    kind = kind or 'star'
    local isProj = (kind == 'bolt' or kind == 'ember' or kind == 'thorn' or kind == 'shard' or kind == 'void')
    local baseKey = isProj and ('proj_' .. kind) or ('hazard_' .. kind)
    local biome = tostring(Sprites.currentBiome or 1)
    local img = Sprites.images[baseKey .. '_b' .. biome] or Sprites.images[baseKey .. '_b1'] or Sprites.images[baseKey] or Sprites.images.hazard_star
    local c = hazardColors[kind] or hazardColors.star
    glowCircle(x, y, (kind == 'armored' and 22 or 18) * (scale or 1), c, 0.11)
    drawCentered(img, x, y, angle or 0, (scale or 1) * ((isProj and 0.25) or 0.42))

    if state == 'windup' and windup and Sprites.images.proj_pulse then
        local factor = math.max(0.2, math.min(1, 1 - windup / 0.65))
        drawCentered(Sprites.images.proj_pulse, x, y, 0, 0.48 + 0.12 * factor,
            nil, 0.18 + 0.20 * factor, {1, 0.32, 0.38})
    end
    if hp and maxHp and maxHp > 1 then
        local ui = Sprites.ui or {}
        local ratio = math.max(0, hp / maxHp)
        if ui.enemy_hp_back then
            love.graphics.setColor(1,1,1,1)
            love.graphics.draw(ui.enemy_hp_back, x - 18, y - 30, 0, 36 / ui.enemy_hp_back:getWidth(), 5 / ui.enemy_hp_back:getHeight())
            local fill = (kind == 'leech' or kind == 'thorn') and ui.enemy_hp_fill_green or ui.enemy_hp_fill_blue
            if fill then love.graphics.draw(fill, x - 18, y - 30, 0, 36 * ratio / fill:getWidth(), 5 / fill:getHeight()) end
        end
    end
end

function Sprites.drawBoss(b)
    ensure()
    local kind = b.kind or 1
    local img = Sprites.images['boss' .. tostring(kind)] or Sprites.images.boss1
    local colors = {{0.25,0.92,0.58},{1,0.48,0.17},{0.36,0.81,1},{0.76,0.40,1}}
    local c = colors[kind] or colors[1]
    local tm = b.time or 0
    glowCircle(b.x, b.y, (b.decoy and 45 or 56) + math.sin(tm * 3) * 3, c, b.decoy and 0.08 or 0.13)
    local diameter = (b.radius or 34) * (b.decoy and 1.8 or 2.8)
    local scale = img and diameter / math.max(1,img:getWidth()) or 0.30
    drawCentered(img, b.x, b.y, b.angle or 0, scale, scale, b.decoy and 0.62 or 1)
    if not b.decoy and Sprites.images.proj_pulse then
        drawCentered(Sprites.images.proj_pulse,b.x,b.y,tm * .25,0.6,nil,0.16,c)
    end
end

function Sprites.drawBossNode(x,y,kind,time)
    ensure()
    local img = kind==4 and Sprites.images.beacon or Sprites.images.powerup_shield
    local c = kind==4 and {0.83,0.48,1} or {0.47,1,0.65}
    local tm = time or 0
    glowCircle(x,y,26,c,0.22)
    if img then drawCentered(img,x,y,tm * .50,0.38,nil,0.95,c) end
end

function Sprites.drawTelegraph(x,y,r,remaining,kind)
    ensure()
    local img = Sprites.images.proj_pulse
    if not img then return end
    local radius = math.max(12,r or 36)
    local phase = 1-math.max(0,math.min(1,(remaining or 0)))
    local tint = kind=='roots' and {0.85,0.38,0.52} or {1,0.43,0.32}
    local scale = radius * 2.3 / math.max(1,img:getWidth())
    drawCentered(img,x,y,(love.timer and love.timer.getTime and love.timer.getTime() or 0)*.45,
        scale,scale,0.22 + phase*.28,tint)
end

function Sprites.drawMapZone(x,y,r,color,time,active)
    ensure()
    local img = Sprites.images.proj_pulse
    if not img then return end
    local tm = time or 0
    local size = (r or 32) * (active and 2.2 or 2.0) / math.max(1,img:getWidth())
    drawCentered(img,x,y,tm * .45,size,nil,active and .37 or .16,color)
end

function Sprites.drawPowerup(x, y, angle, pType)
    ensure()
    local img = Sprites.images[pType == 'shield' and 'powerup_shield' or 'powerup_surge']
    local c = pType == 'shield' and {0.35, 1, 0.72} or {1, 0.72, 0.3}
    local tm = (love.timer and love.timer.getTime and love.timer.getTime() or 0)
    local pulse = 1 + math.sin(tm * 4 + x * 0.01) * 0.05
    glowCircle(x, y, 18, c, 0.18)
    if pType ~= 'shield' and Sprites.images.energy_orb then
        drawCentered(Sprites.images.energy_orb, x, y, -(angle or 0), 0.18 * pulse, 0.18 * pulse, 0.35)
    end
    drawCentered(img, x, y, angle or 0, 0.54 * pulse)
end

function Sprites.drawBeacon(x, y, ttl)
    ensure()
    local tm = (love.timer and love.timer.getTime and love.timer.getTime() or 0)
    local pulse = math.sin(tm * 4.8 + x * 0.01) * 0.5 + 0.5
    glowCircle(x, y, 96, {0.18, 0.92, 0.85}, 0.10)
    if Sprites.images.proj_pulse then
        drawCentered(Sprites.images.proj_pulse, x, y, tm * 0.9, 0.50 + pulse * 0.04, 0.50 + pulse * 0.04, 0.22, {0.55, 0.95, 1})
    end
    drawCentered(Sprites.images.beacon, x, y, 0, 0.52 + pulse * 0.03)
    if Sprites.images.energy_orb then
        drawCentered(Sprites.images.energy_orb, x, y, -tm * 0.7, 0.16 + pulse * 0.02, 0.16 + pulse * 0.02, 0.30)
    end
end

function Sprites.drawMine(x, y, armed, progress)
    ensure()
    local tm = (love.timer and love.timer.getTime and love.timer.getTime() or 0)
    local pulse = math.sin(tm * (armed and 9 or 5) + x * 0.01) * 0.5 + 0.5
    glowCircle(x, y, armed and 22 or 18, armed and {1, 0.38, 0.72} or {0.86, 0.42, 1}, armed and 0.12 or 0.08)
    if Sprites.images.proj_pulse then
        drawCentered(Sprites.images.proj_pulse, x, y, -tm * 1.4, (armed and 0.26 or 0.20) + pulse * 0.03, (armed and 0.26 or 0.20) + pulse * 0.03, armed and 0.20 or 0.12, armed and {1, 0.54, 0.78} or {0.84, 0.70, 1})
    end
    drawCentered(Sprites.images.mine, x, y, tm * 0.5, 0.42 + pulse * 0.02)
    if not armed and progress and Sprites.images.energy_orb then
        drawCentered(Sprites.images.energy_orb, x, y, tm, 0.10 + progress * 0.10, 0.10 + progress * 0.10, 0.18 + progress * 0.20, {0.9, 0.8, 1})
    end
end

function Sprites.getBossPortrait(kind)
    ensure()
    return Sprites.images['boss' .. tostring(kind or 1)]
end

return Sprites
