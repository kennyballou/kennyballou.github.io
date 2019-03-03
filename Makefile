PROJ_ROOT:=$(shell git rev-parse --show-toplevel)
SCRIPTS_DIR:=$(PROJ_ROOT)/scripts
STATIC_DIR:=static
IMAGES_DIR:=$(STATIC_DIR)/media
VIDEOS_DIR:=$(STATIC_DIR)/media/videos
BUILD_DIR:=build
blog_dir = $(shell $(SCRIPTS_DIR)/org-get-slug.sh $(1))
POSTS_ORG_INPUT:=$(wildcard posts/*.org)
POSTS_ORG_SUM_XML_OUTPUT:=$(patsubst posts/%.org, posts/%.sum.xml, $(POSTS_ORG_INPUT))
POSTS_ORG_SUM_OUTPUT:=$(patsubst posts/%.org, posts/%.sum.html, $(POSTS_ORG_INPUT))
POSTS_ORG_HTML_OUTPUT:=$(foreach post,$(POSTS_ORG_INPUT),$(BUILD_DIR)$(call blog_dir,$(post))/index.html)
STATIC_FILES:=$(shell find $(STATIC_DIR) -type f)
STATIC_FILES_OUT:=$(patsubst $(STATIC_DIR)/%,$(BUILD_DIR)/%,$(STATIC_FILES))
TEMPLATE_FILES:=$(wildcard templates/*.html)

.PHONY: all
all: $(BUILD_DIR)/index.html \
	 $(BUILD_DIR)/index.xml \
	 $(POSTS_ORG_HTML_OUTPUT) \
	 $(STATIC_FILES_OUT)

posts/%.preview.org: posts/%.org
	$(SCRIPTS_DIR)/generate_post_preview.sh $< > $@

posts/%.sum.html: posts/%.org posts/%.preview.org
	$(SCRIPTS_DIR)/generate_post_summary_html.sh $^ > $@

posts/%.sum.xml: posts/%.org posts/%.preview.org
	$(SCRIPTS_DIR)/generate_post_summary_xml.sh $^ > $@

$(BUILD_DIR):
	mkdir -p $@

$(BUILD_DIR)/index.html: $(POSTS_ORG_SUM_OUTPUT) $(TEMPLATE_FILES) Makefile \
					   | $(BUILD_DIR)
	$(SCRIPTS_DIR)/generate_index_html.sh $^ > $@

$(BUILD_DIR)/index.xml: $(POSTS_ORG_SUM_XML_OUTPUT) | $(BUILD_DIR)
	$(SCRIPTS_DIR)/generate_rss.sh $^ > $@

define BLOG_BUILD_DEF
$(BUILD_DIR)$(call blog_dir,$T):
	mkdir -p $$@
$(BUILD_DIR)$(call blog_dir,$T)/index.html: $T \
											$(TEMPLATE_FILES) \
											Makefile \
										  | $(BUILD_DIR)$(call blog_dir,$T)
	$(SCRIPTS_DIR)/generate_post_html.sh $$< > $$@
endef

$(foreach T,$(POSTS_ORG_INPUT),$(eval $(BLOG_BUILD_DEF)))

$(BUILD_DIR)/%: $(STATIC_DIR)/% | $(BUILD_DIR)
	mkdir -p $(dir $@)
	cp $< $@

.PHONY: clean
clean:
	-rm -r $(BUILD_DIR)

.PHONY: deploy
deploy: clean all
	aws s3 cp --recursive $(BUILD_DIR)/ s3://blog.kennyballou.com/
