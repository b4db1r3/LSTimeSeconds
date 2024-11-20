TARGET := iphone:clang:14.5:14.5
export ARCHS = arm64 arm64e
INSTALL_TARGET_PROCESSES = SpringBoard
FINAL_PACKAGE=1
#THEOS_PACKAGE_SCHEME=rootless
PACKAGE_VERSION = 0.3


include $(THEOS)/makefiles/common.mk

TWEAK_NAME = LSTimeSeconds

LSTimeSeconds_FILES = Tweak.xm
LSTimeSeconds_CFLAGS = -fobjc-arc
LSTimeSeconds_FRAMEWORKS = UIKit

include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += lstsprefs
include $(THEOS_MAKE_PATH)/aggregate.mk
