--- Item class: Items are objects that can be picked up by the player.
--- Items can be health items, sanity items, weapons, ammo, etc.
--- Items can be placed on the level and picked up by the player(then added to the inventory).
--- @class Item
Item = {
    MAX_STACK_SIZE_PER_KIND = {
        can = 1,
        ammo_9mm = 12,
        ammo_10mm = 16,
        ammo_12mm = 6,
        handgun = 1,
        shotgun = 1,
        mp5 = 1,
        grenade = 1
    },
    ITEM_KINDS = {
        "can",
        "ammo_9mm",
        "ammo_10mm",
        "ammo_12mm",
        "handgun",
        "shotgun",
        "mp5",
        "grenade"
    },
}
Item.__index = Item

function Item.new(x, y, kind, level)
    local self = setmetatable({}, Item)
    self.x = x
    self.y = y
    self.texture = Textures[kind]
    self.kind = kind
    self.amount = 1
    if self.kind == "ammo_9mm" then
        self.amount = math.random(3, 10)
    end
    if self.kind == "ammo_10mm" then
        self.amount = math.random(4, 10)
    end
    if self.kind == "ammo_12mm" then
        self.amount = math.random(2, 6)
    end
    assert(self.x, "Item.new: x is nil")
    assert(self.y, "Item.new: y is nil")
    table.insert(level.items, self)
    return self
end

function Item.draw_all_items()
    for _, item in ipairs(Item.instances) do
        if Player.current_level:get_tile_at(item.x, item.y).visible then
            love.graphics.draw(item.texture, item.x - item.texture:getWidth() / 2, item.y - item.texture:getHeight() / 2)
        end
    end
end

function Item:draw()
    local scale = 1
    if self.kind == "shotgun" then
        scale = 0.6
    end
    if self.kind == "mp5" then
        scale = 0.6
    end
    if Player.current_level:get_tile_at(self.x, self.y).visible then
        love.graphics.draw(self.texture, self.x - self.texture:getWidth() / 2, self.y - self.texture:getHeight() / 2, 0, scale, scale)
    end
end

function Item.place_item_on_random_floor_tile(kind, level)
    local item_tile = level:get_tile_at(math.random(2, level.WORLD_Y_TILES - 1) * level.TILE_SIZE, math.random(2, level.WORLD_X_TILES - 1) * level.TILE_SIZE)
    while item_tile.kind == 0 do
        item_tile = level:get_tile_at(math.random(2, level.WORLD_Y_TILES - 1) * level.TILE_SIZE, math.random(2, level.WORLD_X_TILES - 1) * level.TILE_SIZE)
    end
    local x = item_tile.x + level.TILE_SIZE / 2 + math.random(-level.TILE_SIZE / 4, level.TILE_SIZE / 4)
    local y = item_tile.y + level.TILE_SIZE / 2 + math.random(-level.TILE_SIZE / 4, level.TILE_SIZE / 4)
    Item.new(x, y, kind, level)
end

function Item:to_csv_string()
    return self.x .. "," .. self.y .. "," .. self.kind .. "\n"
end

function Item.from_csv_line(line, level)
    if line == "" then return nil end
    local parts = split(line, ",")
    local x = tonumber(parts[1])
    local y = tonumber(parts[2])
    local kind = parts[3]
    return Item.new(x, y, kind, level)
end

local currently_selected_item = nil

function Item:draw_as_inventory_item(x_pos, y_pos, amount)
    -- 128 * 128: scale my texture up to 128x128
    -- gray background
    love.graphics.setColor(0.3, 0.3, 0.3)
    love.graphics.rectangle("fill", x_pos, y_pos, 128, 128)
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(self.texture, x_pos, y_pos, 0, 128 / self.texture:getWidth(), 128 / self.texture:getHeight())
    love.graphics.print(amount, x_pos + 128 - 20, y_pos + 128 - 25)
    local mouse_x, mouse_y = love.mouse.getPosition()
    if mouse_x > x_pos and mouse_x < x_pos + 128 and mouse_y > y_pos and mouse_y < y_pos + 128 then
        if love.mouse.isDown(1) then
            currently_selected_item = self
        end
    end

    if currently_selected_item == self then
        love.graphics.setColor(1, 1, 1)
        love.graphics.rectangle("line", x_pos, y_pos, 128, 128)
        -- todo: draw the item description and the interaction buttons
        local description = "This is a " .. self.kind
        if self.kind == "can" then
            description = { "A can of food, use to restore some nutrition and stamina;", "small positive effect on sanity and health." }
        elseif self.kind == "ammo_9mm" then
            description = "Default 9mm ammo, use for your pistol."
        elseif self.kind == "handgun" then
            description = "A 9mm pistol, use to shoot zombies."
        elseif self.kind == "ammo_10mm" then
            description = "Default 10mm ammo, use for machine pistols."
        elseif self.kind == "mp5" then
            description = "A MP5 submachine gun, use to shoot zombies."
        elseif self.kind == "ammo_12mm" then
            description = "Default 12mm ammo, use for shotguns."
        elseif self.kind == "shotgun" then
            description = "A shotgun, use to shoot zombies."
        elseif self.kind == "grenade" then
            description = "A grenade, use to blow up zombies."
        end

        if type(description) == "table" then
            for i, line in ipairs(description) do
                love.graphics.print(line, 100, 100 + i * 20)
            end
        else
            love.graphics.print(description, 100, 100)
        end

        self:draw_interaction_buttons()
    end
end

local cooldown = 0
function Item.progress_cooldown(dt)
    if cooldown > 0 then cooldown = cooldown - dt end
end

-- todo: add function for drawing the interaction buttons on the left hand side of the inventory-screen
function Item:draw_interaction_buttons()

    -- todo: add drop buttons for all items

    -- "switch" for item kind ...
    if self.kind == "can" then
        -- draw the "consume" button
        love.graphics.setColor(0.3, 0.3, 0.3)
        local x_pos = 200
        local y_pos = 250
        local width = 200
        local height = 50
        love.graphics.rectangle("fill", x_pos, y_pos, width, height)
        love.graphics.setColor(1, 1, 1)

        love.graphics.print("Consume", x_pos + 10, y_pos + 10)
        local mouse_x, mouse_y = love.mouse.getPosition()
        if mouse_x > x_pos and mouse_x < x_pos + width and mouse_y > y_pos and mouse_y < y_pos + height then
            if love.mouse.isDown(1) and cooldown <= 0 then
                -- apply the effect of the item:
                Player.nutrition = Player.nutrition + 50
                if Player.nutrition > Player.max_nutrition then Player.nutrition = Player.max_nutrition end
                Player.stamina = Player.stamina + 30
                if Player.stamina > Player.max_stamina then Player.stamina = Player.max_stamina end
                Player.sanity = Player.sanity + 15
                if Player.sanity > Player.max_sanity then Player.sanity = Player.max_sanity end
                Player.health = Player.health + 5
                if Player.health > Player.max_health then Player.health = Player.max_health end
                -- search for the item in the inventory and remove it
                for _, item_row in ipairs(Player.inventory) do
                    if item_row[1].kind == self.kind then
                        table.remove(item_row, 1)
                        break
                    end
                end
                print("Consumed the can...")
                cooldown = 0.5
            end
        end

        do
            -- todo: add drop button for can

        end

    end

    if self.kind == "handgun" then
        -- draw the "equip" button
        local x_pos = 200
        local y_pos = 250
        local width = 200
        local height = 50
        love.graphics.setColor(0.3, 0.3, 0.3)
        love.graphics.rectangle("fill", x_pos, y_pos, width, height)
        love.graphics.setColor(1, 1, 1)

        love.graphics.print("Equip Weapon", x_pos + 10, y_pos + 10)
        local mouse_x, mouse_y = love.mouse.getPosition()
        if mouse_x > x_pos and mouse_x < x_pos + width and mouse_y > y_pos and mouse_y < y_pos + height then
            if love.mouse.isDown(1) and cooldown <= 0 then
                -- equip the item
                Player.weapon_in_hand = ShootingWeapon.new("handgun", self)
                -- dont remove the item from the inventory, just equip it
                print("Equipped the handgun...")
                cooldown = 0.5
            end
        end

        -- create a drop button
        do
            local x_pos = 200
            local y_pos = 350
            local width = 200
            local height = 50
            love.graphics.setColor(0.3, 0.3, 0.3)
            love.graphics.rectangle("fill", x_pos, y_pos, width, height)
            love.graphics.setColor(1, 1, 1)

            love.graphics.print("Drop Weapon", x_pos + 10, y_pos + 10)

            local mouse_x, mouse_y = love.mouse.getPosition()
            if mouse_x > x_pos and mouse_x < x_pos + width and mouse_y > y_pos and mouse_y < y_pos + height then
                if love.mouse.isDown(1) and cooldown <= 0 then
                    -- drop the item
                    self:add_to_level(Player.x, Player.y, Player.current_level)
                    -- remove the item from the inventory
                    for i, item_row in ipairs(Player.inventory) do
                        if item_row[1].kind == self.kind then
                            table.remove(Player.inventory, i)
                            if Player.weapon_in_hand.kind == "handgun" then Player.weapon_in_hand = nil end
                            break
                        end
                    end
                    print("Dropped the handgun...")
                    cooldown = 0.5
                end
            end
        end

    end

    if self.kind == "shotgun" then
        -- draw the "equip" button
        local x_pos = 200
        local y_pos = 250
        local width = 200
        local height = 50
        love.graphics.setColor(0.3, 0.3, 0.3)
        love.graphics.rectangle("fill", x_pos, y_pos, width, height)
        love.graphics.setColor(1, 1, 1)

        love.graphics.print("Equip Weapon", x_pos + 10, y_pos + 10)
        local mouse_x, mouse_y = love.mouse.getPosition()
        if mouse_x > x_pos and mouse_x < x_pos + width and mouse_y > y_pos and mouse_y < y_pos + height then
            if love.mouse.isDown(1) and cooldown <= 0 then
                -- equip the item
                Player.weapon_in_hand = ShootingWeapon.new("shotgun", self)
                -- dont remove the item from the inventory, just equip it
                print("Equipped the handgun...")
                cooldown = 0.5
            end
        end

        -- create a drop button
        do
            local x_pos = 200
            local y_pos = 350
            local width = 200
            local height = 50
            love.graphics.setColor(0.3, 0.3, 0.3)
            love.graphics.rectangle("fill", x_pos, y_pos, width, height)
            love.graphics.setColor(1, 1, 1)

            love.graphics.print("Drop Weapon", x_pos + 10, y_pos + 10)

            local mouse_x, mouse_y = love.mouse.getPosition()
            if mouse_x > x_pos and mouse_x < x_pos + width and mouse_y > y_pos and mouse_y < y_pos + height then
                if love.mouse.isDown(1) and cooldown <= 0 then
                    -- drop the item
                    self:add_to_level(Player.x, Player.y, Player.current_level)
                    -- remove the item from the inventory
                    for i, item_row in ipairs(Player.inventory) do
                        if item_row[1].kind == self.kind then
                            table.remove(Player.inventory, i)
                            if Player.weapon_in_hand.kind == "shotgun" then Player.weapon_in_hand = nil end
                            break
                        end
                    end
                    print("Dropped the shotgun...")
                    cooldown = 0.5
                end
            end
        end

    end

    if self.kind == "mp5" then
        -- draw the "equip" button
        local x_pos = 200
        local y_pos = 250
        local width = 200
        local height = 50
        love.graphics.setColor(0.3, 0.3, 0.3)
        love.graphics.rectangle("fill", x_pos, y_pos, width, height)
        love.graphics.setColor(1, 1, 1)

        love.graphics.print("Equip Weapon", x_pos + 10, y_pos + 10)
        local mouse_x, mouse_y = love.mouse.getPosition()
        if mouse_x > x_pos and mouse_x < x_pos + width and mouse_y > y_pos and mouse_y < y_pos + height then
            if love.mouse.isDown(1) and cooldown <= 0 then
                -- equip the item
                Player.weapon_in_hand = ShootingWeapon.new("mp5", self)
                -- dont remove the item from the inventory, just equip it
                print("Equipped the handgun...")
                cooldown = 0.5
            end
        end

        -- create a drop button
        do
            local x_pos = 200
            local y_pos = 350
            local width = 200
            local height = 50
            love.graphics.setColor(0.3, 0.3, 0.3)
            love.graphics.rectangle("fill", x_pos, y_pos, width, height)
            love.graphics.setColor(1, 1, 1)

            love.graphics.print("Drop Weapon", x_pos + 10, y_pos + 10)

            local mouse_x, mouse_y = love.mouse.getPosition()
            if mouse_x > x_pos and mouse_x < x_pos + width and mouse_y > y_pos and mouse_y < y_pos + height then
                if love.mouse.isDown(1) and cooldown <= 0 then
                    -- drop the item
                    self:add_to_level(Player.x, Player.y, Player.current_level)
                    -- remove the item from the inventory
                    for i, item_row in ipairs(Player.inventory) do
                        if item_row[1].kind == self.kind then
                            table.remove(Player.inventory, i)
                            if Player.weapon_in_hand.kind == "mp5" then Player.weapon_in_hand = nil end
                            break
                        end
                    end
                    print("Dropped the shotgun...")
                    cooldown = 0.5
                end
            end
        end

    end

    if kind == "ammo_9mm" then

        -- todo: drpo button for ammo: CAREFUL WITH AMOUNT OF AMMO IN THE STACK

    end


end

function Item:remove_from_level()
    for i, item in ipairs(Player.current_level.items) do
        if item == self then
            table.remove(Player.current_level.items, i)
            return
        end
    end
end

function Item:add_to_level(x, y, level)
    self.x = x
    self.y = y
    table.insert(level.items, self)
end

------------------------------------------------------------------------------
--- Add the item to the player's inventory.
--- If the item is ammo, it will be added to an existing stack if possible.
--- If the item is ammo and no stack is available, a new stack will be created.
--- If the item is not ammo, it will be added to a new stack.
--- If the inventory is full, the item will not be added.
--- The item will be removed from the level after being added to the inventory.
function Item:add_to_player_inventory()

    --- Helper function to handle adding ammo to inventory
    --- @param stack table
    --- @param ammo_count number
    --- @return number
    local function add_ammo_to_stack(stack, ammo_count)
        while ammo_count > 0 do
            if #stack >= Item.MAX_STACK_SIZE_PER_KIND[self.kind] then
                break -- Exit if stack is full
            end
            table.insert(stack, self)
            ammo_count = ammo_count - 1
        end
        return ammo_count
    end

    print("Item:add_to_player_inventory")

    -- Check if the item is ammo and generate random count
    local ammo_count = self.amount

    -- Try to add the item to an existing stack
    for _, inventory_stack in ipairs(Player.inventory) do
        if inventory_stack[1].kind == self.kind then
            local is_full = #inventory_stack >= Item.MAX_STACK_SIZE_PER_KIND[self.kind]

            if not is_full then
                if self.kind == "ammo_9mm" or self.kind == "ammo_10mm" or self.kind == "ammo_12mm" then
                    ammo_count = add_ammo_to_stack(inventory_stack, ammo_count)
                    -- if not all ammo was added to the stack, try to add it to another stack
                    if ammo_count > 0 then goto continue end
                else
                    table.insert(inventory_stack, self)
                end
                self:remove_from_level()
                return
            end
        end
        :: continue ::
    end

    -- If item couldn't be added to an existing stack, try to create a new stack
    if #Player.inventory < Player.max_inventory_size then
        local new_stack = {}
        table.insert(Player.inventory, new_stack)

        if self.kind == "ammo_9mm" or self.kind == "ammo_10mm" or self.kind == "ammo_12mm" then
            ammo_count = add_ammo_to_stack(new_stack, ammo_count)
        else
            table.insert(new_stack, self)
        end

        self:remove_from_level()
        return
    end

    -- If inventory is full and item can't be added
    print("Inventory is full")
    -- todo: display message that inventory is full to the player
    -- todo: we need a system for displaying text badges on the screen for some time like a label
end
