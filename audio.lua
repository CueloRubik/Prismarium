local Audio = {enabled = true, available = false, samples = {}}

local definitions = {
    collect = {500, 780, 0.11, 0.16},
    gold = {660, 1100, 0.19, 0.21},
    coin = {900, 1120, 0.075, 0.13},
    dash = {360, 175, 0.13, 0.19},
    pulse = {190, 500, 0.22, 0.23},
    singularity = {240, 125, 0.27, 0.23},
    overdrive = {310, 740, 0.35, 0.23},
    hurt = {250, 95, 0.24, 0.3},
    shield = {750, 440, 0.22, 0.2},
    hit = {320, 185, 0.09, 0.19},
    boss = {180, 120, 0.42, 0.3},
    shot = {330, 220, 0.09, 0.12},
    powerup = {430, 960, 0.23, 0.22},
    buy = {700, 940, 0.15, 0.2},
    click = {520, 630, 0.07, 0.10},
    victory = {520, 1040, 0.42, 0.25}
}

function Audio.init()
    if not love.sound or not love.audio then return false end
    local success = pcall(function()
        local rate = 22050
        for name, p in pairs(definitions) do
            local f1, f2, duration, volume = p[1], p[2], p[3], p[4]
            local count = math.floor(rate * duration)
            local sound = love.sound.newSoundData(count, rate, 16, 1)
            for i = 0, count - 1 do
                local t = i / count
                local phase = 2 * math.pi * duration * (f1 * t + (f2 - f1) * t * t * 0.5)
                local envelope = math.sin(math.pi * t) ^ 1.7
                local sample = (math.sin(phase) * 0.85 + math.sin(phase * 2) * 0.15)
                    * envelope * volume
                sound:setSample(i, sample)
            end
            local source = love.audio.newSource(sound, "static")
            Audio.samples[name] = source
        end
    end)
    Audio.available = success
    if not success then Audio.samples = {} end
    return success
end

function Audio.play(name)
    if not Audio.enabled or not Audio.available then return end
    local source = Audio.samples[name]
    if source then
        source:stop()
        source:play()
    end
end

function Audio.toggle()
    Audio.enabled = not Audio.enabled
    if not Audio.enabled and love.audio then love.audio.stop() end
    return Audio.enabled
end

return Audio
