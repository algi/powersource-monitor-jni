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

- (void) testCurrentState
{
	NSLog(@"testCurrentState - start");
	
	NSString *curentState = [BatteryWatcher currentState];
	STAssertEqualObjects(curentState, kPOWER_WALL, @"Current state should be on battery.");
	
	NSLog(@"testCurrentState - done");
}

- (void) testAddObserver
{
	NSLog(@"testAddObserver - start");
	
	id watcher = [BatteryWatcher sharedInstance];
	[watcher startMonitor];
	
	[watcher stopMonitor];
	NSLog(@"testAddObserver - stop");
}

@end
