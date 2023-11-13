# WRK Lua 扩充接口

wrk支持在三个不同的阶段执行LuaJIT脚本：设置（setup）、运行（running）和完成（done）。

每个wrk线程对应一个独立的脚本环境，设置（setup）和完成（done）阶段运行环境是独立的，和运行（running）阶段的运行环境不同。

```mermaid
graph LR;
    setup-->Running{{线程1准备开始运行}};
    Running-.->init;
    init-->delay;
    delay-->request;
    request-->response;
    response-->done;
```
## 1，全局概览

开放的 Lua API 包含一个全局table `wrk`和若干的全局函数。

- 全局table `wrk`

```json
  wrk = {
    scheme  = "http",
    host    = "localhost",
    port    = nil,
    method  = "GET",
    path    = "/",
    headers = {},
    body    = nil,
    thread  = <userdata>,
  }
```

- function wrk.format(method, path, headers, body)

wrk.format 函数会返回一个代表HTTP请求的字符串， 这个字符串是合并了原来wrk表内容和传进去的指定参数而获得的。

- function wrk.lookup(host, service)

wrk.lookup 函数会返回一个table，包含指定`host`和`service(或者端口)`组所对应的所有地址。等同于POSIX系统里的getaddrinfo() 函数。

- function wrk.connect(addr)

如果address地址能连上，wrk.connect 函数会返回 true，否则为false。address 地址必须是前面wrk.lookup() 返回的对象。


以下全局设定是可选项的，但它们必须被定义为函数functions：

  - global setup    -- 在线程创建时会被调用；
  - global init     -- 在线程开始时被调用；
  - global delay    -- 获得请求延时；
  - global request  -- 调用该函数，以产生需要的一个或者多个HTTP request；
  - global response -- 用该接口处理HTTP response获得的数据；
  - global done     -- 运行结束后，获得整体的运行结果。  

## 2，设置阶段

- function setup(thread)

设置（setup）阶段处于目标IP地址已经解析好了，所有的线程都初始化好了，但线程还没有正式开始工作之前。

每个线程都会先调用一次setup()函数，该函数的参数是当前线程的`userdata`对象。

  - thread.addr               - get 或者 set 该线程的服务器地址
  - thread:get(name)        - get 在当前线程的环境里，`name`变量的值
  - thread:set(name, value) - set 在当前线程环境里，设置`name`变量的值`value`
  - thread:stop()           - stop 停止当前线程

通过get()/set() 传进传出的值，只能为boolean, nil, number和string类型（存疑： or tables of the same？啥意思），而 thread:stop() 只能在线程运行时被调用。

## 3，运行阶段

运行阶段包括以下函数：

-  function init(args)
-  function delay()
-  function request()
-  function response(status, headers, body)

在运行阶段，首先会总体地执行一次init()调用，然后在每次请求周期里，再调用一次 request() 和 response()。

init() 函数会接收wrk命令执行里的命令行参数，命令行参数以 `--`分隔符传入。

delay() 会返回发给下一个请求的延迟毫秒数。

request() 会返回包含当前 HTTP 请求的字符串。每次都创建一个新的请求很花时间，所以在高强度压力测试下，最好预先在init()里创建好所有请求，然后在request里快速获取预制的请求即可（参见 `lua/init_requests.lua` 里的例子）。

调用 response() 可以获得HTTP 响应状态、响应头和响应体。解析响应头和响应体也很花时间，所以如果init()执行后，全局response是nil，那后续wrk会忽略响应头和响应体。

## 完成阶段

- function done(summary, latency, requests)

done() 函数会获得一个包含整体执行结果的表table和两个预统计对象 ，这两预统计对象是根据请求统计的延迟数和根据线程统计的请求速率。时长和延迟都是毫秒单位，速率是每秒多少个请求。

  latency.min              -- minimum value seen
  latency.max              -- maximum value seen
  latency.mean             -- average value seen
  latency.stdev            -- standard deviation
  latency:percentile(99.0) -- 99th percentile value
  latency(i)               -- raw value and count

  summary = {
    duration = N,  -- run duration in microseconds
    requests = N,  -- total completed requests
    bytes    = N,  -- total bytes received
    errors   = {
      connect = N, -- total socket connection errors
      read    = N, -- total socket read errors
      write   = N, -- total socket write errors
      status  = N, -- total HTTP status codes > 399
      timeout = N  -- total request timeouts
    }
  }
