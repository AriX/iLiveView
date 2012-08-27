include $(THEOS)/makefiles/common.mk

TWEAK_NAME = LiveView
CFLAGS = -Wno-unknown-pragmas -Wno-error

LiveView_FILES = Tweak.xm LVPreferenceManager.m NSMutableData+endian.m LVController.m LiveViewRFCOMM.m LVMenuItem.m LVSimpleItem.m LVMessageItem.m
SUBPROJECTS = settings

include $(FW_MAKEDIR)/tweak.mk
LiveView_FRAMEWORKS = UIKit Foundation QuartzCore AudioToolbox CoreGraphics MediaPlayer
LiveView_CFLAGS = -I/Users/Ari/dev/iLiveView
LiveView_LDFLAGS = -lactivator -ldl libBTstack.dylib

SUBPROJECTS = settings
include $(FW_MAKEDIR)/aggregate.mk
