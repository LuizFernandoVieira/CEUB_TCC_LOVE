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
local loveframes = require("loveframes")

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
-- CLASSES
------------
local GameObject = {}
local Player = {}
local Floor = {}
local Sprite = {}

------------
-- OBJECTS
------------
local physicsWorld = nil
local player = nil
local floor = nil

------------
-- DEBUG
------------
local mouseString = ""

------------
-- AUDIO
------------
local music
local volume = 0.5
local soundEffect

------------
-- JOYSTICKS
------------
local joystricks
local joystick

------------
-- LOAD
------------
function love.load()
  loveframesConfigurations()
  loveConfigurations()
  joystricksConfigurations()
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
  physicsWorld  = love.physics.newWorld(0, 9.81*32, true)
  player        = Player.new(love.graphics.getWidth()/2, love.graphics.getHeight()/2, "img/player_parado_32x32.png", 16, 32, 32, physicsWorld)
  floor         = Floor.new(0, love.graphics.getHeight(), physicsWorld)

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

  player.update(dt)

  local x, y = love.mouse.getPosition()
  mouseString = "Mouse Position: " .. x .. ", " .. y
end

function updateInputs()
  updateKeyInputs()
  updateMouseInputs()
  updateJoystickInputs()
end

function updateKeyInputs()
  if love.keyboard.isDown('a') then
    player:moveLeft()
  end
  if love.keyboard.isDown('d') then
    player:moveRight()
  end
  if love.keyboard.isDown('s') then
  end
end

function updateMouseInputs()
  if love.mouse.isDown(1) then
    mouseString = mouseString .. "\nLeft button pressed"
  end
  if love.mouse.isDown(2) then
    mouseString = mouseString .. "\nRight button pressed"
  end
  if love.mouse.isDown(3) then
    mouseString = mouseString .. "\nMiddle button pressed"
  end
end

function updateJoystickInputs()
  if not joystick then return end

  if joystick:isGamepadDown("dpleft") then
    player:moveLeft()
  elseif joystick:isGamepadDown("dpright") then
    player:moveRight()
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
  love.graphics.print(mouseString)
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
GameObject.new = function(x, y, image, physicsWorld)
  local self = self or {}

  self.x = x
  self.y = y

  return self
end

------------
-- PLAYER
------------
Player.new = function(x, y, image, frameCount, width, height, physicsWorld)
  local self = self or {}

  self.x                = x
  self.y                = y
  self.sprite           = Sprite.new(self, image, frameCount, width, height)
  self.grounded         = false
  self.physics          = {}
  self.physics.world    = physicsWorld
  self.physics.body     = love.physics.newBody(self.physics.world, self.x, self.y, "dynamic")
  self.physics.shape    = love.physics.newRectangleShape(32, 32)
  self.physics.fixture  = love.physics.newFixture(self.physics.body, self.physics.shape, 1)

  self.update = function(dt)
    self.sprite.update(dt)
  end

  self.draw = function()
    self.sprite.draw(
      self.image,
      self.physics.body:getX(),
      self.physics.body:getY()
    )
  end

  self.moveLeft = function()
    self.physics.body:applyForce(-300, 0)
  end

  self.moveRight = function()
    self.physics.body:applyForce(300, 0)
  end

  self.jump = function()
    if self.grounded == true then
      self.physics.body:applyLinearImpulse(0, -300)
    end
  end

  self.shot = function()
  end

  return self
end

------------
-- FLOOR
------------
Floor.new = function(x, y, physicsWorld)
  local self = self or {}

  self.x                = x
  self.y                = y
  self.physics          = {}
  self.physics.world    = physicsWorld
  self.physics.body     = love.physics.newBody(physicsWorld, love.graphics.getWidth()/2, love.graphics.getHeight())
  self.physics.shape    = love.physics.newRectangleShape(love.graphics.getWidth(), 32)
  self.physics.fixture  = love.physics.newFixture(self.physics.body, self.physics.shape)

  return self
end

------------
-- SPRITE
------------
Sprite.new = function(player, image, frameCout, width, height)
  local self = self or {}

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

  self.update = function(dt)
    self.timeElapsed = self.timeElapsed + dt

    if self.timeElapsed > 1 then
      if self.currentFrame < self.frameCout then
        self.currentFrame = self.currentFrame + 1
      else
        self.currentFrame = 1
      end
    end
  end

  self.draw = function(image, x, y)
    love.graphics.draw(
      self.image,
      self.frames[self.currentFrame],
      x,
      y
    )
  end

  return self
end
