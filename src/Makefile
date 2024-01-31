

linux:
	gcc -O3 -g -fPIC -Wall -shared -o libconcurrentlua.so libconcurrentlua.c -llua

install:
	mkdir -p /usr/local/lib/lua/5.4/	# just for ensuring that the dest dir exists
	mkdir -p /usr/local/share/lua/5.4/	# just for ensuring that the dest dir exists
	cp libconcurrentlua.so /usr/local/lib/lua/5.4/
	cp concurrent.lua /usr/local/share/lua/5.4/

test:
	cd ../test && lua test.lua