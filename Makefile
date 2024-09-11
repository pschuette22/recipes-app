#
# Project
#
install-tuist:
	@file_version=$$(cat .tuist-version); \
	brew tap tuist/tuist; \
	brew install --formula tuist@$$file_version

check-tuist:
	@file_version=$$(cat .tuist-version); \
	if ! command -v tuist &> /dev/null; then \
		echo "Missing Tuist. \"make install-tuist\""; \
		echo "Install directly, or"; \
		echo "run \"make install-tuist\""; \
		exit 1; \
	elif [ "$$(tuist version)" != "$$file_version" ]; then \
		echo "Warning: Tuist version does not match, expected $$file_version"; \
		echo "If you experience issues, run 'make install-tuist'"; \
	else \
		echo "Using Tuist $$file_version"; \
	fi

project: check-tuist
	@echo "Generating project"; \
	tuist generate
#
# Mocks
#
mocks:
	./binaries/Mockolo/mockolo \
	-s App/Sources/ \
	-d App/Mocks/Mocks.generated.swift \
	--header "@testable import Recipes"

#
# Swiftlint
#

install-swiftlint:
	file_version=$$(cat .swiftlint-version); \
	brew install swiftlint@$$file_version

check-swiftlint-version:
	@swiftlint_version=$$(swiftlint --version); \
	file_version=$$(cat .swiftlint-version); \
	if [ "$$swiftlint_version" = "$$file_version" ]; then \
		echo "Using swiftlint $$file_version"; \
	else \
		echo "SwiftLint version does not match, expected $$file_version"; \
		echo "\nrun 'make install-swiftlint'"; \
		echo "       - or -"; \
		echo "    'brew install swiftlint@$$file_version'\n"; \
		exit 1; \
	fi

swiftlint: check-swiftlint-version
	swiftlint --config .swiftlint.yml

swiftlint-fix: check-swiftlint-version
	swiftlint --config .swiftlint.yml --fix

#
# Swiftformat
#

install-swiftformat:
	file_version=$$(cat .swiftformat-version); \
	eval("brew install swiftformat@$$file_version")

check-swiftformat-version:
	@swiftformat_version=$$(swiftformat --version); \
	file_version=$$(cat .swiftformat-version); \
	if [ "$$swiftformat_version" = "$$file_version" ]; then \
		echo "Using swiftformat $$file_version"; \
	else \
		echo "SwiftFormat version does not match, expected $$file_version"; \
		echo "\nrun 'make install-swiftformat'"; \
		echo "       - or -"; \
		echo "    'brew install swiftformat@$$file_version'\n"; \
		exit 1; \
	fi

lint: swiftlint-fix check-swiftformat-version
	swiftformat . --config .swiftformat.yml
	
#
# Tests
#

unit-tests: check-tuist mocks
	tuist test