return {
  fields = {
    pdp_url = {type = "string", required = true, },
    pdp_mode = {
                type = "string",
                enum = {"JWTForward", "JSON_XACML"},
                default  = "JWTForward"
              },
    cache_ttl = { type = "number", default = 420 },
    cache_policy = { type = "string", enum = {"redis"}, default = "redis" },
    fault_tolerant = { type = "boolean", default = true },
    redis_host = { type = "string", default = "redis" },
    redis_port = { type = "number", default = 6379 },
    redis_password = { type = "string", default = "" },
    redis_timeout = { type = "number", default = 2000 },
    redis_database = { type = "number", default = 0 }
  }
}
