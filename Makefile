# Define the path to the Mockolo executable
MOCKOLO=./binaries/Mockolo/mockolo

# Define the source directory containing the interfaces to mock
APP_SRC_DIR=App/Sources/

# Define the output directory for the generated mocks
MOCKS_OUTPUT_DIR=App/Mocks

mocks:
	$(MOCKOLO) -s $(APP_SRC_DIR) -d $(MOCKS_OUTPUT_DIR)/Mocks.generated.swift 
