# Define the shell script name
SCRIPT := ./make.sh

# Default target
.PHONY: all
all: $(MAKECMDGOALS)
	@./make.sh all

# Catch-all target to forward arguments to the script
$(MAKECMDGOALS):
	@echo "Calling $(SCRIPT) with argument: $@"
	@$(SCRIPT) "$@"

# Prevent `make` from interpreting the arguments as file names
.PHONY: $(MAKECMDGOALS)
