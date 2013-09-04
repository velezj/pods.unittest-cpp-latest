SVN_URL = 'https://unittest-cpp.svn.sourceforge.net/svnroot/unittest-cpp'
SVN_URL = 'https://svn.code.sf.net/p/unittest-cpp/code/'
SOURCE_DIR_NAME = 'unittest-cpp'


default_target: all

# Default to a less-verbose build.  If you want all the gory compiler output,
# run "make VERBOSE=1"
$(VERBOSE).SILENT:

# Figure out where to build the software.
#   Use BUILD_PREFIX if it was passed in.
#   If not, search up to four parent directories for a 'build' directory.
#   Otherwise, use ./build.
ifeq "$(BUILD_PREFIX)" ""
BUILD_PREFIX:=$(shell for pfx in ./ .. ../.. ../../.. ../../../..; do d=`pwd`/$$pfx/build;\
               if [ -d $$d ]; then echo $$d; exit 0; fi; done; echo `pwd`/build)
endif
# create the build directory if needed, and normalize its path name
BUILD_PREFIX:=$(shell mkdir -p $(BUILD_PREFIX) && cd $(BUILD_PREFIX) && echo `pwd`)

# Default to a release build.  If you want to enable debugging flags, run
# "make BUILD_TYPE=Debug"
ifeq "$(BUILD_TYPE)" ""
BUILD_TYPE="Release"
endif

SED=sed
ifeq ($(shell uname), Darwin)
  SED=gsed
endif

all: configure
	@echo "\nbuilt UnitTest++\n"

$(SOURCE_DIR_NAME)/UnitTest++/Makefile:
	@echo "\n\n CHECKING OUT UnitTest++ \n"
	@echo "\nBUILD_PREFIX: $(BUILD_PREFIX)\n\n"
	@svn co $(SVN_URL) $(SOURCE_DIR_NAME)

$(SOURCE_DIR_NAME)/UnitTest++/libUnitTest++.a: $(SOURCE_DIR_NAME)/UnitTest++/Makefile
	make -C $(SOURCE_DIR_NAME)/UnitTest++/

.PHONY: configure
configure: $(SOURCE_DIR_NAME)/UnitTest++/libUnitTest++.a

	# copy library ot /lib
	@cp $(SOURCE_DIR_NAME)/UnitTest++/libUnitTest++.a $(BUILD_PREFIX)/lib
	@mkdir -p $(BUILD_PREFIX)/include/unittest++/
	@mkdir -p $(BUILD_PREFIX)/include/unittest++/Posix
	@cp -r $(SOURCE_DIR_NAME)/UnitTest++/src/*.h $(BUILD_PREFIX)/include/unittest++/
	@cp -r $(SOURCE_DIR_NAME)/UnitTest++/src/Posix/*.h $(BUILD_PREFIX)/include/unittest++/Posix/

	# create pck-config file	
	@mkdir -p $(BUILD_PREFIX)/lib/pkgconfig/
	@echo "Name: UnitTest++ \nDescription: UnitTest++ (SVN Latest) \nRequires: \nVersion:  \nLibs: -lUnitTest++ \nCflags: -I$(BUILD_PREFIX)/include/unittest++/" > $(BUILD_PREFIX)/lib/pkgconfig/unittest++.pc


clean:
	-if [ -d $(SOURCE_DIR_NAME) ]; then rm -rf $(SOURCE_DIR_NAME); fi
