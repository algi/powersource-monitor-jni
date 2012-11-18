//
//  BatteryWatcher.h
//  BatteryWatcher
//
//  Created by Marian Bouček on 15.11.12.
//  Copyright (c) 2012 Marian Bouček. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JavaVM/jni.h>

// allowed states of power source
#define kPOWER_BATTERY (@"POWER_BATTERY")
#define kPOWER_WALL    (@"POWER_WALL")
#define kPOWER_UNKNOWN (@"POWER_UNKNOWN")

/*
 * Power source observer.
 *
 * Credits: http://context-macosx.googlecode.com/svn-history/r138/trunk/Tools/Applications/Pennyworth/PowerObserver.m
 */
@interface BatteryWatcher : NSObject

/*
 * Returns shared instance of power source observer.
 */
+ (id) sharedInstance;

/*
 * Register IOKit listener with given Java environment.
 */
- (void) registerJNI: (JNIEnv*) env
		   andObject: (jobject) obj;

- (void) startMonitor;
- (void) stopMonitor;

/*
 * Returns current state of power source.
 */
+ (NSString*) currentState;

@end
