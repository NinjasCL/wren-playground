.PHONY: start package lint format icon test build

s r start run:
	yarn start

p package:
	yarn package

b build:
	yarn postinstall && yarn build && yarn electron-builder --publish always --win --mac --linux

l lint:
	yarn lint

f format:
	yarn format

icon:
	yarn icon

t test:
	yarn test
