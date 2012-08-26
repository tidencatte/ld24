
function gen_world()
	local _world = {}

	-- fill in the outside edges with room tiles
	for k = 1,WORLD_HEIGHT do
		_world[k] = {}
		for v = 1,WORLD_WIDTH do
			if (k == 1 or k == WORLD_HEIGHT or v == 1 or v == WORLD_WIDTH) then
				_world[k][v] = 2 -- wall tile
			else
				_world[k][v] = 1 -- floor tile
			end
		end
	end

	function checkdir(x,y)
		if (x < 4 or x > 28) then
			return -1
		end

		if (y < 4 or y > 18) then
			return -1
		end

		return true
	end

	function move_from(x,y)
		local dir = math.random(1,4)
		if (dir == 1) then
			return x,y-1
		end
		if (dir == 2) then
			return x,y+1
		end
		if (dir == 3) then
			return x-1,y
		end
		if (dir == 4) then
			return x+1,y
		end	
	end

	function lavapool (x,y,budget)
		-- "budget" here is just how big the pool can be, in tiles.
		if (budget > 0) then
			-- pick a random direction, change a tile to a lava tile
			_world[y][x] = 4 

			_world[y-1][x] = 4
			_world[y+1][x] = 4
			_world[y][x-1] = 4
			_world[y][x+1] = 4
			_world[y-2][x] = 4
			_world[y+2][x] = 4
			_world[y][x-2] = 4
			_world[y][x+2] = 4
			_world[y-1][x-1] = 4 -- upper left
			_world[y+1][x+1] = 4 -- lower right
			_world[y+1][x-1] = 4 -- lower left
			_world[y-1][x+1] = 4 -- upper right
			-- up, down, left, right; 1,2,3,4
			local _x,_y = nil,nil
			local valid_dir = false
			while (valid_dir == false) do
				_x,_y = move_from(x,y)
				if (checkdir(_x,_y) == true) then
					valid_dir = true
					break
				end

				if (checkdir(_x,_y) == -1) then
					valid_dir = true
					budget = 1
					break
				end
			end
			lavapool(_x,_y,budget-1)
		end
	end

	if (dungeon_rules["lava"]) then
		-- pick a few spots, add some lava pools
		local _pools = {}
		for p = 1,10 do
			-- just generate the origin points for these pools
			table.insert(_pools, p, {math.random(6,28), math.random(7,18)})
		end

		for k,p in pairs(_pools) do
			lavapool(p[1],p[2],12)
		end
	end

	-- put the downward stairs in our world, with some open space around it
	_world[3][3] = 3
	return _world
end
