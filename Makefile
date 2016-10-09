export KITURA_CI_BUILD_SCRIPTS_DIR=Package-Builder/build

-include Package-Builder/build/Makefile

run:
	.build/debug/BookshelfAPI
