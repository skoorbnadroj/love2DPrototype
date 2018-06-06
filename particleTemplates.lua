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
    end,
    ['Shrapnel'] = function(x, y, angleOffset)
        return {
            type = 'Particle',
            x = x,
            y = y,
            speed = random(200, 300),
            lifespan = random(0.25, 1.5),
            w = random(2,5),
            tick = 0,
            angle = angleOffset + random(-math.pi/5, math.pi/5),
            color = ParticleColors[round(random(1, #ParticleColors))],
            dead = false
        }
    end,
    ['ShotEffectParticle'] = function (x, y, particleindex)
        return 
        {
            type = 'Particle',
            x = x,
            y = y,
            speed = 200,
            lifespan = random(0.075, 0.25),
            w = 4,
            tick = 0,
            angle = math.pi + math.pi / 8 * particleindex,
            color = {r = 0, g = 255, b = 255, a = 255},
            dead = false
        }
    end,
}