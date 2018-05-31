require 'Utils'

Canvas = love.graphics.newCanvas(gw, gh)

GameEntities = {}

Player = {
    type = 'Player',
    x = gw / 2,
    y = gh - 30,
    speed = 120,
    dead = false
}

local enemySpawnTimer = 0
local enemySpawnThreshold = 0.25

function love.load()
    Canvas:setFilter('nearest', 'nearest')
    love.graphics.setDefaultFilter('nearest', 'nearest')
    love.graphics.setLineStyle('rough')
    resize(3)

    Enemy = {
        type = 'Enemy',
        x = random(10, gw - 10),
        y = -20,
        speed = 100,
        dead = false
    }
    table.insert(GameEntities, Player)
    table.insert(GameEntities, Enemy)

    love.keyboard.keysPressed = {}

    smallFont = love.graphics.newFont('font.ttf', 8)
end

function love.update(dt)
    for i = #GameEntities, 1, -1 do 
        local entity = GameEntities[i]
        if entity.dead then 
            table.remove(GameEntities, i)
        end
    end

    if enemySpawnTimer > enemySpawnThreshold then 
        local entity = 
        print("Enemy Spawned!")
        table.insert(GameEntities,
            {
                type = 'Enemy',
                x = random(10, gw - 10),
                y = -20,
                speed = random(10, 30),
                dead = false
            }
        )
        print('Game Entities: ' .. #GameEntities)
        enemySpawnTimer = 0
    end

    for i = #GameEntities, 1, -1 do 
        local entity = GameEntities[i]
        local dX, dY
        if entity.type == 'Enemy' then 
            dX, dY = 0, entity.speed * dt
            updateEntityPosition(entity, dX, dY)
        end
        if entity.type == 'Player' then 
            dX, dY = handlePlayerInput(entity, dt)
            updateEntityPosition(entity, dX, dY)
        end
    end

    each(filter(GameEntities, function(entity)
        return entity.type == 'Enemy' and checkBounds(entity)
    end), function(entity) entity.dead = true end)

    enemySpawnTimer = enemySpawnTimer + dt
    love.keyboard.keysPressed = {}
end

function love.draw()
    love.graphics.setColor(255, 255, 255)
    love.graphics.setCanvas(Canvas)
    love.graphics.clear()

    each(filter(GameEntities, function(entity)
            return entity.type == "Enemy"        
        end), drawEnemy)
    each(filter(GameEntities, function(entity)
            return entity.type == "Player"        
        end), drawPlayer)

    displayFPS()
    love.graphics.setColor(255,255,255)
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

function updateEntityPosition(entity, dX, dY)
    entity.x, entity.y = entity.x + dX, entity.y + dY
end

function eachType(entities, type, fn)
    for i, entity in ipairs(entities) do 
        if entity.type == type then fn(entity) end
    end
end

function each(entities, fn)
    for i, entity in ipairs(entities) do 
        fn(entity)
    end
end

function filter (things, fn)
    local filtered = {}
    each(things, function(thing)
        if fn(thing) then
            table.insert(filtered, thing)
        end
    end)
    return filtered
end

function map(things, convert)
    local mapped = {}
    each(things, function(thing)
        table.insert(mapped, convert(thing))
    end)
    return mapped
end

function drawPlayer(entity) 
    love.graphics.setColor(255,255,255)
    love.graphics.circle('line', entity.x, entity.y, 10, 10)
end

function drawEnemy(entity) 
    love.graphics.setColor(255, 128, 0, 50)
    love.graphics.circle('fill', entity.x, entity.y, 20, 20)
end

function handlePlayerInput(entity, dt)
    local dX, dY = 0, 0
    if love.keyboard.isDown('left') then 
        dX = -entity.speed * dt
    end
    if love.keyboard.isDown('right') then 
        dX = entity.speed * dt
    end
    if love.keyboard.isDown('up') then 
        dY = -entity.speed * dt
    end
    if love.keyboard.isDown('down') then 
        dY = entity.speed * dt
    end   
    return dX, dY
end

function checkBounds(entity) 
    return entity.x < -10 or entity.x > gw + 10 or entity.y > gh + 50
end

function displayFPS()
    -- simple FPS display across all states
    love.graphics.setFont(smallFont)
    love.graphics.setColor(0, 255, 0, 255)
    love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 10, 10)
end