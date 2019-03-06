local Game = {}

-- update and draw all Game Objects
-- factory new Game Objects

function Game:new(o)
    local game = o or {}
    self.__index = self
    setmetatable(game, self)

    game.gameObjects = {}

    return game
end

function Game:observe(go)
    table.insert(self.gameObjects, go)
end

function Game:update(dt)
    print(#self.gameObjects)
    for i, go in pairs(self.gameObjects) do
        if go:isDead() then
            print("removing "..i)
            table.remove(self.gameObjects, i)
        end

        go:update(dt)
    end
end

function Game:draw()
    for i, go in pairs(self.gameObjects) do
        go:draw(i)
    end
end


function Game:animate(dt)
    for i, go in pairs(self.gameObjects) do
        if go.animation then
            go.animation:step(dt)
        end
    end
end


function Game:make(object)
    table.insert(self.gameObjects, object)

    return object
end

return Game