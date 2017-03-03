OUTPUT=`pwd`/../www/blog/
all: build

.PHONY: build
build:
	@hugo -d ${OUTPUT}

.PHONY: deploy
deploy: build
	@rsync -avz ${OUTPUT} kennyballou.com:/srv/www/.

.PHONY: serve
serve:
	-hugo -d ${OUTPUT} serve
