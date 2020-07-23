INITIAL_SPEED = 5 -- SceneUnits/seconds

-- Which side of block/wall/paddle had been touched
HitPos = {
    Left = 1,
    Right = 2,
    Top = 3,
    Bottom = 4,
}

function Local.Init()
    This.Sprite:setPosition(This.SceneNode:getPosition())
    _tNode = obe.Collision.TrajectoryNode(This.SceneNode)
    _tNode:addTrajectory("Linear")
        :setAngle(45)
        :setSpeed(INITIAL_SPEED)
        :setAcceleration(0)
        :onCollide(Object.onCollide)
    _tNode:setProbe(This.Collider)
    _trajectory = _tNode:getTrajectory("Linear")
    _trajectory:setStatic(true)
end

function Object:getSceneNode()
    return This.SceneNode
end

function Object:getPos(ref)
    return This.Sprite:getPosition(obe.Transform.Referential.FromString(ref or "TopLeft"))
end

function Object:setPos(x, y, unit, ref)
    local newPos = obe.Transform.UnitVector(x or 0, y or 0, obe.Transform.stringToUnits(unit or "SceneUnits"))
    if ref then
        newPos = newPos + This.SceneNode:getPosition() - Object:getPos(ref) 
    end
    This.SceneNode:setPosition(newPos)
end

function Object:stop()
    _trajectory:setStatic(true)
end

function Object:launch()
    _trajectory:setStatic(false)
end

function Object.onCollide(self, baseOffset, collData)
    -- To record which side had been touched (avoid changing angle two times if two objects had been touched in same side)
    local touchedSides = {}
    if #collData.colliders > 1 then log.info("Ball", "onCollide", "touched > 1 colliders !") end--DEBUG
    for _, coll in pairs(collData.colliders) do
        local other = Engine.Scene:getGameObject(coll:getParentId())
        local otherType = other:getType()
        local side = Object:_relativePosFromObj(other)
        -- If paddle, bounce (angle and speed depending of ball position and paddle movement)
        if otherType == "Paddle" then
            Object:_paddleBounce(side, other)
        -- If block or wall
        else
            if touchedSides[side] == nil then
                Object:_bounce(side)
                touchedSides[side] = true
            end
            if otherType == "Block" then
                other:destroy()
                -- TODO raise score
            end
        end
    end
end

-- Get relative position from brick/wall/paddle
function Object:_relativePosFromObj(target)
    local ballTopLeft = Object:getPos()
    local ballBotRight = Object:getPos("BottomRight")
    local targetTopLeft = target:getPos()
    local targetBotRight = target:getPos("BottomRight")
    log.info("Ball", "_relativePosFromObj", "ballBotRight:", ballBotRight, "targetTopLeft:", targetTopLeft)--DEBUG
    log.info("Ball", "_relativePosFromObj", "target id:", target:getId())
    if ballBotRight.x <= targetTopLeft.x then
        return HitPos.Left
    elseif ballTopLeft.x >= targetBotRight.x then
        return HitPos.Right
    elseif ballBotRight.y <= targetTopLeft.y then
        return HitPos.Top
    else
        return HitPos.Bottom
    end
end



-- Change ball angle depending of which side of an object had been touched
-- BUG Two bricks touched on bottom -> the new ball angle is sometimes wrong (mirrored horizontally instead of vertically)
function Object:_bounce(hitSide)
    local angle = _trajectory:getAngle()
    local newAngle = 0
    if hitSide == HitPos.Left then
        newAngle = 180 - angle
    elseif hitSide == HitPos.Right then
        newAngle = 180 - angle
    elseif hitSide == HitPos.Top then
        newAngle = 360 - angle
    else
        newAngle = 360 - angle
    end
    log.info("Ball", "_bounce", "hitSide:", hitSide, "newAngle:", newAngle)--DEBUG
    _trajectory:setAngle(newAngle)
end

-- Called when ball collide with the paddle
-- TODO speed modified by motion (and position ?) of paddle
-- TODO what to do with sides and bottom collision ?
-- BUG Sometimes the ball new angle is wrong when the ball touched in the middle (hitposes = left and bottom)
function Object:_paddleBounce(hitSide, paddle)
    local ballMiddle = Object:getPos("Center").x
    local paddleMiddle = paddle:getPos("Center").x
    local angle = _trajectory:getAngle()
    local newAngle = 0

    if hitSide == HitPos.Left then
        newAngle = 180 - angle
    elseif hitSide == HitPos.Right then
        newAngle = 180 - angle
    elseif hitSide == HitPos.Top then
        -- TODO Find good angle modifier amount
        local addAngle = -30 * ((ballMiddle-paddleMiddle)/(paddle:getWidth()/2))
        newAngle = 360 - angle + addAngle
        if newAngle > 165 then
            newAngle = 165
        elseif newAngle < 15 then
            newAngle = 15
        end
        log.info("Ball", "_paddleBounce", "angle", angle, "addAngle:", addAngle, "newAngle:", newAngle)--DEBUG
    -- if Bottom
    else
        log.error("Ball", "_paddleBounce", "HitPos = Bottom")--DEBUG
        newAngle = 360 - angle
    end
    _trajectory:setAngle(newAngle)
end

function Object:addSpeed(amount)
    _trajectory:setSpeed(amount + _trajectory:getSpeed())
end

function Object:setAngle(angle)
    _trajectory:setAngle(angle)
end

function Event.Game.Update(dt)
    _tNode:update(dt)
end