TARGET := iphone:clang:10.3:7.0
ARCHS = armv7
INSTALL_TARGET_PROCESSES = bioshock

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = B4BioBoss
B4BioBoss_FILES = Tweak.x
B4BioBoss_CFLAGS = -fno-objc-arc -Wno-deprecated-declarations
B4BioBoss_FRAMEWORKS = UIKit MediaPlayer

include $(THEOS_MAKE_PATH)/tweak.mk
