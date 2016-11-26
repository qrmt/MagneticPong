//
//  BLMagManager.h
//  magtest
//
//  Created by Oskar Vuola on 24/11/16.
//  Copyright © 2016 blastly. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface BLMagManager : NSObject <CLLocationManagerDelegate>

- (NSArray *)latestMagnetometerData;
- (void)startMagnetometerUpdates;
- (void)stopMagnetometerUpdates;
- (void)calibrate;

@end
