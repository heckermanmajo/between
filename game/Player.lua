
--[[

Player-table needs to save the already created levels in a id-table since
we cannot simply loop over a directory: therefore we need always to save the id
of every created level in the player-table.
-> also save this into the player file in t6he savegame folder.

]]
-- todo: currently sanity, health and stuff can become negative ...
Player = {
    x = 100, -- Player's position on the X-axis
    y = 100, -- Player's position on the Y-axis
    speed = 90, -- Speed at which the player moves
    sprint_speed = 180, -- Speed at which the player moves when sprinting
    rotation = 0, -- Player's rotation angle in radians
    radius = 32, -- Player's collision radius
    cam = Camera.new(0, 0, 2, 0), -- Camera object
    inventory_is_open = false,
    max_inventory_size = 10,
    --- the inventory is a table of tables of items
    --- @type table<table<Item>>
    inventory = {},
    --- @type table<number, table<number, Cell>>
    current_level = nil, -- create a new level
    weapon_in_hand = ShootingWeapon.new("shotgun"),
    max_health = 200,
    max_nutrition = 200,
    max_sanity = 200,
    max_stamina = 200,
    health = 200,
    nutrition = 200,
    sanity = 200,
    stamina = 200,
    already_created_levels = {},
    save_room_level = nil
}

local key_cool_down = 0.3

function Player.passively_decrease_stats(dt)
    --Player.health = Player.health - dt
    Player.nutrition = Player.nutrition - (0.01 * dt)
    --Player.sanity = Player.sanity - dt
end

-- Function to handle input and apply movement/rotation
function Player:apply_input(dt)

    key_cool_down = key_cool_down - dt

    -- toggle inventory
    if love.keyboard.isDown("e") and key_cool_down <= 0 then
      self.inventory_is_open = not self.inventory_is_open
      key_cool_down = 0.3
    end

    -- tooglezoom on debug
    if love.keyboard.isDown("z") and key_cool_down <= 0 and DEBUG then
      Player.cam.zoom = 2 and 1 or 2
      key_cool_down = 0.3
    end

    if self.inventory_is_open then
      return
    end

    -- if we press enter and stand on a doorway we should go to the level of the doorway
    if love.keyboard.isDown("return") and key_cool_down <= 0 then

      --- @type Cell
      local tile = self.current_level:get_tile_at(self.x, self.y)
      if tile.is_doorway then tile:use_this_doorway() end

      key_cool_down = 0.5

    end

    -- Get mouse position directly
    local mouseX, mouseY = love.mouse.getX(), love.mouse.getY()
    mouseX, mouseY = self.cam:transform_screen_xy_to_world_xy(mouseX, mouseY)

    -- Calculate the vector from the player to the mouse
    local dx = mouseX - self.x
    local dy = mouseY - self.y
    -- Calculate the rotation angle to face the mouse
    self.rotation = math.atan2(dy, dx)

    -- Handle movement with WASD keys
    local moveX, moveY = 0, 0

    if love.keyboard.isDown("w") then
      -- Move towards the mouse
      moveX, moveY = dx, dy
    elseif love.keyboard.isDown("s") then
      -- Move away from the mouse
      moveX, moveY = -dx, -dy
    end

    if love.keyboard.isDown("a") then
      -- move left relative to the mouse
      moveX, moveY = dy, -dx
    elseif love.keyboard.isDown("d") then
      -- move right relative to the mouse
      moveX, moveY = -dy, dx
    end

    -- Normalize movement to avoid faster diagonal speed
    local magnitude = math.sqrt(moveX ^ 2 + moveY ^ 2)
    if magnitude > 0 then
      moveX = moveX / magnitude
      moveY = moveY / magnitude
    end

    -- check if he is to close to the mouse if so he should not move
    if magnitude < 10 then
      moveX = 0
      moveY = 0
    end

    -- Move the player
    local speed = self.speed
    if EDITOR_MODE then
      speed = 500
    end

    if love.keyboard.isDown("lshift") then
      speed = self.sprint_speed
      Player.stamina = Player.stamina - dt
    end

    self.x = self.x + moveX * speed * dt
    self.y = self.y + moveY * speed * dt

    -- dont move out of the world
    if self.x < self.radius then self.x = self.radius end
    if self.y < self.radius then self.y = self.radius end
    if self.x > self.current_level.WORLD_X_PIXELS + self.current_level.TILE_SIZE- self.radius then self.x = self.current_level.WORLD_X_PIXELS+ self.current_level.TILE_SIZE - self.radius end
    if self.y > self.current_level.WORLD_Y_PIXELS + self.current_level.TILE_SIZE- self.radius then self.y = self.current_level.WORLD_Y_PIXELS+ self.current_level.TILE_SIZE - self.radius end

    if self.weapon_in_hand then
      self.weapon_in_hand:handle_attack(dt)
    end

end

local camera_x = Player.x
local camera_y = Player.y
function Player:update_camera(dt)

    if love.keyboard.isDown("space") then
        local dx = math.cos(self.rotation) * 200
        local dy = math.sin(self.rotation) * 200
        local x_goal = self.x + dx
        local y_goal = self.y + dy
        local x_delta = math.abs(self.cam.x - x_goal)
        local y_delta = math.abs(self.cam.y - y_goal)
        local padding = 3
        --  move camera 400 py towards look direction
        if x_delta > padding then
            if self.cam.x < x_goal then camera_x = camera_x + 400 * dt end
            if self.cam.x > x_goal then camera_x = camera_x - 400 * dt end
        else
            camera_x = x_goal
        end
        if y_delta > padding then
            if self.cam.y < y_goal then camera_y = camera_y + 400 * dt end
            if self.cam.y > y_goal then camera_y = camera_y - 400 * dt end
        else
            camera_y = y_goal
        end
    else
        local x_goal = Player.x
        local y_goal = Player.y
        local x_delta = math.abs(self.cam.x - x_goal)
        local y_delta = math.abs(self.cam.y - y_goal)
        local padding = 3
        --  move camera 400 py towards look direction
        if x_delta > padding then
            if self.cam.x < x_goal then camera_x = camera_x + 400 * dt end
            if self.cam.x > x_goal then camera_x = camera_x - 400 * dt end
        else
            camera_x = Player.x
        end
        if y_delta > padding then
            if self.cam.y < y_goal then camera_y = camera_y + 400 * dt end
            if self.cam.y > y_goal then camera_y = camera_y - 400 * dt end
        else
            camera_y = Player.y
        end
    end

    self.cam.x = camera_x
    self.cam.y = camera_y
end

-- Function to draw the player using a texture
function Player:draw()
    love.graphics.push()
    love.graphics.translate(self.x, self.y)
    love.graphics.rotate(self.rotation + math.pi / 2)  -- Rotate the player
    love.graphics.setColor(1, 1, 1)  -- Set color to white (default)
    love.graphics.draw(Textures.player, -Textures.player:getWidth() / 2, -Textures.player:getHeight() / 2)  -- Draw the player centered
    love.graphics.pop()
    if self.weapon_in_hand then
        self.weapon_in_hand:draw()
    end
end

function Player.draw_ui()

    -- draw the inventory
    if Player.inventory_is_open then

        love.graphics.setColor(0, 0, 0, 0.5)
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
        love.graphics.setColor(1, 1, 1)
        love.graphics.print("Inventory", 10, 10)

        local slots_per_row = 4
        local current_row = 0
        local start_x = 600
        local start_y = 100
        local current_item_index = 1
        for row = 0 , math.floor(Player.max_inventory_size / slots_per_row) - 1 do
            current_row = row
            for slot = 0 , slots_per_row - 1 do
                local x_pos = start_x + slot * 140
                local y_pos = start_y + row * 140
                love.graphics.rectangle("line", x_pos, y_pos, 128, 128)
                --- @type table<Item>
                local current_item = Player.inventory[current_item_index]
                if current_item and #current_item > 0 then
                    local amount = #current_item
                    local first = current_item[1]
                    first:draw_as_inventory_item(x_pos, y_pos, amount)
                end

                current_item_index = current_item_index + 1
            end
        end
        current_row = current_row + 1
        local last_slots = Player.max_inventory_size % slots_per_row
        if last_slots > 0 then
            for slot = 0, last_slots-1 do
                local x_pos = start_x + slot * 140
                local y_pos = start_y + current_row * 140
                love.graphics.rectangle("line", x_pos, y_pos, 128, 128)

                --- @type table<Item>
                local current_item = Player.inventory[current_item_index]
                if current_item and #current_item > 0 then
                  local amount = #current_item
                  local first = current_item[1]
                  first:draw_as_inventory_item(x_pos, y_pos, amount)
                end

                current_item_index = current_item_index + 1

            end
        end

    end

    -- remove all empty lists from the inventory
    -- this can happen if we consume an item (f.e. eating or ammo during shooting)
    local remove = {}
    for i, item_row in ipairs(Player.inventory) do
        if #item_row == 0 then
            table.insert(remove, i)
        end
    end
    for i, index in ipairs(remove) do table.remove(Player.inventory, index)
    end

    -- draw mocks for the ui
    -- 4 bars: sanity: blue, health: red, nutrition: green; stamina: yellow

    local bar_width = 200
    local bar_height = 10
    local stamina = Player.stamina / Player.max_stamina * 200
    local health = Player.health / Player.max_health * 200
    local nutrition = Player.nutrition / Player.max_nutrition * 200
    local sanity = Player.sanity / Player.max_sanity * 200

    love.graphics.setColor(0.3, 0.3, 0.3, 0.8)
    love.graphics.rectangle("fill", 30, love.graphics.getHeight() - 10, bar_width, bar_height)
    -- purple color
    love.graphics.setColor(1, 0, 1)
    love.graphics.rectangle("fill", 30, love.graphics.getHeight() - 10, sanity, bar_height)

    love.graphics.setColor(0.3, 0.3, 0.3, 0.8)
    love.graphics.rectangle("fill", 30, love.graphics.getHeight() - 30, bar_width, bar_height)
    love.graphics.setColor(0, 1, 0)
    love.graphics.rectangle("fill", 30, love.graphics.getHeight() - 30, nutrition, bar_height)

    love.graphics.setColor(0.3, 0.3, 0.3, 0.8)
    love.graphics.rectangle("fill", 30, love.graphics.getHeight() - 50, bar_width, bar_height)
    love.graphics.setColor(1, 1, 0)
    love.graphics.rectangle("fill", 30, love.graphics.getHeight() - 50, stamina, bar_height)

    love.graphics.setColor(0.3, 0.3, 0.3, 0.8)
    love.graphics.rectangle("fill", 30, love.graphics.getHeight() - 70, bar_width, bar_height)
    love.graphics.setColor(1, 0, 0)
    love.graphics.rectangle("fill", 30, love.graphics.getHeight() - 70, health, bar_height)

    -- draw the current fps
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("FPS: " .. love.timer.getFPS(), 10, 10)

end

function Player.place_player_on_random_tile(level)

    -- place the player on a random floor tile
    local player_tile = Player.current_level.maze[math.random(2, level.WORLD_Y_TILES - 1)][math.random(2, level.WORLD_X_TILES - 1)]
    while player_tile.kind == 0 do
      player_tile = Player.current_level.maze[math.random(2, level.WORLD_Y_TILES - 1)][math.random(2, level.WORLD_X_TILES - 1)]
    end
    Player.x = player_tile.x
    Player.y = player_tile.y
    Player.cam.x = Player.x
    Player.cam.y = Player.y

end