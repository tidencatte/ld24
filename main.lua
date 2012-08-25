require "tintor"
-- borrowed from the LOVE snippets wiki

local mt_class = {}

function mt_class:extends(parent)
   self.super = parent
   setmetatable(mt_class, {__index = parent})
   parent.__members__ = parent.__members__ or {}
   return self
end

local function define(class, members)
   class.__members__ = class.__members__ or {}
   for k, v in pairs(members) do
      class.__members__[k] = v
   end
   function class:new(...)
      local newvalue = {}
      for k, v in pairs(class.__members__) do
         newvalue[k] = v
      end
      setmetatable(newvalue, {__index = class})
      if newvalue.__init then
         newvalue:__init(...)
      end
      return newvalue
   end
end

function class(name)
    local newclass = {}
   _G[name] = newclass
   return setmetatable(newclass, {__index = mt_class, __call = define})
end

tileset = {}
tileset["tiles"] = {}
tileset["image"] = nil
animations = {}
needs_updates = {}

class "Player" {
	x = 0;
	y = 0;
}

function Player:__init(x, y, health)
	self.x = 0
	self.y = 0
	self.health = health
end

class "Enemy" {
	x = 0;
	y = 0;
	health = 0;
	update = function(behavior)

	end;
	attack = function(dir)
	end;
}

function Enemy:__init(x, y, health)
	self.x = x
	self.y = y
	self.health = health
end

enemies = {}

function make_animation(img, label, spx, spy)
	local _i = love.graphics.newImage(img)
	local _qs = {}
	local fcounter = 0
	local width, height = _i:getWidth(),_i:getHeight()
	
	for k = 0,(height/spy)-1 do
		for v = 0,(width/spx)-1 do
			table.insert(_qs, love.graphics.newQuad(v*16, k*16, spx, spy, 64, 64))
			fcounter = (fcounter + 1)
		end
	end

	table.insert(_qs, 1, _i)
	table.insert(_qs, 1, fcounter)
	table.insert(_qs, 1, 0)
	animations[label] = _qs
end

function get_animation(label)
	local anim = animations[label]
	needs_updates[label] = true
	return {anim[4+anim[1]], anim[3]}
end

function progressbar (x, y, width, pct, color1, color2)
	-- color1: background color
	-- color2: filled color
	if (pct > 100 or pct < 0) then
		error("Percent out of range")
	end
	local _p = pct/100
	local _r, _g, _b, _a = love.graphics.getColor()
	love.graphics.setColor(unpack(color2))
	love.graphics.rectangle("line", x, y, width, 16)
	love.graphics.setColor(unpack(color1))
	love.graphics.rectangle("fill", x+1, y+1, width-2, 14)
	love.graphics.setColor(unpack(color2))
	love.graphics.rectangle("fill", x+1, y+1, math.ceil(_p*width),14)

	-- restore the color when we're done with our drawing operation

	love.graphics.setColor(_r, _g, _b, _a)
end

function love.load()
	love.graphics.setMode(720, 480)
	player = Player:new(50, 50, 100)

	uih_scale = 1.0
	uih_accum = 0.5
	uih_factor = 0.01

	-- create the tileset, 16x16 tiles
	tileset["image"] = love.graphics.newImage("tileset.png")
	local _image = tileset["image"]
	local _w = _image:getWidth()
	local _h = _image:getHeight()
	for k = 1,(_w/16)-1 do
		tileset["tiles"][k] = {}
		for v = 1,(_h/16)-1 do
			table.insert(tileset["tiles"][k], v, 
				love.graphics.newQuad((k-1)*16, (v-1)*16, 16, 16, _w, _h))
		end
	end

	teffect = tintor("simple")
	-- create a bunch of enemies
	for k = 1,25 do

	end
	ui_icons = love.graphics.newImage("ui_icons.png")

	ui_heart = love.graphics.newQuad(0,0,16,16,256,256)
	love.graphics.setDefaultImageFilter("nearest", "nearest")
end

function love.update(dt)
	for k,v in pairs(enemies) do

	end

	uih_accum = uih_accum + uih_factor
	if (uih_accum < 0.5) then
		uih_factor = -uih_factor
	end
	if (uih_accum > 0.8) then
		uih_factor = -uih_factor
	end

	uih_scale = math.sin(uih_accum*2)
end

function love.draw()
	progressbar(1,1,64,55,{128,0,0},{255,0,0})
	teffect:send("color2", {219,221,255,255})
	love.graphics.drawq(ui_icons, ui_heart, 66, 1, 0, uih_scale)
end


function love.keypressed (key, unicode)
	if (key == "escape") or (key == "q") then
		love.event.push("quit")
	end
end