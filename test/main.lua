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
local Bow         = {}
local Arrow       = {}
local Floor       = {}
local Tile        = {}
local Sprite      = {}
GameObject.__index  = GameObject
GameActor.__index   = GameActor
Player.__index      = Player
Bow.__index         = Bow
Arrow.__index       = Arrow
Sprite.__index      = Sprite
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
  __index = GameObject,
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})
------------
-- TABLES
------------
local players       = {}
local tiles         = {}
local arrows        = {}
------------
-- OBJECT
------------
local physicsWorld  = nil
local player        = nil
------------
-- CONSTANTS
------------
local GRAVITY_SCALE = 9.81 * 128
------------
-- DEBUG
------------
local debug       = true
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
  love.audio.setVolume(volume)

  if not debug then
    love.graphics.setBackgroundColor(200,200,200,100)
  else
    love.graphics.setBackgroundColor(0,0,0,100)
  end
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
  loadPhysicsWorld()
  loadTileMap()
  loadPlayer()
  physicsWorld:setCallbacks(beginContact, endContact, preSolve, postSolve)
end

function loadPhysicsWorld()
  physicsWorld = love.physics.newWorld(0, GRAVITY_SCALE, true)
end

function loadTileMap()
  map={
  	{ 01, 01, 01, 01, 01, 01, 01, 01, 00, 00, 00, 01, 01, 01, 01, 00, 00, 00, 01, 01, 01, 01, 01, 01, 01, 01},
  	{ 01, 01, 01, 00, 00, 00, 00, 00, 00, 00, 00, 01, 01, 01, 01, 00, 00, 00, 00, 00, 00, 00, 00, 01, 01, 01},
  	{ 01, 01, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 01, 01},
  	{ 01, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 01},
  	{ 01, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 01},
  	{ 01, 00, 00, 00, 00, 00, 00, 00, 00, 01, 01, 00, 00, 00, 00, 01, 01, 00, 00, 00, 00, 00, 00, 00, 00, 01},
    { 01, 00, 00, 00, 01, 01, 01, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 01, 01, 01, 00, 00, 00, 01},
  	{ 01, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 01, 01, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 01},
  	{ 01, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 01},
  	{ 01, 01, 01, 00, 00, 00, 00, 00, 01, 01, 00, 00, 00, 00, 00, 00, 01, 01, 00, 00, 00, 00, 00, 00, 00, 01},
  	{ 01, 01, 00, 00, 00, 00, 00, 00, 01, 00, 00, 00, 00, 00, 00, 00, 00, 01, 00, 00, 00, 00, 00, 00, 00, 01},
  	{ 00, 00, 00, 00, 00, 00, 01, 01, 01, 00, 00, 00, 00, 00, 00, 00, 00, 01, 01, 01, 00, 00, 00, 00, 00, 00},
    { 00, 00, 00, 00, 00, 00, 01, 01, 01, 00, 00, 00, 00, 00, 00, 00, 00, 01, 01, 01, 00, 00, 00, 00, 00, 00},
  	{ 00, 00, 00, 00, 00, 00, 00, 00, 01, 00, 00, 00, 00, 00, 00, 00, 00, 01, 00, 00, 00, 00, 00, 00, 00, 00},
  	{ 01, 01, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 01, 01},
  	{ 01, 01, 00, 00, 01, 01, 00, 00, 00, 00, 00, 00, 01, 01, 00, 00, 00, 00, 00, 00, 01, 01, 00, 00, 01, 01},
  	{ 01, 01, 00, 00, 01, 01, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 01, 01, 00, 00, 01, 01},
  	{ 01, 01, 01, 01, 01, 01, 01, 01, 01, 00, 00, 00, 00, 00, 00, 00, 00, 01, 01, 01, 01, 01, 01, 01, 01, 01},
    { 01, 01, 01, 01, 01, 01, 01, 01, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 01, 01, 01, 01, 01, 01, 01, 01},
    { 01, 01, 01, 01, 01, 01, 01, 01, 00, 00, 00, 01, 01, 01, 01, 00, 00, 00, 01, 01, 01, 01, 01, 01, 01, 01}
  }

  mapX = 1
  mapY = 1
  tilesDisplayWidth = 26
  tilesDisplayHeight = 20

  zoomX = 1
  zoomY = 1

  tilesetImage = love.graphics.newImage( "img/tile_set.png" )
  tilesetImage:setFilter("nearest", "linear")
  tileSize = 32

  tileQuads = {}
  for y=0, 1-1 do
    for x=0, 2-1 do
      tileQuads[x+(y*5)] = love.graphics.newQuad(
        x * tileSize,
        y * tileSize,
        tileSize,
        tileSize,
        tilesetImage:getWidth(),
        tilesetImage:getHeight()
      )
    end
  end

  for y=0, tilesDisplayHeight-1 do
    for x=0, tilesDisplayWidth-1 do
      if map[y+mapY][x+mapX] == 01 then
        tiles[x+(y*tilesDisplayWidth)] = Tile.new(x * tileSize, y * tileSize, physicsWorld)
      end
    end
  end

  tilesetBatch = love.graphics.newSpriteBatch(tilesetImage, tilesDisplayWidth * tilesDisplayHeight)
  updateTilesetBatch()
end

function loadPlayer()
  player = Player.new(
    love.graphics.getWidth()/2,
    love.graphics.getHeight()/2,
    "img/player.png", 1, 32, 32,
    physicsWorld
  )
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
  arrows.update(dt)

  handleSpecialCollision()

  updateDebug()
end

function handleSpecialCollision()
  if player.physics.body:getX() < -16 then
    player.physics.body:setX(25*32 + 16)
  elseif player.physics.body:getX() > 25*32 + 16 then
    player.physics.body:setX(16)
  elseif player.physics.body:getY() < 0  then
    player.physics.body:setY(32*20)
  elseif player.physics.body:getY() > 32*20  then
    player.physics.body:setY(0)
  end
end

function updateDebug()
  if(debug == true) then
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

  if love.keyboard.isDown('left') then
    player.bow:changeAngle(180)
  end
  if love.keyboard.isDown('right') then
    player.bow:changeAngle(0)
  end

  if  love.keyboard.isDown('up') and
  not love.keyboard.isDown('left') and
  not love.keyboard.isDown('right') then
    player.bow:changeAngle(270)
  elseif love.keyboard.isDown('up') and
  not love.keyboard.isDown('left') and
      love.keyboard.isDown('right') then
    player.bow:changeAngle(315)
  elseif love.keyboard.isDown('up') and
      love.keyboard.isDown('left') and
  not love.keyboard.isDown('right') then
    player.bow:changeAngle(225)
  end

  if  love.keyboard.isDown('down') and
  not love.keyboard.isDown('left') and
  not love.keyboard.isDown('right') then
    player.bow:changeAngle(90)
  elseif love.keyboard.isDown('down') and
  not love.keyboard.isDown('left') and
      love.keyboard.isDown('right') then
    player.bow:changeAngle(45)
  elseif love.keyboard.isDown('down') and
      love.keyboard.isDown('left') and
  not love.keyboard.isDown('right') then
    player.bow:changeAngle(135)
  end
end

function updateMouseInputs()
  if love.mouse.isDown(1) then
    if(debug == true) then
    end
  end
  if love.mouse.isDown(2) then
    if(debug == true) then
    end
  end
  if love.mouse.isDown(3) then
    if(debug == true) then
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

function updateTilesetBatch()
  tilesetBatch:clear()
  for y=0, tilesDisplayHeight-1 do
    for x=0, tilesDisplayWidth-1 do
      tilesetBatch:add(tileQuads[map[y+mapY][x+mapX]], x*tileSize, y*tileSize)
    end
  end
  tilesetBatch:flush()
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

  if not debug then
    drawTiles()

    player:draw()
    arrows.draw()
  end

  drawDebug()

  love.graphics.print(mouseString)
end

function drawTiles()
  love.graphics.draw(tilesetBatch)
end

function drawDebug()
  if(debug == true) then

    drawPlayerDebug()
    drawTilesDebug()

    love.graphics.setColor(255, 255, 255)
  end
end

function drawPlayerDebug()
  love.graphics.setColor(255, 0, 0, 50)
  love.graphics.rectangle(
    "fill",
    player.physics.body:getX(),
    player.physics.body:getY(),
    32, 32
  )
  love.graphics.setColor(255, 0, 0)
  love.graphics.rectangle(
    "line",
    player.physics.body:getX(),
    player.physics.body:getY(),
    32, 32
  )
end

function drawTilesDebug()
  love.graphics.setColor(0, 255, 0)
  for y=0, tilesDisplayHeight-1 do
    for x=0, tilesDisplayWidth-1 do
      if map[y+mapY][x+mapX] == 01 then
        love.graphics.setColor(0, 255, 0, 50)
        love.graphics.rectangle(
          "fill",
          x * tileSize, y * tileSize,
          tileSize, tileSize
        )
        love.graphics.setColor(0, 255, 0)
        love.graphics.rectangle(
          "line",
          x * tileSize, y * tileSize,
          tileSize, tileSize
        )
      end
    end
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
  if key == "r" then
    if debug == true then debug = false
    else debug = true end
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
-- LISTS
------------
function arrows.update(dt)
  for i, v in ipairs(arrows) do
    v:update(dt)
  end
end

function arrows.draw()
  for i, v in ipairs(arrows) do
    v:draw()
  end
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
  GameObject._init(self, physicsWorld)

  self.physics.body     = love.physics.newBody(physicsWorld, x, y, "dynamic")
  self.physics.shape    = love.physics.newRectangleShape(32, 32)
  self.physics.fixture  = love.physics.newFixture(
                            self.physics.body,
                            self.physics.shape,
                            1
                          )
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
-- ARROW
------------
Arrow.new = function(physicsWorld, bow, angle)
  local self = setmetatable({}, Arrow)

  self.bow              = bow
  self.sprite           = Sprite.new(self, "img/arrow.png", 1, 32, 32)
  self.physics          = {}
  self.physics.world    = physicsWorld
  self.physics.body     = love.physics.newBody(
                            self.physics.world,
                            self.bow.physics.body:getX(),
                            self.bow.physics.body:getY(),
                            "dynamic"
                          )
  self.physics.shape    = love.physics.newPolygonShape(
                            -1.4*16, 0,
                            0, -0.1*16,
                            0.6*16, 0,
                            0, 0.1*16
                          )
  self.physics.fixture  = love.physics.newFixture(
                            self.physics.body,
                            self.physics.shape,
                            1
                          )

  self.physics.fixture:setMask(2)
  self.physics.fixture:setFilterData(1, 0, 0)
  self.physics.body:isBullet()
  self.physics.body:setMass(0.1)
  self.physics.body:setGravityScale(0.5)

  return self
end

Arrow.update = function(self, dt)
end

Arrow.draw = function(self)
  self.sprite:draw(
    self.image,
    true,
    self.physics.body:getX(),
    self.physics.body:getY()
  )
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
  self.physics.body     = love.physics.newBody(
                            self.physics.world,
                            player.physics.body:getX(),
                            player.physics.body:getY(),
                            "dynamic"
                          )
  self.physics.shape    = love.physics.newRectangleShape(32, 32)
  self.physics.fixture  = love.physics.newFixture(
                            self.physics.body,
                            self.physics.shape,
                            1
                          )

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
  local arrow = Arrow.new(physicsWorld, self, self.angle)
  table.insert(arrows, arrow)

  local impulse = 0.1 * 600;
  local ang = self.physics.body:getAngle()

  if ang == 0 then
    arrow.physics.body:applyLinearImpulse( impulse, 0      )
  elseif ang == 45 then
    arrow.physics.body:applyLinearImpulse( impulse, impulse)
  elseif ang == 90 then
    arrow.physics.body:applyLinearImpulse(       0, impulse)
  elseif ang == 135 then
    arrow.physics.body:applyLinearImpulse(-impulse, impulse)
  elseif ang == 180 then
    arrow.physics.body:applyLinearImpulse(-impulse, 0      )
  elseif ang == 225 then
    arrow.physics.body:applyLinearImpulse(-impulse,-impulse)
  elseif ang == 270 then
    arrow.physics.body:applyLinearImpulse(       0,-impulse)
  elseif ang == 315 then
    arrow.physics.body:applyLinearImpulse( impulse,-impulse)
  else
    arrow.physics.body:applyLinearImpulse( impulse, 0      )
  end

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
  self.physics.body     = love.physics.newBody(
                            self.physics.world,
                            x - self.sprite:getWidth()/2,
                            y - self.sprite:getHeight()/2,
                            "dynamic"
                          )
  self.physics.shape    = love.physics.newRectangleShape(
                            self.sprite:getWidth(),
                            self.sprite:getHeight()
                          )
  self.physics.fixture  = love.physics.newFixture(
                            self.physics.body,
                            self.physics.shape,
                            1
                          )
  self.desiredVelocity  = 0
  self.bow              = Bow.new(self, "img/bow.png", physicsWorld)

  self.physics.body:setMass(0.5)
  self.physics.fixture:setMask(2)
  return self
end

Player.update = function(self, dt)
  self.sprite:update(dt)

  -- i = m * dv
  local velChange =
    self.desiredVelocity - self.physics.body:getLinearVelocity();
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
  self.bow:shot()
end

------------
-- FLOOR
------------
Floor.new = function(x, y, physicsWorld)
  local self = self or {}

  self.physics          = {}
  self.physics.world    = physicsWorld
  self.physics.body     = love.physics.newBody(
                            physicsWorld,
                            x + love.graphics.getWidth()/2 ,
                            y
                          )
  self.physics.shape    = love.physics.newRectangleShape(
                            love.graphics.getWidth(),
                            32
                          )
  self.physics.fixture  = love.physics.newFixture(
                            self.physics.body,
                            self.physics.shape
                          )

  return self
end

------------
-- SOLID TILE
------------
Tile.new = function(x, y, physicsWorld)
  local self = self or {}

  self.physics          = {}
  self.physics.world    = physicsWorld
  self.physics.body     = love.physics.newBody(
                            physicsWorld,
                            x,
                            y,
                            "static"
                          )
  self.physics.shape    = love.physics.newRectangleShape(
                            32,
                            32
                          )
  self.physics.fixture  = love.physics.newFixture(
                            self.physics.body,
                            self.physics.shape
                          )

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
    x + self.image:getWidth()/2, y + self.image:getHeight()/2,
    math.rad(angle), 1, 1, -self.image:getWidth()/2,
    self.image:getHeight()/2
  )
end

Sprite.getWidth = function(self)
  return self.image:getWidth()/self.frameCout
end

Sprite.getHeight = function(self)
  return self.image:getHeight()
end
