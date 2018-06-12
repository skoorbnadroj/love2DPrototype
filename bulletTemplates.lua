return {
    ['DefaultPlayerBullet'] = function (x, y, offsetX)
        return 
        {
            type = 'PlayerBullet',
            x = x + (offsetX * 8),
            y = y,
            speed = 350,
            w = 4,
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