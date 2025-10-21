local s = require("settings")

function love.load()
	-- set background
	love.graphics.setBackgroundColor(s.BACKGROUND)
	grid = create_grid()
	cells = create_cells()
	
	-- simple state
	locked = true
end

function love.update(dt)
	--handle mouse input
	if love.mouse.isDown(1) then
		local x, y = love.mouse.getPosition()
		-- arrays in lua start at 1 (lol) so we need to add 1
		-- so we dont index an invalid cell
		cells[math.floor(y / s.SIZE) + 1][math.floor(x / s.SIZE) + 1] = s.ALIVE
	elseif love.mouse.isDown(2) then
		local x, y = love.mouse.getPosition()
		cells[math.floor(y / s.SIZE) + 1][math.floor(x / s.SIZE) + 1] = s.DEAD
	end
	
	-- handle keyboard
	if love.keyboard.isDown("s") then
		locked = false
	elseif love.keyboard.isDown("p") then
		locked = true
	elseif love.keyboard.isDown("r") then
		random_cells(cells)
	end
	
	-- update cells if not locked
	if not locked then
		update_cells(cells)
	end

end

function love.draw()
	-- draw screen objects
	love.graphics.draw(grid)
	draw_cells(cells)
end

function create_grid()
	-- create a canvas to draw a grid to
	-- this will reduce calls to draw
	local canvas = love.graphics.newCanvas(s.WIDTH, s.HEIGHT)
	love.graphics.setCanvas(canvas)
	
	-- use two loops to draw grid lines
	-- minus 1 so we only draw inner grid
	love.graphics.setColor(s.FOREGROUND)
	for i = 1, s.HEIGHT / s.SIZE - 1 do
		love.graphics.line(0, i * s.SIZE, s.WIDTH, i * s.SIZE)
	end
	for i = 1, s.WIDTH / s.SIZE - 1 do
		love.graphics.line(i * s.SIZE, 0, i * s.SIZE, s.HEIGHT)
	end
	-- after done drawing to canvas make sure to reset canvas
	love.graphics.setCanvas()
	
	return canvas
end

function create_cells()
	local cells = {}
	-- create a 2d array of cells
	for i = 1, s.HEIGHT / s.SIZE do
		cells[i] = {}
		for j = 1, s.WIDTH / s.SIZE do
			cells[i][j] = s.DEAD
		end
	end
	
	return cells
end

function update_cells(cells)
	-- create a temporary array to hold updates
	local tmp = create_cells()
	
	-- iterate through cells, count neighbors
	for i = 1, s.HEIGHT / s.SIZE do
		for j = 1, s.WIDTH / s.SIZE do
			local count = 0
			for c = -1, 1 do
				for v = -1, 1 do
					-- do not count current cell
					if not (c == 0 and v == 0) then
						-- check cell bounds
						if i + c >= 1 and i + c <= s.HEIGHT / s.SIZE and j + v >= 1 and j + v <= s.WIDTH / s.SIZE then
							if cells[i + c][j + v] == s.ALIVE then
								count = count + 1
							end
						end
					end
				end
			end
			-- apply rules
			-- a living cell with fewer than two neighbors dies
			-- a living cell with more than three neighbors dies
			-- a living cell with two or three neighbors lives on
			-- a dead cell with exactly three neighbors becomes alive
			if cells[i][j] == s.ALIVE then
				if count > 3 or count < 2 then
					tmp[i][j] = s.DEAD
				else 
					tmp[i][j] = s.ALIVE
				end
			elseif cells[i][j] == s.DEAD then
				if count == 3 then
					tmp[i][j] = s.ALIVE
				else
					tmp[i][j] = s.DEAD
				end
			end			
		end
	end
	
	for i = 1, s.HEIGHT / s.SIZE do
		for j = 1, s.WIDTH / s.SIZE do
			cells[i][j] = tmp[i][j]
		end
	end
end

function random_cells(cells)
	-- randomize cells
	for i = 1, s.HEIGHT / s.SIZE do
		for j = 1, s.WIDTH / s.SIZE do
			cells[i][j] = love.math.random() < 0.2 and s.ALIVE or s.DEAD
		end
	end
end

function draw_cells(cells)
	-- iterate over a 2d array of cells
	-- draw any that are alive
	for i = 1, s.HEIGHT / s.SIZE do
		for j = 1, s.WIDTH / s.SIZE do
			if cells[i][j] == s.ALIVE then
				love.graphics.rectangle("fill", (j - 1) * s.SIZE, (i - 1) * s.SIZE, s.SIZE, s.SIZE)
			end
		end
	end
end