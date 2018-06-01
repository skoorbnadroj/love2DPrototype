return {
    ['OnEnemyDeathSmall'] = function(entity, colorIndex)
        return {
            type = 'Particle',
            x = entity.x,
            y = entity.y,
            speed = random(250, 275),
            lifespan = random(0.125, 0.5),
            w = random(4, 8),
            tick = 0,
            angle = random(0, math.pi * 2),
            color = ParticleColors[colorIndex],
            dead = false
        }
    end,
    ['OnEnemyDeathLarge'] = function(entity, colorIndex)
    return {
        type = 'Particle',
        x = entity.x,
        y = entity.y,
        speed = random(10, 20),
        lifespan = random(0.075, 0.25),
        w = random(entity.w-10,entity.w+10),
        tick = 0,
        angle = 0,
        color = ParticleColors[colorIndex],
        dead = false
    }
    end
}