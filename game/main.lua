--[[




WHAT IS NEEDED TIL RELEASE:

TECHNICAL:

- [ ] working doors to different level types
- [ ] collecting ORBS to find the exit door and open it
  - [ ] Orbs allow to open doors: different colored orbs
  - [ ] But also Orbs can be used to use magic
  - [ ] Some orbs are only dropped by some enemies
  - [ ] Other orbs can be found in containers
- [ ] design the exit door
- [ ] design orbs: one for each door type
- [ ] orbs need to glow/pulsate
- [ ] orbs have multiple uses: healing, increase max hp, improve weapon.
- [ ] add a "home" level
    - [ ] some doors are home doors on creation
    - [ ] those doors get another color
    - [ ] they lead back to the home level
    - [ ] comment this extensively

- [x] editor: add items, change layout
  - [x] Editor-input-function in player (maybe own file)
  - [x] disable monsters and other game logic in editor mode
  - [x] increase player speed
  - [x] saves during editor mode go into a different folder: those levels
        are then copied into the save-game folder when a game starts.
        Not all levels are designed, but some are, so there is sth. to discover.
        f.e. we can design some treasure rooms, and more difficult levels  by hand
        and have a certain rng that a new level is not randomly generated but
        taken from the designed levels

- [ ] save/load the player
- [x] add menu: new game, load game, exit

- [ ] add loot-drops for monsters (just create an item if a monster dies)

- [ ] add option to save game on exit and save in intervals

- [ ] delete the save game folder content if the game is started new or the player dies

- [ ] fix the status-bar of the player
  - [ ] add a loose condition and add a win condition:
       - you need to collect orbs AND find a Door -> then next level, end of demo

- [ ] create some equipment effects: bag, west, helmet, etc: more defense, more inventory-space, etc.


CONTENT:

- [ ] health items
- [ ] sanity items
- [x] more weapons
- [ ] bags
- [ ] more food items
- [ ] more monsters
- [ ] more blood splatter effects
- [ ] create a bunch of levels

LATER (non-demo-version):
- [ ] add throwables: grenades, Molotows, etc. (like projectiles until they hit a wall, also fly towards a point)
- [ ] add a fire system (fire can spread)
- [ ] currently the player can shoot through a wall: fix this
- [ ] add notes lying around
  - [ ] add text-box function: text box as an object with state(display duration, what char to display, etc.)
- [ ] add a marker function, to mark the floor
   - [ ] allow to choose a few symbols: home, arrow, cross
   - [ ] marker function needs item
- [ ] add build-ables: containers, barricades, sleeping bags, etc.

]]

require "utils"
require "Camera"
require "Maze"
require "Monster"
require "Item"
require "ShootingWeapon"
require "Sprite"
require "Level"
require "Cell"
require "Player"
require "Menu"
require "FileFunctions"
require "load_and_save_level"
require "player_editor_mode"

math.randomseed(os.time())

DEBUG = false
EDITOR_MODE = false
SAVE_PATH = "game/savegame" --- Here os the save game saved to. There is only one save game at a time: "Rouge-like"

LEVEL_TEMPLATES = {
    { name = "start_level_1", file_name = "t1", path = "game/level_templates/t1", },
    { name = "start_level_2", file_name = "t2", path = "game/level_templates/t2", },
    { name = "start_level_3", file_name = "t3", path = "game/level_templates/t3", },
    { name = "start_level_4", file_name = "t4", path = "game/level_templates/t3", },
    { name = "start_level_5", file_name = "t5", path = "game/level_templates/t3", }
}

-- todo; Create a script that we can use to generate a lot of mazes
--       Then we can auto-check those mazes for quality and also load them into
--       an editor for adding more details and objects
--Maze.export_raw_maze_as_png("maze.png", maze)
--for i = 1, 100 do
--  local maze = Maze.generate_a_maze(WORLD_X_TILES, WORLD_Y_TILES, 15, 1, 4)
--  Maze.export_raw_maze_as_png("maze_" .. i .. ".png", maze)
--end

Textures = {
    player = love.graphics.newImage("assets/player.png"),
    floor = love.graphics.newImage("assets/floor.png"),
    wall = love.graphics.newImage("assets/wall.png"),
    monster = love.graphics.newImage("assets/monster_2.png"),
    can = love.graphics.newImage("assets/can.png"),
    pointer_cursor = love.mouse.newCursor("assets/pointer.png", 0, 0),
    crosshair_cursor = love.mouse.newCursor("assets/crosshair.png", 0, 0),
    handgun = love.graphics.newImage("assets/handgun.png"),
    shooting_fire = love.graphics.newImage("assets/shooting_fire.png"),
    hit = love.graphics.newImage("assets/hit.png"),
    claimed_blood = love.graphics.newImage("assets/claimed_blood.png"),
    doorway = love.graphics.newImage("assets/door.png"),
    ammo_9mm = love.graphics.newImage("assets/ammo_9mm.png"),
    wallpaper = love.graphics.newImage("assets/wallpaper.png"),
    backrooms = love.graphics.newImage("assets/backrooms.jpg"),
    shotgun = love.graphics.newImage("assets/shotgun.png"),
    mp5 = love.graphics.newImage("assets/mp5.png"),
    ammo_10mm = love.graphics.newImage("assets/ammo_10mm.png"),
    ammo_12mm = love.graphics.newImage("assets/ammo_12mm.png"),
    grenade = love.graphics.newImage("assets/grenade.png"),
    door_green = love.graphics.newImage("assets/door_green.png"),
    door_red = love.graphics.newImage("assets/door_red.png"),
    door_blue = love.graphics.newImage("assets/door_blue.png"),
    door_yellow = love.graphics.newImage("assets/door_yellow.png"),
    door_purple = love.graphics.newImage("assets/door_purple.png"),
}

Sounds = {
    claimed_moan = love.audio.newSource("assets/claimed_moan.wav", "static"),
    shot = love.audio.newSource("assets/shot.wav", "static"),
}

----------------------------------------------
--- region LOAD
--- @param dt number
----------------------------------------------
function love.load()

    FileFunctions.initSaveFolder()
    love.graphics.setNewFont(12)
    music = love.audio.newSource("background.wav", "stream") -- the "stream" tells LÖVE to stream the file from disk, good for longer music track
    music:setVolume(1) -- 90% of ordinary volume
    music:setPitch(1) -- one octave lower
    music:setVolume(0.1)
    music:play()
    music:setLooping(true) -- loop the music

end

local key_cool_down = 0.5
----------------------------------------------
--- region UPDATE
--- @param dt number
----------------------------------------------
function love.update(dt)
    if Menu.game_mode == "game" then

        Player.editor_mode(dt)
        Item.progress_cooldown(dt)
        key_cool_down = key_cool_down - dt

        if love.keyboard.isDown("escape") then love.event.quit() end

        if love.keyboard.isDown("f1") and key_cool_down <= 0 then
            DEBUG = not DEBUG;
            key_cool_down = 0.5
        end

        if love.keyboard.isDown("f2") and key_cool_down <= 0 then
            Level.current_level:save_to_file()
            Player.save_player_to_file()
            key_cool_down = 0.5
        end

        if love.keyboard.isDown("f3") and key_cool_down <= 0 then
            Level.new(30, 15, 1, 4)
            key_cool_down = 0.5
        end

        if love.keyboard.isDown("f4") and key_cool_down <= 0 then
            EDITOR_MODE = not EDITOR_MODE
            if EDITOR_MODE then DEBUG = true
            else DEBUG = false end
            key_cool_down = 0.5
        end

        Level.current_level:update(dt, "game")

        if Player.inventory_is_open then
            -- set the mouse cursor to the pointer
            love.mouse.setCursor(Textures.pointer_cursor)
        end

    end -- end if Menu.game_mode == "game"
end

----------------------------------------------
--- region DRAW
----------------------------------------------
function love.draw()

    if Menu.game_mode == "main_menu" then
        Menu.MainMenu()
        return
    end

    if Menu.game_mode == "in_game_menu" then
        Menu.InGameMenu()
        return
    end

    if Menu.game_mode == "editor_menu" then
        Menu.OpenEditorMenu()
        return
    end

    Level.current_level:draw("game")
    Player.draw_editor_mode()

end
