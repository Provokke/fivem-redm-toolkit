.PHONY: test lint demo

test:
	busted

lint:
	luacheck bridge spec demo ui_sample

demo:
	lua demo/demo.lua
