####################################################################
# Project Structure                                                #
####################################################################
PROJECT_DIR   = .
LINKER_DIR    = $(PROJECT_DIR)/Project_Settings/Linker_Files
INCLUDE_DIR   = $(PROJECT_DIR)/include \
				$(wildcard  $(PROJECT_DIR)/src/*/*)

# List of all project files		
PROJECT_FILES = $(shell find $(PROJECT_DIR) -name '*')

# Project files with directory
C_SOURCE_FILES   += $(filter %.c, $(PROJECT_FILES))
CXX_SOURCE_FILES += $(filter %.cpp, $(PROJECT_FILES))
CXX_SOURCE_FILES += $(filter %.cc, $(PROJECT_FILES))
ASM_SOURCE_FILES += $(filter %.s, $(PROJECT_FILES))
ASM_SOURCE_FILES += $(filter %.S, $(PROJECT_FILES))
LIB_FILES        += $(filter %.a, $(PROJECT_FILES))

####################################################################
# Project Settings                                                 #
####################################################################

# Color codes for highlighting output logs
BLUE   = \033[1;34m
WHITE  = \033[1;0m
RED    = \033[1;31m
GREEN  = \033[1;32m

# Command output is hidden by default, it can be enabled by
# setting VERBOSE=true on the commandline.
ifeq ($(VERBOSE),)
  ECHO = @
endif

# Firmware is loaded to flash by default
# To make it flashed to RAM, setting LOAD_TO=RAM 
LOAD_TO = FLASH
ifeq ($(LOAD_TO),FLASH)
	LINKER_FILE = $(LINKER_DIR)/S32K144_64_flash.ld
else
	LINKER_FILE = $(LINKER_DIR)/S32K144_64_ram.ld
endif

####################################################################
# Macros Definition                                                #
####################################################################

# C/C++ macros definition. Format: ' -DMACRO_NAME=VALUE '
C_DEFS +=

# Assembly macros definition. Format: ' -DMACRO_NAME=VALUE '
ASM_DEFS +=

####################################################################
# Included Objects                                                 #
####################################################################

# Included directories. Format: -Iinclude_dir 
INCLUDES += $(foreach DIR, $(INCLUDE_DIR),-I $(DIR))

GROUP_START =-Wl,--start-group
GROUP_END =-Wl,--end-group

# Included libraries
PROJECT_LIBS = \
 -lgcc \
 -lc \
 -lm \
 -lnosys

LIBS += $(GROUP_START) $(PROJECT_LIBS) $(GROUP_END)

LIB_FILES += $(filter %.a, $(PROJECT_LIBS))

####################################################################
# Compiler, Assembler, Linker Flags                                #
####################################################################

# Flags for compiling C files
C_FLAGS += \
 -DCPU_S32K144HFT0VLLT \
 -Os \
 -g3 \
 -Wall \
 -fmessage-length=0 \
 -ffunction-sections \
 -fdata-sections \
 -mcpu=cortex-m4 \
 -mthumb \
 -mlittle-endian \
 -specs=nano.specs \
 -specs=nosys.specs \
 --sysroot="C:/NXP/gcc-9.2-arm32-eabi/arm-none-eabi/newlib"

# Flags for compiling CXX files
CXX_FLAGS +=

# Flags for linking object files
LD_FLAGS += \
 -Wl,-Map,"$(OUTPUT_DIR)/S32K144_Demo.map" \
 -Xlinker \
 --gc-sections \
 -n \
 -mcpu=cortex-m4 \
 -mthumb \
 -mlittle-endian \
 -T $(LINKER_FILE) \
 --sysroot="C:/NXP/gcc-9.2-arm32-eabi/arm-none-eabi/newlib"

# Flags for compiling assembly files
ASM_FLAGS += \
 -c \
 -x assembler-with-cpp \
 -g3 \
 -mcpu=cortex-m4 \
 -mthumb \
 -mlittle-endian \
 -specs=nano.specs \
 -specs=nosys.specs \
 --sysroot="C:/NXP/gcc-9.2-arm32-eabi/arm-none-eabi/newlib"
ifeq ($(LOAD_TO),FLASH)
	ASM_FLAGS += \
	 -DSTART_FROM_FLASH \
	 -D__START
endif