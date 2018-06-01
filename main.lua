require 'Utils'

Canvas = love.graphics.newCanvas(gw, gh)

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

ParticleColors = {
    {
        r = 255,
        g = 128,
        b = 0,
        a = 235
    },
    {
        r = 255,
        g = 0,
        b = 0,
        a = 235
    },
    {
        r = 255,
        g = 255,
        b = 255,
        a = 235
    }
}

local enemySpawnTimer = 0
local enemySpawnThreshold = 0.75

function love.load()
    Canvas:setFilter('nearest', 'nearest')
    love.graphics.setDefaultFilter('nearest', 'nearest')
    love.graphics.setLineStyle('rough')
    resize(3)

    Enemy = {
        type = 'Enemy',
        x = random(10, gw - 10),
        y = -20,
        w = 20,
        speed = 100,
        health = 10,
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
            dX, dY = 0, entity.speed * dt
            updateEntityPosition(entity, dX, dY)
            if checkEntityBounds(entity, -50, gw + 50, -100, gh + 50) then 
                entity.dead = true 
            end
            if entity.health < 0 then 
                entity.dead = true 
                for i = random(8, 20), 1, -1 do 
                    table.insert(GameEntities,
                        {
                            type = 'Particle',
                            x = entity.x,
                            y = entity.y,
                            speed = random(250, 275),
                            lifespan = random(0.125, 0.5),
                            w = random(4, 8),
                            tick = 0,
                            angle = random(0, math.pi * 2),
                            color = ParticleColors[3],
                            dead = false
                        }
                    )
                end
                for i = 3, 1, -1 do 
                    table.insert(GameEntities,
                        {
                            type = 'Particle',
                            x = entity.x,
                            y = entity.y,
                            speed = random(10, 20),
                            lifespan = random(0.075, 0.25),
                            w = random(entity.w-10,entity.w+10),
                            tick = 0,
                            angle = 0,
                            color = ParticleColors[i],
                            dead = false
                        }
                    )
                end
            end
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
                        local originX = newX
                        local originY = newY
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
        if entity.type == 'PlayerBullet' then 
            drawPlayerBullet(entity)
        end
        if entity.type == 'Enemy' then 
            drawEnemy(entity)
        end
        if entity.type == 'Particle' then 
            drawParticle(entity)
        end
        if entity.type == 'Player' then 
            drawPlayer(entity)
        end
    end

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

    if key == 'p' then 
        local originX = random(Player.x - Player.w / 2, Player.x + Player.w / 2)
        local originY = Player.y + Player.w / 2
        for i = random(4, 8), 1, -1 do 
            table.insert(GameEntities,
                {
                    type = 'Particle',
                    x = originX,
                    y = originY,
                    speed = random(150, 250),
                    lifespan = random(1, 3),
                    w = random(2,5),
                    tick = 0,
                    angle = random(math.pi*0.125, math.pi*0.75),
                    color = ParticleColors[round(random(1, #ParticleColors))],
                    dead = false
                }
            )
        end
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

function map(things, convert)
    local mapped = {}
    each(things, function(thing)
        table.insert(mapped, convert(thing))
    end)
    return mapped
end

function drawPlayer(entity) 
    love.graphics.setColor(255,255,255, 255)
    love.graphics.circle('line', entity.x, entity.y, entity.w, entity.w)
end

function drawPlayerBullet(entity)
    love.graphics.setColor(0 , 255, 255, 255)
    love.graphics.push()
    love.graphics.translate(entity.x - entity.w / 2, entity.y - entity.w / 2)
    love.graphics.rotate(entity.angle)
    love.graphics.circle('fill', 0, 0, entity.w, entity.w)
    love.graphics.pop()
    love.graphics.setColor(255, 255, 255, 255)
end

function drawParticle(entity)
    love.graphics.setColor(entity.color.r, entity.color.g, entity.color.b, (1 - entity.tick / entity.lifespan) * entity.color.a)
    love.graphics.push()
    love.graphics.translate(entity.x - entity.w / 2, entity.y - entity.w / 2)
    love.graphics.rotate(entity.angle)
    love.graphics.rectangle('fill', 0, 0, entity.w, entity.w)
    love.graphics.pop()
    love.graphics.setColor(255, 255, 255, 255)
end

function drawEnemy(entity) 
    love.graphics.setColor(0, 0, 0, 255)
    love.graphics.circle('fill', entity.x, entity.y, entity.w, entity.w)
    love.graphics.setColor(255, 0, 0, 255)
    love.graphics.circle('line', entity.x, entity.y, entity.w, entity.w)
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
            local originX = (Player.x - Player.w / 2) + 4
            local originY = Player.y - Player.w / 2 - 10
            for i = 2, 1, -1 do 
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