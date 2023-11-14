# wrkit
Staff for wrk benchmarking tool.

学习 wrk 这个压力测试工具时的一些记录。

## 运行

把自己练手用的lua扩展，打包进docker容器里运行。用了 https://github.com/czerasz/docker-wrk-json 的现成环境，感谢！之所以用这个Docker容器版，是因为自己写的某个lua插件，用到了cjson库，容器版里一并打包进去，就不用单独再安装了。如果是独立的wrk，还需要通过luarocks安装一下cjson（`$ luarocks install lua-cjson`）。

容器版wrk及插件脚本的使用：

```
# 创建自己的镜像
$ docker build -t="0n100/wrkit" .

# 最基本的运行命令，更详细的wrk参数请参见原版的文档：
$ docker run -it --rm 0n100/wrkit -c5 -d10s -t2 http://$WEB:$PORT

# 测试form-urlencoded编码方式的POST
$ docker run -it -v $(pwd)/lua:/lua --rm 0n100/wrkit -c5 -d10s -t2 -s /lua/post.lua http://$WEB:$PORT

# 测试把多个url写在urls.txt列表里，然后顺序按列表url访问，并统计响应码的数量
$ docker run -it -v $(pwd)/lua:/lua --rm 0n100/wrkit -c5 -d10s -t2 -s /lua/urlist_get.lua http://$WEB:$PORT

# 测试json格式的提交
$ docker run -it -v $(pwd)/lua:/lua --rm 0n100/wrkit -c5 -d10s -t2 -s /lua/post_json.lua http://$WEB:$PORT

# 测试提前产生一堆需要的请求示例
$ docker run -it -v $(pwd)/lua:/lua --rm 0n100/wrkit -c5 -d10s -t2 -s /lua/init_requests.lua http://$WEB:$PORT
```

## 资料

- WRK：https://github.com/wg/wrk

- Lua扩展编程：[lua_scripting_cn.md](./lua_scripting_cn.md)，我自己翻译整理的。官方的英文版对我还是需要稍微反应一下。

