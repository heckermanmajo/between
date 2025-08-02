--[[

LOAD ANS SAVE LEVELS

-> Levels are saved as csv files with the id of the level as the name of the file.
-> the csv files are separated into different parts: cells, items, monsters, objects, sprites
-> those parts are separated by a special string: "####################################\n"
-> The player position is NOT saved into the level file.


]]

--- @type string This is used to separate the different parts of the level in the csv file: cells, items, monsters, objects, sprites
CSV_SEPERATOR = "####################################\n"

-----------------------------------------------------------------------------
--- Load a level from a file
--- region from_file
--- @param level_name string The name of the level file
-----------------------------------------------------------------------------
function Level.from_file(level_name, load_path)

    -- the level is saved as one big csv file with separators

    load_path = load_path or SAVE_PATH
    local path = load_path .. "/" .. level_name

    local file = io.open(path, "r")
    local content = file:read("*all")

    -- split on seperators "####################################"
    local parts = split(content, CSV_SEPERATOR)
    -- !!!order is SUPER important
    local LEVEL_META_DATA = 1
    local CELLS = 2
    local ITEMS = 3
    local MONSTERS = 4
    local OBJECTS = 5
    local SPRITES = 6

    local meta_data = parts[LEVEL_META_DATA]
    local meta_data_parts = split(meta_data, ",")
    local level_id = meta_data_parts[1]
    local WORLD_X_TILES = tonumber(meta_data_parts[2])
    local WORLD_Y_TILES = tonumber(meta_data_parts[3])

    local self = setmetatable({}, Level)
    self.my_path = path
    self.tileSize = Level.TILE_SIZE
    self.WORLD_X_TILES = WORLD_X_TILES
    self.WORLD_Y_TILES = WORLD_Y_TILES
    self.WORLD_X_PIXELS = WORLD_X_TILES * Level.TILE_SIZE
    self.WORLD_Y_PIXELS = WORLD_Y_TILES * Level.TILE_SIZE
    self.id = level_id
    self.objects = {}
    self.sprites = {}
    self.monsters = {}
    self.items = {}
    self.objects = {}

    -- check for enough parts
    if #parts < 5 then
        print("not enough parts in level file")
        return
    end

    -- load the cells of the maze
    do
        local cells = parts[CELLS]
        local cells_as_table = split(cells, "\n")
        print(#cells_as_table)
        --os.exit()
        local maze = {}
        for _, cell in ipairs(cells_as_table) do
            if cell ~= "" then
                local real_cell = Cell.from_csv_line(cell)
                local x_index = real_cell.x_index
                local y_index = real_cell.y_index
                if x_index == nil or y_index == nil then
                    print("could not load cell: " .. cell)
                    os.exit()
                end
                if x_index > self.WORLD_X_TILES or y_index > self.WORLD_Y_TILES then
                    print("cell out of bounds: " .. x_index .. " " .. y_index)
                    os.exit()
                end
                if x_index < 1 or y_index < 1 then
                    print("cell out of bounds: " .. x_index .. " " .. y_index)
                    os.exit()
                end
                maze[y_index] = maze[y_index] or {}
                maze[y_index][x_index] = real_cell
            end
        end
        self.maze = maze
    end

    -- load monsters
    do
        local monsters = parts[MONSTERS]
        local monsters_as_table = split(monsters, "\n")
        for _, monster_line in ipairs(monsters_as_table) do
            Monster.from_csv_line(monster_line, self)
        end
    end

    -- load items
    do
        local items = parts[ITEMS]
        local item_lines_as_table = split(items, "\n")
        for _, item_line in ipairs(item_lines_as_table) do
            Item.from_csv_line(item_line, self)
        end
    end

    -- load sprite
    do
        local sprites = parts[SPRITES]
        local sprite_lines_as_table = split(sprites, "\n")
        for _, sprite_line in ipairs(sprite_lines_as_table) do
            Sprite.from_csv_line(sprite_line, self)
        end
        -- todo: remember to register the sprite into the level
    end

    Player.place_player_on_random_tile(self)

    return self

end

-----------------------------------------------------------------------------
--- Save the level to a file
--- region save_to_file
-----------------------------------------------------------------------------
function Level:save_to_file()

    -- overwrite the file if it exists

    local path = SAVE_PATH .. "/" .. self.id
    if self.my_path then
        --os.remove(self.my_path)
        path = self.my_path
    end

    local file = io.open(path, "w")
    if not file then
        print("could not open file: " .. path)
        return
    end

    local content = ""

    -- save the meta_data
    do
        local meta_data = self.id .. "," .. self.WORLD_X_TILES .. "," .. self.WORLD_Y_TILES .. "," .. "\n"
        content = content .. meta_data
        content = content .. CSV_SEPERATOR
    end

    -- save the cells of the maze
    do
        for y, row in ipairs(self.maze) do
            for x, cell in ipairs(row) do
                content = content .. cell:to_csv_string()
            end
        end
        content = content .. CSV_SEPERATOR
    end

    -- save the items
    do
        for _, item in ipairs(self.items) do
            content = content .. item:to_csv_string()
        end
        content = content .. CSV_SEPERATOR
    end

    -- save the monsters
    do
        for _, monster in ipairs(self.monsters) do
            content = content .. monster:to_csv_string()
        end
        content = content .. CSV_SEPERATOR
    end

    -- save the objects
    do
        for _, object in ipairs(self.objects) do
            content = content .. object:to_csv_string()
        end
        content = content .. CSV_SEPERATOR
    end

    -- save the sprites
    do
        for _, sprite in ipairs(self.sprites) do
            content = content .. sprite:to_csv_string()
        end
        content = content .. CSV_SEPERATOR
    end

    file:write(content)

end

-----------------------------------------------------------------------------
--- Returns a random floor tile.
--- @return Cell
-----------------------------------------------------------------------------
function Level:get_random_floor_tile()

    local random_x = math.random(1, self.WORLD_X_TILES)
    local random_y = math.random(1, self.WORLD_Y_TILES)
    local tile = self.maze[random_y][random_x]
    while tile.kind == 0 do
        random_x = math.random(1, self.WORLD_X_TILES)
        random_y = math.random(1, self.WORLD_Y_TILES)
        tile = self.maze[random_y][random_x]
    end
    return tile

end