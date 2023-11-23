
.PHONY	: install
install	: ## Init zenn CLI
	npm init --yes
	npm install zenn-cli

.PHONY	: update
update	: ## Update zenn CLI
	npm install zenn-cli@latest

.PHONY	: run
run	: ## Run a preview
	npx zenn preview

.PHONY	: new
new	: ## Show command for create new file
	@-echo "RUN"
	@-echo "npx zenn new:article --slug article_slug_name"

.PHONY	: help
help	: ## Display this help screen
	@grep -E '^[a-zA-Z_-]+.*:.*?## .*$$' Makefile \
	| awk 'BEGIN {FS = "\t:.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'
