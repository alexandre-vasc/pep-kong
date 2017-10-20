local _M = {}

local pl_stringx = require "pl.stringx"
local req_get_headers = ngx.req.get_headers
local responses = require "kong.tools.responses"

local utils = require "kong.plugins.pepkong.utils"
local PDPSender = require "kong.plugins.pepkong.pdpsender"
local policies = require "kong.plugins.pepkong.pdpcache"


function _M.run(conf)
    utils.printToFile(debug.getinfo(1).currentline, 'Inicio de access.run()')

    -- missing JWT token on the HTTP header
    if not req_get_headers()["Authorization"] then
      return responses.send(401)
    end

    -- remove the word 'bearer' from te token
    local rawJWT = string.sub(req_get_headers()["Authorization"]  , 8)

    -- gather information about the request. Like ip address and HTTP method
    local jwtjti = utils.jwtExtractField(rawJWT, 'jti')
    local ipAddr  = ngx.var.remote_addr
    local method = ngx.var.request_method

    -- Get the URL prefix and discard URL parameters
    local path_prefix = utils.split(ngx.var.request_uri , '?' )[1]

    if not pl_stringx.endswith(path_prefix, "/") then
        path_prefix = path_prefix .. "/"
    end

    local unhashedKey = jwtjti .. ";" .. method .. ";" .. path_prefix
    local veredict, err = policies[conf.cache_policy].getByHash(conf, unhashedKey)

    if not veredict then
      utils.printToFile(debug.getinfo(1).currentline,"Cached nil")
    else
      utils.printToFile(debug.getinfo(1).currentline,"Cached " .. veredict)
    end

    -- if permission is not on cache, we must ask on the PDP
    if not veredict then
      -- send the gathered information to PDP, asking if the access is allowed
      veredict = PDPSender.sendRequest(conf, rawJWT, method, path_prefix, ipAddr)

      utils.printToFile(debug.getinfo(1).currentline,'PDP Veredict: ' .. veredict)
      -- error ocurried
      if not (veredict == 'permit' or veredict == 'deny') then
          veredict = 'deny'
          -- log
      else
        -- update cache with PDP anwser
        local ok, err = policies[conf.cache_policy].insert(conf, unhashedKey, veredict)
      end
    end

    if not (veredict == 'permit') then
      return responses.send(403)
    end

end

return _M
