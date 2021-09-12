# check_defined
# Check that given variables are set and all have non-empty values,
# die with an error otherwise.
#
# Params:
#   1. Variable name(s) to test.
#   2. (optional) Error message to print.
#
# Example usage:
#
# $(call check_defined, MY_FLAG)
# $(call check_defined, OUT_DIR, build directory)
# $(call check_defined, BIN_DIR, where to put binary artifacts)
#
# Sourced from https://stackoverflow.com/questions/10858261/how-to-abort-makefile-if-variable-not-set
check_defined = \
    $(strip $(foreach 1,$1, \
        $(call __check_defined,$1,$(strip $(value 2)))))
__check_defined = \
    $(if $(value $1),, \
      $(error Undefined $1$(if $2, ($2))))

