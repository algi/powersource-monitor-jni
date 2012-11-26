/*
 *  export.c
 *  AddressBookExporter
 *
 *  Created by Marian Bouček on 5/21/08.
 *  Copyright 2008 Ptakopysk.cz. All rights reserved.
 *
 */

#include "export.h"

JNIEXPORT jboolean JNICALL Java_cz_boucek_intellij_plugin_battery_PowerSourceObserver_registerJNI (JNIEnv *env, jobject obj)
{
	@autoreleasepool {
		BatteryWatcher *watcher = [BatteryWatcher sharedWatcher];
		[watcher registerJNI:env withObject:obj];
		
		return YES;
	}
}

JNIEXPORT jboolean JNICALL Java_cz_boucek_intellij_plugin_battery_PowerSourceObserver_startMonitor (JNIEnv *env, jobject obj)
{
	@autoreleasepool {
		[[BatteryWatcher sharedWatcher] startMonitor];
		return YES;
	}
}

JNIEXPORT jboolean JNICALL Java_cz_boucek_intellij_plugin_battery_PowerSourceObserver_stopMonitor (JNIEnv *env, jobject obj)
{
	@autoreleasepool {
		[[BatteryWatcher sharedWatcher] stopMonitor];
		return YES;
	}
}

JNIEXPORT jstring JNICALL Java_cz_boucek_intellij_plugin_battery_PowerSourceObserver_getPowerSourceState (JNIEnv *env, jobject obj)
{
	@autoreleasepool {
		NSString *state = [BatteryWatcher currentState];
		
		jstring result = (*env)->NewStringUTF(env, [state UTF8String]);
		return result;
	}
}
