return {
    ['DefaultPlayerBullet'] = function (x, y, offsetX)
        local width = 10
        return 
        {
            type = 'PlayerBullet',
            x = x + (offsetX * (width*2)),
            y = y,
            speed = 500,
            w = width,
            angle = math.pi + math.pi / 2,
            dead = false
        }
    end,
    ['LargePlayerBullet'] = function (x, y)
        return 
        {
            type = 'PlayerBullet',
            x = x,
            y = y,
            speed = 400,
            w = 8,
            angle = math.pi + math.pi / 2,
            dead = false
        }
    end,
}