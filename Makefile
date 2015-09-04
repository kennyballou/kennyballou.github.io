OUTPUT=`pwd`/../www/blog/
all: build

build:
	@hugo -d ${OUTPUT}

deploy:
	@rsync -avz ${OUTPUT} kennyballou.com:/srv/www/blog/
