.PHONY: build deploy
OUTPUT=`pwd`/../www/blog/
all: build

build:
	@hugo -d ${OUTPUT}

deploy: build
	@rsync -avz ${OUTPUT} kennyballou.com:/srv/www/blog/
