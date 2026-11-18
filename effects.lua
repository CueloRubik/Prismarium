local Effects = {}
local shards, shockwaves, texts = {}, {}, {}
local shakeTime, shakePower = 0, 0

function Effects.reset()
    shards, shockwaves, texts = {}, {}, {}
    shakeTime, shakePower = 0, 0
end

function Effects.shake(duration, power)
    shakeTime = math.max(shakeTime, duration or 0)
    shakePower = math.max(shakePower, power or 4)
end

function Effects.addShard(x, y, vx, vy, life, r, g, b, size)
    if #shards >= 90 then table.remove(shards, 1) end
    shards[#shards + 1] = {
        x = x, y = y, vx = vx, vy = vy,
        life = life, maxLife = life,
        r = r, g = g, b = b, size = size or 5,
        angle = love.math.random() * math.pi * 2,
        vAngle = love.math.random(-12, 12)
    }
end

function Effects.addShockwave(x, y, speed, maxR, r, g, b)
    if #shockwaves >= 20 then table.remove(shockwaves, 1) end
    shockwaves[#shockwaves + 1] = {
        x = x, y = y, radius = 6,
        maxR = maxR or 80, speed = speed or 220,
        r = r, g = g, b = b
    }
end

function Effects.addText(x, y, value, r, g, b)
    if #texts >= 22 then table.remove(texts, 1) end
    texts[#texts + 1] = {
        x = x, y = y, value = tostring(value),
        life = 0.9, r = r or 0.2, g = g or 0.2, b = b or 0.2,
        wobble = love.math.random() * math.pi * 2,
        scale = 1 + love.math.random() * 0.12
    }
end

function Effects.update(dt)
    shakeTime = math.max(0, shakeTime - dt)
    if shakeTime == 0 then shakePower = 0 end

    for i = #shockwaves, 1, -1 do
        local wave = shockwaves[i]
        wave.radius = wave.radius + wave.speed * dt
        if wave.radius >= wave.maxR then table.remove(shockwaves, i) end
    end
    for i = #shards, 1, -1 do
        local shard = shards[i]
        shard.x = shard.x + shard.vx * dt
        shard.y = shard.y + shard.vy * dt
        local damping = math.exp(-6 * dt)
        shard.vx, shard.vy = shard.vx * damping, shard.vy * damping
        shard.angle = shard.angle + shard.vAngle * dt
        shard.life = shard.life - dt
        if shard.life <= 0 then table.remove(shards, i) end
    end
    for i = #texts, 1, -1 do
        local txt = texts[i]
        txt.life = txt.life - dt
        txt.y = txt.y - 26 * dt
        txt.wobble = (txt.wobble or 0) + dt * 7
        txt.x = txt.x + math.sin(txt.wobble) * 8 * dt
        if txt.life <= 0 then table.remove(texts, i) end
    end
end

function Effects.applyCamera()
    if shakeTime > 0 then
        love.graphics.translate(
            (love.math.random() * 2 - 1) * shakePower,
            (love.math.random() * 2 - 1) * shakePower
        )
    end
end

function Effects.draw()
    for _,wave in ipairs(shockwaves) do
        local alpha=math.max(0,1-wave.radius/wave.maxR)
        love.graphics.setColor(wave.r,wave.g,wave.b,alpha*0.08)
        love.graphics.circle('fill',wave.x,wave.y,wave.radius + 8)
        love.graphics.setColor(wave.r,wave.g,wave.b,alpha*0.12)
        love.graphics.circle('fill',wave.x,wave.y,wave.radius)
        love.graphics.setColor(wave.r,wave.g,wave.b,alpha*0.65)
        love.graphics.setLineWidth(3)
        love.graphics.circle('line',wave.x,wave.y,wave.radius)
        love.graphics.setColor(1,1,1,alpha*0.34)
        love.graphics.setLineWidth(1.2)
        love.graphics.circle('line',wave.x,wave.y,math.max(1,wave.radius-5))
        love.graphics.setColor(wave.r*0.9+0.1,wave.g*0.9+0.1,wave.b*0.9+0.1,alpha*0.4)
        love.graphics.circle('line',wave.x,wave.y,math.max(1,wave.radius+6))
        for i=1,10 do
            local a=i*math.pi/5+wave.radius*0.008
            love.graphics.setColor(wave.r,wave.g,wave.b,alpha*(0.18 + 0.3*(i%2)))
            love.graphics.line(wave.x+math.cos(a)*(wave.radius+3),wave.y+math.sin(a)*(wave.radius+3),
                wave.x+math.cos(a)*(wave.radius+11),wave.y+math.sin(a)*(wave.radius+11))
        end
    end
    for _, shard in ipairs(shards) do
        local alpha = math.max(0, shard.life / shard.maxLife)
        love.graphics.push()
        love.graphics.translate(shard.x, shard.y)
        love.graphics.rotate(shard.angle)
        love.graphics.setColor(shard.r, shard.g, shard.b, alpha*0.18)
        love.graphics.circle('fill',0,0,shard.size*2.6)
        love.graphics.setColor(1,1,1, alpha*0.08)
        love.graphics.circle('fill',0,0,shard.size*1.15)
        love.graphics.setColor(shard.r, shard.g, shard.b, alpha)
        love.graphics.polygon("fill", 0, -shard.size,
            shard.size * 0.7, shard.size, -shard.size * 0.7, shard.size)
        love.graphics.setColor(1,1,1, alpha*0.55)
        love.graphics.line(0,-shard.size*0.75,0,shard.size*0.6)
        love.graphics.pop()
    end
    for _, txt in ipairs(texts) do
        local alpha = math.min(1, txt.life * 1.7)
        local font = love.graphics.getFont()
        local width = font:getWidth(txt.value)
        love.graphics.setColor(0.02,0.04,0.08,alpha*0.55)
        love.graphics.print(txt.value, txt.x - width / 2 + 1, txt.y + 2, 0, txt.scale or 1, txt.scale or 1)
        love.graphics.setColor(txt.r, txt.g, txt.b, alpha)
        love.graphics.print(txt.value, txt.x - width / 2, txt.y, 0, txt.scale or 1, txt.scale or 1)
    end
end

return Effects
