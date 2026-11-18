local Effects = require("effects")
local Sprites = require("sprites")
local Audio = require("audio")
local Bosses = require("bosses")

local World = {
    crystals = {}, hazards = {}, coins = {}, powerups = {}, beacons = {}, mines = {}, boss = nil,
    spawnTimer = 0, bossCrystalTimer = 0, visualTime = 0,
    score = 0, coinsCount = 0, combo = 0, comboTimer = 0,
    level = 1, levelProgress = 0, levelTargetScore = 400,
    maxHazards = 8, maxCrystals = 6, isVictory = false, tutorialMode = false
}

local function distanceSq(ax, ay, bx, by)
    local dx, dy = ax - bx, ay - by
    return dx * dx + dy * dy
end

local function crossedCircle(player, x, y, radius)
    local ax, ay = player.prevX or player.x, player.prevY or player.y
    local bx, by = player.x, player.y
    local dx, dy = bx - ax, by - ay
    local lenSq = dx * dx + dy * dy
    local t = 0
    if lenSq > 0 then
        t = math.max(0, math.min(1, ((x - ax) * dx + (y - ay) * dy) / lenSq))
    end
    local cx, cy = ax + dx * t, ay + dy * t
    local hitRadius = (player.radius or 15) + radius
    return distanceSq(cx, cy, x, y) < hitRadius * hitRadius
end

local function spawnPosition(player, minDistance)
    for _ = 1, 16 do
        local x, y = love.math.random(72, 728), love.math.random(130, 507)
        if not player or distanceSq(x, y, player.x, player.y) > minDistance * minDistance then
            return x, y
        end
    end
    return love.math.random(72, 728), love.math.random(130, 507)
end

function World.addCrystal(x, y, golden)
    World.crystals[#World.crystals + 1] = {
        x = x, y = y, vx = 0, vy = 0, radius = 11,
        angle = love.math.random() * math.pi * 2, golden = golden or false
    }
end

function World.reset()
    World.crystals, World.hazards, World.coins, World.powerups, World.beacons, World.mines = {}, {}, {}, {}, {}, {}
    World.boss = nil
    World.spawnTimer, World.bossCrystalTimer, World.visualTime = 0, 0, 0
    World.score, World.coinsCount, World.combo, World.comboTimer = 0, 0, 0, 0
    World.level, World.levelProgress, World.levelTargetScore = 1, 0, 400
    World.isVictory = false
    World.tutorialMode = false
    for _ = 1, 4 do
        local x, y = spawnPosition({x = 400, y = 300}, 110)
        World.addCrystal(x, y, false)
    end
    World.spawnEntity({x = 400, y = 300})
end

function World.addProjectile(x,y,vx,vy,radius,kind)
    if #World.hazards >= 90 then return end
    World.hazards[#World.hazards+1]={x=x,y=y,vx=vx,vy=vy,radius=radius or 9,
        angle=0,vAngle=4,type=kind or 'bolt',scale=0.8,generation=1,
        projectile=true,ttl=5}
end

function World.addEnemy(kind,x,y)
    if #World.hazards>=World.maxHazards+World.level*3+8 then return end
    local hp=kind=='armored' and 3 or 1
    local a=love.math.random()*math.pi*2
    World.hazards[#World.hazards+1]={x=x,y=y,homeX=x,homeY=y,radius=kind=='armored' and 20 or 13,
        vx=math.cos(a)*75,vy=math.sin(a)*75,angle=a,vAngle=love.math.random(-3,3),
        type=kind,scale=1,generation=0,hp=hp,maxHp=hp,attackTimer=love.math.random(),
        state='roam',windup=0,orbit=love.math.random()*math.pi*2}
end

function World.spawnEntity(player)
    if World.boss or World.isVictory then return end
    local x,y=spawnPosition(player,130)
    local roll=love.math.random()
    if #World.crystals<3 or (roll<0.56 and #World.crystals<World.maxCrystals) then
        World.addCrystal(x,y,love.math.random()<0.18)
    elseif roll<0.88 and #World.hazards<World.maxHazards then
        local byLevel={
            {'star','seeker'},
            {'star','seeker','splitter'},
            {'star','seeker','splitter','charger'},
            {'star','seeker','splitter','charger','turret','orbiter'},
            {'star','seeker','splitter','charger','turret','orbiter','leech'},
            {'star','seeker','splitter','charger','turret','orbiter','leech','armored'}
        }
        local pool=byLevel[math.min(#byLevel,World.level)] or byLevel[#byLevel]
        local kind=pool[love.math.random(1,#pool)]
        World.addEnemy(kind,x,y)
    elseif #World.powerups<1 then
        World.powerups[#World.powerups+1]={x=x,y=y,radius=12,type=love.math.random()<0.5 and 'shield' or 'surge',angle=0}
    end
end

function World.spawnBoss()
    if World.boss then return end
    World.hazards={};World.crystals={};World.mines={};World.beacons={}
    World.combo,World.comboTimer=0,0
    World.boss=Bosses.create(World.level)
    World.bossCrystalTimer=0
    Effects.addShockwave(400,170,250,140,0.85,0.35,0.9)
    Effects.addText(400,128,'BOSS: '..World.boss.name,1,0.82,0.34)
    Audio.play('boss')
end

function World.defeatBoss(player)
    local b=World.boss
    if not b then return end
    local bx,by=b.x,b.y
    World.boss=nil;World.hazards={}
    World.score=World.score+750*World.level
    World.coinsCount=World.coinsCount+12+World.level*3
    player.energy=math.min(player.maxEnergy,player.energy+45)
    for j=1,24 do
        local a=j*math.pi/12
        Effects.addShard(bx,by,math.cos(a)*love.math.random(120,340),math.sin(a)*love.math.random(120,340),0.8,b.color[1],b.color[2],b.color[3],love.math.random(3,8))
    end
    Effects.addShockwave(bx,by,500,240,1,0.83,0.28)
    Effects.addText(bx,by-40,'+'..(750*World.level)..' PTS',1,0.85,0.3)
    Effects.shake(0.5,10);Audio.play('victory')
    World.isVictory=true
end

function World.onPulse(player,radius)
    Bosses.onPulse(World,player,radius)
end

function World.damageBoss(player,damage,source)
    return Bosses.damage(World,player,damage,source)
end

local function updateCrystals(dt, player)
    local magnetRadius = 175 + player.magnetUpgrade * 60
    for i = #World.crystals, 1, -1 do
        local crystal = World.crystals[i]
        crystal.angle = crystal.angle + dt * 1.65
        local dx, dy = player.x - crystal.x, player.y - crystal.y
        local distance = math.sqrt(dx * dx + dy * dy)
        if (player.polarity == -1 and distance < magnetRadius or distance < 65) and distance > 1 then
            local accel = player.polarity == -1 and 890 or 450
            crystal.vx = crystal.vx + dx / distance * accel * dt
            crystal.vy = crystal.vy + dy / distance * accel * dt
        end
        local damping = math.exp(-5 * dt)
        crystal.vx, crystal.vy = crystal.vx * damping, crystal.vy * damping
        crystal.x = math.max(55, math.min(745, crystal.x + crystal.vx * dt))
        crystal.y = math.max(78, math.min(524, crystal.y + crystal.vy * dt))

        if crossedCircle(player, crystal.x, crystal.y, crystal.radius) then
            World.combo = math.min(World.combo + 1, 12)
            World.comboTimer = 3.2
            local gain = crystal.golden and 30 or 12
            player.energy = math.min(player.maxEnergy, player.energy + gain)
            local earned = 15 * World.combo * (crystal.golden and 2 or 1)
            World.score = World.score + earned
            if not World.boss then
                World.levelProgress = World.levelProgress + (crystal.golden and 30 or 20)
            end
            if love.math.random() < (crystal.golden and 0.8 or 0.42) then
                World.coins[#World.coins + 1] = {
                    x = crystal.x, y = crystal.y, vx = love.math.random(-50, 50),
                    vy = love.math.random(-40, 40), angle = 0, ttl = 15
                }
            end
            Effects.addText(crystal.x, crystal.y - 14, "+" .. earned, 0.25, 0.72, 0.45)
            Effects.addShockwave(crystal.x, crystal.y, 210, 50, 0.22, 0.78, 0.48)
            for _ = 1, 5 do
                local angle = love.math.random() * math.pi * 2
                local speed = love.math.random(80, 180)
                Effects.addShard(crystal.x, crystal.y,
                    math.cos(angle) * speed, math.sin(angle) * speed,
                    0.35, 0.22, 0.78, 0.48, 3)
            end
            table.remove(World.crystals, i)
            Audio.play(crystal.golden and "gold" or "collect")
            if not World.boss and World.levelProgress >= World.levelTargetScore then
                World.spawnBoss()
                return true
            end
        end
    end
    return false
end

local function updateCoins(dt, player)
    for i = #World.coins, 1, -1 do
        local coin = World.coins[i]
        coin.angle = coin.angle + dt * 4
        coin.ttl = (coin.ttl or 15) - dt
        local dx, dy = player.x - coin.x, player.y - coin.y
        local distance = math.sqrt(dx * dx + dy * dy)
        if distance < 105 and distance > 1 then
            coin.vx = (coin.vx or 0) + dx / distance * 900 * dt
            coin.vy = (coin.vy or 0) + dy / distance * 900 * dt
        end
        coin.vx = (coin.vx or 0) * math.exp(-4 * dt)
        coin.vy = (coin.vy or 0) * math.exp(-4 * dt)
        coin.x = coin.x + coin.vx * dt
        coin.y = coin.y + coin.vy * dt
        if crossedCircle(player, coin.x, coin.y, 10) then
            World.coinsCount = World.coinsCount + 1
            Effects.addShockwave(coin.x, coin.y, 180, 35, 0.98, 0.82, 0.2)
            table.remove(World.coins, i)
            Audio.play("coin")
        elseif coin.ttl <= 0 then
            table.remove(World.coins, i)
        end
    end
end

local function updateHazards(dt, player)
    local canDestroy=player.isDashing or player.overdriveTimer>0
    for i=#World.hazards,1,-1 do
        local h=World.hazards[i]
        local dx,dy=player.x-h.x,player.y-h.y
        local d=math.max(1,math.sqrt(dx*dx+dy*dy))
        h.attackTimer=(h.attackTimer or 0)+dt
        if h.type=='seeker' or h.type=='leech' then
            local speed=h.type=='leech' and 75 or 115
            h.vx,h.vy=dx/d*speed,dy/d*speed
        elseif h.type=='turret' then
            h.vx,h.vy=0,0
            if h.attackTimer>2.5 then
                h.attackTimer=0;World.addProjectile(h.x,h.y,dx/d*175,dy/d*175,7,'bolt')
                Effects.addShockwave(h.x,h.y,140,32,1,0.3,0.3)
            end
        elseif h.type=='orbiter' then
            h.orbit=(h.orbit or 0)+dt*2.1
            local tx=h.homeX+math.cos(h.orbit)*65
            local ty=h.homeY+math.sin(h.orbit)*65
            h.vx,h.vy=(tx-h.x)*3,(ty-h.y)*3
        elseif h.type=='charger' then
            if h.state=='roam' and h.attackTimer>2.2 then
                h.state='windup';h.windup=0.65;h.vx,h.vy=0,0
                h.chargeAngle=math.atan2(dy,dx)
            elseif h.state=='windup' then
                h.windup=h.windup-dt
                if h.windup<=0 then
                    h.state='charging';h.chargeTime=0.5
                    h.vx,h.vy=math.cos(h.chargeAngle)*370,math.sin(h.chargeAngle)*370
                end
            elseif h.state=='charging' then
                h.chargeTime=h.chargeTime-dt
                if h.chargeTime<=0 then h.state='roam';h.attackTimer=0;h.vx,h.vy=h.vx*0.2,h.vy*0.2 end
            end
        elseif h.type=='armored' then
            h.vx=h.vx+dx/d*50*dt;h.vy=h.vy+dy/d*50*dt
            local sp=math.sqrt(h.vx*h.vx+h.vy*h.vy)
            if sp>82 then h.vx,h.vy=h.vx/sp*82,h.vy/sp*82 end
        end
        local slow=1
        for _,beacon in ipairs(World.beacons) do
            if distanceSq(h.x,h.y,beacon.x,beacon.y)<125*125 then slow=0.38;break end
        end
        h.x=h.x+(h.vx or 0)*dt*slow;h.y=h.y+(h.vy or 0)*dt*slow
        h.angle=h.angle+(h.vAngle or 0)*dt
        if h.ttl then h.ttl=h.ttl-dt end
        if h.projectile then
            if h.x<36 or h.x>764 or h.y<72 or h.y>530 then h.ttl=0 end
        else
            if h.x<46 then h.x=46;h.vx=math.abs(h.vx) end
            if h.x>754 then h.x=754;h.vx=-math.abs(h.vx) end
            if h.y<124 then h.y=124;h.vy=math.abs(h.vy) end
            if h.y>525 then h.y=525;h.vy=-math.abs(h.vy) end
        end
        local remove=h.ttl and h.ttl<=0
        if not remove and h.projectile and player.counterTimer>0 and distanceSq(h.x,h.y,player.x,player.y)<72*72 then
            remove=true;World.score=World.score+15
            Effects.addShockwave(h.x,h.y,250,48,0.35,0.9,1)
            if World.boss and distanceSq(h.x,h.y,World.boss.x,World.boss.y)<310*310 then
                Bosses.damage(World,player,3,'counter')
                if World.isVictory then return end
            end
        end
        if not remove and crossedCircle(player,h.x,h.y,h.radius) then
            if canDestroy and not h.projectile then
                h.hp=(h.hp or 1)-(player.isDashing and 2 or 1)
                if h.hp<=0 then
                    remove=true;World.score=World.score+60
                    Effects.addShockwave(h.x,h.y,250,60,0.95,0.55,0.15)
                    for _=1,6 do
                        local a=love.math.random()*math.pi*2
                        local speed=love.math.random(80,200)
                        Effects.addShard(h.x,h.y,math.cos(a)*speed,math.sin(a)*speed,0.45,1,0.44,0.2,4)
                    end
                    if h.type=='splitter' and h.generation==0 then
                        for j=1,2 do
                            local dir=j==1 and -1 or 1
                            World.hazards[#World.hazards+1]={x=h.x+dir*13,y=h.y,radius=8,vx=dir*110,vy=-70,
                                angle=0,vAngle=5,type='star',scale=0.6,generation=1,hp=1}
                        end
                    end
                    if love.math.random()<0.18 then World.addCrystal(h.x,h.y,false) end
                else
                    h.vx,h.vy=-h.vx*0.5,-h.vy*0.5
                    Effects.addText(h.x,h.y-20,'ARMADURA '..h.hp,1,0.7,0.3)
                end
                Audio.play('hit')
            elseif canDestroy and h.projectile then remove=true
            else
                local damage=h.type=='leech' and 12 or (h.projectile and 16 or 25)
                local hit=player.takeHit(damage)
                if hit=='damage' then Audio.play('hurt') elseif hit=='shield' then Audio.play('shield') end
                if hit~='immune' or h.projectile then remove=true end
            end
        end
        if remove then table.remove(World.hazards,i) end
    end
end

local function updateDevices(dt,player)
    for i=#World.beacons,1,-1 do
        local b=World.beacons[i];b.ttl=b.ttl-dt
        for _,c in ipairs(World.crystals) do
            local dx,dy=b.x-c.x,b.y-c.y;local d=math.sqrt(dx*dx+dy*dy)
            if d>3 and d<185 then c.vx=c.vx+dx/d*420*dt;c.vy=c.vy+dy/d*420*dt end
        end
        if b.ttl<=0 then table.remove(World.beacons,i) end
    end
    for i=#World.mines,1,-1 do
        local m=World.mines[i];m.ttl=m.ttl-dt;m.armed=m.armed-dt
        local trigger=m.ttl<=0
        if m.armed<=0 then
            for _,h in ipairs(World.hazards) do
                if distanceSq(m.x,m.y,h.x,h.y)<65*65 then trigger=true;break end
            end
            if World.boss and distanceSq(m.x,m.y,World.boss.x,World.boss.y)<75*75 then trigger=true end
        end
        if trigger then
            Effects.addShockwave(m.x,m.y,360,115,0.85,0.48,1)
            for j=#World.hazards,1,-1 do
                local h=World.hazards[j]
                if distanceSq(m.x,m.y,h.x,h.y)<112*112 then
                    h.hp=(h.hp or 1)-2
                    if h.hp<=0 then table.remove(World.hazards,j);World.score=World.score+35 end
                end
            end
            if World.boss and distanceSq(m.x,m.y,World.boss.x,World.boss.y)<125*125 then
                Bosses.damage(World,player,5,'mine')
            end
            table.remove(World.mines,i);Audio.play('pulse')
        end
    end
end

local function updatePowerups(dt, player)
    for i = #World.powerups, 1, -1 do
        local item = World.powerups[i]
        item.angle = item.angle + dt * 2.3
        if crossedCircle(player, item.x, item.y, item.radius) then
            if item.type == "shield" then
                player.hasShield = true
                Effects.addText(item.x, item.y - 18, "ESCUDO", 0.25, 0.72, 0.55)
            else
                player.energy = player.maxEnergy
                Effects.addText(item.x, item.y - 18, "ENERGIA MAX.", 0.95, 0.55, 0.15)
            end
            World.score = World.score + 35
            Effects.addShockwave(item.x, item.y, 190, 60, 0.25, 0.72, 0.55)
            table.remove(World.powerups, i)
            Audio.play("powerup")
        end
    end
end

function World.update(dt,player)
    if World.isVictory then return end
    World.visualTime=World.visualTime+dt
    World.comboTimer=math.max(0,World.comboTimer-dt)
    if World.comboTimer<=0 then World.combo=0 end
    if World.boss then
        Bosses.update(World,dt,player)
        if World.isVictory then return end
        World.bossCrystalTimer=World.bossCrystalTimer+dt
        if World.bossCrystalTimer>=1.9 and #World.crystals<7 then
            World.bossCrystalTimer=0
            local x,y=spawnPosition(player,110)
            World.addCrystal(x,y,love.math.random()<0.33)
        end
    elseif not World.tutorialMode then
        World.spawnTimer=World.spawnTimer+dt
        if World.spawnTimer>=1.25 then
            World.spawnTimer=World.spawnTimer-1.25
            World.spawnEntity(player)
        end
    end
    if updateCrystals(dt,player) then return end
    updateCoins(dt,player)
    updateHazards(dt,player)
    if World.isVictory then return end
    updateDevices(dt,player)
    updatePowerups(dt,player)
end

function World.draw()
    for _,b in ipairs(World.beacons) do
        Sprites.drawBeacon(b.x, b.y, b.ttl)
    end
    for _,m in ipairs(World.mines) do
        local armed = (m.armed or 0) <= 0
        local progress = armed and 1 or (1 - math.max(0, m.armed or 0) / 0.45)
        Sprites.drawMine(m.x, m.y, armed, progress)
    end
    for _,c in ipairs(World.crystals) do
        local scale=1+0.06*math.sin(World.visualTime*3+c.angle)
        Sprites.drawCrystal(c.x,c.y,c.angle,scale,c.golden)
    end
    for _,c in ipairs(World.coins) do Sprites.drawCoin(c.x,c.y,c.angle) end
    for _,h in ipairs(World.hazards) do
        Sprites.drawHazard(h.x,h.y,h.angle,h.scale,h.type,h.hp,h.maxHp,h.state,h.windup)
    end
    for _,p in ipairs(World.powerups) do Sprites.drawPowerup(p.x,p.y,p.angle,p.type) end
    if World.boss then Bosses.draw(World) end
end
return World
