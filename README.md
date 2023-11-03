# wrkit
Staff for wrk benchmarking tool.

学习 wrk 这个压力测试工具时的一些记录。

## 运行

把自己练手用的lua扩展，打包进docker容器里运行。用了 https://github.com/czerasz/docker-wrk-json 的现成环境，感谢！

执行：

```
docker build -t="0n100/wrkit" .
```

## 资料

WRK：https://github.com/wg/wrk

Lua扩展编程：`lua_scripting_cn.md`，我自己翻译整理的。官方的英文版对我还是需要稍微反应一下。

