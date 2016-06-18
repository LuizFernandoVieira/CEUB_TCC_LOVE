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
local suit        = require "suit"
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
local Enemy       = {}
local Player      = {}
local Bow         = {}
local Arrow       = {}
local Tile        = {}
local Sprite      = {}
GameObject.__index  = GameObject
GameActor.__index   = GameActor
Enemy.__index       = Enemy
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
setmetatable(Enemy, {
  __index = GameActor,
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})
setmetatable(Player, {
  __index = GameActor,
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})
------------
-- TABLES
------------
local tiles         = {}
local arrows        = {}
local enemies       = {}
local physicsWorld  = nil
local player        = {}
local enemy         = nil
------------
-- GAMESTATES
------------
local mainMenuState         = {}
local playMenuState         = {}
local gameState             = {}
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
local joystickMenuSelected = nil

------------
-- LOAD
------------
function love.load(arg)
  Gamestate.registerEvents()
  Gamestate.switch(mainMenuState)
end

------------
-- MAIN MENU STATE
------------
function mainMenuState:init()
  loveConfigurations()
  joystricksConfigurations()
  debugConfigurations()
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
  joystickMenuSelected = "play"
end

function debugConfigurations()
  if agr ~= nil then
    debug = true
  end
end

function mainMenuState:update(dt)
    updateMainMenuGUI(dt)
    updateMainMenuJoystickGUI(dt)
end

function updateMainMenuGUI(dt)
  updateSuitButtonPlay(dt)
  updateSuitButtonQuit(dt)
end

function updateSuitButtonPlay(dt)
  buttonPlay = suit.Button(
    "Play",
    love.graphics.getWidth()/2 - 100,
    love.graphics.getHeight()/2, 200, 50
  )
  if buttonPlay.hit then
    Gamestate.switch(playMenuState)
  end
end

function updateSuitButtonQuit(dt)
  buttonQuit = suit.Button(
    "Quit",
    love.graphics.getWidth()/2 - 100,
    love.graphics.getHeight()/2 + 75, 200, 50
  )
  if buttonQuit.hit then
    love.event.quit()
  end
end

function updateMainMenuJoystickGUI(dt)
  if joystick ~= nil then
    if joystickMenuSelected == "play" then
      buttonQuit.color = {0,0,0}
    else
      buttonQuit.color = {255,0,0}
    end
  end
end

function mainMenuState:gamepadpressed(joystick, button)
  if button == "dpup" or button == "dpdown" then
    if joystickMenuSelected == "play" then
      joystickMenuSelected = "exit"
    else
      joystickMenuSelected = "play"
    end
  end

  if button == "a" then
    if joystickMenuSelected == "play" then
      Gamestate.switch(playMenuState)
      joystickMenuSelected = "singleplayer"
    else
      love.event.quit()
    end
  end
end

function mainMenuState:draw()
  suit.draw()
end

------------
-- PLAY MENU STATE
------------
function playMenuState:update()
  updatePlayMenuGUI(dt)
end

function updatePlayMenuGUI(dt)
  updateSuitButtonSinglePlayer(dt)
  updateSuitButtonMultiPlayer(dt)
  updateSuitButtonBack(dt)
end

function updateSuitButtonSinglePlayer(dt)
  buttonSinglePlayer = suit.Button(
    "Singleplayer",
    love.graphics.getWidth()/2 - 100,
    love.graphics.getHeight()/2, 200, 50
  )
  if buttonSinglePlayer.hit then
    Gamestate.switch(gameState)
  end
end

function updateSuitButtonMultiPlayer(dt)
  buttonMultiPlayer = suit.Button(
    "Multiplayer",
    love.graphics.getWidth()/2 - 100,
    love.graphics.getHeight()/2 + 75, 200, 50
  )
end

function updateSuitButtonBack(dt)
  buttonBack = suit.Button(
    "Back",
    love.graphics.getWidth()/2 - 100,
    love.graphics.getHeight()/2 + 145, 200, 50
  )
  if buttonBack.hit then
    Gamestate.switch(mainMenuState)
  end
end

function playMenuState:gamepadpressed(joystick, button)
  if button == "dpup" or button == "dpdown" then
    if joystickMenuSelected == "singleplayer" then
      joystickMenuSelected = "multiplayer"
    elseif joystickMenuSelected == "multiplayer" then
      joystickMenuSelected = "back"
    else
      joystickMenuSelected = "singleplayer"
    end
  end

  if button == "a" then
    if joystickMenuSelected == "singleplayer" then
      Gamestate.switch(gameState)
    elseif joystickMenuSelected == "multiplayer" then
      print("multiplayer")
    else
      Gamestate.switch(mainMenuState)
    end
  end
end

function playMenuState:draw()
  suit.draw()
end

------------
-- GAME STATE
------------
------------
-- INIT
------------
function gameState:init()
  loadObjects()
  loadAudio()
end

function loadObjects()
  loadPhysicsWorld()
  loadTileMap()
  loadPlayer()
  loadEnemies()
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
  table.insert(player, Player(
    physicsWorld,
    love.graphics.getWidth()/2,
    love.graphics.getHeight()/2,
    "img/player.png", 1, 32, 32
  ))
end

function loadEnemies()
  table.insert(enemies, Enemy(physicsWorld, 100, 200))
  table.insert(enemies, Enemy(physicsWorld, 200, 200))
  table.insert(enemies, Enemy(physicsWorld, 300, 200))
end

function loadAudio()
  music = love.audio.newSource("audio/music.mp3") -- music:play()
  soundEffect = love.audio.newSource("audio/audio_coin.ogg", "static")
end

function gameState:update(dt)
  physicsWorld:update(dt)
  updateInputs()

  for i,v in ipairs(player) do
    v:update(dt)
  end

  for i,v in ipairs(enemies) do
    v:update(dt)
  end

  arrows.update(dt)

  handleSpecialCollision()

  updateDebug()
end

function handleSpecialCollision()
  for i,v in ipairs(player) do
    if v.physics.body:getX() < -16 then
      v.physics.body:setX(25*32 + 16)
    elseif v.physics.body:getX() > 25*32 + 16 then
      v.physics.body:setX(16)
    elseif v.physics.body:getY() < 0  then
      v.physics.body:setY(32*20)
    elseif v.physics.body:getY() > 32*20  then
      v.physics.body:setY(0)
    end
  end

  for i,v in ipairs(enemies) do
    if v.physics.body:getX() < -16 then
      v.physics.body:setX(25*32 + 16)
    elseif v.physics.body:getX() > 25*32 + 16 then
      v.physics.body:setX(16)
    elseif v.physics.body:getY() < 0  then
      v.physics.body:setY(32*20)
    elseif v.physics.body:getY() > 32*20  then
      v.physics.body:setY(0)
    end
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
    player[1]:moveLeft()
  elseif love.keyboard.isDown('d') then
    player[1]:moveRight()
  else
    player[1].desiredVelocity = 0
  end

  if love.keyboard.isDown('s') then
  end

  if love.keyboard.isDown('left') then
    player[1].bow:changeAngle(180)
  end
  if love.keyboard.isDown('right') then
    player[1].bow:changeAngle(0)
  end

  if  love.keyboard.isDown('up') and
  not love.keyboard.isDown('left') and
  not love.keyboard.isDown('right') then
    player[1].bow:changeAngle(270)
  elseif love.keyboard.isDown('up') and
  not love.keyboard.isDown('left') and
      love.keyboard.isDown('right') then
    player[1].bow:changeAngle(315)
  elseif love.keyboard.isDown('up') and
      love.keyboard.isDown('left') and
  not love.keyboard.isDown('right') then
    player[1].bow:changeAngle(225)
  end

  if  love.keyboard.isDown('down') and
  not love.keyboard.isDown('left') and
  not love.keyboard.isDown('right') then
    player[1].bow:changeAngle(90)
  elseif love.keyboard.isDown('down') and
  not love.keyboard.isDown('left') and
      love.keyboard.isDown('right') then
    player[1].bow:changeAngle(45)
  elseif love.keyboard.isDown('down') and
      love.keyboard.isDown('left') and
  not love.keyboard.isDown('right') then
    player[1].bow:changeAngle(135)
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

function beginContact(a, b, coll)

  if  a:getBody():getUserData().type == "Tile" and
      b:getBody():getUserData().type == "Player" then
    player[1].grounded = true
  end

  if a:getBody():getUserData().type == "Tile" and
      b:getBody():getUserData().type == "Enemy" then
      enemies[1].grounded = true
      enemies[2].grounded = true
      enemies[3].grounded = true
  end

  -- if b player
  --   if a enemy
  -- elseif b enemy
  --   if a player
  -- else
  -- end
  -- for i,v in ipairs(enemies) do
  --   v.grounded = true
  -- end
end

function endContact(a, b, coll)
end

function preSolve(a, b, coll)
end

function postSolve(a, b, coll, normalimpulse, tangentimpulse)
end

function gameState:draw()

  if not debug then
    drawTiles()

  for i,v in ipairs(player) do
      v:draw()
    end
    arrows.draw()
  end

  drawDebug()
end

function drawTiles()
  love.graphics.draw(tilesetBatch)
end

function drawDebug()
  if(debug == true) then

    drawPlayerDebug()
    -- drawBowDebug()
    drawEnemyDebug()
    drawTilesDebug()
    drawArrowsDebug()

    love.graphics.setColor(255, 255, 255)
    love.graphics.print(mouseString)
  end
end

function drawPlayerDebug()
  for i,v in ipairs(player) do
    love.graphics.setColor(0, 200, 255, 50)
    love.graphics.rectangle(
      "fill",
      v.physics.body:getX(),
      v.physics.body:getY(),
      32, 32
    )
    love.graphics.setColor(0, 200, 255)
    love.graphics.rectangle(
      "line",
      v.physics.body:getX(),
      v.physics.body:getY(),
      32, 32
    )
  end
end

function drawBowDebug()
  for i,v in ipairs(player) do
    love.graphics.setColor(255, 255, 0, 50)
    love.graphics.polygon(
      "fill",
      v.physics.body:getX() + 0,
      v.physics.body:getY() - 16,
      v.physics.body:getX() + 48,
      v.physics.body:getY() + 16,
      v.physics.body:getX() + 0,
      v.physics.body:getY() + 48
    )
  end
end

function drawEnemyDebug()
  for i,v in ipairs(enemies) do
    love.graphics.setColor(255, 0, 0, 50)
    love.graphics.rectangle(
      "fill",
      v.physics.body:getX(),
      v.physics.body:getY(),
      32, 32
    )
    love.graphics.setColor(255, 0, 0)
    love.graphics.rectangle(
      "line",
      v.physics.body:getX(),
      v.physics.body:getY(),
      32, 32
    )
  end
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

function drawArrowsDebug()
  love.graphics.setColor(255, 0, 255)
  for i, v in ipairs(arrows) do
    love.graphics.setColor(255, 0, 255, 50)
    love.graphics.circle(
      "fill",
      v.physics.body:getX(),
      v.physics.body:getY(),
      16
    )
    love.graphics.setColor(255, 0, 255)
      love.graphics.circle(
        "line",
        v.physics.body:getX(),
        v.physics.body:getY(),
        16
      )
  end
end

function gameState:quit()
end

------------
-- GAME STATE KEYS
------------
function gameState:keypressed(key, unicode)

  if key == "w" then
    player[1]:jump()
  end
  if key == "space" then
    player[1]:shot()
  end
  if key == "r" then
    if debug == true then debug = false
    else debug = true end
  end
end

function gameState.keyreleased(key)
end

------------
-- GAME STATE GAMEPAD
------------
function gameState:gamepadpressed(joystick, button)
  if button == "a" then
    player:jump()
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

function gameState:gamepadreleased(joystick, button)
end

------------
-- GAME STATE JOYSTICKS
------------
function gameState.joystickreleased(joystick, button)
end

function gameState.joystickreleased(key)
end

function gameState.joystickadded(joystick)
end

function gameState.joystickremoved(joystick)
end

------------
-- GAME STATE LISTS
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
-- CLASSES
------------

------------
-- GAME OBJECT
------------
function GameObject:_init(physicsWorld)
  self.physics          = {}
  self.physics.world    = physicsWorld
end

function GameObject:getPhysics()
  return self.physics
end

function GameObject:getPhysicsWorld()
  return self.physics.world
end

function GameObject:setPhysics(physics)
  self.physics = physics
end

function GameObject:setPhysicsWorld(physicsWorld)
  self.physicsWorld = physicsWorld
end

------------
-- GAME ACTOR
------------
function GameActor:_init(physicsWorld, x, y)
  GameObject._init(self, physicsWorld)

  self.type             = nil
  self.physics.body     = love.physics.newBody(physicsWorld, x, y, "dynamic")
  self.physics.shape    = love.physics.newRectangleShape(32, 32)
  self.physics.fixture  = love.physics.newFixture(
                            self.physics.body,
                            self.physics.shape,
                            1
                          )
end

function GameActor:moveLeft()
  self.desiredVelocity = -100
end

function GameActor:moveRight()
  self.desiredVelocity = 100
end

function GameActor:getType()
  return self.type
end

function GameActor:getBody()
  return self.physics.body
end

function GameActor:getShape()
  return self.physics.shape
end

function GameActor:getFixture()
  return self.physics.fixture
end

function GameActor:setType(type)
  self.type = type
end

function GameActor:setBody(body)
  self.physics.body = body
end

function GameActor:setShape(shape)
  self.physics.shape = shape
end

function GameActor:setFixture(fixture)
  self.physics.fixture = fixture
end

------------
-- ENEMY
------------
function Enemy:_init(physicsWorld, x, y)
  GameActor._init(self, physicsWorld, x, y)

  self.grounded         = false
  self.desiredVelocity  = 0
  self.stuckCounter     = 0

  self:setType("Enemy")
  self.physics.body:setUserData(self)
end

function Enemy:update(dt)
  self.stuckCounter = self.stuckCounter + dt

  if self.stuckCounter > (dt*60*3) then
    self:jump()
    self.stuckCounter = 0
  end

  if self.physics.body:getX() > player[1].physics.body:getX() + 32 then
    self:moveLeft()
  elseif self.physics.body:getX() < player[1].physics.body:getX() - 32 then
    self:moveRight()
  else
  end

  -- i = m * dv
  local velChange = self.desiredVelocity - self.physics.body:getLinearVelocity();
  local impulse = self.physics.body:getMass() * velChange;
  self.physics.body:applyLinearImpulse(impulse, 0)
end

function Enemy:jump()
  if self.grounded == true then
    local impulse = self.physics.body:getMass() * 500;
    self.physics.body:applyLinearImpulse(0, -impulse)
    self.grounded = false
  end
end

function Enemy:getGrounded()
  return self.grounded
end

function Enemy:getDesiredVelocity()
  return self.desiredVelocity
end

function Enemy:getStuckCounter()
  return self.stuckCounter
end

function Enemy:setGrounded(grounded)
  self.grounded = grounded
end

function Enemy:setDesiredVelocity(desiredVelocity)
  self.desiredVelocity = desiredVelocity
end

function Enemy:setStuckCounter(stuckCounter)
  self.stuckCounter = stuckCounter
end

------------
-- PLAYER
------------
function Player:_init(physicsWorld, x, y, image, frameCount, width, height)
  GameActor._init(self, physicsWorld, x, y)

  self.type             = "Player"
  self.sprite           = Sprite.new(self, image, frameCount, width, height)
  self.facingRight      = true
  self.grounded         = false
  self.desiredVelocity  = 0
  self.bow              = Bow.new(self, "img/bow.png", physicsWorld)

  self.physics.body:setMass(0.5)
  self.physics.body:setUserData(self)
  self.physics.fixture:setMask(2)
end

function Player:update(dt)
  self.sprite:update(dt)

  -- i = m * dv
  local velChange =
    self.desiredVelocity - self.physics.body:getLinearVelocity();
  local impulse = self.physics.body:getMass() * velChange;

  self.physics.body:applyLinearImpulse(impulse, 0)

  self.bow:update(dt)
end

function Player:draw()
  self.sprite:draw(
    self.image,
    self.facingRight,
    self.physics.body:getX(),
    self.physics.body:getY()
  )
  self.bow:draw()
end

function Player:moveLeft()
  if self.facingRight == true then
    self.facingRight = false
  end
  self.desiredVelocity = -150
end

function Player:moveRight()
  if self.facingRight ~= true then
    self.facingRight = true
  end
  self.desiredVelocity = 150
end

function Player:jump()
  if self.grounded == true then
    local impulse = self.physics.body:getMass() * 500;
    self.physics.body:applyLinearImpulse(0, -impulse)
    self.grounded = false
  end
end

function Player:shot()
  self.bow:shot()
end

------------
-- ARROW
------------
function Arrow.new(physicsWorld, bow, angle)
  local self = setmetatable({}, Arrow)

  self.bow              = bow
  self.sprite           = Sprite.new(self, "img/arrow.png", 1, 32, 32)
  self.physics          = {}
  self.physics.world    = physicsWorld
  self.physics.body     = love.physics.newBody(
                            self.physics.world,
                            self.bow.physics.body:getX() + 16,
                            self.bow.physics.body:getY() + 16,
                            "dynamic"
                          )
  self.physics.shape    = love.physics.newCircleShape(16)
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
  self.physics.body:setAngle(math.rad(angle))

  return self
end

function Arrow:update(dt)
end

function Arrow:draw()
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
  self.physics.body:setPosition(self.player.physics.body:getPosition())
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
  local impulse = 0.1 * 600;
  local ang = self.physics.body:getAngle()

  local arrow = Arrow.new(physicsWorld, self, ang)
  table.insert(arrows, arrow)

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
-- SOLID TILE
------------
Tile.new = function(x, y, physicsWorld)
  local self = self or {}

  self.type             = "Tile"
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

  self.physics.body:setUserData(self)

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


    -- v.physics.body:getX() - (0), v.physics.body:getY() - (5),
    -- v.physics.body:getX() - (12), v.physics.body:getY() - (0),
    -- v.physics.body:getX() - (32), v.physics.body:getY() - (5),
    -- v.physics.body:getX() - (12), v.physics.body:getY() - (12)

    -- if player[1].facingRight then
    --   love.graphics.setColor(255, 0, 255, 50)
    --   love.graphics.polygon(
    --     "fill",
    --     v.physics.body:getX() - (0), v.physics.body:getY() - (5),
    --     v.physics.body:getX() - (12), v.physics.body:getY() - (0),
    --     v.physics.body:getX() - (32), v.physics.body:getY() - (5),
    --     v.physics.body:getX() - (12), v.physics.body:getY() - (12)
    --   )
    --   love.graphics.setColor(255, 0, 255)
    --   love.graphics.polygon(
    --     "line",
    --     v.physics.body:getX() - (0), v.physics.body:getY() - (5),
    --     v.physics.body:getX() - (12), v.physics.body:getY() - (0),
    --     v.physics.body:getX() - (32), v.physics.body:getY() - (5),
    --     v.physics.body:getX() - (12), v.physics.body:getY() - (12)
    --   )
    -- else
    --   love.graphics.setColor(255, 0, 255, 50)
    --   love.graphics.polygon(
    --     "fill",
    --     v.physics.body:getX() - (0), v.physics.body:getY() - (5),
    --     v.physics.body:getX() - (20), v.physics.body:getY() - (0),
    --     v.physics.body:getX() - (32), v.physics.body:getY() - (5),
    --     v.physics.body:getX() - (20), v.physics.body:getY() - (12)
    --   )
    --   love.graphics.setColor(255, 0, 255)
    --   love.graphics.polygon(
    --     "line",
    --     v.physics.body:getX() - (0), v.physics.body:getY() - (5),
    --     v.physics.body:getX() - (20), v.physics.body:getY() - (0),
    --     v.physics.body:getX() - (32), v.physics.body:getY() - (5),
    --     v.physics.body:getX() - (20), v.physics.body:getY() - (12)
    --   )
    -- end
