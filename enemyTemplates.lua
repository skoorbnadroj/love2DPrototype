return {
    ['Circling'] = function() 
    return 
    {
        type = 'Enemy',
        x = gw / 2 - 20,
        y = gh / 2,
        w = 100,
        speed = 100,
        tick = 0,
        health = 1000000,
        dead = false
    }
    end, 
    ['FlyDown'] = function()
        return            
        {
            type = 'Enemy',
            x = random(10, gw - 10),
            y = -20,
            w = 50,
            speed = random(100, 200),
            health = 2,
            dead = false
        }
    end
}