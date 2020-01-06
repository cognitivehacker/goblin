local copy = require("pkg.Helper").Copy

local collision = {}

function collision.Euclidian(bodyA, bodyB, radius)
    radius = radius or 0
    return math.sqrt(((bodyB.x - bodyA.x) ^ 2) + ((bodyB.y - bodyA.y) ^ 2)) <= radius;
end

function collision.CollideBox(bodyA, bodyB)
    if bodyA.invincible or bodyB.invincible then return false end
    for  _, a in ipairs(bodyA:getBoxes()) do         
      for _, b in ipairs(bodyB:getBoxes()) do
        if a.x + bodyA.x < bodyB.x + b.x + b.width 
        and bodyA.x + a.x + a.width > b.x + bodyB.x 
        and a.y + bodyA.y < b.y + b.height + bodyB.y
        and a.height + a.y + bodyA.y  > b.y + bodyB.y
        then
          return true;
        end
      end
    end
    return false;
  end

function collision.SelfColide(group, callback, collideMethod)
    local colideFunc = collideMethod or collision.CollideBox

    for i=1, #group  do
        for j=i+1, #group do
            if colideFunc(group[i], group[j]) then
                callback(group[i], group[j])
            end
        end
    end
end

function collision.ColideWithB(groupA, groupB, callback, collideMethod)
    local colideFunc = collideMethod or collision.CollideBox

    for i, u1 in pairs(groupA) do
        for _, u2 in pairs(groupB) do
            if colideFunc(u1, u2) then
                callback(u1, u2)
            end
        end
    end
end

function collision.ColideSingle(group, go, callback, collideMethod)
    local colideFunc = collideMethod or collision.CollideBox
    for _, u1 in pairs(group) do
        if colideFunc(u1, go) then
            callback(u1, go)
        end
    end
end

return collision
