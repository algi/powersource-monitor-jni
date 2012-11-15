//
//  PowerObserver.h
//  BatteryWatcher
//
//  Created by Marian Bouček on 15.11.12.
//  Copyright (c) 2012 Marian Bouček. All rights reserved.
//

#import <Foundation/Foundation.h>

#define OBSERVATION_UPDATE @"GKB: Observation Update"
#define OBSERVATION_OBSERVER @"Observation Name"
#define OBSERVATION_OBSERVATION @"Observation Description"
#define OBSERVATION_DATE @"Observation Date"
#define OBSERVATION_LIFESPAN @"Observation Lifespan"

@interface PowerObserver : NSObject

- (void) setStatus:(unsigned int) status;

- (void) awakeFromNib;

@end