local counter = 1
local threads = {}
local cjson = require("cjson")
cjson.encode_sparse_array(true)
local urls = {}
local filename = "result.txt"
local url_list = "./urls.txt"
	
function get_urls() 
    local file = io.open(url_list, "r")  
	local lines = {}  -- 存储每行内容的表
    local i=0
	if file then
		for line in file:lines() do
		    if line and line ~= ""  then
			   lines[i] = line
			   i = i+1
			end
		end
		file:close()
	else
		print("无法打开文件")
	end
	-- 打印每行内容
	--for i, line in ipairs(lines) do
	--	print("行 " .. i .. ": " .. line)
	--end
	return lines
end

function typeof(var)
    local _type = type(var);
    if(_type ~= "table" and _type ~= "userdata") then
        return _type;
    end
    local _meta = getmetatable(var);
    if(_meta ~= nil and _meta._NAME ~= nil) then
        return _meta._NAME;
    else
        return _type;
    end
end

function setup(thread)
   thread:set("id", counter)
   statusInfo = {}
   local jsonString = cjson.encode(statusInfo)
   thread:set("status", jsonString) 
   table.insert(threads, thread)
   counter = counter + 1
end

function init(args)
   requests  = 0
   responses = 0
   local msg = "thread %d created"
   --print(msg:format(id))
   urls=get_urls()
end

function request()
   requests = requests +1
   n=#urls+1
   url = urls[requests % n]
   return wrk.format("GET", url, nil, nil)
end

function response(status, headers, body)
  local threadId = wrk.thread:get("id")  
  local statusTable = cjson.decode(wrk.thread:get("status") )
  ss=tostring(status)
  if statusTable[ss] then
	statusTable[ss]=statusTable[ss]+1 
  else 
	statusTable[ss]=1
  end  
  wrk.thread:set("status", cjson.encode(statusTable) )  

end

function done(summary, latency, requests)
   for index, thread in ipairs(threads) do
      local id        = thread:get("id")
      local requests  = thread:get("requests")
      local responses = thread:get("responses")
	  local statusTable = cjson.decode(thread:get("status"))
      local msg = "thread %d made %d requests and got %d responses"
      print(msg:format(id, requests, responses))
      for status, count in pairs(statusTable) do
		print(status, count)
      end	  
   end
    local currentTime = os.date("%Y-%m-%d %H:%M:%S")
    file = assert(io.open(filename, "a"))
    file.write(
        file,
        string.format(
            "[%s] %d,%.2d,%d,%d\n",
			currentTime,
            summary.requests,
            summary.errors.status,
            summary.errors.read,
            summary.errors.timeout
            ));
    file.close()
	
end