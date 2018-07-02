require 'Utils'

Canvas = love.graphics.newCanvas(gw, gh)

require 'camera'
RenderStyles = require 'renderStyles'
ParticleTemplates = require 'particleTemplates'
EnemyTemplates = require 'enemyTemplates'
EntityUpdates = require 'entityUpdates'
BulletTemplates = require 'bulletTemplates'

GameEntities = {}

Player = {
    type = 'Player',
    x = gw / 2,
    y = gh - 30,
    w = 50,
    speed = 300,
    fireRate = 0.085,
    tick = 0,
    dead = false
}

Camera = {
    x = 0,
    y = 0,
    scaleX = 1,
    scaleY = 1,
    rotation = 0
}

local enemySpawnTimer = 0
local enemySpawnThreshold = 0.125

function love.load()

    local enemy = EnemyTemplates['Circling']()
    table.insert(GameEntities, Player)
    table.insert(GameEntities, enemy)

    love.keyboard.keysPressed = {}

    smallFont = love.graphics.newFont('font.ttf', 20)

    print(RenderStyles)
end

function love.update(dt)
    RemoveDeadEntities(GameEntities)

    if enemySpawnTimer > enemySpawnThreshold then 
        table.insert(GameEntities, EnemyTemplates['FlyDown']())
        enemySpawnTimer = 0
    end

    for i = #GameEntities, 1, -1 do 
        local entity = GameEntities[i]
        updateEntity(EntityUpdates, entity, dt)
    end

    setCameraPosition(Camera, 0, 0)
    enemySpawnTimer = enemySpawnTimer + dt
    love.keyboard.keysPressed = {}
end

function love.draw()

    love.graphics.setColor(255, 255, 255)
    love.graphics.setCanvas(Canvas)
    love.graphics.clear()
    setCamera(Camera)
    for i = #GameEntities, 1, -1 do 
        local entity = GameEntities[i]
        if not entity.dead then
            renderEntity(RenderStyles, entity)
        end
    end
    unsetCamera(Camera)
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

function RemoveDeadEntities(entities)
    for i = #GameEntities, 1, -1 do 
        local entity = GameEntities[i]
        if entity.dead then 
            entity = nil
            table.remove(GameEntities, i)
        end
    end
end

function each(table, fn)
    for i = #table, 1, -1 do 
        fn(table[i])
    end
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

function renderEntity(renderStyles, entity, opts)
    renderStyles[entity.type](entity, opts)
end

function updateEntity(entityUpdates, entity, dt)
    entityUpdates[entity.type](entity, dt)
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
            for i = 3, 1, -1 do 
                table.insert(GameEntities, 
                    BulletTemplates['DefaultPlayerBullet'](
                        Player.x, 
                        Player.y - Player.w, 
                        i - 1)
                )
            end
            for i = 6, 1, -1 do 
                table.insert(GameEntities,
                    ParticleTemplates['ShotEffectParticle'](
                        Player.x, 
                        Player.y - Player.w, 
                        i
                    )
                )
            end
            table.insert(GameEntities,
                {
                    type = 'ShotEffect',
                    x = Player.x,
                    y = Player.y - Player.w,
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