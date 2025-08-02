---------------------------------------------------------------
--- Bresenham line algorithm that works with tile indices
--- Returns a list of tiles that the line passes through
--- @param startTile: The starting tile
--- @param endTile: The ending tile
---------------------------------------------------------------
function bresenham_line(startTile, endTile)
    local x1, y1 = startTile.x_index, startTile.y_index
    local x2, y2 = endTile.x_index, endTile.y_index
    local line = {}

    local dx = math.abs(x2 - x1)
    local dy = math.abs(y2 - y1)
    local sx = (x1 < x2) and 1 or -1
    local sy = (y1 < y2) and 1 or -1
    local err = dx - dy

    while true do
        -- Add current tile to the line
        table.insert(line, Level.current_level.maze[y1][x1])

        -- Break if we reach the end tile
        if x1 == x2 and y1 == y2 then break end

        local e2 = err * 2
        if e2 > -dy then
            err = err - dy
            x1 = x1 + sx
        end
        if e2 < dx then
            err = err + dx
            y1 = y1 + sy
        end
    end

    return line
end

---------------------------------------------------------------
--- pushCircleOut
--- Pushes circle1 out of circle2 if they are overlapping
--- @param circle1: The circle to push out
--- @param circle2: The circle to avoid overlap with
--- @param deltaTime: The time since the last frame
---------------------------------------------------------------
function pushCircleOut(circle1, circle2, deltaTime)
    -- Calculate the distance between the centers of the two circles
    local dx = circle2.x - circle1.x
    local dy = circle2.y - circle1.y
    local distance = math.sqrt(dx * dx + dy * dy)

    -- Calculate the minimum distance required to avoid overlap
    local minDistance = circle1.radius + circle2.radius

    -- If the circles are overlapping, push circle1 out
    if distance < minDistance then
        -- Calculate the overlap distance
        local overlap = minDistance - distance

        -- Calculate the direction vector from circle1 to circle2
        local pushDirectionX = dx / distance
        local pushDirectionY = dy / distance

        -- Apply the push to circle1 (scaled by deltaTime for smooth movement)
        local pushAmount = overlap -- * deltaTime  -- Can adjust scaling factor as needed
        circle1.x = circle1.x - pushDirectionX * pushAmount
        circle1.y = circle1.y - pushDirectionY * pushAmount
    end
end

function split(string, seperator)
    local result = {}
    for match in (string .. seperator):gmatch("(.-)" .. seperator) do
        table.insert(result, match)
    end
    return result
end

--- Calculate the distance between two points
--- @param x1 number
--- @param y1 number
--- @param x2 number
--- @param y2 number
--- @return number
function distance(x1, y1, x2, y2)
    return math.sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2)
end
