PREFIX ?= $(HOME)/.local/bin
SCRIPTS = $(wildcard pishot-*.sh pishot-*.js)

install: node_modules
	@mkdir -p $(PREFIX)
	@for f in $(SCRIPTS); do \
		ln -sf $(CURDIR)/$$f $(PREFIX)/$$f; \
		echo "  $(PREFIX)/$$f -> $(CURDIR)/$$f"; \
	done
	@echo "Installed $(words $(SCRIPTS)) scripts to $(PREFIX)"

uninstall:
	@for f in $(SCRIPTS); do \
		rm -f $(PREFIX)/$$f; \
	done
	@echo "Removed pishot scripts from $(PREFIX)"

node_modules: package.json
	npm install
	@touch node_modules

.PHONY: install uninstall
