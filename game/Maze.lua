
--[[
  Maze is used to create a raw outline of a level.

  It generates a 2d array of numbers: 0 for walls, 1 for paths.

  This data is then used as the basis fo the real tiles("Cell")- tables.

  We can also export the raw maze to csv and png and also load it from csv.

  This way we can generate a couple hundred mazes and choose the best ones by
  looking at the pngs.

]]

--- @class Maze
Maze = {}

--------------------------------------------------------------------
--- Generates a maze using a recursive backtracking algorithm.
--- @param width number
--- @param height number
--- @param maxRooms number
--- @param roomMinSize number
--- @param roomMaxSize number
--- @return table<number, table<number, number>>
--------------------------------------------------------------------
function Maze.generate_a_maze(width, height, maxRooms, roomMinSize, roomMaxSize)
    -- Initialize the grid (0 = wall, 1 = path)
    local maze = {}
    for y = 1, height do
        maze[y] = {}
        for x = 1, width do
            maze[y][x] = 0 -- Start with all walls
        end
    end

    -- Directions for movement (up, down, left, right)
    local directions = {
      { x = 0, y = -1 }, -- Up
      { x = 0, y = 1 }, -- Down
      { x = -1, y = 0 }, -- Left
      { x = 1, y = 0 }   -- Right
    }

    -- Helper function to shuffle directions
    local function shuffle(t)
        for i = #t, 2, -1 do
            local j = math.random(i)
            t[i], t[j] = t[j], t[i]
        end
    end

    -- Room placement function
    local function placeRoom()
      -- Random size and position
      local roomWidth = math.random(roomMinSize, roomMaxSize)
      local roomHeight = math.random(roomMinSize, roomMaxSize)
      local startX = math.random(1, width - roomWidth - 1)
      local startY = math.random(1, height - roomHeight - 1)

      -- Check if the area is clear
      for y = startY, startY + roomHeight do
          for x = startX, startX + roomWidth do
              if maze[y][x] == 1 then
                  return false -- Abort if room overlaps with existing path
              end
          end
      end

      -- Carve the room into the grid
      for y = startY, startY + roomHeight do
          for x = startX, startX + roomWidth do
              maze[y][x] = 1 -- Room becomes part of the path
          end
      end

      -- Create an entrance
      local entranceX = math.random(startX, startX + roomWidth)
      local entranceY = math.random(startY, startY + roomHeight)
      maze[entranceY][entranceX] = 1

      return true
    end

    -- Place rooms
    local roomsPlaced = 0
    while roomsPlaced < maxRooms do
        if placeRoom() then
            roomsPlaced = roomsPlaced + 1
        end
    end

    -- Recursive DFS function
    local function carve(x, y)
        maze[y][x] = 1 -- Mark the current cell as a path

        -- Shuffle directions for randomness
        shuffle(directions)

        -- Visit each neighboring cell
        for _, dir in ipairs(directions) do
            local nx, ny = x + dir.x * 2, y + dir.y * 2 -- Neighboring cell (2 steps away)

            -- Check if the neighbor is within bounds and unvisited
            if nx > 0 and nx <= width and ny > 0 and ny <= height and maze[ny][nx] == 0 then
                -- Carve a path between the current cell and the neighbor
                maze[y + dir.y][x + dir.x] = 1
                -- Recurse into the neighbor
                carve(nx, ny)
            end
        end
    end

    -- Start DFS from a random position
    local startX = math.random(1, math.floor(width / 2)) * 2 - 1
    local startY = math.random(1, math.floor(height / 2)) * 2 - 1
    carve(startX, startY)

    return maze
end


--- Get the four tiles around a given tile.
--- @param maze table<number, table<number, number>>
--- @param x number
--- @param y number
--- @return table<number>
function Maze.raw_maze_get_four_tiles_around(maze, x, y)
    local tiles = {}
    local directions = {
      { x = 0, y = -1 },
      { x = 0, y = 1 },
      { x = -1, y = 0 },
      { x = 1, y = 0 },
    }
    for _, dir in ipairs(directions) do
        local tile = maze[y + dir.y] and maze[y + dir.y][x + dir.x]
        if tile then
            table.insert(tiles, maze[y + dir.y][x + dir.x])
        end
    end
    return tiles
end

function Maze.raw_maze_post_processing(maze, break_through_number)

    -- break long maze lines, so we gte more backrooms and less maze
    -- configure the break break_through_number
    local counter = 0
    local world_y_tiles = #maze
    local world_x_tiles = #maze[1]
    for y = 1, world_y_tiles do
        for x = 1, world_x_tiles do
            local row = maze[y]
            if row then
                local tile = maze[y][x]
                if tile then
                    local tiles_around = Maze.raw_maze_get_four_tiles_around(maze, x, y)
                    local wall_count = 0
                    for _, t in ipairs(tiles_around) do
                        if t == 0 then wall_count = wall_count + 1 end
                    end
                    if wall_count == 2 and tile == 0 then
                        counter = counter + 1
                        if counter > break_through_number then
                            maze[y][x] = 1
                            print("break through")
                            counter = 0
                        end
                    end
                end
            else
              print("no row at y in maze", y)
            end
        end
    end

    -- todo: maybe do some random wall removals if at least one floor is a neighbor

    local chance = 0.1
    for y = 1, world_y_tiles do
        for x = 1, world_x_tiles do
            local row = maze[y]
            if row then
                local tile = maze[y][x]
                if tile == 0 then
                    local tiles_around = Maze.raw_maze_get_four_tiles_around(maze, x, y)
                    local floor_count = 0
                    for _, t in ipairs(tiles_around) do
                        if t == 1 then floor_count = floor_count + 1 end
                    end
                    if floor_count > 0 and math.random() < chance then
                        maze[y][x] = 1
                    end
                end
            end
        end
    end

    return maze

end


function Maze.export_raw_maze_to_csv(file_name, maze)
    local file = io.open(file_name, "w")
    for y, row in ipairs(maze) do
        for x, cell in ipairs(row) do
            file:write(cell.kind)
            if x < #row then
                file:write(",")
            end
        end
        file:write("\n")
    end
    file:close()
end

function Maze.export_raw_maze_as_png(file_name, maze)
    local world_y_tiles = #maze
    local world_x_tiles = #maze[1]
    local image = love.image.newImageData(world_x_tiles, world_y_tiles)
    for y, row in ipairs(maze) do
        for x, cell in ipairs(row) do
            local color = cell == 0 and { 0, 0, 0 } or { 255, 255, 255 }
            image:setPixel(x - 1, y - 1, unpack(color))
        end
    end
    image:encode("png", file_name)
    local saveDir = love.filesystem.getSaveDirectory()
    os.execute("cp " .. saveDir .. "/" .. file_name .. " game/maps/" .. file_name)
    --print("Saved maze to " .. saveDir .. "/" .. file_name)
end

function Maze.import_raw_maze_from_csv(file_name)
    local file = io.open(file_name, "r")
    local maze = {}
    for line in file:lines() do
        local row = {}
        for cell in line:gmatch("%d+") do
            table.insert(row, tonumber(cell))
        end
        table.insert(maze, row)
    end
    file:close()
    return maze
end
