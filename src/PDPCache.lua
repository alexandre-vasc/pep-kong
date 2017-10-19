-- TODO: use luarocks installed lib
-- lib from https://github.com/nrk/redis-lua
local redis = require 'redis'
local socket = require("socket")




local client = redis.connect('127.0.0.1', 6379)

client:set('usr:nrk', 10)
print(client:expire('usr:nrk', 8))
client:set('usr:nobody', 5)

socket.sleep(4)
local value = client:get('usr:nrk')
print(value)

socket.sleep(5)
local value = client:get('usr:nrk')
print(value)
