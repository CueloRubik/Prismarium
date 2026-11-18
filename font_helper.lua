local FontHelper = { cache = {} }
local FONT_PATH = 'assets/fonts/rpg.ttf'

function FontHelper.get(size)
    local key = tostring(size)
    if not FontHelper.cache[key] then
        if love.filesystem.getInfo(FONT_PATH) then
            FontHelper.cache[key] = love.graphics.newFont(FONT_PATH, size)
        else
            FontHelper.cache[key] = love.graphics.newFont(size)
        end
    end
    return FontHelper.cache[key]
end

function FontHelper.clear()
    FontHelper.cache = {}
end

return FontHelper
