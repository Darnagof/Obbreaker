INITIAL_SPEED = 0.5 -- SceneUnits/secondes

function Local.Init(position)
    --This.Sprite:setPosition(This.SceneNode:getPosition())
    Object:setPos(position.x, position.y, position.unit, position.ref)
end

function Object:getSceneNode()
    return This.SceneNode
end

function Object:getPos(ref)
    return This.Sprite:getPosition(obe.Transform.Referential.FromString(ref or "TopLeft"))
end

function Object:destroy()
    -- Add score
    This:deleteObject()
end

function Object:getType()
    return This:getType()
end

function Object:getId()
    return This:getId()
end

function Object:setPos(x, y, unit, ref)
    local newPos = obe.Transform.UnitVector(x or 0, y or 0, obe.Transform.stringToUnits(unit or "SceneUnits"))
    if ref then
        newPos = newPos + This.SceneNode:getPosition() - Object:getPos(ref) 
    end
    This.SceneNode:setPosition(newPos)
end