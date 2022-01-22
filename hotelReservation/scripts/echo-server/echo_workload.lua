require "socket"

-- curl 10.96.88.88:80
-- ./wrk/wrk -t1 -c1 -d 60s http://10.96.88.88:80 --latency -s echo-server/echo_workload.lua


local function req()
  local method = "GET"
  local str = string.rep("123", 10000)
  local path = "http://localhost:80/" .. str
  local headers = {}
  return wrk.format(method, path, headers, nil)
end

request = function()
    return req()
end
