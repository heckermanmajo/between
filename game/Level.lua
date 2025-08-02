---------------------------------------------------------------------------------------------
--- @class Level Contains all state EXCEPT the player state; Level: Created from a raw maze into a game level.
--- @field sprites table<number, Sprite> Sprites in the level
--- @field monsters table<number, Monster> Monsters in the level
--- @field items table<number, Item> Items in the level
--- @field tileSize number Size of a tile
--- @field WORLD_X_TILES number Number of tiles in the x direction
--- @field WORLD_Y_TILES number Number of tiles in the y direction
--- @field WORLD_X_PIXELS number Number of pixels in the x direction
--- @field WORLD_Y_PIXELS number Number of pixels in the y direction
--- @field maze table<number, table<number, Cell>> The maze
--- @field raw_maze table<number, table<number, number>> The raw maze
--- @field objects
--- @field id string The id of the level
--- @field my_path string The path of the level
--- @field current_level Level The current level
------------------------------------------------------------------------------------------------
Level = {
    TILE_SIZE = 64,
    current_level = nil
}
Level.__index = Level

---------------------------------------------------------------------------------------------
--- Create a new level from a raw maze.
--- region Level.new
--- @param size_in_tiles number The size of the maze in tiles
--- @param max_rooms number The maximum number of rooms
--- @param room_min_size number The minimum size of a room
--- @param room_max_size number The maximum size of a room
--- @return Level
---------------------------------------------------------------------------------------------
function Level.new(size_in_tiles, max_rooms, room_min_size, room_max_size)

    local self = setmetatable({}, Level)
    self.tileSize = Level.TILE_SIZE
    self.WORLD_X_TILES = size_in_tiles
    self.WORLD_Y_TILES = size_in_tiles

    local max = 9999999999
    self.id = math.random(0, max) .. "_this"
    self.my_path = "game/savegame/" .. self.id
    self.raw_maze = Maze.generate_a_maze(size_in_tiles, size_in_tiles, max_rooms, room_min_size, room_max_size)
    assert(self.raw_maze, "could not generate maze")
    print(#self.raw_maze)
    self.raw_maze = Maze.raw_maze_post_processing(self.raw_maze, 20)

    -- make maze to level
    -- convert mace of number into mace of tables {kind = number}
    do
        local maze_table = {}
        for y, row in ipairs(self.raw_maze) do
            maze_table[y] = {}
            for x, cell in ipairs(row) do
                maze_table[y][x] = {
                    kind = cell,
                    x_index = x,
                    y_index = y,
                    x = (x - 1) * self.TILE_SIZE,
                    y = (y - 1) * self.TILE_SIZE,
                    visible = false,
                }
            end
        end
        self.maze = maze_table
    end

    --- all border tiles are walls; WITTHOUT CHANGE EXISTING MAZE -> create a new one
    local new_maze = {}
    local new_x_size = self.WORLD_X_TILES + 2
    local new_y_size = self.WORLD_Y_TILES + 2
    self.WORLD_Y_TILES = self.WORLD_Y_TILES + 2
    self.WORLD_X_TILES = self.WORLD_X_TILES + 2
    self.WORLD_X_PIXELS = self.WORLD_X_TILES * self.TILE_SIZE
    self.WORLD_Y_PIXELS = self.WORLD_Y_TILES * self.TILE_SIZE
    for y = 1, new_y_size do
        new_maze[y] = {}
        for x = 1, new_x_size do
            if y == 1 or y == new_y_size or x == 1 or x == new_x_size then
                new_maze[y][x] = Cell.new(
                    0,
                    x,
                    y,
                    (x - 1) * self.TILE_SIZE,
                    (y - 1) * self.TILE_SIZE,
                    false,
                    ""
                )
            else
                local row = self.maze[y - 1]
                if row then
                    local old = self.maze[y - 1][x - 1]
                    if old then
                        -- todo: why do we need this check?
                        new_maze[y][x] = Cell.new(
                            old.kind, -- preserve the old kind
                            x,
                            y,
                            (x - 1) * self.TILE_SIZE,
                            (y - 1) * self.TILE_SIZE,
                            false,
                            ""
                        )
                    end
                else
                    print("row is nil in maze uin Level.new: " .. y)
                end
            end
        end
    end

    self.maze = new_maze

    --- Add a random doorway to the level.
    local function add_random_doorway()

        local random_tile = self:get_random_floor_tile()
        random_tile.is_doorway = true
        random_tile.doorway_to = "" -- setting this to "" makes it generate a new level

    end

    add_random_doorway()
    add_random_doorway()
    add_random_doorway()
    add_random_doorway()
    add_random_doorway()
    add_random_doorway()
    add_random_doorway()
    add_random_doorway()
    add_random_doorway()
    add_random_doorway()
    add_random_doorway()
    add_random_doorway()
    add_random_doorway()
    add_random_doorway()
    add_random_doorway()
    add_random_doorway()
    add_random_doorway()
    add_random_doorway()
    add_random_doorway()
    add_random_doorway()
    add_random_doorway()
    add_random_doorway()

    Level.current_level = self

    self.WORLD_X_PIXELS = size_in_tiles * Level.TILE_SIZE
    self.WORLD_Y_PIXELS = size_in_tiles * Level.TILE_SIZE

    self.objects = {}
    self.sprites = {}
    self.monsters = {}
    self.items = {}

    Monster.new(nil, nil, self)
    Monster.new(nil, nil, self)
    Monster.new(nil, nil, self)
    Monster.new(nil, nil, self)
    Monster.new(nil, nil, self)
    Monster.new(nil, nil, self)
    Monster.new(nil, nil, self)
    Monster.new(nil, nil, self)
    Monster.new(nil, nil, self)
    Monster.new(nil, nil, self)
    Monster.new(nil, nil, self)
    Monster.new(nil, nil, self)

    Item.place_item_on_random_floor_tile("can", self)
    Item.place_item_on_random_floor_tile("can", self)
    Item.place_item_on_random_floor_tile("can", self)
    Item.place_item_on_random_floor_tile("can", self)
    Item.place_item_on_random_floor_tile("can", self)
    Item.place_item_on_random_floor_tile("can", self)
    Item.place_item_on_random_floor_tile("can", self)
    Item.place_item_on_random_floor_tile("can", self)
    Item.place_item_on_random_floor_tile("can", self)
    Item.place_item_on_random_floor_tile("can", self)
    Item.place_item_on_random_floor_tile("can", self)
    Item.place_item_on_random_floor_tile("can", self)
    Item.place_item_on_random_floor_tile("can", self)
    Item.place_item_on_random_floor_tile("can", self)
    Item.place_item_on_random_floor_tile("can", self)
    Item.place_item_on_random_floor_tile("can", self)
    Item.place_item_on_random_floor_tile("can", self)
    Item.place_item_on_random_floor_tile("can", self)
    Item.place_item_on_random_floor_tile("can", self)
    Item.place_item_on_random_floor_tile("can", self)
    Item.place_item_on_random_floor_tile("can", self)
    Item.place_item_on_random_floor_tile("can", self)
    Item.place_item_on_random_floor_tile("can", self)
    Item.place_item_on_random_floor_tile("can", self)
    Item.place_item_on_random_floor_tile("can", self)
    Item.place_item_on_random_floor_tile("can", self)
    Item.place_item_on_random_floor_tile("can", self)
    Item.place_item_on_random_floor_tile("can", self)

    for i = 1, 20 do
        Item.place_item_on_random_floor_tile("ammo_9mm", self)
    end

    for i = 1, 20 do
        Item.place_item_on_random_floor_tile("ammo_10mm", self)
    end

    for i = 1, 20 do
        Item.place_item_on_random_floor_tile("ammo_12mm", self)
    end

    for i = 1, 20 do
        Item.place_item_on_random_floor_tile("handgun", self)
    end

    for i = 1, 20 do
        Item.place_item_on_random_floor_tile("shotgun", self)
    end

    for i = 1, 20 do
        Item.place_item_on_random_floor_tile("mp5", self)
    end
    Player.place_player_on_random_tile(self) -- level is also state of the player

    return self
end -- new

-----------------------------------------------------------------------------
--- Update the level. Also updates the player since the player is part of the
--- level while the level is played. The player is basically the changing
--- force of the level.
---
--- Even logic that is not directly related to the player is dependent on the
--- Player state, since its needs knowledge of karma, etc.
---
--- region update
--- @param dt number The delta time
--- @param mode number "editor" or "game"; determines how stuff is updated
-----------------------------------------------------------------------------
function Level:update(dt, mode)

    if mode == editor then
        --region updateEDITOR


        -- todo
    else

        --region updateGAME
        Player:apply_input(dt)
        Player:update_camera(dt)
        Player.passively_decrease_stats(dt)

        if not EDITOR_MODE then
            for _, monster in ipairs(self.monsters) do
                monster:wander(dt)
                monster:collide_with_walls(dt)
                monster:target_player()
                monster:moan(dt)
                monster:degrade_player_health(dt)
            end
        end

        -- collide with walls
        if not EDITOR_MODE then
            for y, row in ipairs(self.maze) do
                for x, cell in ipairs(row) do
                    if cell.kind == 0 then
                        pushCircleOut(Player, { x = (x) * self.TILE_SIZE - (self.TILE_SIZE / 2), y = (y) * self.TILE_SIZE - (self.TILE_SIZE / 2), radius = self.TILE_SIZE / 2 }, dt)
                    end
                end
            end
        end

        -- update visibilty
        local player_tile = self:get_tile_at(Player.x, Player.y)
        for y, row in ipairs(self.maze) do
            for x, cell in ipairs(row) do

                if EDITOR_MODE then
                    cell.visible = true
                else

                    local distance_to_player_tile = distance(player_tile.x_index, player_tile.y_index, x, y)
                    if distance_to_player_tile < 10 then

                        local line = bresenham_line(player_tile, cell)
                        local visible = true
                        for index, point in ipairs(line) do
                            if point.kind == 0 and #line ~= index then
                                visible = false
                                break
                            end
                        end
                        cell.visible = visible
                    else
                        cell.visible = false
                    end
                end

            end
        end
    end

end -- update



-----------------------------------------------------------------------------
--- Draw the level -> makes heavy use of the Player-table, since drawing is
--- relative to the player.
---
--- region draw
--- @param mode number "editor" or "game"; determines how stuff is drawn
-----------------------------------------------------------------------------
function Level:draw(mode)
    if not Player.inventory_is_open then
        love.mouse.setCursor(Textures.crosshair_cursor, 7, 7)
    end
    if mode == editor then
        --region drawEDITOR
        -- todo
    else
        --region drawGAME
        Player.cam:attach()

        for y, row in ipairs(self.maze) do
            for x, cell in ipairs(row) do
                cell:draw()
                --if cell.kind == 0 then
                --  love.graphics.setColor(1, 1, 1)
                -- love.graphics.draw(Textures.wall, (x - 1) * tileSize, (y - 1) * tileSize)
                --else
                --  love.graphics.setColor(1, 1, 1)
                --  love.graphics.draw(Textures.floor, (x - 1) * tileSize, (y - 1) * tileSize)
                --end
            end
        end

        -- draw all collision circles
        if DEBUG then
            love.graphics.setColor(1, 0, 0)
            love.graphics.circle("line", Player.x, Player.y, Player.radius)


            -- draw collision circles for walls
            for y, row in ipairs(self.maze) do
                for x, cell in ipairs(row) do
                    if cell.kind == 0 then
                        love.graphics.setColor(0, 1, 0)
                        love.graphics.circle("line", (x) * self.TILE_SIZE - (self.TILE_SIZE / 2), (y) * self.TILE_SIZE - (self.TILE_SIZE / 2), self.TILE_SIZE / 2)
                    end
                end
            end

        end

        -- draw  a gray over lay if not visible
        for y, row in ipairs(self.maze) do
            for x, cell in ipairs(row) do
                if not cell.visible then
                    love.graphics.setColor(0.5, 0.5, 0.5, 0.5)
                    if DEBUG then
                        love.graphics.setColor(0.5, 0.5, 1, 0.5)
                    else
                        love.graphics.setColor(0, 0, 0, 1)
                    end
                    love.graphics.rectangle("fill", (x - 1) * self.TILE_SIZE, (y - 1) * self.TILE_SIZE, self.TILE_SIZE, self.TILE_SIZE)
                end
            end
        end

        -- draw the bresenham_line from player to mouse
        if DEBUG then
            local mouseX, mouseY = love.mouse.getX(), love.mouse.getY()
            mouseX, mouseY = Player.cam:transform_screen_xy_to_world_xy(mouseX, mouseY)
            local startTile = self:get_tile_at(Player.x, Player.y)
            local endTile = self:get_tile_at(mouseX, mouseY)
            if startTile and endTile then
                local line = bresenham_line(startTile, endTile)
                love.graphics.setColor(1, 0, 0)
                for _, point in ipairs(line) do
                    love.graphics.circle("fill", point.x + self.TILE_SIZE / 2, point.y + self.TILE_SIZE / 2, 5)
                end
            end
        end

        if DEBUG then
            -- draw a yellow circle on the tile the player is on
            love.graphics.setColor(1, 1, 0)
            local player_tile = self:get_tile_at(Player.x, Player.y)
            love.graphics.circle("fill", (player_tile.x_index - 1) * self.TILE_SIZE + self.TILE_SIZE / 2, (player_tile.y_index - 1) * self.TILE_SIZE + self.TILE_SIZE / 2, self.TILE_SIZE / 4)
        end

        -- draw the player
        for _, sprite in ipairs(self.sprites) do sprite:draw() end
        Player:draw()
        for _, monster in ipairs(self.monsters) do monster:draw() end
        for _, item in ipairs(self.items) do item:draw() end

        Player.cam:detach()

        Player.draw_ui()

        do

            for _, item in ipairs(self.items) do
                local real_world_x, real_world_y = Player.x, Player.y
                local min_distance = item.texture:getWidth() / 2
                if min_distance < 20 then min_distance = 20 end
                if distance(item.x, item.y, real_world_x, real_world_y) < min_distance then
                    -- display press f to pick up as text
                    love.graphics.setColor(1, 1, 1)
                    love.graphics.print("Press 'f' to pick up", love.graphics.getWidth() / 2, love.graphics.getHeight() / 2)
                    if love.keyboard.isDown("f") then
                        -- add item to player inventory and remove it from the level
                        item:add_to_player_inventory()
                        return
                    end
                    return
                end
            end

        end


    end

end -- draw



-----------------------------------------------------------------------------
--- Returns a random floor tile that is als a doorway but has not been defined yet.
--- Means the player has not passed through it yet : so it its target is still ""
--- @return Cell
-----------------------------------------------------------------------------
function Level:get_undefined_door_cell()

    local all_undefined_doorways = {}
    for y, row in ipairs(self.maze) do
        for x, cell in ipairs(row) do
            if cell.is_doorway and cell.doorway_to == "" then
                table.insert(all_undefined_doorways, cell)
            end
        end
    end

    if #all_undefined_doorways == 0 then
        return nil
    end

    local random_index = math.random(1, #all_undefined_doorways)
    return all_undefined_doorways[random_index]

end -- get_undefined_door_cell



-----------------------------------------------------------------------------
--- Get the tile at a given position
--- region get_tile_at
--- @param x number The x-coordinate
--- @param y number The y-coordinate
--- @return table<number, number> The tile at the given position
-----------------------------------------------------------------------------
function Level:get_tile_at(x, y)
    local row = self.maze[math.floor(y / self.TILE_SIZE) + 1]
    if not row then return nil end
    return row[math.floor(x / self.TILE_SIZE) + 1]
end

-----------------------------------------------------------------------------
--- Get the tiles around a given position
--- region get_tiles_around
--- @param x number The x-coordinate
--- @param y number The y-coordinate
--- @return table<number, table<number, number>> The tiles around the given position
-----------------------------------------------------------------------------
function Level:get_tiles_around(x, y)
    local tiles = {}
    for dy = -1, 1 do
        for dx = -1, 1 do
            local tile = self:get_tile_at(x + dx * self.TILE_SIZE, y + dy * self.TILE_SIZE)
            if tile then
                table.insert(tiles, tile)
            end
        end
    end
    return tiles
end

---------------------------------------------------------------------------------------------
--- Create level from a template file.
---------------------------------------------------------------------------------------------
function Level.new_level_from_templates()
    -- determine what level to clone
    local max = #LEVEL_TEMPLATES
    local random_index = math.random(1, max)
    local template = LEVEL_TEMPLATES[random_index]
    local name = template.file_name
    local path = "game/level_templates"
    local level = Level.from_file(name, path)
    level.id = math.random(0, 9999999999) .. "_this"
    level.my_path = "game/savegame/" .. level.id
    return level
end

function Level:get_random_floor_tile()
    local x = math.random(2, self.WORLD_Y_TILES - 1) * self.TILE_SIZE
    local y = math.random(2, self.WORLD_X_TILES - 1) * self.TILE_SIZE
    self:get_tile_at(x, y)
end