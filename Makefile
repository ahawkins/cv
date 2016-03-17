DOCKER_IMAGE:=ahawkins/cv
IMAGE:=tmp/image
CV:=resume.json
PDF:=dist/resume.pdf
HTML:=dist/resume.html
MD:=dist/resume.md

.DEFAULT_GOAL: $(DOCKER_IMAGE)

$(IMAGE):
	docker build -t $(DOCKER_IMAGE) .
	mkdir -p $(@D)
	touch $@

.PHONY: init
init: $(IMAGE)
	docker run --rm -it \
		-v $(CURDIR):/data \
		-w /data \
		$(DOCKER_IMAGE) \
		resume init

.PHONY:
test: $(IMAGE) $(CV)
	jq . $(CV) > /dev/null
	docker run --rm -it \
		-v $(CURDIR):/data \
		-w /data \
		$(DOCKER_IMAGE) \
		resume test

$(PDF): $(IMAGE) $(CV)
	mkdir -p $(@D)
	docker run --rm -it \
		-v $(CURDIR):/data \
		-w /data \
		$(DOCKER_IMAGE) \
		resume export $@ --format pdf --theme paper

.PHONY: pdf
pdf: $(PDF)

$(HTML): $(IMAGE) $(CV)
	mkdir -p $(@D)
	docker run --rm -it \
		-v $(CURDIR):/data \
		-w /data \
		$(DOCKER_IMAGE) \
		resume export $@ --format html

.PHONY: html
html: $(HTML)

.PHONY: clean
clean:
	rm -rf $(IMAGE) $(MD) $(PDF) $(HTML)
