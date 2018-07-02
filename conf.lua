
-- Game Width and Height
gw = 600
gh = 800

-- Scale Width and Height
sx = 1
sy = 1

function love.conf(t)
    t.console = true 
    t.window.width = gw * sx
    t.window.height = gh * sy
end