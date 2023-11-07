FROM czerasz/wrk-json
MAINTAINER 0n100 <onion@163.com>

ADD dockerenv/lua /

ENTRYPOINT ["/usr/local/bin/wrk"]