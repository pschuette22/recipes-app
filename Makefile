# Define the path to the Mockolo executable
MOCKOLO=./binaries/Mockolo/mockolo

# Define the source directory containing the interfaces to mock
APP_SRC_DIR=App/Sources/

# Define the output directory for the generated mocks
MOCKS_OUTPUT_DIR=App/Mocks

mocks:
	$(MOCKOLO) -s $(APP_SRC_DIR) -d $(MOCKS_OUTPUT_DIR)/Mocks.generated.swift --header "@testable import Recipes"

#
# Swiftlint
#

install-swiftlint:
	file_version=$$(cat .swiftlint-version); \
	eval("brew install swiftlint@$$file_version")

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

install-swiftlint:
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

swiftformat: check-swiftformat-version
	