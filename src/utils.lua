local json = require("json")

local utils_module = {}

-- a simple log function
-- TODO: use a real log module
function utils_module.printToFile(line, txt)
	local s = "echo \"Linha " .. line .. " - " .. txt .."\"  >> /tmp/lualogs.txt"
	os.execute(s)
end

-- String split (or explode)
function utils_module.split(source, delimiters)
      local elements = {}
      local pattern = '([^'..delimiters..']+)'
      string.gsub(source, pattern, function(value) elements[#elements + 1] =  value;  end);
      return elements
end


-- base64 character table string
local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'

-- base 64 decode
local function dec64(data)
    data = string.gsub(data, '[^'..b..'=]', '')
    return (data:gsub('.', function(x)
        if (x == '=') then return '' end
        local r,f='',(b:find(x)-1)
        for i=6,1,-1 do r=r..(f%2^i-f%2^(i-1)>0 and '1' or '0') end
        return r;
    end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
        if (#x ~= 8) then return '' end
        local c=0
        for i=1,8 do c=c+(x:sub(i,i)=='1' and 2^(8-i) or 0) end
        return string.char(c)
    end))
end

function utils_module.jwtExtractField(rawJWT, field)
  local rawJWTCut = utils_module.split(rawJWT,'.')

  --verify if the JWT have all 3 parts
  if table.getn(rawJWTCut) == 3 then
    local plainBody = dec64(rawJWTCut[2])
    if plainBody then
      local jsonJWTBody = json.decode(plainBody)
      return jsonJWTBody[field]
    end
  end
	return nil
end

return utils_module
