------------
-- Linguagem de Programação: LUA
-- Trabalho de Graduação
-- Centro Universitário de Brasília
-- Luiz Fernando Vieira de Castro Ferreira
-- 21416741
------------

------------
-- LIBS
------------
local loveframes  = require "loveframes"
local Gamestate   = require "hump.gamestate"
local Timer       = require "hump.timer"
local Class       = require "hump.class"
local Camera      = require "hump.camera"
------------
-- GUI
------------
local frame
local buttonPlay
local buttonQuit
local buttonSinglePlayer
local buttonMultiPlayer
local buttonBack
------------
-- CLASSES*
------------
local GameObject  = {}
local GameActor   = {}
local Player      = {}
local Floor       = {}
local Sprite      = {}
local Bow         = {}
GameObject.__index  = GameObject
GameActor.__index   = GameActor
Player.__index      = Player
Sprite.__index      = Sprite
Bow.__index         = Bow
------------
-- INHERITANCE
------------
setmetatable(GameObject, {
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})
setmetatable(GameActor, {
  __index = GameObject, -- this is what makes the inheritance work
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})
------------
-- OBJECTS
------------
local physicsWorld  = nil
local player        = nil
local floor         = nil
------------
-- DEBUG
------------
local debug       = false
local mouseString = ""
------------
-- AUDIO
------------
local music       = nil
local volume      = 0.5
local soundEffect = nil
------------
-- JOYSTICKS
------------
local joystricks
local joystick

------------
-- LOAD
------------
function love.load(arg)
  loveframesConfigurations()
  loveConfigurations()
  joystricksConfigurations()
  debugConfigurations(arg)
  loadGUI()
  loadObjects()
  loadAudio()
end

function loveframesConfigurations()
  loveframes.SetState("gameState")
end

function loveConfigurations()
  love.keyboard.setKeyRepeat(false)
  love.mouse.setCursor(love.mouse.getSystemCursor("hand"))
  love.physics.setMeter(32)
  love.graphics.setNewFont(24)
  love.graphics.setBackgroundColor(200,200,200,100)
  love.audio.setVolume(volume)
end

function joystricksConfigurations()
  joysticks = love.joystick.getJoysticks()
  joystick = joysticks[1]
end

function debugConfigurations()
  if(agr ~= nil) then
    debug = true
  end
end

function loadGUI()
  loadButtonPlay()
  loadButtonQuit()
  loadButtonSinglePlayer()
  loadButtonMultiPlayer()
  loadButtonBack()
end

function loadButtonPlay()
  buttonPlay = loveframes.Create("button")
  buttonPlay: SetSize(200,50):
              SetText("Play"):
              CenterX():
              CenterY():
              SetState("mainMenuState")
  buttonPlay.OnClick = function()
    loveframes.SetState("gameState")
  end
  buttonPlay.OnMouseEnter = function()
  end
  buttonPlay.OnMouseExit = function()
  end
end

function loadButtonQuit()
  buttonQuit = loveframes.Create("button")
  buttonQuit: SetSize(200, 50):
              SetText("Quit"):
              CenterX():
              SetY(love.graphics.getHeight()/2 + 50):
              SetState("mainMenuState")
  buttonQuit.OnClick = function()
    love.event.push('quit')
  end
  buttonQuit.OnMouseEnter = function()
  end
  buttonQuit.OnMouseExit = function()
  end
end

function loadButtonSinglePlayer()
  buttonSinglePlayer = loveframes.Create("button")
  buttonSinglePlayer: SetSize(200, 50):
                      SetText("Single Player"):
                      CenterX():
                      CenterY():
                      SetState("playMenuState")
end

function loadButtonMultiPlayer()
  buttonMultiPlayer = loveframes.Create("button")
  buttonMultiPlayer:  SetSize(200, 50):
                      SetText("Multi Player"):
                      CenterX():
                      SetY(love.graphics.getHeight()/2 + 50):
                      SetState("playMenuState")
end

function loadButtonBack()
  buttonBack = loveframes.Create("button")
  buttonBack: SetSize(200, 50):
              SetText("Back"):
              CenterX():
              SetY(love.graphics.getHeight()/2 + 125):
              SetState("playMenuState")
end

function loadObjects()
  physicsWorld  = love.physics.newWorld(0, 9.81*128, true)
  player        = Player.new(love.graphics.getWidth()/2, love.graphics.getHeight()/2, "img/player.png", 1, 32, 32, physicsWorld)
  floor         = Floor.new(0, love.graphics.getHeight() - 32, physicsWorld)

  physicsWorld:setCallbacks(beginContact, endContact, preSolve, postSolve)
end

function loadAudio()
  music = love.audio.newSource("audio/music.mp3") -- music:play()
  soundEffect = love.audio.newSource("audio/audio_coin.ogg", "static")
end

------------
-- UPDATE
------------
function love.update(dt)
  loveframes.update(dt)
  physicsWorld:update(dt)
  updateInputs()

  player:update(dt)

  updateDebug()
end

function updateDebug()
  if(debug == true) then
    -- local x, y = love.mouse.getPosition()
    -- mouseString = "Mouse Position: " .. x .. ", " .. y
  end
end

function updateInputs()
  updateKeyInputs()
  updateMouseInputs()
  updateJoystickInputs()
end

function updateKeyInputs()
  if love.keyboard.isDown('a') then
    player:moveLeft()
  elseif love.keyboard.isDown('d') then
    player:moveRight()
  else
    player.desiredVelocity = 0
  end

  if love.keyboard.isDown('s') then
  end
end

function updateMouseInputs()
  if love.mouse.isDown(1) then
    if(debug == true) then
      -- mouseString = mouseString .. "\nLeft button pressed"
    end
  end
  if love.mouse.isDown(2) then
    if(debug == true) then
      -- mouseString = mouseString .. "\nRight button pressed"
    end
  end
  if love.mouse.isDown(3) then
    if(debug == true) then
      -- mouseString = mouseString .. "\nMiddle button pressed"
    end
  end
end

function updateJoystickInputs()
  if not joystick then return end

  if  joystick:isGamepadDown("dpleft") or
      joystick:getGamepadAxis("leftx") < -0.2 then
    player:moveLeft()
  elseif  joystick:isGamepadDown("dpright") or
          joystick:getGamepadAxis("leftx") > 0.2 then
    player:moveRight()
  else
    player.desiredVelocity = 0
  end

  if joystick:getGamepadAxis("lefty") < -0.7 then
    player:jump()
  end

  if joystick:getGamepadAxis("righty") < -0.7 then
    player.bow:changeAngle(270)
  end
  if joystick:getGamepadAxis("rightx") > 0.7 then
    player.bow:changeAngle(0)
  end
  if joystick:getGamepadAxis("righty") > 0.7 then
    player.bow:changeAngle(90)
  end
  if joystick:getGamepadAxis("rightx") < -0.7 then
    player.bow:changeAngle(180)
  end

  if  joystick:getGamepadAxis("righty") < -0.5 and
      joystick:getGamepadAxis("rightx") >  0.5 then
    player.bow:changeAngle(315)
  end
  if  joystick:getGamepadAxis("righty") >  0.5 and
      joystick:getGamepadAxis("rightx") >  0.5 then
    player.bow:changeAngle(45)
  end
  if  joystick:getGamepadAxis("righty") >  0.5 and
      joystick:getGamepadAxis("rightx") <  -0.5 then
    player.bow:changeAngle(135)
  end
  if  joystick:getGamepadAxis("righty") < -0.5 and
      joystick:getGamepadAxis("rightx") < -0.5 then
    player.bow:changeAngle(225)
  end

  if joystick:isGamepadDown("dpdown") then
  end
end

------------
-- COLLISION
------------

function beginContact(a, b, coll)
  player.grounded = true
end

function endContact(a, b, coll)
end

function preSolve(a, b, coll)
end

function postSolve(a, b, coll, normalimpulse, tangentimpulse)
end

------------
-- DRAW
------------
function love.draw()
  loveframes.draw()

  player:draw()

  drawDebug()

  love.graphics.print(mouseString)
end

function drawDebug()
  if(debug == true) then
    love.graphics.setColor(250, 116, 107)
    love.graphics.polygon("line", floor.physics.body:getWorldPoints(floor.physics.shape:getPoints()))

    love.graphics.setColor(189, 252, 196)
    love.graphics.rectangle("line", player.physics.body:getX(), player.physics.body:getY(), 32, 32)
  end
end

------------
-- QUIT
------------
function love.quit()
end

------------
-- KEYS
------------
function love.keypressed(key, unicode)
  loveframes.keypressed(key, unicode)

  if key == "w" then
    player:jump()
  end
  if key == "space" then
    player:shot()
  end

  if key == "up" then
    print("UP")
    player.bow:changeAngle(270)
  end
  if key == "right" then
    print("RIGHT")
    player.bow:changeAngle(0)
  end
  if key == "down" then
    print("DOWN")
    player.bow:changeAngle(90)
  end
  if key == "left" then
    print("LEFT")
    player.bow:changeAngle(180)
  end
  if key == "up" and love.keyboard.isDown('left') then
    print("UP LEFT")
    player.bow:changeAngle(225)
  end
  if key == "up" and love.keyboard.isDown('right') then
    print("UP RIGHT")
    player.bow:changeAngle(315)
  end
  if key == "down" and love.keyboard.isDown('left') then
    print("UP RIGHT")
    player.bow:changeAngle(135)
  end
  if key == "down" and love.keyboard.isDown('right') then
    print("UP RIGHT")
    player.bow:changeAngle(45)
  end
end

function love.keyreleased(key)
  loveframes.keyreleased(key)
end

------------
-- MOUSE
------------
function love.mousepressed(x, y, button)
  loveframes.mousepressed(x, y, button)
end

function love.mousereleased(x, y, button)
   loveframes.mousereleased(x, y, button)
end

------------
-- LOVEFRAMES MOUSE
------------
function loveframes.mousepressed(x, y, button)
  print("loveframes.mousepressed")
end

function loveframes.mousereleased(x, y, button)
  print("loveframes.mousereleased")
end

function loveframes.textinput(text)
end

------------
-- GAMEPAD
------------
function love.gamepadpressed(joystick, button)
  if button == "a" then
  end
  if button == "b" then
  end
  if button == "x" then
    player:shot()
  end
  if button == "y" then
  end
  if button == "dpup" then
    player:jump()
  end
end

function love.gamepadreleased(joystick, button)
end

------------
-- JOYSTICKS
------------
function love.joystickreleased(joystick, button)
end

function love.joystickreleased(key)
end

function love.joystickadded(joystick)
end

function love.joystickremoved(joystick)
end

------------
-- GAME OBJECT
------------
function GameObject:_init(physicsWorld)
  self.physics          = {}
  self.physics.world    = physicsWorld
end

function GameObject:get_physics()
  return self.physics
end

function GameObject:get_physicsWorld()
  return self.physics.world
end

------------
-- GAME ACTOR
------------
function GameActor:_init(physicsWorld, x, y)
  GameObject._init(self, physicsWorld) -- call the base class constructor

  self.physics.body     = love.physics.newBody(physicsWorld, x, y, "dynamic")
  self.physics.shape    = love.physics.newRectangleShape(32, 32)
  self.physics.fixture  = love.physics.newFixture(self.physics.body, self.physics.shape, 1)
end

function GameActor:moveLeft()
  self.physics.body:applyForce(-300, 0)
end

function GameActor:moveRight()
  self.physics.body:applyForce(300, 0)
end

function GameActor:get_Body()
  return self.physics.body
end

function GameActor:get_Shape()
  return self.physics.shape
end

function GameActor:get_Fixture()
  return self.physics.fixture
end

------------
-- BOW
------------
Bow.new = function(player, image, physicsWorld)
  local self = setmetatable({}, Bow)

  self.player           = player
  self.angle            =  0
  self.sprite           = Sprite.new(self, image, 1, 32, 32)
  self.physics          = {}
  self.physics.world    = physicsWorld
  self.physics.body     = love.physics.newBody(self.physics.world, player.physics.body:getX() , player.physics.body:getY(), "dynamic")
  self.physics.shape    = love.physics.newRectangleShape(32, 32)
  self.physics.fixture  = love.physics.newFixture(self.physics.body, self.physics.shape, 1)

  self.physics.fixture:setMask(2)
  self.physics.fixture:setFilterData(1, 0, 0)

  return self
end

Bow.update = function(self, dt)
  self.physics.body:setPosition(player.physics.body:getPosition())
end

Bow.draw = function(self)
  self.sprite:drawRotation(
    self.image,
    self.physics.body:getAngle(),
    self.physics.body:getX(),
    self.physics.body:getY()
  )
end

Bow.changeAngle = function(self, angle)
  self.physics.body:setAngle(angle)
end

Bow.shot = function(self)
end

------------
-- PLAYER
------------
Player.new = function(x, y, image, frameCount, width, height, physicsWorld)
  local self = setmetatable({}, Player)

  self.sprite           = Sprite.new(self, image, frameCount, width, height)
  self.facingRight      = true
  self.grounded         = false
  self.physics          = {}
  self.physics.world    = physicsWorld
  self.physics.body     = love.physics.newBody(self.physics.world, x, y, "dynamic")
  self.physics.shape    = love.physics.newRectangleShape(32, 32)
  self.physics.fixture  = love.physics.newFixture(self.physics.body, self.physics.shape, 1)
  self.desiredVelocity  = 0
  self.bow              = Bow.new(self, "img/bow.png", physicsWorld)

  self.physics.body:setMass(0.5)
  self.physics.fixture:setMask(2)
  return self
end

Player.update = function(self, dt)
  self.sprite:update(dt)

  -- i = m * dv
  local velChange = self.desiredVelocity - self.physics.body:getLinearVelocity();
  local impulse = self.physics.body:getMass() * velChange;

  self.physics.body:applyLinearImpulse(impulse, 0)

  self.bow:update(dt)
end

Player.draw = function(self)
  self.sprite:draw(
    self.image,
    self.facingRight,
    self.physics.body:getX(),
    self.physics.body:getY()
  )
  self.bow:draw()
end

Player.moveLeft = function(self)
  if self.facingRight == true then
    self.facingRight = false
  end
  self.desiredVelocity = -150
end

Player.moveRight = function(self)
  if self.facingRight ~= true then
    self.facingRight = true
  end
  self.desiredVelocity = 150
end

Player.jump = function(self)
  if self.grounded == true then
    local impulse = self.physics.body:getMass() * 500;
    self.physics.body:applyLinearImpulse(0, -impulse)
    self.grounded = false
  end
end

Player.shot = function(self)
end

------------
-- FLOOR
------------
Floor.new = function(x, y, physicsWorld)
  local self = self or {}

  self.physics          = {}
  self.physics.world    = physicsWorld
  self.physics.body     = love.physics.newBody(physicsWorld, x + love.graphics.getWidth()/2 , y)
  self.physics.shape    = love.physics.newRectangleShape(love.graphics.getWidth(), 32)
  self.physics.fixture  = love.physics.newFixture(self.physics.body, self.physics.shape)

  return self
end

------------
-- SPRITE
------------
Sprite.new = function(player, image, frameCout, width, height)
  local self = setmetatable({}, Sprite)

  self.parent       = player
  self.image        = love.graphics.newImage(image)
  self.frames       = {}
  self.frameCout    = frameCout
  self.currentFrame = 1
  self.timeElapsed  = 0
  self.frameTime    = 1

  for i=1, frameCout, 1 do
    self.frames[i] = love.graphics.newQuad(
      (i-1)*(self.image:getWidth() / frameCout),
      0,
      self.image:getWidth() / frameCout,
      self.image:getHeight(),
      self.image:getDimensions()
     )
  end

  return self
end

Sprite.update = function(self, dt)
  self.timeElapsed = self.timeElapsed + dt

  if self.timeElapsed > 1 then
    if self.currentFrame < self.frameCout then
      self.currentFrame = self.currentFrame + 1
    else
      self.currentFrame = 1
    end
  end
end

Sprite.draw = function(self, image, facingRight, x, y)
  local w = self.image:getWidth() / self.frameCout
  if facingRight == true then
    love.graphics.draw(
      self.image,
      self.frames[self.currentFrame],
      x,y
    )
  else
    love.graphics.draw(
      self.image,
      self.frames[self.currentFrame],
      x, y, 0, -1, 1, w, 0
    )
  end
end

Sprite.drawRotation = function(self, image, angle, x, y)
  love.graphics.draw(
    self.image,
    self.frames[self.currentFrame],
    x + self.image:getWidth()/2, y + self.image:getHeight()/2, math.rad(angle), 1, 1, -self.image:getWidth()/2, self.image:getHeight()/2
  )
end
