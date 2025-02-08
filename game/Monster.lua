--- @class Monster
Monster = {
}

Monster.__index = Monster
function Monster.new(x,y, level)
    local self = setmetatable({}, Monster)
    if x == nil then
      -- create the monster on a random floor tile
        local monster_tile = Player.current_level:get_tile_at(math.random(2, level.WORLD_Y_TILES - 1) * level.TILE_SIZE, math.random(2, level.WORLD_X_TILES - 1) * level.TILE_SIZE)
        while monster_tile.kind == 0 do
          monster_tile = Player.current_level:get_tile_at(math.random(2, level.WORLD_Y_TILES - 1) * level.TILE_SIZE, math.random(2, level.WORLD_X_TILES - 1) * level.TILE_SIZE)
        end

        self.x = monster_tile.x + level.TILE_SIZE / 2
        self.y = monster_tile.y + level.TILE_SIZE / 2
    else
        self.x = x
        self.y = y
    end
    self.radius = 32
    self.speed = 30
    self.rotation = 0
    self.health = 40
    self.target_tile = nil
    self.last_wandered_tile = nil
    self.moan_timer = math.random(1, 5)

    table.insert(level.monsters, self)

    return self
end

function Monster:draw()
    if Player.current_level:get_tile_at(self.x, self.y).visible then
        love.graphics.push()
        love.graphics.translate(self.x, self.y)
        love.graphics.rotate(self.rotation + math.pi / 2)  -- Rotate the player
        love.graphics.setColor(1, 1, 1)  -- Set color to white (default)
        love.graphics.draw(Textures.monster, -Textures.monster:getWidth() / 2, -Textures.monster:getHeight() / 2)  -- Draw the player centered
        love.graphics.pop()
    end
end


function Monster:collide_with_walls(dt)
    local monster_tile = Player.current_level:get_tile_at(self.x, self.y)
    if monster_tile.kind == 0 then
        pushCircleOut(self, { x = monster_tile.x + Player.current_level.TILE_SIZE / 2, y = monster_tile.y + Player.current_level.TILE_SIZE / 2, radius = Player.current_level.TILE_SIZE / 2 }, dt)
    end
end

function Monster:moan(dt)
    self.moan_timer = self.moan_timer - dt
    if self.moan_timer < 0 then
        self.moan_timer = math.random(1, 5)
        local distance_to_player = distance(self.x, self.y, Player.x, Player.y)
        if distance_to_player < 500 then
            Sounds.claimed_moan:play()
        end
    end
end


function Monster:wander(dt)
    local m = self
    local distance_to_player = distance(m.x, m.y, Player.x, Player.y)
    if distance_to_player < 100 then
        -- directly move to player without tiles
        m.target_tile = nil
        local dx = Player.x - m.x
        local dy = Player.y - m.y
        m.rotation = math.atan2(dy, dx)
        local magnitude = math.sqrt(dx ^ 2 + dy ^ 2)
        if magnitude > 0 then
            dx = dx / magnitude
            dy = dy / magnitude
        end
        m.x = m.x + dx * m.speed * dt
        m.y = m.y + dy * m.speed * dt

    else

        if m.target_tile == nil then
            local tiles = Player.current_level:get_tiles_around(m.x, m.y)
            local wander_tile = tiles[math.random(1, #tiles)]
            while wander_tile.kind == 0 or wander_tile == m.last_wandered_tile do
                wander_tile = tiles[math.random(1, #tiles)]
            end
            m.target_tile = wander_tile
            m.last_wandered_tile = wander_tile
        end

        if m.target_tile == Player.current_level:get_tile_at(m.x, m.y) then
            m.target_tile = nil
        end

        if m.target_tile then
            local dx = (m.target_tile.x + Player.current_level.TILE_SIZE / 2) - m.x
            local dy = (m.target_tile.y + Player.current_level.TILE_SIZE / 2) - m.y
            m.rotation = math.atan2(dy, dx)
            local magnitude = math.sqrt(dx ^ 2 + dy ^ 2)
            if magnitude > 0 then
                dx = dx / magnitude
                dy = dy / magnitude
            end
            m.x = m.x + dx * m.speed * dt
            m.y = m.y + dy * m.speed * dt
        end
    end
end


function Monster:degrade_player_health(dt)
    local m = self
    if distance(m.x, m.y, Player.x, Player.y) < m.radius - 6 then
        Player.health = Player.health - 10 * dt
        Player.sanity = Player.sanity - 15 * dt
        print("Player health took damage: " .. Player.health)
    end
    if distance(m.x, m.y, Player.x, Player.y) < 300 then
        Player.sanity = Player.sanity - (0.2 * dt)
    end
end


function Monster:target_player()
    local m = self
    -- if we are visible, then target the player -> smart as code
    if Player.current_level:get_tile_at(m.x, m.y).visible then
        -- add some small advantage to the player: monster dont see as far as the player
        local bresenham_line_to_player = bresenham_line(Player.current_level:get_tile_at(m.x, m.y), Player.current_level:get_tile_at(Player.x, Player.y))
        local distance_in_tiles = #bresenham_line_to_player
        if distance_in_tiles < 5 then
            m.target_tile = Player.current_level:get_tile_at(Player.x, Player.y)
        end
    end
end

function Monster.point_hit_monster(x, y)
    -- todo: LEVEL is a very bad global variable here ...
    for _, m in ipairs(LEVEL.monsters) do
        if distance(m.x, m.y, x, y) < m.radius then
            return m
        end
    end
    return nil
end

function Monster:take_damage(damage)
    self.health = self.health - damage
    if self.health <= 0 then
        self:delete()
        -- increase sanity of player when monster dies
        Player.sanity = Player.sanity + 10
        if Player.sanity > Player.max_sanity then
            Player.sanity = Player.max_sanity
        end
    end
end

function Monster:delete()
    -- todo: LEVEL is a very bad global variable here ...
    for i, m in ipairs(LEVEL.monsters) do
        if m == self then
            table.remove(LEVEL.monsters, i)
            return
        end
    end
end

function Monster:to_csv_string()
    return self.x .. "," .. self.y .. "\n"
end

function Monster.from_csv_line(line, level)
    if line == "" then return end
    local parts = split(line, ",")
    local x = tonumber(parts[1])
    local y = tonumber(parts[2])
    return Monster.new(x, y, level)
end