function setCamera(camera)
    love.graphics.push()
    love.graphics.rotate(-camera.rotation)
    love.graphics.scale(1 / camera.scaleX, 1 / camera.scaleY)
    love.graphics.translate(-camera.x, -camera.y)
end

function unsetCamera()
    love.graphics.pop()
end

function moveCamera(camera, dx, dy)
    camera.x = camera.x + (dx or 0)
    camera.y = camera.y + (dx or 0)
end

function setCameraPosition(camera, x, y)
    if x then camera.x = x end 
    if y then camera.y = y end
end