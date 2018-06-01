require 'Utils'

Canvas = love.graphics.newCanvas(gw, gh)

RenderStyles = require 'renderStyles'
ParticleTemplates = require 'particleTemplates'
EnemyTemplates = require 'enemyTemplates'

GameEntities = {}

Player = {
    type = 'Player',
    x = gw / 2,
    y = gh - 30,
    w = 10,
    speed = 120,
    fireRate = 0.085,
    tick = 0,
    dead = false
}

local enemySpawnTimer = 0
local enemySpawnThreshold = 3

function love.load()
    Canvas:setFilter('nearest', 'nearest')
    love.graphics.setDefaultFilter('nearest', 'nearest')
    love.graphics.setLineStyle('rough')
    resize(3)

    local enemy = EnemyTemplates['Circling']()
    table.insert(GameEntities, Player)
    table.insert(GameEntities, enemy)

    love.keyboard.keysPressed = {}

    smallFont = love.graphics.newFont('font.ttf', 8)
end

function love.update(dt)
    for i = #GameEntities, 1, -1 do 
        local entity = GameEntities[i]
        if entity.dead then 
            entity = nil
            table.remove(GameEntities, i)
        end
    end

    if enemySpawnTimer > enemySpawnThreshold then 
        table.insert(GameEntities,
            {
                type = 'Enemy',
                x = random(10, gw - 10),
                y = -20,
                w = 20,
                speed = random(70, 100),
                health = 10,
                dead = false
            }
        )
        enemySpawnTimer = 0
    end

    for i = #GameEntities, 1, -1 do 
        local entity = GameEntities[i]
        local dX, dY
        if entity.type == 'Enemy' then 
            dX, dY = (math.sin(entity.tick or 0) * entity.speed) * dt, (math.cos(entity.tick or 0) * entity.speed) * dt 
            updateEntityPosition(entity, dX, dY)
            if checkEntityBounds(entity, -50, gw + 50, -100, gh + 50) then 
                entity.dead = true 
            end
            if entity.health < 0 then 
                entity.dead = true 
                for i = random(8, 20), 1, -1 do 
                    local p = ParticleTemplates['OnEnemyDeathSmall'](entity, 3)
                    table.insert(GameEntities, p)
                end
                for i = 3, 1, -1 do 
                    local p = ParticleTemplates['OnEnemyDeathLarge'](entity, i)
                    table.insert(GameEntities, p)
                end
            end
            if entity.tick  then entity.tick = entity.tick + dt end
        end
        if entity.type == 'Particle' then 
            if entity.tick > entity.lifespan then entity.dead = true end
            entity.tick = entity.tick + dt
            dX, dY = entity.speed * math.cos(entity.angle) * dt, entity.speed * math.sin(entity.angle) * dt
            entity.speed = entity.speed * 0.98
            updateEntityPosition(entity, dX, dY)
        end
        if entity.type == 'PlayerBullet' then 
            dX, dY = entity.speed * math.cos(entity.angle) * dt, entity.speed * math.sin(entity.angle) * dt
            updateEntityPosition(entity, dX, dY)
            if checkEntityBounds(entity, -entity.w, gw + entity.w, -entity.w, gh + entity.w) then 
                entity.dead = true 
            end
            for j = #GameEntities, 1, -1 do 
                local entityA = GameEntities[j]
                local entityB = entity
                if entityA.type == 'Enemy' then 
                    local result, newX, newY = circleCollision(entityA, entityB)
                     if result then 
                        entityB.dead = true
                        entityA.health = entityA.health - 1
                        local originX = newX + 4
                        local originY = newY + 4
                        local angleOffset = math.atan2(newY - entityA.y, newX - entityA.x)
                        for i = random(1, 3), 1, -1 do 
                            table.insert(GameEntities,
                                {
                                    type = 'Particle',
                                    x = originX,
                                    y = originY,
                                    speed = random(200, 300),
                                    lifespan = random(0.25, 1.5),
                                    w = random(2,5),
                                    tick = 0,
                                    angle = angleOffset + random(-math.pi/5, math.pi/5),
                                    color = ParticleColors[round(random(1, #ParticleColors))],
                                    dead = false
                                }
                            )
                        end
                    end
                end
            end
        end
        if entity.type == 'ShotEffect' then 
            if entity.tick > entity.lifespan then entity.dead = true end
            moveTo(entity, Player.x, (Player.y - Player.w / 2 - 4))
            entity.tick = entity.tick + dt
        end
        if entity.type == 'Player' then 
            entity.tick = entity.tick - dt
            dX, dY = handlePlayerInput(entity, dt)
            updateEntityPosition(entity, dX, dY)
        end
    end

    enemySpawnTimer = enemySpawnTimer + dt
    love.keyboard.keysPressed = {}
end

function love.draw()
    love.graphics.setColor(255, 255, 255)
    love.graphics.setCanvas(Canvas)
    love.graphics.clear()

    for i = #GameEntities, 1, -1 do 
        local entity = GameEntities[i]
        if not entity.dead then
            renderEntity(RenderStyles, entity)
        end
    end

    displayFPS()
    love.graphics.setColor(255,255,255)
    love.graphics.setCanvas()  
    love.graphics.draw(Canvas, 0, 0, 0, sx, sy)
end

function moveTo(entity, x, y)
    entity.x, entity.y = x, y
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
    return love.keyboard.keysPressed[key]
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

function renderEntity(renderStyles, entity, opts)
    renderStyles[entity.type](entity, opts)
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

    if entity.tick < 0 then 
        if love.keyboard.isDown('space') then 
            local originX = (Player.x - Player.w / 2)
            local originY = Player.y - Player.w / 2 - 10
            for i = 3, 1, -1 do 
                local offsetX = i - 1
                table.insert(GameEntities,
                    {
                        type = 'PlayerBullet',
                        x = originX + (offsetX * 8),
                        y = originY,
                        speed = 350,
                        w = 4,
                        angle = math.pi + math.pi / 2,
                        dead = false
                    }
                )
            end
            for i = 6, 1, -1 do 
                local originX = Player.x 
                local originY = (Player.y - Player.w / 2) - 5
                table.insert(GameEntities,
                    {
                        type = 'Particle',
                        x = originX,
                        y = originY,
                        speed = 200,
                        lifespan = random(0.075, 0.25),
                        w = 4,
                        tick = 0,
                        angle = math.pi + math.pi / 8 * i,
                        color = {r = 0, g = 255, b = 255, a = 255},
                        dead = false
                    }
                )
            end
            table.insert(GameEntities,
                {
                    type = 'ShotEffect',
                    x = Player.x,
                    y = Player.y - Player.w / 2 - 4,
                    lifespan = 0.15,
                    w = 10,
                    tick = 0,
                    dead = false
                }
            )
        end  
        entity.tick = entity.fireRate 
    end

    return dX, dY
end

function checkEntityBounds(entity, minX, maxX, minY, maxY) 
    return entity.x < minX or entity.x > maxX or entity.y < minY or entity.y > maxY
end

function displayFPS()
    -- simple FPS display across all states
    love.graphics.setFont(smallFont)
    love.graphics.setColor(0, 255, 0, 255)
    love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 10, 10)
    love.graphics.print('Game Entitis: ' .. #GameEntities, 10, 20)
end

function circleCollision(entityA, entityB) 
    if entityA.x + entityA.w + entityB.w > entityB.x and entityA.x < entityB.x + entityA.w + entityB.w
       and entityA.y + entityA.w + entityB.w > entityB.y and entityA.y < entityB.y + entityA.w + entityB.w then 
        local distance = math.sqrt(math.pow(entityA.x - entityB.x, 2) + math.pow(entityA.y - entityB.y, 2))
        if (distance < entityA.w + entityB.w) then
            local collisionPointX = ((entityA.x * entityB.w) + (entityB.x * entityA.w)) / (entityA.w + entityB.w)
            local collisionPointY = ((entityA.y * entityB.w) + (entityB.y * entityA.w)) / (entityA.w + entityB.w);
            return true, collisionPointX, collisionPointY
        end  
    else
        return false
    end
end