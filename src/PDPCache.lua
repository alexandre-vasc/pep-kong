local redis = require "resty.redis"
local ngx_log = ngx.log

return {
  ["redis"] = {
      insert = function(conf, hashKey, permssion)
      local red = redis:new()
      red:set_timeout(conf.redis_timeout)
      do
        local ok, err = red:connect(conf.redis_host, conf.redis_port)
        if not ok then
          ngx_log(ngx.ERR, "failed to connect to Redis: ", err)
          return nil, err
        end
      end

      if conf.redis_password and conf.redis_password ~= "" then
        local ok, err = red:auth(conf.redis_password)
        if not ok then
          ngx_log(ngx.ERR, "failed to connect to Redis: ", err)
          return nil, err
        end
      end

      if conf.redis_database ~= nil and conf.redis_database > 0 then
        local ok, err = red:select(conf.redis_database)
        if not ok then
          ngx_log(ngx.ERR, "failed to change Redis database: ", err)
          return nil, err
        end
      end

      red:set(hashKey, permssion)
      red:expire(hashKey, conf.cache_ttl)
      return true, nil
    end,

    getByHash = function(conf, hashKey)
      local red = redis:new()
      red:set_timeout(conf.redis_timeout)

      do
        local ok, err = red:connect(conf.redis_host, conf.redis_port)
        if not ok then
          ngx_log(ngx.ERR, "failed to connect to Redis: ", err)
          return nil, err
        end
      end

      if conf.redis_password and conf.redis_password ~= "" then
        local ok, err = red:auth(conf.redis_password)
        if not ok then
          ngx_log(ngx.ERR, "failed to connect to Redis: ", err)
          return nil, err
        end
      end

      if conf.redis_database ~= nil and conf.redis_database > 0 then
        local ok, err = red:select(conf.redis_database)
        if not ok then
          ngx_log(ngx.ERR, "failed to change Redis database: ", err)
          return nil, err
        end
      end

      local current_metric, err = red:get(hashKey)
      if err then
        return nil, err
      end

      if current_metric == ngx.null then
        current_metric = nil
      end

      local ok, err = red:set_keepalive(10000, 100)
      if not ok then
        ngx_log(ngx.ERR, "failed to set Redis keepalive: ", err)
      end

      return current_metric
    end
  }
}
