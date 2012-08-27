include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = LiveViewSettings
LiveViewSettings_FILES = LiveViewSettings.mm
LiveViewSettings_INSTALL_PATH = /Library/PreferenceBundles
LiveViewSettings_FRAMEWORKS = UIKit
LiveViewSettings_PRIVATE_FRAMEWORKS = Preferences

include $(FW_MAKEDIR)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(FW_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(FW_STAGING_DIR)/Library/PreferenceLoader/Preferences/LiveViewSettings.plist$(ECHO_END)
