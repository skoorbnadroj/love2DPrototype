return {
    ['PlayerBullet'] = function(entity, dt)
        local dX = entity.speed * math.cos(entity.angle) * dt
        local dY = entity.speed * math.sin(entity.angle) * dt
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
                        local p = ParticleTemplates['Shrapnel'](originX, originY, angleOffset)
                        table.insert(GameEntities, p)
                    end
                end
            end
        end
    end,
    ['Particle'] = function(entity, dt)
        if entity.tick > entity.lifespan then entity.dead = true end
        entity.tick = entity.tick + dt
        local dX = entity.speed * math.cos(entity.angle) * dt
        local dY = entity.speed * math.sin(entity.angle) * dt
        entity.speed = entity.speed * 0.95
        updateEntityPosition(entity, dX, dY)
    end,
    ['Enemy'] = function(entity, dt) 
        local dX = (math.sin(entity.tick or 0) * entity.speed) * dt
        local dY = (math.cos(entity.tick or 0) * entity.speed) * dt 
        updateEntityPosition(entity, dX, dY)
        if checkEntityBounds(entity, -50, gw + 50, -100, gh + 50) then 
            entity.dead = true 
        end
        if entity.health < 0 then 
            entity.dead = true 
            for i = random(50, 100), 1, -1 do 
                local p = ParticleTemplates['OnEnemyDeathSmall'](entity, 3)
                table.insert(GameEntities, p)
            end
            for i = 3, 1, -1 do 
                local p = ParticleTemplates['OnEnemyDeathLarge'](entity, i)
                table.insert(GameEntities, p)
            end
        end
        if entity.tick  then entity.tick = entity.tick + dt end
  
    end,
    ['ShotEffect'] = function(entity, dt)
        if entity.tick > entity.lifespan then entity.dead = true end
        moveTo(entity, Player.x, Player.y - Player.w)
        entity.tick = entity.tick + dt
    end,
    ['Player'] = function(entity, dt)
        entity.tick = entity.tick - dt
        dX, dY = handlePlayerInput(entity, dt)
        updateEntityPosition(entity, dX, dY)
    end
}