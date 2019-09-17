all: build

build:
	@docker build --tag=pdouble16/docker-apt-cacher-ng .
