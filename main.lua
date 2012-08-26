require "tintor"

-- borrowed from the LOVE snippets wiki
require "classes"
require "utils"
require "worldgen"
dungeon_rules = {
	slow = false,
	hurt = false,
	dark = false,
	fatal_blocks = false,
	more_enemies = false,
	even_more_enemies = false,
	aggressive_enemies = false,
	even_more_aggressive_enemies = false,
	lava = true,
	decay = false,
}

player_dna = {
	laser_eyes = false, -- pew pew pew |3
	speed = false, -- you move faster
	jump = false, -- pesky lava pits are no longer a problem
	attack = false, -- HOLY SHIT YOU CAN PUNCH STUFF!
	durable = false, -- more health
	more_durable = false, -- even more health
	even_more_durable = false, -- so much health
	vuln_heat = false, -- health loss from lava floors
}

tileset = {}
tileset["tiles"] = {}
tileset["image"] = nil

enemy_sprites = {}

animations = {}
needs_updates = {}

class "_Player" {
	x = 0;
	y = 0;
}

projectiles = {}

function _Player:__init(_x, _y, health)
	self.x = _x
	self.y = _y
	self.health = health
end

class "Enemy" {
	x = 0;
	y = 0;
	health = 0;
	mdir = 1; -- up
	update = function(behavior)

	end;
	attack = function()
		local vel_x, vel_y = math.random(1,15),math.random(1,15)
		table.insert(projectiles,1,{x,y,vel_x,vel_y})
	end;
}

function Enemy:__init(health)
	self.health = health
end

function Enemy:spawn(world)
	local suitable = false
	while (suitable == false) do
		local _x,_y = math.random(1,32),math.random(1,24)
		if (world[_x][_y] == 1) then
			suitable = true
			break
		end
	end
	self.x = (_x*16)-8
	self.y = (_y*16)-8
end

function Enemy:update()
	-- random movement behavior.
	if (mdir == 1) then
		self.y = self.y - 1
	end

	if (mdir == 2) then
		self.y = self.y + 1
	end

	if (mdir == 3) then
		self.x = self.x - 1
	end

	if (mdir == 4) then
		self.x = self.x + 1
	end
end

enemies = {}

-- some constants

WORLD_WIDTH = 32
WORLD_HEIGHT = 24

GAMESTATE = {
	showing_rules = false,
	started = false,
	player_dead = false,
	game_finished = false,
	floor = 1, -- max: 25, introduce a new rule every 3 floors
}

function checktile(x,y)
	local _x,_y = x, y
	local x,y = math.floor(x),math.floor(y)

	if (_x == 4 and _y == 4) then
		return 2 -- Stairs.
	end

	if (world[y][x] == 4) then
		return 3 -- ~LAVA~
	end
end

local player =  nil

function love.load()
	love.graphics.setMode(720, 480)

	player = _Player:new(30*16, 22*16, 100)

	-- create the tileset, 16x16 tiles

	tileset["image"] = love.graphics.newImage("tileset.png")
	local _image = tileset["image"]
	local _w = _image:getWidth()
	local _h = _image:getHeight()

	for k = 1,(_w/32)-1 do
		for v = 1,(_h/32)-1 do
			table.insert(tileset["tiles"], k*v,
				love.graphics.newQuad((k-1)*32, (v-1)*32, 32, 32, _w, _h))
		end
	end

	teffect = tintor("simple")

	for k = 1,10 do
		table.insert(enemies,k,Enemy:new(20))
	end

	ui_icons = love.graphics.newImage("ui_icons.png")

	ui_heart = love.graphics.newQuad(0,0,16,16,256,256)
	love.graphics.setDefaultImageFilter("nearest", "nearest")

	player_img = love.graphics.newImage("player.png")
	love.keyboard.setKeyRepeat(0, 0.22)

	world = gen_world()
end

function love.update(dt)
	-- agh, movement code!!!!
	-- TODO: set directionality for attacks.
	if (love.keyboard.isDown("left")) then
		player.x = player.x - 1
	end

	if (love.keyboard.isDown("right")) then
		player.x = player.x + 1
	end

	if (love.keyboard.isDown("up")) then
		player.y = player.y - 1
	end

	if (love.keyboard.isDown("down")) then
		player.y = player.y + 1
	end

	-- check the tile the player is under
	local t = checktile(player.x/16,player.y/16) -- fucking hacky

	if (t == 4) then
		GAMESTATE["player_dead"] = true
	end

	if (t == 2) then
		world = gen_world()
		player.x = (28*16)
		player.y = (19*16)
		GAMESTATE["floor"] = GAMESTATE["floor"] + 1

		for k = 1,#enemies do
			table.remove(enemies)
		end

		for k = 1,10 do
			table.insert(enemies,k,Enemy:new(20))
		end	
	end
end

function love.draw()
	for k = 1,WORLD_HEIGHT do
		for v = 1,WORLD_WIDTH do
			if (world[k][v] == 4) then -- lava
				teffect:send("color2",{202,0,0,255})
				love.graphics.setPixelEffect(teffect)
			else
				love.graphics.setPixelEffect()
			end

			love.graphics.drawq(
				tileset["image"],
				tileset["tiles"][world[k][v]],
				(32+(16*v)), (32+(16*k)),0,0.5)
		end
	end

	love.graphics.setPixelEffect()
	love.graphics.push() -- store current render state
	love.graphics.translate(32,32)
	love.graphics.draw(player_img, player.x, player.y)
	love.graphics.pop()

	if (GAMESTATE["player_dead"] == true) then
		-- draw a big fancy GAME OVER! image
	end

	-- DEBUG CRAP
	love.graphics.print("X: "..player.x.." wX:"..(player.x/16),0,0)
	love.graphics.print("Y: "..player.y.." wY:"..(player.y/16),0,16)
	love.graphics.print("Floor: "..GAMESTATE["floor"],640,0)
end

function love.keypressed (key, unicode)
	if (key == "space") then
		-- need to add attack code.
	end

	if (key == "j") then
		world = gen_world()
	end
	if (key == "escape") or (key == "q") then
		love.event.push("quit")
	end
end