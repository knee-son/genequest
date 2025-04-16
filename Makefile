# Define variables
BRANCH = gh-pages
BUILD_DIR = build/web
BASE_HREF = "/genequest/"

# Ensure we are on gh-pages before running any commands
check-branch:
	@if [ "$$(git rev-parse --abbrev-ref HEAD)" != "$(BRANCH)" ]; then \
		echo "Error: Must be on $(BRANCH) branch"; \
		exit 1; \
	fi

reset: check-branch
	git fetch origin
	git reset --hard origin/main

pub-get: check-branch
	flutter pub get

# Enable Flutter web support
enable-web: check-branch
	flutter config --enable-web

# Create a new Flutter project (only needed for a fresh setup)
create: check-branch
	flutter create .

# Build the Flutter web app
build: check-branch
	MSYS_NO_PATHCONV=1 flutter build web --base-href="/genequest/" --release

# Deploy to GitHub Pages
deploy: check-branch build
	git rm -rf -- . && git checkout main Makefile
	cp -r $(BUILD_DIR)/* .
	git add .
	git commit -m "ready for gh-pages deployment"
	git push origin $(BRANCH) --force

site:
	@echo "🌐 GitHub Pages link available here:"
	@echo -e "\e[36mhttps://knee-son.github.io/genequest/\e[0m"

# Full setup and deployment in one command
all: check-branch pub-get reset enable-web create deploy site
