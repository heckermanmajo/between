--- Camera 2D implementation for LÖVE; used in battle AND camp.
--- @class Camera
--- @field x number Camera's x-coordinate
--- @field y number Camera's y-coordinate
--- @field zoom number Camera's zoom level
--- @field rotation number Camera's rotation angle
Camera = {}
Camera.__index = Camera

--- Creates a new Camera instance
--- @param x number Initial x-coordinate
--- @param y number Initial y-coordinate
--- @param zoom number Initial zoom level
--- @param rotation number Initial rotation angle
--- @return Camera
function Camera.new(x, y, zoom, rotation)

  x = x or 0
  y = y or 0
  zoom = zoom or 1
  rotation = rotation or 0

  assert(type(x) == "number", "x must be a number")
  assert(type(y) == "number", "y must be a number")
  assert(type(zoom) == "number" and zoom > 0, "zoom must be a positive number")
  assert(type(rotation) == "number", "rotation must be a number")

  local self = setmetatable({}, Camera)
  self.x = x
  self.y = y
  self.zoom = zoom
  self.rotation = rotation
  self.minimap = false

  self.isDragging = false
  self.dragStartX = 0
  self.dragStartY = 0

  return self
end

--- Moves the camera relative to its current position
--- @param dx number Change in x-coordinate
--- @param dy number Change in y-coordinate
function Camera:move(dx, dy)
  assert(type(dx) == "number", "dx must be a number")
  assert(type(dy) == "number", "dy must be a number")

  self.x = math.floor(self.x + dx)
  self.y = math.floor(self.y + dy)
end

--- Adjusts the zoom level incrementally
--- @param dzoom number Change in zoom level
function Camera:zoomBy(dzoom)
  assert(type(dzoom) == "number", "dzoom must be a number")

  -- other Zoom steps than 0.2 fuck up tile alignment ...
  if dzoom > 0 then
    self.zoom = self.zoom + 0.2
  else
    self.zoom = self.zoom - 0.2
  end

  if self.zoom == 0.27 then
    self.zoom = 0.2
  end
  -- round to 2 decimal places
  --self.zoom = math.floor(self.zoom * 10 + 0.5) / 10

  if self.zoom < 0.07 then
    self.zoom = 0.07
    self.minimap = true
  else
    self.minimap = false
  end -- Prevent zooming too far out
end

--- Sets the camera rotation
--- @param rotation number New rotation angle
function Camera:setRotation(rotation)
  assert(type(rotation) == "number", "rotation must be a number")

  self.rotation = rotation
end

--- Rotates the camera incrementally
--- @param drotation number Change in rotation angle
function Camera:rotate(drotation)
  assert(type(drotation) == "number", "drotation must be a number")

  self.rotation = self.rotation + drotation
end

--- Applies the camera transformations
function Camera:attach()
  love.graphics.push()
  love.graphics.translate(love.graphics.getWidth() / 2, love.graphics.getHeight() / 2)
  love.graphics.scale(self.zoom, self.zoom)
  love.graphics.rotate(self.rotation)
  love.graphics.translate(-self.x, -self.y)
end

--- Resets transformations to their original state
function Camera:detach()
  love.graphics.pop()
end

--- Checks if a rectangle is in view
--- @param rectX number Rectangle's x-coordinate
--- @param rectY number Rectangle's y-coordinate
--- @param rectWidth number Rectangle's width
--- @param rectHeight number Rectangle's height
--- @return boolean True if the rectangle is in view
function Camera:rectInView(rectX, rectY, rectWidth, rectHeight)
  assert(type(rectX) == "number", "rectX must be a number")
  assert(type(rectY) == "number", "rectY must be a number")
  assert(type(rectWidth) == "number" and rectWidth >= 0, "rectWidth must be a non-negative number")
  assert(type(rectHeight) == "number" and rectHeight >= 0, "rectHeight must be a non-negative number")

  local screenWidth = love.graphics.getWidth()
  local screenHeight = love.graphics.getHeight()

  local viewLeft = self.x - (screenWidth / 2) / self.zoom
  local viewRight = self.x + (screenWidth / 2) / self.zoom
  local viewTop = self.y - (screenHeight / 2) / self.zoom
  local viewBottom = self.y + (screenHeight / 2) / self.zoom

  local rectRight = rectX + rectWidth
  local rectBottom = rectY + rectHeight

  return rectRight > viewLeft and rectX < viewRight and rectBottom > viewTop and rectY < viewBottom
end

--- Handles mouse dragging to move the camera
--- @param isPressed boolean Whether the middle mouse button is pressed
--- @param mouseX number Current mouse x-coordinate
--- @param mouseY number Current mouse y-coordinate
function Camera:handleMouseDrag(isPressed, mouseX, mouseY)
  if isPressed then
    if not self.isDragging then
      self.isDragging = true
      self.dragStartX = mouseX
      self.dragStartY = mouseY
    else
      local dx = (self.dragStartX - mouseX) / self.zoom
      local dy = (self.dragStartY - mouseY) / self.zoom
      self:move(dx, dy)
      self.dragStartX = mouseX
      self.dragStartY = mouseY
    end
  else
    self.isDragging = false
  end
end

--- Prints camera information on the screen
--- @param x number The x-coordinate to print the information
--- @param y number The y-coordinate to print the information
--- @return nil
function Camera:print_camera_info_on_screen(x, y)
  love.graphics.setColor(1, 1, 1)
  love.graphics.print("Camera x: " .. self.x, x, y)
  love.graphics.print("Camera y: " .. self.y, x, y + 20)
  love.graphics.print("Camera zoom: " .. self.zoom, x, y + 40)
  love.graphics.print("Camera rotation: " .. self.rotation, x, y + 60)
end

--- Handles movement based on WASD keys
--- @param dt number Delta time
function Camera:apply_wasd_movement(dt)
  --- @type number
  local speed = 1000
  if love.keyboard.isDown("w") then self.y = math.floor(self.y - speed * dt) end
  if love.keyboard.isDown("a") then self.x = math.floor(self.x - speed * dt) end
  if love.keyboard.isDown("s") then self.y = math.floor(self.y + speed * dt) end
  if love.keyboard.isDown("d") then self.x = math.floor(self.x + speed * dt) end

  -- Rotate camera on R key
  if love.keyboard.isDown("r") then self.rotation = self.rotation + 1 * dt end
end

--- Transforms screen coordinates to screen coordinates
--- @param screen_x number Screen x-coordinate
--- @param screen_y number Screen y-coordinate
--- @return number, number World x and y coordinates
function Camera:transform_screen_xy_to_world_xy(screen_x, screen_y)
  assert(type(screen_x) == "number", "screen_x must be a number")
  assert(type(screen_y) == "number", "screen_y must be a number")
  local world_x = (screen_x - love.graphics.getWidth() / 2) / self.zoom + self.x
  local world_y = (screen_y - love.graphics.getHeight() / 2) / self.zoom + self.y
  return world_x, world_y
end