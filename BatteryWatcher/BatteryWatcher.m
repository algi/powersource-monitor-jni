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

// private extension with C function definitions
@interface BatteryWatcher ()

jint GetJNIEnv(JNIEnv **env, bool *mustDetach);
static void update (void * context);
static bool stringsAreEqual (CFStringRef a, CFStringRef b);

@end

@implementation BatteryWatcher {
	
	CFRunLoopSourceRef loopSource;
}

static JavaVM *jvm;
static jmethodID method;
static jclass cls;

#pragma mark Public API
+ (instancetype) sharedWatcher
{
	static BatteryWatcher* sharedWatcher;
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken, ^{
		sharedWatcher = [[BatteryWatcher alloc]init];
	});
		
	return sharedWatcher;
}

- (void) registerJNI: (JNIEnv*) env
		  withObject: (jobject) obj
{
	[self findJavaMethodWithEnv: env andObject: obj];
}

- (void) startMonitor
{
	if (loopSource) {
		NSLog(@"Monitor is already running.");
		return;
	}
	
	loopSource = IOPSNotificationCreateRunLoopSource (update, (__bridge void *)(self));
	if (loopSource) {
		CFRunLoopAddSource (CFRunLoopGetCurrent(), loopSource, kCFRunLoopDefaultMode);
	}
	
	CFRunLoopRun();
}

- (void) stopMonitor
{
	if (!loopSource) {
		NSLog(@"Monitor is already stopped.");
		return;
	}
	
	CFRunLoopRemoveSource(CFRunLoopGetCurrent(), loopSource, kCFRunLoopCommonModes);
	CFRunLoopStop(CFRunLoopGetCurrent());
	
	loopSource = nil;
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
		NSLog(@"Java monitor service is not inicialized.");
		return;
	}
	
	NSLog(@"- update -");
	
	JNIEnv *env;
	bool shouldDetach = false;
	
	if (GetJNIEnv(&env, &shouldDetach) != JNI_OK) {
		NSLog(@"Could not attach to JVM.");
		return;
	}
	
	@autoreleasepool {
		(*env)->CallStaticVoidMethod(env, cls, method);
		
		if (shouldDetach) {
			(*jvm)->DetachCurrentThread(jvm);
		}
	}
}

#pragma mark Utility functions
jint GetJNIEnv(JNIEnv **env, bool *mustDetach)
{
	jint getEnvErr;
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
	if (a == nil || b == nil) {
		return 0;
	}
	
	return (CFStringCompare (a, b, 0) == kCFCompareEqualTo);
}

JNIEXPORT jint JNICALL JNI_OnLoad(JavaVM *vm, void *reserved)
{
	jvm = vm;
	return JNI_VERSION_1_6;
}

@end
