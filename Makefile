export ARCHS = arm64 arm64e
export DEBUG = 0
export FINALPACKAGE = 1

export PREFIX = $(THEOS)/toolchain/Xcode11.xctoolchain/usr/bin/

TARGET := iphone:clang:latest:7.0

include $(THEOS)/makefiles/common.mk

TOOL_NAME = vexillarius

vexillarius_FILES = $(wildcard *.mm)
vexillarius_CFLAGS = -fobjc-arc
vexillarius_CODESIGN_FLAGS = -Sentitlements.plist
vexillarius_INSTALL_PATH = /usr/libexec

include $(THEOS_MAKE_PATH)/tool.mk
