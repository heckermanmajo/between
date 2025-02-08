Menu = {
  game_mode = "main_menu",
}

--- returns the place where the text should be drawn to be centered
--- @param text string
--- @param width number the width of the area the text should be centered in
--- @param height number the height of the area the text should be centered in
--- @return number, number
local function center_text(text, width, height)
    local font = love.graphics.getFont()
    local text_width = font:getWidth(text)
    local text_height = font:getHeight()
    local x = (width - text_width) / 2
    local y = (height - text_height) / 2
    return x, y
end

local function Button(x, y, text, width, height, callback)

    local text_x, text_y = center_text(text, width, height)
    local mouse_x, mouse_y = love.mouse.getPosition()
    local hovered = mouse_x > x and mouse_x < x + width and mouse_y > y and mouse_y < y + height

    local yellow = { 1, 1, 0 }
    if hovered then
        yellow = { 1, 1, 0.5 }
    end
    love.graphics.setColor(yellow)
    love.graphics.rectangle("fill", x, y, width, height)
    love.graphics.setColor(0.2, 0.2, 0.2)
    love.graphics.print(text, x + text_x, y + text_y)

    -- draw a black border 2 px wide around the button
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle("line", x, y, width, height)
    -- another black border
    love.graphics.rectangle("line", x - 1, y - 1, width + 2, height + 2)

    if love.mouse.isDown(1) then
        if hovered then
            callback()
        end
    end

    love.graphics.setColor(1, 1, 1)
end

function Menu.MainMenu()

    local background = Textures.backrooms
    love.graphics.draw(background, 0, 0)

    -- sale up to screen size
    local scale_x = love.graphics.getWidth() / background:getWidth()
    local scale_y = love.graphics.getHeight() / background:getHeight()
    love.graphics.draw(background, 0, 0, 0, scale_x, scale_y)

    local screen_width = love.graphics.getWidth()
    local screen_height = love.graphics.getHeight()
    local start_x = screen_width - 300
    local start_y = 180

    Button(start_x, start_y, "Continue", 200, 50, function()
      -- load the player data and from the player data -> we know what level to load
    end)

    local y = start_y + 60

    Button(start_x, y, "Start NEW GAME", 200, 50, function()
        -- delete the save games and then create a new one
        -- todo: delete the ld savegames...
        LEVEL = Level.new(30, 15, 1, 4)
        Menu.game_mode = "game"
    end)

    y = y + 60

    Button(start_x, y, "Editor", 200, 50, function()
        -- switch to the editor menu, where you can edit the blue-print-levels that are
        -- used in the game an stored in the template folder
        Menu.game_mode = "editor_menu"
    end)

    y = y + 60

    Button(start_x, y, "Quit", 200, 50, function()
        love.event.quit()
    end)


    -- end on escape
    if love.keyboard.isDown("escape") then love.event.quit() end

end

function Menu.InGameMenu()

    if love.keyboard.isDown("escape") then
        Menu.game_mode = "main_menu"
    end

    local background = Textures.backrooms
    love.graphics.draw(background, 0, 0)

    -- sale up to screen size
    local scale_x = love.graphics.getWidth() / background:getWidth()
    local scale_y = love.graphics.getHeight() / background:getHeight()
    love.graphics.draw(background, 0, 0, 0, scale_x, scale_y)

    local screen_width = love.graphics.getWidth()
    local screen_height = love.graphics.getHeight()
    local start_x = 100
    local start_y = 100

end

function Menu.OpenEditorMenu()


    if love.keyboard.isDown("escape") then
        Menu.game_mode = "main_menu"
    end
    local background = Textures.backrooms
    love.graphics.draw(background, 0, 0)

    -- sale up to screen size
    local scale_x = love.graphics.getWidth() / background:getWidth()
    local scale_y = love.graphics.getHeight() / background:getHeight()
    love.graphics.draw(background, 0, 0, 0, scale_x, scale_y)

    local start_x = 100
    local start_y = 100

    local function t_button(n, x, y)
        Button(x * 110, y * 110, "t"..n, 100, 100, function()
            LEVEL = Level.from_file("t"..n, "game/level_templates")
            Menu.game_mode = "game"
            DEBUG = true
            EDITOR_MODE = true
            Player.cam.zoom = 0.7
        end)
    end
    
    t_button(1, 0, 0)
    t_button(2, 1, 0)
    t_button(3, 2, 0)
    t_button(4, 3, 0)
    t_button(5, 4, 0)
    t_button(6, 5, 0)


end