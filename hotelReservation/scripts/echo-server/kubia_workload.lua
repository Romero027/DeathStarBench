require "socket"

-- curl 10.96.88.88:80
-- ./wrk/wrk -t1 -c1 -d 60s http://10.96.88.88:80 --latency -s echo-server/kubia_workload.lua


-- 500b: 100  16k: 6000 32k: 11000 60k: 20000

local function req()
  local method = "POST"
  local str = string.rep("123", 120000)
  local path = "http://localhost:80/"
  local headers = {}
  return wrk.format(method, path, headers, str)
end

request = function()
    return req()
end
