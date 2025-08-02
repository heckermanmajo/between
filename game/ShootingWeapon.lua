-- todo: IF WE WANT TO SHOOT: look into the inventory for ammo and if we dont have it then dont shoot(empty clicking sound)
-- todo: IF WE SHOOT TAKE ONE SHELL FROM THE INVENTORY

--- @class ShootingWeapon
ShootingWeapon = {
    weapon_types = {
        handgun = { damage = 10, shoot_cooldown_time = 1, ammo_kind = "ammo_9mm" },
        shotgun = { damage = 40, shoot_cooldown_time = 2, ammo_kind = "ammo_12mm" },
        mp5 = { damage = 20, shoot_cooldown_time = 0.3, ammo_kind = "ammo_10mm" }
    }
}
ShootingWeapon.__index = ShootingWeapon

function ShootingWeapon.new(weapon_kind, from_item)
    local self = setmetatable({}, ShootingWeapon)
    self.shoot_effect_cooldown = 0
    self.shoot_cooldown = 0
    self.hit_effect_cooldown = 0
    self.hit_target = nil
    self.max_range = 500
    self.kind = weapon_kind
    self.from_item = from_item
    return self
end

function ShootingWeapon:handle_attack(dt)

    if Player.weapon_in_hand == nil then return end
    local shift_is_pressed = love.keyboard.isDown("lshift")
    if shift_is_pressed then return end

    if self.shoot_effect_cooldown > 0 then self.shoot_effect_cooldown = self.shoot_effect_cooldown - dt end
    if self.shoot_cooldown > 0 then self.shoot_cooldown = self.shoot_cooldown - dt end
    if self.hit_effect_cooldown > 0 then self.hit_effect_cooldown = self.hit_effect_cooldown - dt end

    if love.mouse.isDown(1) and self.shoot_cooldown <= 0 then
        -- todo: the hit target needs to be in a clean line of sight bresham line algorithm

        local has_ammo = false
        for _, item_row in ipairs(Player.inventory) do
            if item_row[1].kind == ShootingWeapon.weapon_types[self.kind].ammo_kind then
                has_ammo = true
                table.remove(item_row, 1)
                break
            end
        end
        if not has_ammo then
            --todo: Sounds.empty_click:play()
            return
        end

        Sounds.shot:play()
        self.shoot_effect_cooldown = 0.03
        self.hit_effect_cooldown = 0.05
        self.shoot_cooldown = ShootingWeapon.weapon_types[self.kind].shoot_cooldown_time
        local hitx, hity = Player.cam:transform_screen_xy_to_world_xy(love.mouse.getX(), love.mouse.getY())
        self.hit_target = { x = hitx, y = hity }
        local hit_monster = Monster.point_hit_monster(self.hit_target.x, self.hit_target.y)
        if hit_monster then
            hit_monster:take_damage(ShootingWeapon.weapon_types[self.kind].damage)
            print("hit monster & Created blood at " .. hit_monster.x .. " " .. hit_monster.y)
            Sprite.new(hit_monster.x, hit_monster.y, "claimed_blood", 1, 1, Level.current_level)
        end
    end
end

function ShootingWeapon:draw()
    if Player.weapon_in_hand == nil then return end

    if Player.weapon_in_hand.kind == "handgun" then
        love.graphics.push()
        love.graphics.translate(Player.x, Player.y)
        love.graphics.rotate(Player.rotation + math.pi / 2)  -- Rotate the player
        love.graphics.setColor(1, 1, 1)  -- Set color to white (default)
        local shift_is_pressed = love.keyboard.isDown("lshift")
        local scale = 1
        local scale_one = 1
        local scale_two = 1
        local x = -Textures.player:getWidth() / 2 + 20
        local y = -Textures.player:getHeight() / 2 - 7
        local degrees = 0
        if shift_is_pressed then
            degrees = -90
            x = -Textures.player:getHeight() / 2 + 20
            y = -Textures.player:getWidth() / 2 + 16
            -- scale_one = -scale
        end
        love.graphics.rotate(math.rad(degrees))
        love.graphics.draw(Textures.handgun, x, y, 0, scale_one, scale_two)

        if self.shoot_effect_cooldown > 0 then
            love.graphics.draw(Textures.shooting_fire, -Textures.player:getWidth() / 2 + 20, -Textures.player:getHeight() / 2 - 20)  -- Draw the player centered
        end

        love.graphics.pop()

        if self.hit_effect_cooldown > 0 then
            -- draw a hit effect
            love.graphics.setColor(1, 1, 1)  -- Set color to white (default)
            local texture = Textures.hit
            local scale = 0.3
            local x = self.hit_target.x - texture:getWidth() / 2 * scale + 3
            local y = self.hit_target.y - texture:getHeight() / 2 * scale + 3
            love.graphics.draw(texture, x, y, 0, scale, scale)

        end

    elseif Player.weapon_in_hand.kind == "shotgun" then

        -- 32 * 64 px
        love.graphics.push()
        love.graphics.translate(Player.x, Player.y)
        love.graphics.rotate(Player.rotation + math.pi / 2)  -- Rotate the player
        love.graphics.setColor(1, 1, 1)  -- Set color to white (default)
        local x = -Textures.player:getHeight() / 2 + 4
        local y = -Textures.player:getWidth() / 2 - 20
        local degrees = 12
        local shift_is_pressed = love.keyboard.isDown("lshift")
        local scale = 0.6
        local scale_one = scale
        local scale_two = scale
        if shift_is_pressed then
            degrees = 90
            x = -Textures.player:getHeight() / 2 + 20
            y = -Textures.player:getWidth() / 2 + 6
            scale_one = -scale
        end
        love.graphics.rotate(math.rad(degrees))
        love.graphics.draw(Textures.shotgun, x, y, 0, scale_one, scale_two)  -- Draw the player centered

        if self.shoot_effect_cooldown > 0 then
            love.graphics.draw(Textures.shooting_fire, -Textures.player:getWidth() / 2 + 20, -Textures.player:getHeight() / 2 - 20)  -- Draw the player centered
        end

        love.graphics.pop()

    elseif Player.weapon_in_hand.kind == "mp5" then
        love.graphics.push()
        love.graphics.translate(Player.x, Player.y)
        love.graphics.rotate(Player.rotation + math.pi / 2)  -- Rotate the player
        love.graphics.setColor(1, 1, 1)  -- Set color to white (default)
        -- rotate the weapon to the right
        local degrees = 12
        local shift_is_pressed = love.keyboard.isDown("lshift")
        local x = -Textures.player:getHeight() / 2 - 15
        local y = -Textures.player:getWidth() / 2 + 6
        local scale = 0.5
        local scale_one = scale
        local scale_two = scale
        if shift_is_pressed then
            degrees = 90
            x = -Textures.player:getHeight() / 2 + 10
            y = -Textures.player:getWidth() / 2 + 15
            scale_one = -scale
        end
        love.graphics.rotate(math.rad(degrees))
        love.graphics.draw(Textures.mp5, y, x, 0, scale_one, scale_two)  -- Draw the player centered

        if self.shoot_effect_cooldown > 0 then
            love.graphics.draw(Textures.shooting_fire, -Textures.player:getWidth() / 2 + 20, -Textures.player:getHeight() / 2 - 20)  -- Draw the player centered
        end

        love.graphics.pop()

    end

end