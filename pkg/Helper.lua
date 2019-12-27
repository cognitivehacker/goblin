local helper = {}

function helper.Copy(obj, seen)
    if type(obj) ~= 'table' then return obj end
    if seen and seen[obj] then return seen[obj] end
    local s = seen or {}
    local res = setmetatable({}, getmetatable(obj))
    s[obj] = res
    for k, v in pairs(obj) do res[copy(k, s)] = copy(v, s) end
    return res
end

function helper.ArrFilter(arr, func)
    local out = {}
    for _, e in ipairs(arr) do
        if not func(e) then
            table.insert(out, e)
        end
    end
    return out
end


function helper.ArrMap(arr, func)
    local out = {}
    for _, e in ipairs(arr) do
        table.insert(out, func(e))
    end
    return out
end

function helper.Euclid(a, b)
    return math.sqrt(((b.x - a.x) ^ 2) + ((b.y - a.y) ^ 2));
end

return helper