####################################################################
# User Makefile                                                    #
# This will not be overwritten. Edit as desired.                   #
####################################################################
.SUFFIXES:				# ignore builtin rules
.PHONY: all debug release print-% clean 

# Default goal
all: debug

####################################################################
# Definitions                                                      #
####################################################################

# Project target
PROJECT_TARGET = S32K144_Demo.elf

# GNU GCC directory
ARM_GCC_DIR_WIN = C:/NXP/gcc-9.2-arm32-eabi
ARM_GCC_DIR_OSX =
ARM_GCC_DIR_LINUX =

ifeq ($(OS),Windows_NT)
  ARM_GCC_DIR ?= $(ARM_GCC_DIR_WIN)
else
  UNAME_S := $(shell uname -s)
  ifeq ($(UNAME_S),Darwin)
    ARM_GCC_DIR ?= $(ARM_GCC_DIR_OSX)
  else
    ARM_GCC_DIR ?= $(ARM_GCC_DIR_LINUX)
  endif
endif

# Build directory
BUILD_DIR = build

ifneq ($(filter $(MAKECMDGOALS),release),)
  OUTPUT_DIR = $(BUILD_DIR)/release
else
  OUTPUT_DIR = $(BUILD_DIR)/debug
endif

# Values that should be appended by the sub-makefiles
C_SOURCE_FILES   =
CXX_SOURCE_FILES =
ASM_SOURCE_FILES =

LIBS =

C_DEFS   =
ASM_DEFS =

INCLUDES =

C_FLAGS           =
C_FLAGS_DEBUG     =
C_FLAGS_RELEASE   =
CXX_FLAGS         =
CXX_FLAGS_DEBUG   =
CXX_FLAGS_RELEASE =
ASM_FLAGS         =
ASM_FLAGS_DEBUG   =
ASM_FLAGS_RELEASE =
LD_FLAGS          =

OBJS =

####################################################################
# Toolchain Definitions                                            #
####################################################################

CC  = "$(ARM_GCC_DIR)/bin/arm-none-eabi-gcc"
CXX = "$(ARM_GCC_DIR)/bin/arm-none-eabi-g++"
LD  = "$(ARM_GCC_DIR)/bin/arm-none-eabi-gcc"
AS  = "$(ARM_GCC_DIR)/bin/arm-none-eabi-gcc"

####################################################################
# Include sub-makefiles                                            #
# Define a makefile here to add files/settings to the debug.       #
####################################################################
-include S32K144_Demo.project.mak

####################################################################
# Rules                                                            #
####################################################################

# -MMD : Don't generate dependencies on system header files.
# -MP  : Add phony targets, useful when a h-file is removed from a project.
# -MF  : Specify a file to write the dependencies to.
DEPFLAGS = -MMD -MP -MF $(@:.o=.d)

CSOURCES     = $(notdir $(C_SOURCE_FILES))
CXXSOURCES   = $(notdir $(filter %.cpp, $(CXX_SOURCE_FILES)))
CCSOURCES    = $(notdir $(filter %.cc, $(CXX_SOURCE_FILES)))
ASMSOURCES_s = $(notdir $(filter %.s, $(ASM_SOURCE_FILES)))
ASMSOURCES_S = $(notdir $(filter %.S, $(ASM_SOURCE_FILES)))

COBJS     = $(addprefix $(OUTPUT_DIR)/,$(CSOURCES:.c=.o))
CXXOBJS   = $(addprefix $(OUTPUT_DIR)/,$(CXXSOURCES:.cpp=.o))
CCOBJS    = $(addprefix $(OUTPUT_DIR)/,$(CCSOURCES:.cc=.o))
ASMOBJS_s = $(addprefix $(OUTPUT_DIR)/,$(ASMSOURCES_s:.s=.o))
ASMOBJS_S = $(addprefix $(OUTPUT_DIR)/,$(ASMSOURCES_S:.S=.o))
OBJS      += $(COBJS) $(CXXOBJS) $(CCOBJS) $(ASMOBJS_s) $(ASMOBJS_S)

CDEPS     += $(addprefix $(OUTPUT_DIR)/,$(CSOURCES:.c=.d))
CXXDEPS   += $(addprefix $(OUTPUT_DIR)/,$(CXXSOURCES:.cpp=.d))
CXXDEPS   += $(addprefix $(OUTPUT_DIR)/,$(CCSOURCES:.cc=.d))
ASMDEPS_s += $(addprefix $(OUTPUT_DIR)/,$(ASMSOURCES_s:.s=.d))
ASMDEPS_S += $(addprefix $(OUTPUT_DIR)/,$(ASMSOURCES_S:.S=.d))

C_PATHS   = $(subst \,/,$(sort $(dir $(C_SOURCE_FILES))))
CXX_PATHS = $(subst \,/,$(sort $(dir $(CXX_SOURCE_FILES))))
ASM_PATHS = $(subst \,/,$(sort $(dir $(ASM_SOURCE_FILES))))

vpath %.c $(C_PATHS)
vpath %.cpp $(CXX_PATHS)
vpath %.cc $(CXX_PATHS)
vpath %.s $(ASM_PATHS)
vpath %.S $(ASM_PATHS)

override CFLAGS = $(C_FLAGS) $(C_DEFS) $(INCLUDES) $(DEPFLAGS)
override CXXFLAGS = $(CXX_FLAGS) $(C_DEFS) $(INCLUDES) $(DEPFLAGS)
override ASMFLAGS = $(ASM_FLAGS) $(ASM_DEFS) $(INCLUDES) $(DEPFLAGS)

# Rule definitions
debug: C_FLAGS += $(C_FLAGS_DEBUG)
debug: CXX_FLAGS += $(CXX_FLAGS_DEBUG)
debug: ASM_FLAGS += $(ASM_FLAGS_DEBUG)
debug: $(OUTPUT_DIR)/$(PROJECT_TARGET)
	@echo -e "$(GREEN)Debug version is succesfully built!$(WHITE)"

release: C_FLAGS += $(C_FLAGS_RELEASE)
release: CXX_FLAGS += $(CXX_FLAGS_RELEASE)
release: ASM_FLAGS += $(ASM_FLAGS_RELEASE)
release: $(OUTPUT_DIR)/$(PROJECT_TARGET)
	@echo -e "$(GREEN)Release version is succesfully built!$(WHITE)"

# include auto-generated dependency files (explicit rules)
ifneq (clean,$(findstring clean, $(MAKECMDGOALS)))
-include $(CDEPS)
-include $(CXXDEPS)
-include $(ASMDEPS_s)
-include $(ASMDEPS_S)
endif

$(OUTPUT_DIR)/$(PROJECT_TARGET): $(OBJS) $(LIB_FILES)
	@echo -e "$(BLUE)Linking files. $(WHITE)"
	@echo $(OBJS) > $(OUTPUT_DIR)/linker_objs
	$(ECHO)$(LD) $(LD_FLAGS) @$(OUTPUT_DIR)/linker_objs $(LIBS) -o $(OUTPUT_DIR)/$(PROJECT_TARGET)

$(OBJS):

$(OUTPUT_DIR)/%.o: %.c 
	@echo -e "$(RED)Building $<$(WHITE)"
	@mkdir -p $(@D)
	$(ECHO)$(CC) $(CFLAGS) -c -o $@ $<

$(OUTPUT_DIR)/%.o: %.cc
	@echo -e "$(RED)Building $< $(WHITE)"
	@mkdir -p $(@D)
	$(ECHO)$(CXX) $(CXXFLAGS) -c -o $@ $<

$(OUTPUT_DIR)/%.o: %.cpp 
	@echo -e "$(RED)Building $< $(WHITE)"
	@mkdir -p $(@D)
	$(ECHO)$(CXX) $(CXXFLAGS) -c -o $@ $<

$(OUTPUT_DIR)/%.o: %.S 
	@echo -e "$(RED)Building $< $(WHITE)"
	@mkdir -p $(@D)
	$(ECHO)$(AS) $(ASMFLAGS) -c -o $@ $<

$(OUTPUT_DIR)/%.o: %.s
	@echo -e "$(RED)Building $< $(WHITE)"
	@mkdir -p $(@D)
	$(ECHO)$(AS) $(ASMFLAGS) -c -o $@ $<

print-%:
	@echo "$(subst print-,,$@): $($(subst print-,,$@))"

clean:
	@rm -rf $(BUILD_DIR)
	@echo -e "$(GREEN)Clean done!$(WHITE)"