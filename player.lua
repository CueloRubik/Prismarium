local Effects = require('effects')
local Sprites = require('sprites')
local Progress = require('progression')

local Player = {
    x = 400, y = 300, prevX = 400, prevY = 300,
    vx = 0, vy = 0, angle = 0, radius = 15,
    energy = 100, maxEnergy = 100,
    dashCooldown = 0, dashMaxCooldown = 0.45,
    isDashing = false, dashTimer = 0, dashVx = 0, dashVy = 0,
    hasShield = false, invulnTimer = 0, polarity = 1,
    pulseCooldown = 0, pulseMaxCooldown = 1.4,
    overdriveTimer = 0, overdriveCooldown = 0, overdriveMaxCooldown = 5.5,
    singularityCooldown = 0, singularityMaxCooldown = 4.5,
    speedUpgrade = 0, magnetUpgrade = 0, efficiencyUpgrade = 0,
    afterimages = {}, trailTimer = 0,
    counterCooldown=0, counterTimer=0, beaconCooldown=0, mineCooldown=0, slipperyTimer=0,
    skinStats = nil
}

local function clamp(value, a, b)
    return math.max(a, math.min(b, value))
end

local function stats()
    if not Player.skinStats then Player.skinStats = Progress.getSkinStats(Progress.equippedSkin) end
    return Player.skinStats
end

function Player.reset()
    Player.skinStats = Progress.getSkinStats(Progress.equippedSkin)
    local s = stats()
    Player.x, Player.y = 400, 300
    Player.prevX, Player.prevY = 400, 300
    Player.vx, Player.vy = 0, 0
    Player.dashVx, Player.dashVy = 0, 0
    Player.angle = 0
    Player.energy, Player.maxEnergy = s.maxEnergy, s.maxEnergy
    Player.dashCooldown, Player.dashTimer = 0, 0
    Player.pulseCooldown, Player.singularityCooldown = 0, 0
    Player.overdriveTimer, Player.overdriveCooldown = 0, 0
    Player.isDashing = false
    Player.hasShield, Player.invulnTimer = false, 0
    Player.polarity = 1
    Player.speedUpgrade, Player.magnetUpgrade, Player.efficiencyUpgrade = 0, 0, 0
    Player.afterimages = {}
    Player.trailTimer = 0
    Player.counterCooldown,Player.counterTimer,Player.beaconCooldown,Player.mineCooldown=0,0,0,0
    Player.slipperyTimer=0
end

function Player.isProtected()
    return Player.hasShield or Player.overdriveTimer > 0 or Player.invulnTimer > 0
end

function Player.takeHit(amount)
    if Player.overdriveTimer > 0 or Player.invulnTimer > 0 then return 'immune' end
    if Player.hasShield then
        Player.hasShield = false
        Player.invulnTimer = 0.7
        Effects.addShockwave(Player.x, Player.y, 300, 90, 0.2, 0.75, 0.55)
        return 'shield'
    end
    local reduction = stats().damageReduction or 0
    local real = math.max(1, math.floor(amount * (1 - reduction)))
    Player.energy = clamp(Player.energy - real, 0, Player.maxEnergy)
    Player.invulnTimer = 0.9
    Effects.shake(0.24, 7)
    Effects.addShockwave(Player.x, Player.y, 300, 95, 0.9, 0.25, 0.2)
    Effects.addText(Player.x, Player.y - 24, '-' .. real, 0.9, 0.25, 0.2)
    return 'damage'
end

function Player.triggerPulse(world)
    local s = stats()
    local cost = s.pulseCost or 18
    local radius = s.pulseRadius or 180
    if Player.pulseCooldown > 0 or Player.energy < cost then return false end
    Player.energy = Player.energy - cost
    Player.pulseCooldown = math.max(0.7, Player.pulseMaxCooldown - s.tech * 0.04)
    Effects.addShockwave(Player.x, Player.y, radius * 2.2, radius, 0.95, 0.55, 0.15)
    Effects.shake(0.18, 4)

    local converted = 0
    for i = #world.hazards, 1, -1 do
        local h = world.hazards[i]
        local dx, dy = h.x - Player.x, h.y - Player.y
        if dx * dx + dy * dy <= radius * radius then
            if h.type=='armored' and (h.hp or 1)>1 then
                h.hp=h.hp-1
                Effects.addText(h.x,h.y-22,'ARMADURA ROTA',1,0.7,0.35)
            else
                table.remove(world.hazards, i)
                world.crystals[#world.crystals + 1] = {x = h.x, y = h.y, vx = 0, vy = 0, radius = 11, angle = 0, golden = true}
                converted = converted + 1
            end
        end
    end
    if world.onPulse then world.onPulse(Player,radius) end
    if world.damageBoss and world.boss then world.damageBoss(Player, s.pulseBossDamage or 2, 'pulse') end
    if converted > 0 then Effects.addText(Player.x, Player.y - 32, '+' .. converted .. ' PRISMAS', 0.95, 0.55, 0.15) end
    return true
end

function Player.triggerOverdrive()
    if Player.overdriveCooldown > 0 or Player.energy < 25 then return false end
    Player.energy = Player.energy - 25
    Player.overdriveTimer = 3.5
    Player.overdriveCooldown = Player.overdriveMaxCooldown
    Effects.addShockwave(Player.x, Player.y, 350, 130, 0.92, 0.28, 0.2)
    Effects.shake(0.17, 5)
    return true
end

function Player.triggerSingularity(world)
    if Player.singularityCooldown > 0 or Player.energy < 15 then return false end
    Player.energy = Player.energy - 15
    Player.singularityCooldown = Player.singularityMaxCooldown
    Effects.addShockwave(Player.x, Player.y, 490, 270, 0.25, 0.72, 0.45)
    for _, c in ipairs(world.crystals) do
        local dx, dy = Player.x - c.x, Player.y - c.y
        local dist = math.sqrt(dx * dx + dy * dy)
        if dist > 1 then c.vx = (dx / dist) * 650; c.vy = (dy / dist) * 650 end
    end
    return true
end

function Player.dash(cursorX, cursorY)
    local s = stats()
    local cost = s.dashCost or 10
    if Player.isDashing or Player.dashCooldown > 0 or Player.energy < cost then return false end
    Player.energy = Player.energy - cost
    Player.dashCooldown = math.max(0.20, Player.dashMaxCooldown - s.speed * 0.025)
    Player.isDashing = true
    Player.dashTimer = 0.15
    local dx, dy = cursorX - Player.x, cursorY - Player.y
    local dist = math.sqrt(dx * dx + dy * dy)
    local force = s.dashForce or 1150
    if dist > 5 then
        Player.angle = math.atan2(dy, dx)
        Player.dashVx, Player.dashVy = dx / dist * force, dy / dist * force
    else
        Player.dashVx = math.cos(Player.angle) * force
        Player.dashVy = math.sin(Player.angle) * force
    end
    Effects.addShockwave(Player.x, Player.y, 310, 85, 1, 0.5, 0.1)
    Effects.shake(0.1, 3)
    return true
end

function Player.activateShield()
    if Player.hasShield or Player.energy < 12 then return false end
    Player.energy = Player.energy - 12
    Player.hasShield = true
    Effects.addShockwave(Player.x, Player.y, 250, 70, 0.45, 0.95, 0.85)
    return true
end

function Player.counter()
    if Player.counterCooldown>0 or Player.energy<7 then return false end
    Player.energy=Player.energy-7
    Player.counterCooldown=2.6
    Player.counterTimer=0.33
    Player.invulnTimer=math.max(Player.invulnTimer,0.27)
    Effects.addShockwave(Player.x,Player.y,330,78,0.3,0.9,1)
    return true
end

function Player.deployBeacon(world)
    if Player.beaconCooldown>0 or Player.energy<20 then return false end
    Player.energy=Player.energy-20
    Player.beaconCooldown=9
    world.beacons[#world.beacons+1]={x=Player.x,y=Player.y,ttl=6}
    Effects.addShockwave(Player.x,Player.y,280,95,0.2,0.85,0.8)
    return true
end

function Player.deployMine(world)
    if Player.mineCooldown>0 or Player.energy<17 then return false end
    Player.energy=Player.energy-17
    Player.mineCooldown=5.5
    world.mines[#world.mines+1]={x=Player.x,y=Player.y,ttl=10,armed=0.45}
    Effects.addShockwave(Player.x,Player.y,180,42,0.8,0.4,1)
    return true
end

function Player.update(dt, targetX, targetY)
    local s = stats()
    Player.prevX, Player.prevY = Player.x, Player.y
    Player.dashCooldown = math.max(0, Player.dashCooldown - dt)
    Player.pulseCooldown = math.max(0, Player.pulseCooldown - dt)
    Player.singularityCooldown = math.max(0, Player.singularityCooldown - dt)
    Player.overdriveCooldown = math.max(0, Player.overdriveCooldown - dt)
    Player.overdriveTimer = math.max(0, Player.overdriveTimer - dt)
    Player.invulnTimer = math.max(0, Player.invulnTimer - dt)
    Player.counterCooldown=math.max(0,Player.counterCooldown-dt)
    Player.counterTimer=math.max(0,Player.counterTimer-dt)
    Player.beaconCooldown=math.max(0,Player.beaconCooldown-dt)
    Player.mineCooldown=math.max(0,Player.mineCooldown-dt)
    Player.slipperyTimer=math.max(0,Player.slipperyTimer-dt)

    for i = #Player.afterimages, 1, -1 do
        local img = Player.afterimages[i]
        img.alpha = img.alpha - dt * 4.8
        if img.alpha <= 0 then table.remove(Player.afterimages, i) end
    end

    if Player.isDashing then
        Player.trailTimer = Player.trailTimer - dt
        if Player.trailTimer <= 0 then
            Player.afterimages[#Player.afterimages + 1] = {x = Player.x, y = Player.y, angle = Player.angle, alpha = 0.7}
            Player.trailTimer = 0.025
        end
        Player.x = Player.x + Player.dashVx * dt
        Player.y = Player.y + Player.dashVy * dt
        Player.dashTimer = Player.dashTimer - dt
        if Player.dashTimer <= 0 then
            Player.isDashing = false
            Player.vx, Player.vy = Player.dashVx * 0.18, Player.dashVy * 0.18
        end
    else
        local dx, dy = targetX - Player.x, targetY - Player.y
        local dist = math.sqrt(dx * dx + dy * dy)
        local accel = (s.movement or 280) * 3.2
        if dist > 8 then
            local targetAngle = math.atan2(dy, dx)
            local diff = (targetAngle - Player.angle + math.pi) % (math.pi * 2) - math.pi
            Player.angle = Player.angle + diff * math.min(1, 19 * dt)
            Player.vx = Player.vx + dx / dist * accel * dt
            Player.vy = Player.vy + dy / dist * accel * dt
        end
        local drag = math.exp(-(Player.slipperyTimer>0 and 2.1 or 6.6) * dt)
        Player.vx, Player.vy = Player.vx * drag, Player.vy * drag
        local speed = math.sqrt(Player.vx * Player.vx + Player.vy * Player.vy)
        local maxSpeed = s.movement or 280
        if speed > maxSpeed then Player.vx, Player.vy = Player.vx / speed * maxSpeed, Player.vy / speed * maxSpeed end
        Player.x = Player.x + Player.vx * dt
        Player.y = Player.y + Player.vy * dt
        local drain = math.max(0.7, s.drain or 1.8)
        Player.energy = clamp(Player.energy - drain * dt, 0, Player.maxEnergy)
    end

    if Player.x < 40 then Player.x = 40; Player.vx = math.abs(Player.vx) * 0.25 end
    if Player.x > 760 then Player.x = 760; Player.vx = -math.abs(Player.vx) * 0.25 end
    if Player.y < 121 then Player.y = 121; Player.vy = math.abs(Player.vy) * 0.25 end
    if Player.y > 526 then Player.y = 526; Player.vy = -math.abs(Player.vy) * 0.25 end
end

function Player.draw()
    for _, img in ipairs(Player.afterimages) do
        Sprites.drawAfterimage(img.x,img.y,img.angle,img.alpha,Progress.equippedSkin)
    end
    if Player.invulnTimer > 0 and math.floor(Player.invulnTimer * 14) % 2 == 0 then
        love.graphics.setColor(0.95, 0.55, 0.15, 0.28)
        love.graphics.circle('fill', Player.x, Player.y, 25)
    end
    if Player.counterTimer>0 then
        love.graphics.setColor(0.3,0.95,1,0.4+0.3*math.sin(Player.counterTimer*24)^2)
        love.graphics.setLineWidth(3)
        love.graphics.circle('line',Player.x,Player.y,48)
    end
    local stretch = (Player.isDashing or Player.overdriveTimer > 0) and 1.19 or 1
    Sprites.drawPlayer(Player.x, Player.y, Player.angle, stretch,
        Player.hasShield or Player.overdriveTimer > 0, Player.isDashing,
        1, clamp(Player.energy / Player.maxEnergy, 0, 1), Player.overdriveTimer > 0,
        Progress.equippedSkin, Progress.getSkinLevel(Progress.equippedSkin))
end

return Player
