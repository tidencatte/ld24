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

animations = {}
needs_updates = {}

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

