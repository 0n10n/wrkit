-- docker环境运行本例子的命令行：
-- docker run -it -v $(pwd)/lua:/lua --rm 0n100/wrkit -c5 -d10s -t1 -s ./lua/init_requests.lua http://192.168.99.90 2
init = function(args)
	depth = tonumber(args[1]) or 1	
	local reqs = {}

	for i=1, depth do
		wrk.path =  string.format("/env.php?id=%d",i)
		wrk.method = "POST"
		wrk.body ="This is request body "
		wrk.headers["Content-Type"] = "application/x-www-form-urlencoded"
		reqs[i] = wrk.format(nil , method, body, headers)
	end
	req = table.concat(reqs)
    --print(req)
end

request = function()
	return req
end 