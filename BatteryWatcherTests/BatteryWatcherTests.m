//
//  BatteryWatcherTests.m
//  BatteryWatcherTests
//
//  Created by Marian Bouček on 15.11.12.
//  Copyright (c) 2012 Marian Bouček. All rights reserved.
//

#import "BatteryWatcherTests.h"
#import "BatteryWatcher.h"

@implementation BatteryWatcherTests

- (void)setUp
{
    [super setUp];
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    [super tearDown];
}

- (void) testStartStopMonitor
{
	NSLog(@"testAddObserver - start");
	
	id watcher = [BatteryWatcher sharedWatcher];
	
	dispatch_queue_t myQueue = dispatch_queue_create("com.mycompany.myqueue", 0);
	dispatch_async(myQueue, ^{
		NSLog(@"... starting monitor.");
		[watcher startMonitor];
	});
	
	NSLog(@"... scheduling stopMonitor.");
	[NSTimer scheduledTimerWithTimeInterval: 2 target: self selector:@selector(stopMonitor) userInfo:nil repeats:NO];
	
	CFRunLoopRun();
	NSLog(@"testAddObserver - done");
}

- (void) stopMonitor
{
	NSLog(@"... stop monitor.");
	[[BatteryWatcher sharedWatcher] stopMonitor];
}

@end
