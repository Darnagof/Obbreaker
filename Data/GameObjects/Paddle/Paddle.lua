-- Paddle follow horizontal position of cursor ?
Object.followCursor = true
-- Max X axis the paddle can traverse (in SceneUnits)
MAX_X = 14
-- Initial width of the paddle
BASE_WIDTH = 0.775
-- Height of the paddle
HEIGHT = 0.175
-- Width of the paddle (in SceneUnits)
_width = BASE_WIDTH

function Local.Init(position)
    Object:setPos(position.x, position.y, position.unit)
    --This.Sprite:setPosition(Object:getPos(), obe.Transform.Referential.TopLeft)
    Object:setWidth(BASE_WIDTH)
    _xBounds = {Object:getPos("Center").x - MAX_X/2, Object:getPos("Center").x + MAX_X/2}
end

function Object:getSceneNode()
    return This.SceneNode
end

-- @param vPos UnitVector of position
-- @param ref Reference
function Object:setPos(x, y, unit)
    This.SceneNode:setPosition(obe.Transform.UnitVector(x or 0, y or 0, obe.Transform.stringToUnits(unit or "SceneUnits")))
end

function Object:setWidth(width, unit)
    unit = obe.Transform.stringToUnits(unit or "SceneUnits")
    -- Change sprite width
    This.Sprite:setSize(obe.Transform.UnitVector(width, This.Sprite:getSize().y, unit))
    -- Change collider width
    This.Collider:get(0):set(Object:getPos())
    This.Collider:get(1):setRelativePosition(obe.Transform.RelativePositionFrom.Point0, obe.Transform.UnitVector(width, 0, unit))
    This.Collider:get(2):setRelativePosition(obe.Transform.RelativePositionFrom.Point0, obe.Transform.UnitVector(width, HEIGHT, unit))
    This.Collider:get(3):setRelativePosition(obe.Transform.RelativePositionFrom.Point0, obe.Transform.UnitVector(0, HEIGHT, unit))
    _width = obe.Transform.UnitVector(width, 0, unit):to(obe.Transform.Units.SceneUnits).x
end

function Object:getWidth()
    return _width
end

function Object:getPos(ref)
    if ref then
        return This.Sprite:getPosition(obe.Transform.Referential.FromString(ref or "Center"))
    end
    return This.SceneNode:getPosition()
end

function Object:getType()
    return This:getType()
end

function Object:getId()
    return This:getId()
end

function Event.Game.Update(dt)
    
    -- Paddle vertical center follow cursor
    if Object.followCursor then
        local cursorX = Engine.Cursor:getPosition():to(obe.Transform.Units.SceneUnits).x
        if cursorX + _width/2 > _xBounds[2] then
            Object:setPos(_xBounds[2] - _width, Object:getPos().y)
        elseif cursorX - _width/2 < _xBounds[1] then
            Object:setPos(_xBounds[1], Object:getPos().y)
        else
            Object:setPos(cursorX - _width/2, Object:getPos().y)
        end
    end

end