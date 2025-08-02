--[[

todo: comment how the editor works...

]]
local editor_edit_type_mode = "walls"
local cool_down = 0.5
local current_item_to_place = "ammo_9mm"

function Player.draw_editor_mode()

    if not EDITOR_MODE then return end

    -- draw place mode text
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Place mode: " .. editor_edit_type_mode, 100, 100)

    if editor_edit_type_mode == "items" then
        -- draw the current_item_to_place at mouse postion in 2x scale
        local texture = Textures[current_item_to_place]
        local mouse_x, mouse_y = love.mouse.getPosition()
        love.graphics.draw(texture, mouse_x - texture:getWidth() / 2, mouse_y - texture:getHeight() / 2, 0, 2, 2)
    end

    if editor_edit_type_mode == "monsters" then
        -- draw the current_item_to_place at mouse postion in 2x scale
        local texture = Textures.monster
        local mouse_x, mouse_y = love.mouse.getPosition()
        love.graphics.draw(texture, mouse_x - texture:getWidth() / 2, mouse_y - texture:getHeight() / 2, 0, 2, 2)
    end

    if editor_edit_type_mode == "walls" then
        local texture = Textures.wall
        local mouse_x, mouse_y = love.mouse.getPosition()
        love.graphics.draw(texture, mouse_x - texture:getWidth() / 2, mouse_y - texture:getHeight() / 2, 0, 0.5, 0.5)
    end

    if editor_edit_type_mode == "doors" then
        local texture = Textures.doorway
        local mouse_x, mouse_y = love.mouse.getPosition()
        love.graphics.draw(texture, mouse_x - texture:getWidth() / 2, mouse_y - texture:getHeight() / 2, 0, 0.5, 0.5)
    end

end

function Player.editor_mode(dt)

    if not EDITOR_MODE then return end

    local mouse_x, mouse_y = love.mouse.getPosition()
    local real_mouse_x, real_mouse_y = Player.cam:transform_screen_xy_to_world_xy(mouse_x, mouse_y)
    --- @type Cell
    local mouse_over_tile = Level.current_level:get_tile_at(real_mouse_x, real_mouse_y)
    if mouse_over_tile == nil then return end

    --- @param tile Cell
    local function clear_tile(tile)
        local level = Level.current_level
        local item_indexes_to_delete = {}
        for index, item in ipairs(level.items) do
            local tile_item_is_on = level:get_tile_at(item.x, item.y)
            if tile_item_is_on == tile then table.insert(item_indexes_to_delete, index) end
        end
        for _, index in ipairs(item_indexes_to_delete) do table.remove(level.items, index) end

        local monster_indexes_to_delete = {}
        for index, monster in ipairs(level.monsters) do
            local tile_monster_is_on = level:get_tile_at(monster.x, monster.y)
            if tile_monster_is_on == tile then
                table.insert(monster_indexes_to_delete, index)
            end
        end
        for _, index in ipairs(monster_indexes_to_delete) do table.remove(level.monsters, index) end
        local sprite_indexes_to_delete = {}
        for index, sprite in ipairs(level.sprites) do
            local tile_sprite_is_on = level:get_tile_at(sprite.x, sprite.y)
            if tile_sprite_is_on == tile then
                table.insert(sprite_indexes_to_delete, index)
            end
        end
        for _, index in ipairs(sprite_indexes_to_delete) do table.remove(level.sprites, index) end
    end

    cool_down = cool_down - dt

    local mouse_x, mouse_y = love.mouse.getPosition()

    local real_mouse_x, real_mouse_y = Player.cam:transform_screen_xy_to_world_xy(mouse_x, mouse_y)
    --- @type Cell
    local mouse_over_tile = Level.current_level:get_tile_at(real_mouse_x, real_mouse_y)
    local mouse_left_click = love.mouse.isDown(1)
    local mouse_right_click = love.mouse.isDown(2)

    if editor_edit_type_mode == "walls" then

        if mouse_left_click then
            mouse_over_tile.kind = 0
            mouse_over_tile.is_doorway = false
            mouse_over_tile.doorway_to = ""
            clear_tile(mouse_over_tile)
        end

        if mouse_right_click then
            mouse_over_tile.kind = 1
            mouse_over_tile.is_doorway = false
            mouse_over_tile.doorway_to = ""
            clear_tile(mouse_over_tile)
        end

    elseif editor_edit_type_mode == "doors" then

        if mouse_left_click then
            mouse_over_tile.is_doorway = true
            mouse_over_tile.doorway_to = ""
            mouse_over_tile.kind = 1
            clear_tile(mouse_over_tile)
        end

        if mouse_right_click then
            mouse_over_tile.is_doorway = false
            mouse_over_tile.doorway_to = ""
            clear_tile(mouse_over_tile)
        end

    elseif editor_edit_type_mode == "items" then

        -- if enter is pressed, change the current item to place
        if love.keyboard.isDown("return") and cool_down <= 0 then
            local items = Item.ITEM_KINDS
            local current_index = 1
            for i, item in ipairs(items) do
                if item == current_item_to_place then
                    current_index = i
                    break
                end
            end

            current_index = current_index + 1
            if current_index > #items then current_index = 1 end
            current_item_to_place = items[current_index]
            cool_down = 0.5
        end

        if mouse_left_click and cool_down <= 0 then
            -- don't place items on walls
            if mouse_over_tile.kind == 0 then return end
            local item = Item.new(real_mouse_x, real_mouse_y, current_item_to_place, Level.current_level)
            clear_tile(mouse_over_tile)
            table.insert(Level.current_level.items, item)
            cool_down = 0.5
        end


    elseif editor_edit_type_mode == "monsters" then

        if mouse_left_click and cool_down <= 0 then
            -- don't place monsters on walls
            if mouse_over_tile.kind == 0 then return end
            clear_tile(mouse_over_tile)
            local monster = Monster.new(real_mouse_x, real_mouse_y, Level.current_level)
            table.insert(Level.current_level.monsters, monster)
            cool_down = 0.5
        end

    end

    if love.keyboard.isDown("1") and cool_down <= 0 then
        editor_edit_type_mode = "walls"
        cool_down = 0.5
    end

    if love.keyboard.isDown("2") and cool_down <= 0 then
        editor_edit_type_mode = "doors"
        cool_down = 0.5
    end

    if love.keyboard.isDown("3") and cool_down <= 0 then
        editor_edit_type_mode = "items"
        cool_down = 0.5
    end

    if love.keyboard.isDown("4") and cool_down <= 0 then
        editor_edit_type_mode = "monsters"
        cool_down = 0.5
    end

end