
-- Game Width and Height
gw = 200
gh = 260

-- Scale Width and Height
sx = 1
sy = 1

function love.conf(t)
    t.console = true 
    t.window.width = gw * sx
    t.window.height = gh * sy
end