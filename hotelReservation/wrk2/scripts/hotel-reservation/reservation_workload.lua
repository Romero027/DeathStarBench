require "socket"
math.randomseed(socket.gettime()*1000)
math.random(); math.random(); math.random()


local function reserve()
  local method = "GET"
  local path = "http://localhost:5000/reservation?inDate=2015-04-21&outDate=2015-04-23&lat=nil&lon=nil&hotelId=63&customerName=cornell123&username=cornell123&password=1234&number=1" 
  local headers = {}
  -- headers["Content-Type"] = "application/x-www-form-urlencoded"
  return wrk.format(method, path, headers, nil)
end


request = function()
  return reserve()
end
