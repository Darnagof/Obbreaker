local class = require 'Lib.Extlibs.pl.class'



--[[ Vector2 = class()

function Vector2:_init(x, y)
    self.x = x
    self.y = y
end

function Vector2:magnitude()
    return sqrt(self.x^2 + self.y^2)
end

function Vector2:__add(V)
    return Vector2(self.x + V.x, self.y + V.y)
end

function Vector2:normalize()
    local mag = self:magnitude()
    if mag > 0 then
        return Vector2(self.x / mag, self.y / mag)
    else return 0 end
end ]]