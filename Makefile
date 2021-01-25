run:
	resty src/main.lua

dev:
	echo src/main.lua | entr -r resty src/main.lua