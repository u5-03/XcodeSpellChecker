PRODUCT_NAME=XcodeSpellChecker
SCHEME_NAME=XcodeSpellChecker
TEMPORARY_FOLDER=/tmp/$(SCHEME_NAME)/.dst
BINARIES_FOLDER=/usr/local/bin
BINARY_PATH=$(BINARIES_FOLDER)/$(PRODUCT_NAME)

.PHONY: build clean install uninstall test xcode

build:
	swift build --disable-sandbox -c release

clean:
	swift package clean

install: clean build
	mkdir -p "$(BINARIES_FOLDER)"
	cp -f ".build/release/XcodeSpellChecker" "$(BINARY_PATH)"

uninstall:
	rm -rf "$(BINARY_PATH)"

test: clean
	swift test

xcode:
	swift package generate-xcodeproj

