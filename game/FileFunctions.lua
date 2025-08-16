-- https://love2d-community.github.io/love-api/#filesystem

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
function FileFunctions.getSaveFolderName() return "save" end


function FileFunctions.createSafeFolderIfNotExists()    
    local saveDir = FileFunctions.getSaveFolderName()
    if not love.filesystem.getInfo(saveDir) then
        love.filesystem.createDirectory(saveDir)
    end 
end

------------------------------------------------------------------------------
---
------------------------------------------------------------------------------

function FileFunctions.initSaveFolder()
    FileFunctions.createSafeFolderIfNotExists()
    print("Save directory (real path):", love.filesystem.getSaveDirectory())
end

------------------------------------------------------------------------------
---
------------------------------------------------------------------------------
function FileFunctions.deleteAllSavegames() 
    FileFunctions.createSafeFolderIfNotExists()
    local saveDir = FileFunctions.getSaveFolderName()
    local files = love.filesystem.getDirectoryItems(saveDir)
    for k, file in ipairs(files) do
        success = love.filesystem.remove( name )
        if not success then 
            error("Could not delete " .. name)
        end
    end 
end

------------------------------------------------------------------------------
---
------------------------------------------------------------------------------
function FileFunctions.getAllSafeGameFileNames() 
    FileFunctions.createSafeFolderIfNotExists()
    local saveDir = FileFunctions.getSaveFolderName()
    local files = love.filesystem.getDirectoryItems(saveDir)
    return files
end

------------------------------------------------------------------------------
---
------------------------------------------------------------------------------
function FileFunctions.setRawSaveGameFileContentLevel( content, name, overwrite )
    local saveDir = FileFunctions.getSaveFolderName()
    local path = saveDir .. "/" .. name
    success, message = love.filesystem.write( path, content )
    if not success then
        error ( message )
    end
end

------------------------------------------------------------------------------
---
------------------------------------------------------------------------------
function FileFunctions.getRawSaveGameFileContentLevel( name )
    local saveDir = FileFunctions.getSaveFolderName()
    local path = saveDir .. "/" .. name
    contents, size, contents, errorMsg = love.filesystem.read( path )
    if content == nil then 
        if errorMsg then 
            error( errorMsg )
        else 
            error( path .. " could not be read - nil but no error" )
        end
    end

end
------------------------------------------------------------------------------
---
------------------------------------------------------------------------------
function FileFunctions.setRawSaveGameFileContentPlayer( content )

end

------------------------------------------------------------------------------
---
------------------------------------------------------------------------------
function FileFunctions.getRawSaveGameFileContentPlayer() end

function FileFunctions.getLevelTemplates() end

function FileFunctions.getMapsItems() end
function FileFunctions.getMapImage() end
--function FileFunctions
