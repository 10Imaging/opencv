LOCAL_PATH := $(call my-dir)

# import libopencv_java3.so
include $(CLEAR_VARS)
LOCAL_MODULE := libopencv_java3
LOCAL_MODULE_TARGET_ARCH := armeabi-v7a arm64-v8a
$(info NDK-BUILD $(LOCAL_PATH)/../jniLibs/${TARGET_ARCH_ABI}/libopencv_java3.so)
LOCAL_SRC_FILES := $(LOCAL_PATH)/../jniLibs/${TARGET_ARCH_ABI}/libopencv_java3.so
include $(PREBUILT_SHARED_LIBRARY)

# now build opencv_native
include $(CLEAR_VARS)
$(info NDK-BUILD ${TARGET_ARCH_ABI} opencv_native)
LOCAL_MODULE := opencv_native
LOCAL_MODULE_TARGET_ARCH := armeabi-v7a arm64-v8a
LOCAL_C_INCLUDES += $(LOCAL_PATH)/include \
    $(LOCAL_PATH)/include/opencv \
    $(LOCAL_PATH)/include/opencv2 \
    $(JNI_H_INCLUDE)
LOCAL_SRC_FILES := OpenCVLibrary.cpp
#LOCAL_CFLAGS += --verbose
LOCAL_CPPFLAGS	:= -fexceptions -I$(LOCAL_PATH)/include -frtti -fPIC -DANDROID -fsigned-char
#LOCAL_CPPFLAGS += -v
LOCAL_LDLIBS := -ljnigraphics -llog -landroid
LOCAL_SHARED_LIBRARIES := libopencv_java3
ifneq (,$(TARGET_BUILD_APPS))
	LOCAL_JNI_SHARED_LIBRARIES := libopencv_java3 libc++_shared
else
	LOCAL_REQUIRED_MODULES := libopencv_java3 libc++_shared
endif
include $(BUILD_SHARED_LIBRARY)
