PREFIX ?= /usr/local

install:
	install -d $(PREFIX)/bin
	install bin/greet.sh bin/cleanup.sh $(PREFIX)/bin

dist:
	tar czf greeter-$(VERSION).tar.gz bin Makefile
