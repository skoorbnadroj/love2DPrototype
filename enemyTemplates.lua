return {
    ['Circling'] = function() 
    return 
    {
        type = 'Enemy',
        x = gw / 2 - 20,
        y = gh / 2,
        w = 20,
        speed = 30,
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
            w = 20,
            speed = random(70, 100),
            health = 10,
            dead = false
        }
    end
}