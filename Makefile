.PHONY: all
all: org-publish

.PHONY: org-publish
org-publish:
	emacs -Q --script ./build-site.el

.PHONY: clean
clean:
	-rm -r $(BUILD_DIR)

.PHONY: deploy
deploy: clean all
	aws s3 cp --recursive $(BUILD_DIR)/ s3://blog.kennyballou.com/
