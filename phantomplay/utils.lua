-- Utility classes using MTA OOP system
-- Organized utility functions for common operations

-- Math utilities
MathUtils = {}

function MathUtils.round(number, decimals)
    local multiplier = 10^(decimals or 0)
    return math.floor(number * multiplier + 0.5) / multiplier
end

function MathUtils.clamp(value, min, max)
    return math.max(min, math.min(max, value))
end

function MathUtils.lerp(a, b, t)
    return a + (b - a) * t
end

function MathUtils.distance2D(x1, y1, x2, y2)
    return math.sqrt((x2 - x1)^2 + (y2 - y1)^2)
end

function MathUtils.distance3D(x1, y1, z1, x2, y2, z2)
    return math.sqrt((x2 - x1)^2 + (y2 - y1)^2 + (z2 - z1)^2)
end

function MathUtils.randomFloat(min, max)
    return min + (max - min) * math.random()
end

-- String utilities
StringUtils = {}

function StringUtils.trim(str)
    return str:match("^%s*(.-)%s*$")
end

function StringUtils.split(str, delimiter)
    delimiter = delimiter or "%s"
    local result = {}
    for match in str:gmatch("([^" .. delimiter .. "]+)") do
        table.insert(result, match)
    end
    return result
end

function StringUtils.startsWith(str, prefix)
    return str:sub(1, #prefix) == prefix
end

function StringUtils.endsWith(str, suffix)
    return str:sub(-#suffix) == suffix
end

function StringUtils.capitalize(str)
    return str:sub(1, 1):upper() .. str:sub(2):lower()
end

function StringUtils.formatMoney(amount)
    local formatted = tostring(amount)
    local k = 0
    while k < #formatted do
        k = k + 4
        if k < #formatted then
            formatted = formatted:sub(1, #formatted - k + 1) .. "," .. formatted:sub(#formatted - k + 2)
        end
    end
    return "$" .. formatted
end

function StringUtils.formatTime(seconds)
    local hours = math.floor(seconds / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    local secs = seconds % 60
    
    if hours > 0 then
        return string.format("%02d:%02d:%02d", hours, minutes, secs)
    else
        return string.format("%02d:%02d", minutes, secs)
    end
end

-- Validation utilities
ValidationUtils = {}

function ValidationUtils.isValidEmail(email)
    if not email or type(email) ~= "string" then
        return false
    end
    return email:match("^[%w%._%+%-]+@[%w%._%+%-]+%.%w+$") ~= nil
end

function ValidationUtils.isValidUsername(username)
    if not username or type(username) ~= "string" then
        return false
    end
    return #username >= 3 and #username <= 20 and username:match("^[%w_]+$") ~= nil
end

function ValidationUtils.isValidPassword(password)
    if not password or type(password) ~= "string" then
        return false
    end
    return #password >= 6 and #password <= 50
end

function ValidationUtils.isValidPlayerName(name)
    if not name or type(name) ~= "string" then
        return false
    end
    return #name >= 2 and #name <= 30 and name:match("^[%w%s_%-%.]+$") ~= nil
end

function ValidationUtils.isValidAge(age)
    local numAge = tonumber(age)
    return numAge and numAge >= 16 and numAge <= 100
end

function ValidationUtils.isValidCoordinate(coord)
    local numCoord = tonumber(coord)
    return numCoord and numCoord >= -20000 and numCoord <= 20000
end

-- Color utilities
ColorUtils = {}

function ColorUtils.hexToRGB(hex)
    hex = hex:gsub("#", "")
    if #hex ~= 6 then
        return 255, 255, 255
    end
    
    local r = tonumber(hex:sub(1, 2), 16) or 255
    local g = tonumber(hex:sub(3, 4), 16) or 255
    local b = tonumber(hex:sub(5, 6), 16) or 255
    
    return r, g, b
end

function ColorUtils.rgbToHex(r, g, b)
    return string.format("#%02X%02X%02X", r, g, b)
end

function ColorUtils.getRandomColor()
    local r = math.random(0, 255)
    local g = math.random(0, 255)
    local b = math.random(0, 255)
    return string.format("%d,%d,%d", r, g, b)
end

-- Table utilities
TableUtils = {}

function TableUtils.isEmpty(tbl)
    return next(tbl) == nil
end

function TableUtils.count(tbl)
    local count = 0
    for _ in pairs(tbl) do
        count = count + 1
    end
    return count
end

function TableUtils.copy(tbl)
    local copy = {}
    for key, value in pairs(tbl) do
        if type(value) == "table" then
            copy[key] = TableUtils.copy(value)
        else
            copy[key] = value
        end
    end
    return copy
end

function TableUtils.merge(tbl1, tbl2)
    local merged = TableUtils.copy(tbl1)
    for key, value in pairs(tbl2) do
        merged[key] = value
    end
    return merged
end

function TableUtils.contains(tbl, value)
    for _, v in pairs(tbl) do
        if v == value then
            return true
        end
    end
    return false
end

function isTableNotEmpty(t)
	return type(t) == "table" and next(t) ~= nil
end
