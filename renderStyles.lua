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

return {

    ['Player'] = function(entity) 
        love.graphics.setColor(255,255,255, 255)
        love.graphics.setLineWidth(3)
        love.graphics.circle('line', entity.x, entity.y, entity.w, entity.w)
        love.graphics.setLineWidth(1)
    end,
    
    ['PlayerBullet'] = function(entity)
        love.graphics.setColor(0, 128, 255, 255)
        love.graphics.push()
        love.graphics.translate(entity.x - entity.w / 2, entity.y - entity.w / 2)
        love.graphics.rotate(entity.angle)
        love.graphics.circle('fill', 0, 0, entity.w, entity.w)
        love.graphics.pop()
        love.graphics.setColor(255, 255, 255, 255)
    end,
    
    ['Particle'] = function(entity)
        love.graphics.setColor(entity.color.r, entity.color.g, entity.color.b, (1 - entity.tick / entity.lifespan) * entity.color.a)
        love.graphics.push()
        love.graphics.translate(entity.x - entity.w / 2, entity.y - entity.w / 2)
        love.graphics.rotate(entity.angle)
        love.graphics.rectangle('fill', 0, 0, entity.w, entity.w)
        love.graphics.pop()
        love.graphics.setColor(255, 255, 255, 255)
    end,
    
    ['ShotEffect'] = function(entity)
        love.graphics.setColor(255,255,255,(1 - entity.tick / entity.lifespan) * 255)
        love.graphics.push()
        love.graphics.translate(entity.x - entity.w / 2, entity.y - entity.w / 2)
        love.graphics.rotate(math.pi * 0.25)
        love.graphics.rectangle('fill', (entity.w / 2) - 3, -entity.w / 2, entity.w, entity.w)
        love.graphics.pop()
        love.graphics.setColor(255, 255, 255, 255)
    end,
    
    ['Enemy'] = function(entity) 
        love.graphics.setColor(255, 0, 0, 255)
        love.graphics.setLineWidth(4)
        love.graphics.circle('line', entity.x, entity.y, entity.w, entity.w)
        love.graphics.setLineWidth(1)
        love.graphics.setFont(smallFont)
        love.graphics.setColor(255, 255, 255, 255)
        love.graphics.printf( 'Enemy', entity.x - entity.w, entity.y, entity.w * 2, 'center' )
    end,
}