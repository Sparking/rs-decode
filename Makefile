AR       := ar
CC       := gcc
CXX      := g++
RANLIB   := ranlib
ARFLAGS  := rc
CXXFLAGS := -g -O0 -ffunction-sections -fdata-sections -fno-strict-aliasing
CPPFLAGS := -Wall -Werror -ansi -MMD -I$(CURDIR)
LDFLAGS  := -Wl,-gc-section -L$(CURDIR)
LIBS     :=

RSLILB_SRC  := generic_gf.c rsdecode.c
RSLILB_DEPS := $(patsubst %.c,%.d,$(RSLILB_SRC))
RSLILB_OBJS := $(patsubst %.c,%.o,$(RSLILB_SRC))
RSLILB_OUT  := librsdecode.a
LIBS     += -lrsdecode

SRC      := demo.cc
DEPS     := $(patsubst %.cc,%.d,$(SRC))
OBJS     := $(patsubst %.cc,%.o,$(SRC))
ifeq ($(OS),Windows_NT)
OUT      := run.exe
else
OUT      := run
endif

define compile_c
@echo CC	$1
@$(CC) $(CPPFLAGS) -std=c99 $(CXXFLAGS) -c -o $1 $2
endef

define compile_cc
@echo CXX	$1
@$(CXX) $(CPPFLAGS) -std=c++11 $(CXXFLAGS) -c -o $1 $2
endef

define ar_lib
@echo AR	$1
@$(AR) $(ARFLAGS) $1 $2
@$(RANLIB) $1
endef

define link_objects
@echo LD	$1
@$(CXX) $(CXXFLAGS) $(LDFLAGS) -o $1 $2 $(LIBS)
endef

.PHONY: all
all: $(OUT)
$(OUT): $(RSLILB_OUT) $(OBJS)
	$(call link_objects, $@, $^)
$(RSLILB_OUT): $(RSLILB_OBJS)
	$(call ar_lib, $@, $^)
-include $(RSLILB_DEPS) $(DEPS)
$(RSLILB_OBJS): %.o: %.c
	$(call compile_c, $@, $<)
$(OBJS): %.o: %.cc
	$(call compile_cc, $@, $<)

.PHONY: pack
pack: all
ifeq ($(OS), Windows_NT)
	@if exist pack rd /s /q pack
	@mkdir pack\include pack\lib pack\bin
	@copy common\*.h pack\include > .pack.common.info.tmp && del .pack.common.info.tmp
	@copy image\*.h pack\include > .pack.image.info.tmp && del .pack.image.info.tmp
	@copy $(IMAGE_OUT) pack\lib > .pack.$(IMAGE_OUT).info.tmp && del .pack.$(IMAGE_OUT).info.tmp
	@copy $(OUT) pack\bin > .pack.$(OUT).info.tmp && del .pack.$(OUT).info.tmp
else
	@rm -rf pack
	@mkdir -p pack/include pack/lib pack/bin
	@cp common/*.h image/*.h pack/include
	@cp $(IMAGE_OUT) pack/lib
	@cp $(OUT) pack/bin
endif

.PHONY: clean
clean:
ifeq ($(OS), Windows_NT)
	@if exist pack rd /s /q pack
	@for %%I in ($(subst /,\,$(IMAGE_DEPS) $(IMAGE_OBJS) $(IMAGE_OUT) $(DEPS) $(OBJS) $(OUT))) do if exist %%I del /f /q %%I
else
	@$(RM) $(IMAGE_DEPS) $(IMAGE_OBJS) $(IMAGE_OUT) $(DEPS) $(OBJS) $(OUT)
endif
