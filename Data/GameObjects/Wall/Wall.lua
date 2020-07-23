function Local.Init(pos, size, color)
    This.SceneNode:setPosition(obe.Transform.UnitVector(pos.x or 0, pos.y or 0, obe.Transform.stringToUnits(pos.unit or "SceneUnits")))
    This.Sprite:setColor(obe.Graphics.Color(color or "#FFFFFF"))
    Object:setSize(size.x or 0, size.y or 0, size.unit)
end

function Object:setSize(width, height, unit)
    unit = obe.Transform.stringToUnits(unit or "SceneUnits")
    local _size = obe.Transform.UnitVector(width, height, unit):to(obe.Transform.Units.SceneUnits)
    -- Change sprite width
    This.Sprite:setSize(_size)
    -- Change collider width
    This.Collider:get(0):set(Object:getPos())
    This.Collider:get(1):setRelativePosition(obe.Transform.RelativePositionFrom.Point0, obe.Transform.UnitVector(width, 0, unit))
    This.Collider:get(2):setRelativePosition(obe.Transform.RelativePositionFrom.Point0, _size)
    This.Collider:get(3):setRelativePosition(obe.Transform.RelativePositionFrom.Point0, obe.Transform.UnitVector(0, height, unit))
end

function Object:getSize()
    return Object.sprite:getSize()
end

function Object:getPos(ref)
    if ref then
        return This.Sprite:getPosition(obe.Transform.Referential.FromString(ref or "TopLeft"))
    end
    return This.SceneNode:getPosition()
end

function Object:getType()
    return This:getType()
end

function Object:getId()
    return This:getId()
end

-- Unused
function Object:getSprite()
    return Object.sprite
end