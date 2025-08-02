--[[

Door concept:

- yellow doors lead to other default rooms: some rng that the door leads to
  a already created room, if not create a new room
- red doors lead to hard levels: harder enemies, but needed for game progress (key orbs)
  if all key orbs are collected -> one red level leads to the final boss and then the game is won
- green doors lead the save-room: always the same room
- blue doors lead to a stock up level: there is some goodie there (good weapon, lots of supplies)
  those supplies can be somewhat crazy: only cans, only weapons (no ammo), etc.
   since we are in the backrooms.
- purple doors: go back to a random tile in the previous roomokay okaydi nee

]]

--- @class Cell One tile in the level, created from the raw maze data in Level.new
--- @field kind number
--- @field x_index number
--- @field y_index number
--- @field x number
--- @field y number
--- @field visible boolean
--- @field doorway_to string 'unknown' | '<load_path_of_the_room>' | '' (empty string means no doorway)

Cell = {}
Cell.__index = Cell

function Cell.new(kind, x_index, y_index, x, y, is_doorway, doorway_to)
    local self = setmetatable({}, Cell)
    self.kind = kind
    self.x_index = x_index
    self.y_index = y_index
    self.x = x
    self.y = y
    self.visible = false
    self.is_doorway = is_doorway or false
    self.doorway_to = doorway_to or ""
    return self
end

function Cell:to_csv_string()
    local is_doorway = "false"
    if self.is_doorway then is_doorway = "true" end
    return self.kind .. "," .. self.x_index .. "," .. self.y_index .. "," .. self.x .. "," .. self.y .. "," .. is_doorway .. "," .. self.doorway_to .. "\n"
end

function Cell.from_csv_line(line)
    local parts = split(line, ",")
    print("parts", parts)
    for i, p in ipairs(parts) do
        print(i, p)
    end
    local kind = tonumber(parts[1])
    local x_index = tonumber(parts[2])
    local y_index = tonumber(parts[3])
    local x = tonumber(parts[4])
    local y = tonumber(parts[5])
    local is_doorway = parts[6] == "true"
    local doorway_to = parts[7]
    return Cell.new(kind, x_index, y_index, x, y, is_doorway, doorway_to)
end

function Cell:draw()
    if self.is_doorway then
        love.graphics.setColor(1, 1, 1)
        -- todo: display different door based on the door type
        love.graphics.draw(Textures.door_yellow, (self.x_index - 1) * Level.TILE_SIZE, (self.y_index - 1) * Level.TILE_SIZE)
        return
    end
    if self.kind == 0 then
        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(Textures.wall, (self.x_index - 1) * Level.TILE_SIZE, (self.y_index - 1) * Level.TILE_SIZE)

        -- scale down the wallpaper texture down to the size of the wall - 4 pixel
        local wall_padding = 4
        local scale = (Level.TILE_SIZE - wall_padding * 2) / Textures.wallpaper:getWidth()
        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(Textures.wallpaper, (self.x_index - 1) * Level.TILE_SIZE + wall_padding, (self.y_index - 1) * Level.TILE_SIZE + wall_padding, 0, scale, scale)

        love.graphics.setColor(1, 1, 1)

    else
        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(Textures.floor, (self.x_index - 1) * Level.TILE_SIZE, (self.y_index - 1) * Level.TILE_SIZE)
    end
end


---
---
function Cell:use_this_doorway()
    if EDITOR_MODE then return end -- dont use doorways in editor mode
    -- todo: document in details since this is very important ...
    -- todo: if count the levels in the savegame directory: if alot increase possibility of a new
    --       door also leading back to a already created level
    -- todo: Add red doorways that lead back to your base-level (hub); also add dorrways with different clors and one special type
    local level_name = self.doorway_to

    if level_name == "" then

        local new_level = Level.new_level_from_templates()
        self.doorway_to = new_level.id
        Level.current_level:save_to_file()
        Level.current_level = new_level

        local door = new_level:get_undefined_door_cell()
        if door then
            door.doorway_to = Level.current_level.id
            -- place player at the door
            do
                Player.x = door.x
                Player.y = door.y
                Player.cam.x = door.x
                Player.cam.y = door.y
            end
        end
    else
        Level.current_level:save_to_file()
        print("Try to load level name: " .. tostring(level_name) )
        Level.current_level = Level.from_file(level_name)
        if Level.current_level == nil then
            print("Current level is nil for some crazy retarded reason")
        end
        -- find the door that leads to this level (if it exists)
        local door = nil
        do
            for _, row in ipairs(Level.current_level.maze) do
                for _, cell in ipairs(row) do
                    if cell.doorway_to == Level.current_level.id then
                        door = cell
                        goto found_door
                    end
                end
            end
            :: found_door ::
        end
        if door then
            Player.x = door.x
            Player.y = door.y
            Player.cam.x = door.x
            Player.cam.y = door.y
        else
            print("have not found a matching door cell in the loaded level")
        end
    end
end

--- The doorway of this cell is defined: means that the doorway has an established 2-way connection
--- to another level.
--- @return boolean
function Cell:is_defined_doorway()
    return self.doorway_to ~= ""
end
