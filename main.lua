

Canvas = love.graphics.newCanvas(gw, gh)

Player = {
    x = gw / 2,
    y = gh / 2,
    speed = 120
}

function love.load()
    Canvas:setFilter('nearest', 'nearest')
    love.graphics.setDefaultFilter('nearest', 'nearest')
    love.graphics.setLineStyle('rough')
    resize(3)

    love.keyboard.keysPressed = {}
end

function love.update(dt)
    if Player then 
        local dX, dY = 0, 0
        if love.keyboard.isDown('left') then 
            dX = -Player.speed * dt
        end
        if love.keyboard.isDown('right') then 
            dX = Player.speed * dt
        end
        if love.keyboard.isDown('up') then 
            dY = -Player.speed * dt
        end
        if love.keyboard.isDown('down') then 
            dY = Player.speed * dt
        end        
        updateEntityPosition(Player, dX, dY)
    end

    love.keyboard.keysPressed = {}
end

function love.draw()
    love.graphics.setColor( 255, 255, 255, 255)
    love.graphics.setCanvas(Canvas)
    love.graphics.clear()

    -- Player Render
    love.graphics.circle('line', Player.x, Player.y, 10, 10)

    love.graphics.setCanvas()  
    love.graphics.draw(Canvas, 0, 0, 0, sx, sy)
end

function resize(s)
    love.window.setMode(s*gw, s*gh)
    sx, sy = s, s
end

function love.keypressed(key)
    love.keyboard.keysPressed[key] = true

    if love.keyboard.isDown('escape') then 
        love.event.quit()
    end
end

function keyWasPressed(keyTable, key)
    return keyTable[key]
end

function updateEntityPosition(entity, deltaX, deltaY)
    entity.x, entity.y = entity.x + deltaX, entity.y + deltaY
end