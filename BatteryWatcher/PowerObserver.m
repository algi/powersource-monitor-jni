//
//  PowerObserver.m
//  BatteryWatcher
//
//  Created by Marian Bouček on 15.11.12.
//  Copyright (c) 2012 Marian Bouček. All rights reserved.
//

#import "PowerObserver.h"

#include <IOKit/IOKitLib.h>
#include <IOKit/ps/IOPSKeys.h>
#include <IOKit/ps/IOPowerSources.h>

#define POWER_WALL 1
#define POWER_BATTERY 0
#define POWER_UNKNOWN -1

static bool stringsAreEqual (CFStringRef a, CFStringRef b)
{
	if (a == nil || b == nil)
		return 0;
	
	return (CFStringCompare (a, b, 0) == kCFCompareEqualTo);
}

static void update (void * context)
{
	PowerObserver * self = (PowerObserver *) context;
	
	CFTypeRef blob = IOPSCopyPowerSourcesInfo ();
	CFArrayRef list = IOPSCopyPowerSourcesList (blob);
	
	CFIndex count = CFArrayGetCount (list);
	
	if (count == 0)
		[self setStatus:POWER_WALL];
	
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
			
			if (stringsAreEqual (currentState, CFSTR (kIOPSACPowerValue)))
				[self setStatus:POWER_WALL];
			else if (stringsAreEqual (currentState, CFSTR (kIOPSBatteryPowerValue)))
				[self setStatus:POWER_BATTERY];
			else
				[self setStatus:POWER_UNKNOWN];
			
			// Add charge code once thresholding code is implemented.
		}
	}
	
	CFRelease (list);
	CFRelease (blob);
}

@implementation PowerObserver

- (void) setStatus:(unsigned int) status
{
	NSMutableDictionary * note = [NSMutableDictionary dictionary];
	
	[note setValue:@"Power Observer" forKey:OBSERVATION_OBSERVER];
	
	if (status == POWER_WALL) {
		[note setValue:@"Wall" forKey:OBSERVATION_OBSERVATION];
	}
	else if (status == POWER_BATTERY) {
		[note setValue:@"Battery" forKey:OBSERVATION_OBSERVATION];
	}
	else {
		[note setValue:@"Unknown" forKey:OBSERVATION_OBSERVATION];
	}
	
	[[NSNotificationCenter defaultCenter] postNotificationName:OBSERVATION_UPDATE object:self userInfo:note];
	NSLog(@"Value changed: %@.", [note valueForKey:OBSERVATION_OBSERVATION]);
}

- (void) awakeFromNib
{
	CFRunLoopSourceRef loopSource = IOPSNotificationCreateRunLoopSource (update, self);
	
	if (loopSource)
		CFRunLoopAddSource (CFRunLoopGetCurrent(), loopSource, kCFRunLoopDefaultMode);
	
	[[NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(refresh:) userInfo:nil repeats:NO] retain];
}

- (void) refresh:(NSTimer *) theTimer
{
	update (( void *)(self));
	
	[theTimer release];
}

@end
