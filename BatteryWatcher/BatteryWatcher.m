//
//  BatteryWatcher.m
//  BatteryWatcher
//
//  Created by Marian Bouček on 15.11.12.
//  Copyright (c) 2012 Marian Bouček. All rights reserved.
//

#import "BatteryWatcher.h"

#import <IOKit/ps/IOPSKeys.h>
#import <IOKit/ps/IOPowerSources.h>

@implementation BatteryWatcher {
	
	CFRunLoopSourceRef loopSource;
}

#pragma mark Private functions
jint GetJNIEnv(JNIEnv **env, bool *mustDetach);
static void update (void * context);
static bool stringsAreEqual (CFStringRef a, CFStringRef b);

static JavaVM *jvm;
static jmethodID method;
static jclass cls;

static BatteryWatcher* _instance;

#pragma mark Public API
+ (id) sharedInstance
{
	if (! _instance) {
		_instance = [[BatteryWatcher alloc] init];
	}
	
	return _instance;
}

- (void) registerJNI: (JNIEnv*) env
		   andObject: (jobject) obj
{
	[self findJavaMethodWithEnv: env andObject: obj];
}

- (void) startMonitor
{
	loopSource = IOPSNotificationCreateRunLoopSource (update, self);
	
	if (loopSource) {
		CFRunLoopAddSource (CFRunLoopGetCurrent(), loopSource, kCFRunLoopDefaultMode);
	}
	
	// run infinite loop
//	CFRunLoopRun();
}

- (void) stopMonitor
{
	CFRunLoopRef rl = CFRunLoopGetCurrent();
	
	CFRunLoopRemoveSource(rl, loopSource, kCFRunLoopCommonModes);
//	CFRunLoopStop(rl);
}

+ (NSString*) currentState
{
	NSString *result = nil;
	
	CFTypeRef blob = IOPSCopyPowerSourcesInfo ();
	CFArrayRef list = IOPSCopyPowerSourcesList (blob);
	
	CFIndex count = CFArrayGetCount (list);
	
	if (count == 0) {
		result = kPOWER_WALL;
	}
	
	unsigned int i = 0;
	for (i = 0; i < count; i++)
	{
		CFTypeRef source;
		CFDictionaryRef description;
		
		source = CFArrayGetValueAtIndex (list, i);
		description = IOPSGetPowerSourceDescription (blob, source);
		
		if (stringsAreEqual (CFDictionaryGetValue (description, CFSTR (kIOPSTransportTypeKey)), CFSTR (kIOPSInternalType)))
		{
			CFStringRef currentState = CFDictionaryGetValue (description, CFSTR (kIOPSPowerSourceStateKey));
			
			if (stringsAreEqual (currentState, CFSTR (kIOPSACPowerValue))) {
				result = kPOWER_WALL;
			}
			else if (stringsAreEqual (currentState, CFSTR (kIOPSBatteryPowerValue))) {
				result = kPOWER_BATTERY;
			}
			else {
				result = kPOWER_UNKNOWN;
			}
		}
	}
	
	CFRelease (list);
	CFRelease (blob);
	
	return result;
}

#pragma mark Callback methods
- (void) findJavaMethodWithEnv: (JNIEnv*) env
					 andObject: (jobject) obj
{
	// cz.boucek.intellij.plugin.battery.BatteryMonitor -> cz/boucek/intellij/plugin/battery/PowerSourceObserver
	jclass local_tester_cls = (*env)->FindClass(env, "cz/boucek/intellij/plugin/battery/PowerSourceObserver");
	if (local_tester_cls == NULL) {
		NSLog(@"Failed to obtain Java class cz.boucek.intellij.plugin.battery.PowerSourceObserver");
		return;
	}
	
	/* Create a global reference */
	cls = (*env)->NewGlobalRef(env, local_tester_cls);
	
	/* The local reference is no longer useful */
	(*env)->DeleteLocalRef(env, local_tester_cls);
	
	/* Is the global reference created successfully? */
	if (cls == NULL) {
		NSLog(@"Cannot obtain global reference to the class.");
		return;
	}
	
    method = (*env)->GetStaticMethodID(env, cls, "powerSourceChanged", "()V");
	if (method == NULL) {
		NSLog(@"Cannot obtain ID of method 'static void powerSourceChanged(String)'.");
		return;
	}
}

#pragma mark Update function
static void update (void * context)
{	
	if (method == NULL) {
		NSLog(@"Java monitor service not inicialized.");
		return;
	}
	
	JNIEnv *env;
	bool shouldDetach = false;
	
	if (GetJNIEnv(&env, &shouldDetach) != JNI_OK) {
		NSLog(@"Could not attach to JVM.");
		return;
	}
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	(*env)->CallStaticVoidMethod(env, cls, method);
	
	if (shouldDetach) {
		(*jvm)->DetachCurrentThread(jvm);
	}
	
	[pool release];
}

#pragma mark Utility functions
jint GetJNIEnv(JNIEnv **env, bool *mustDetach)
{
	jint getEnvErr = JNI_OK;
	*mustDetach = false;
	
	if (jvm) {
		getEnvErr = (*jvm)->GetEnv(jvm, (void **)env, JNI_VERSION_1_6);
		if (getEnvErr == JNI_EDETACHED) {
			getEnvErr = (*jvm)->AttachCurrentThread(jvm, (void **)env, NULL);
			if (getEnvErr == JNI_OK) {
				*mustDetach = true;
			}
		}
	}
	else {
		getEnvErr = JNI_ERR;
	}
	
	return getEnvErr;
}

static bool stringsAreEqual (CFStringRef a, CFStringRef b)
{
	if (a == nil || b == nil)
		return 0;
	
	return (CFStringCompare (a, b, 0) == kCFCompareEqualTo);
}

JNIEXPORT jint JNICALL JNI_OnLoad(JavaVM *vm, void *reserved)
{
	jvm = vm;
	return JNI_VERSION_1_6;
}

@end
