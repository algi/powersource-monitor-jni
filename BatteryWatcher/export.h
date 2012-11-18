/*
 *  export.h
 *  BatteryWatcher
 *
 *  Created by Marian Bouček on 11/18/12.
 *  Copyright 2012 Ptakopysk.cz. All rights reserved.
 *
 */

#include <Cocoa/Cocoa.h>
#include <JavaVM/jni.h>

#include "BatteryWatcher.h"

/* Header for class BatteryMonitor */

#ifndef _Included_JNIHandler
#define _Included_JNIHandler
#ifdef __cplusplus
extern "C" {
#endif
	
	JNIEXPORT jboolean JNICALL Java_cz_boucek_intellij_plugin_battery_PowerSourceObserver_registerJNI(JNIEnv *, jobject);
	JNIEXPORT jboolean JNICALL Java_cz_boucek_intellij_plugin_battery_PowerSourceObserver_startMonitor(JNIEnv *, jobject);
	JNIEXPORT jboolean JNICALL Java_cz_boucek_intellij_plugin_battery_PowerSourceObserver_stopMonitor(JNIEnv *, jobject);
	JNIEXPORT jstring JNICALL  Java_cz_boucek_intellij_plugin_battery_PowerSourceObserver_getPowerSourceState(JNIEnv *, jobject);
	
#ifdef __cplusplus
}
#endif
#endif
