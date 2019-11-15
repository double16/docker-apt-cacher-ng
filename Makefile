all: build

build:
	@docker build --tag=pdouble16/apt-cacher-ng .
