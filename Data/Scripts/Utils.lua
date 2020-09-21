Utils = {}

Utils.Axis = {Horizontally = 1, Vertically = 2}
function Utils.mirrorAngle(angle, axis)
    if axis == Utils.Axis.Horizontally then
        return 360 - angle
    elseif axis == Utils.Axis.Vertically then
        return 180 - angle
    else
        log.error("Utils", "mirrorAngle", "unknown axis: ", axis)
        return angle
    end
end

function Utils.angleTo360(angle)
    while angle > 360 do
        angle = angle - 360
    end
    while angle < 0 do
        angle = angle + 360
    end
    return angle
end

return Utils