------------------------------------------------------------------------------
---
------------------------------------------------------------------------------
FileFunctions = {}

if false then
    -- Generiere zufälligen Dateinamen und Inhalt
    local name = tostring(math.random(0, 9999999999999))
    local path = saveDir .. "/" .. name
    local content = tostring(math.random(0, 9999999999999))

    -- Schreibe Datei
    local success, err = love.filesystem.write(path, content)
    print("Write success:", success, "Error:", err)

    -- Iteriere über alle Dateien im Save-Ordner
    local files = love.filesystem.getDirectoryItems(saveDir)
    for k, file in ipairs(files) do
        print(k .. ". " .. file)

        -- Lese den Inhalt der Datei
        local contents, size = love.filesystem.read(saveDir .. "/" .. file)
        print("Contents:", contents, "Size:", size)

        -- Hole Datei-Info
        local info = love.filesystem.getInfo(saveDir .. "/" .. file)
        if info then
            for a, b in pairs(info) do
                print(a, b)
            end
        end
    end
end

------------------------------------------------------------------------------
---
------------------------------------------------------------------------------
function FileFunctions.initSaveFolder()
    local saveDir = "save"
    if not love.filesystem.getInfo(saveDir) then
        love.filesystem.createDirectory(saveDir)
    end
    print("Save directory (real path):", love.filesystem.getSaveDirectory())
end

------------------------------------------------------------------------------
---
------------------------------------------------------------------------------
function FileFunctions.deleteAllSavegames() end

------------------------------------------------------------------------------
---
------------------------------------------------------------------------------
function FileFunctions.setRawSaveGameFileContentLevel(content, name) end

------------------------------------------------------------------------------
---
------------------------------------------------------------------------------
function FileFunctions.getRawSaveGameFileContentLevel(name) end

------------------------------------------------------------------------------
---
------------------------------------------------------------------------------
function FileFunctions.setRawSaveGameFileContentPlayer(content) end

------------------------------------------------------------------------------
---
------------------------------------------------------------------------------
function FileFunctions.getRawSaveGameFileContentPlayer() end