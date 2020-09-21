local Utils = require "Data/Scripts/Utils"

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
    local touchedSides = {0, 0, 0, 0}
    if #collData.colliders > 1 then log.info("Ball", "onCollide", "touched "..#collData.colliders.." colliders !") end--DEBUG
    for _, coll in pairs(collData.colliders) do
        local other = Engine.Scene:getGameObject(coll:getParentId())
        local otherType = other:getType()
        local sides = Object:_relativePosFromObj(other)
        -- If paddle, bounce (angle and speed depending of ball position and paddle movement)
        if otherType == "Paddle" then
            Object:_paddleBounce(sides, other)
        -- If block or wall
        else
            for _, side in ipairs(sides) do
                touchedSides[side] = touchedSides[side] + 1
            end
            if otherType == "Block" then
                other:destroy()
                -- TODO raise score
            end
        end
    end
    local maxSideAmount = 0
    for _, sideAmount in ipairs(touchedSides) do
        if maxSideAmount < sideAmount then maxSideAmount = sideAmount end
    end
    if maxSideAmount > 0 then
        for side, amount in ipairs(touchedSides) do
            if amount == maxSideAmount then Object:_bounce(side) end
        end
    end
end

-- Get relative position from brick/wall/paddle
function Object:_relativePosFromObj(target)
    local ballTopLeft = Object:getPos()
    local ballBotRight = Object:getPos("BottomRight")
    local targetTopLeft = target:getPos()
    local targetBotRight = target:getPos("BottomRight")
    local hitPoses = {}
    log.info("Ball", "_relativePosFromObj", "target id:", target.id)
    log.info("Ball", "_relativePosFromObj", "\n\tballTopLeft:", ballTopLeft, "\n\tballBotRight:", ballBotRight, "\n\ttargetTopLeft:", targetTopLeft, "\n\ttargetBotRight:", targetBotRight)--DEBUG
    if ballBotRight.x <= targetTopLeft.x then table.insert(hitPoses, HitPos.Left) end
    if ballTopLeft.x >= targetBotRight.x then table.insert(hitPoses, HitPos.Right) end
    if ballBotRight.y <= targetTopLeft.y then table.insert(hitPoses, HitPos.Top) end
    if ballTopLeft.y >= targetBotRight.y then table.insert(hitPoses, HitPos.Bottom) end

    return hitPoses
end



-- Change ball angle depending of which side of an object had been touched
-- BUG Two bricks touched on bottom -> the new ball angle is sometimes wrong (mirrored horizontally instead of vertically)
function Object:_bounce(hitSide)
    local angle = _trajectory:getAngle()
    if hitSide == HitPos.Left or hitSide == HitPos.Right then
        newAngle = Utils.mirrorAngle(angle, Utils.Axis.Vertically)
    else
        newAngle = Utils.mirrorAngle(angle, Utils.Axis.Horizontally)
    end
    log.info("Ball", "_bounce", "hitSide:", hitSide, "newAngle:", Utils.angleTo360(newAngle))--DEBUG
    _trajectory:setAngle(Utils.angleTo360(newAngle))
end

-- Called when ball collide with the paddle
-- TODO speed modified by motion (and position ?) of paddle
-- TODO what to do with sides and bottom collision ?
-- BUG Sometimes the ball new angle is wrong when the ball touched in the middle (hitposes = left and bottom)
-- BUG Removed teleport only if hitSide != Top, because if you move paddle toward the ball, the ball can be inside the paddle during collision detection
-- and so no hitsides are found
function Object:_paddleBounce(hitSides, paddle)
    --[[ for _, side in ipairs(hitSides) do
        if side ~= HitPos.Top then
            -- Teleport ball on top of paddle (with a little offset to avoid ball being stuck)
            log.info("Ball", "_paddleBounce", "ball to top of paddle")
            Object:setPos(Object:getPos("Bottom").x, paddle:getPos().y - 0.0001, "SceneUnits", "Bottom")
            break
        end
    end ]]
    log.info("Ball", "_paddleBounce", "tp ball to (", Object:getPos("Bottom").x, ",", paddle:getPos().y - 0.0001, ")")
    Object:setPos(Object:getPos("Bottom").x, paddle:getPos().y - 0.0001, "SceneUnits", "Bottom")

    local ballMiddle = Object:getPos("Center").x
    local paddleMiddle = paddle:getPos("Center").x
    local angle = _trajectory:getAngle()

    -- BUG Wrong new angle mirroring; example : with -15 angle, the new is 165 (it should be 15)
    local addAngle = -30 * ((ballMiddle-paddleMiddle)/(paddle:getWidth()/2))
    newAngle = Utils.angleTo360(Utils.mirrorAngle(angle, Utils.Axis.Horizontally)) + addAngle
    log.info("Ball", "_paddleBounce", "newAngle:", newAngle)
    if newAngle > 165 then
        newAngle = 165
    elseif newAngle < 15 then
        newAngle = 15
    end

    log.info("Ball", "_paddleBounce", "angle", angle, "addAngle:", addAngle, "newAngle:", newAngle)--DEBUG
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