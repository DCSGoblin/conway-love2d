s = require("settings")

function love.conf(t)
	t.window.width = s.WIDTH
	t.window.height = s.HEIGHT
	t.window.title = s.TITLE
end