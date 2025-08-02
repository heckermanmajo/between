--- @class Sprite blood stains, dirt, marks like drawings, etc.
Sprite = {}
Sprite.__index = Sprite

function Sprite.new(x, y, type, rotation, scale, level)

    local self = setmetatable({}, Sprite)
    self.x = x
    self.y = y
    self.type = type
    self.rotation = rotation or 0
    self.scale = scale or 1
    self.texture = Textures[type]

    table.insert(level.sprites, self)
    return self

end

function Sprite:draw()
    love.graphics.setColor(1, 1, 1)
    local tile = Level.current_level:get_tile_at(self.x, self.y)
    if tile.visible then
        love.graphics.draw(
            self.texture,
            self.x - self.texture:getWidth() / 2,
            self.y - self.texture:getHeight() / 2,
            self.rotation,
            self.scale,
            self.scale
        )
    end
end

function Sprite:to_csv_string()
    return self.x .. "," .. self.y .. "," .. self.type .. "," .. self.rotation .. "," .. self.scale .. "\n"
end

function Sprite.from_csv_line(line, level)
    if line == "" then return nil end
    local parts = split(line, ",")
    local x = tonumber(parts[1])
    local y = tonumber(parts[2])
    local type = parts[3]
    local rotation = tonumber(parts[4])
    local scale = tonumber(parts[5])
    return Sprite.new(x, y, type, rotation, scale, level)
end