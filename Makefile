.PHONY: help
help:
	@echo 'make install      install the dotfiles'
	@echo 'make check        style check the files'

.PHONY: check
check:
	bash -n bash* install
	./tools/style-check bash* install

.PHONY: install
install:
	./install
