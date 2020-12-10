# Makefile to make it all

IMAGE_NAME  := droid-builder
DOCKER_USERNAME := fr3akyphantom
# DOCKER_PASSWORD is SECRET
DOCKER_SLUG := $(DOCKER_USERNAME)/$(IMAGE_NAME)

BUILD_DATE  :=  $(shell date -u +"%Y%m%d")

LABELS  := \
	--label org.label-schema.build-date=$(BUILD_DATE) \
	--label org.label-schema.name="Android ROM Builder" \
	--label org.label-schema.description="Ubuntu LTS Image Containing All Required Packages Installed For Building Android ROMs or TWRPs" \
	--label org.label-schema.url="https://rokibhasansagar.github.io/" \
	--label org.label-schema.vcs-ref=$(shell git rev-parse --short HEAD) \
	--label org.label-schema.vcs-url=$(shell git remote get-url origin) \
	--label org.label-schema.vendor="Rokib Hasan Sagar" \
	--label org.label-schema.version='1.2' \
	--label org.label-schema.schema-version="1.0"

BUILDFLAGS  := \
	--rm --force-rm --compress --no-cache=true --pull \
	--file Dockerfile \
	--tag $(DOCKER_SLUG):$(NAME) \
	--build-arg CODENAME=$(NAME) \
	--build-arg SHORTCODE="${ID}"

builder :
	docker build . $(BUILDFLAGS) $(LABELS)

pusher :
	docker push $(DOCKER_SLUG):$(NAME)

snapper :
	docker tag $(DOCKER_SLUG):$(NAME) $(DOCKER_SLUG):$(NAME)-$(BUILD_DATE)
	docker push $(DOCKER_SLUG):$(NAME)-$(BUILD_DATE)

# Bionic will only have self tag from now on
push_bionic : pusher

# Focal will have the Default "latest" tag from now on
push_focal : pusher
	docker tag $(DOCKER_SLUG):$(NAME) $(DOCKER_SLUG):latest
	docker push $(DOCKER_SLUG):latest

bionic_worker :
	$(MAKE) ID=bionic builder NAME=bionic
	$(MAKE) push_bionic snapper NAME=bionic

focal_worker :
	$(MAKE) ID=focal builder NAME=focal
	$(MAKE) push_focal snapper NAME=focal

test :
	docker pull $(DOCKER_SLUG):$(NAME)
	docker run --rm -i --name docker_$(NAME) --hostname $(NAME) -c 64 -m 256m \
		$(DOCKER_SLUG):$(NAME) bash -c 'cat /etc/os-release'

tester :
	$(MAKE) test NAME=bionic
	$(MAKE) test NAME=focal

do_all : bionic_worker focal_worker
