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
	jboolean result = YES;
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	BatteryWatcher *watcher = [BatteryWatcher sharedInstance];
	[watcher registerJNI:env withObject:obj];
	
	[pool release];
	return result;
}

JNIEXPORT jboolean JNICALL Java_cz_boucek_intellij_plugin_battery_PowerSourceObserver_startMonitor (JNIEnv *env, jobject obj)
{
	jboolean result = YES;
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	[[BatteryWatcher sharedInstance] startMonitor];
	
	[pool release];
	return result;
}

JNIEXPORT jboolean JNICALL Java_cz_boucek_intellij_plugin_battery_PowerSourceObserver_stopMonitor (JNIEnv *env, jobject obj)
{
	jboolean result = YES;
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	[[BatteryWatcher sharedInstance] stopMonitor];
	
	[pool release];
	return result;
}

JNIEXPORT jstring JNICALL Java_cz_boucek_intellij_plugin_battery_PowerSourceObserver_getPowerSourceState (JNIEnv *env, jobject obj)
{
	jstring result = NULL;
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	NSString *state = [BatteryWatcher currentState];
	result = (*env)->NewStringUTF(env, [state UTF8String]);
	
	[pool release];
	return result;
}
