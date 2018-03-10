# Must follow the format in the Naming section of https://vcvrack.com/manual/PluginDevelopmentTutorial.html)
SLUG = ElasticOrange-Evaluator4x4

# Must follow the format in the Versioning section of https://vcvrack.com/manual/PluginDevelopmentTutorial.html
VERSION = 0.6.0dev

# FLAGS will be passed to both the C and C++ compiler
FLAGS += -I/usr/local/Cellar/chicken/4.13.0/include/chicken
CFLAGS +=
CXXFLAGS +=

# Careful about linking to shared libraries, since you can't assume much about the user's environment and library search path.
# Static libraries are fine.
LDFLAGS += -L/usr/local/Cellar/chicken/4.13.0/lib -lchicken -lm

# Add .cpp and .c files to the build
SOURCES += $(wildcard src/*.cpp)
SOURCES += engine.scm

# Add files to the ZIP package when running `make dist`
# The compiled plugin is automatically added.
DISTRIBUTABLES += $(wildcard LICENSE*) res

# If RACK_DIR is not defined when calling the Makefile, default to two levels above
RACK_DIR ?= ../..

# Include the VCV Rack plugin Makefile framework
include $(RACK_DIR)/plugin.mk

build/engine.scm.o: src/engine.scm
	csc -C $(MAC_SDK_FLAGS) src/engine.scm -emit-external-prototypes-first -c -o build/engine.scm.o

