function random(a, b) 
    local min, max = 0, 0
    if b == nil then 
        max, min = a, 0 
    else 
        if a > b then 
            max, min = a, b 
        else 
            max, min = b, a 
        end
    end
    return love.math.random()*(max - min) + min
end