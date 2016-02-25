//
//  BikeStationAnnotation.h
//  Assessment4
//
//  Created by Jonathan Kilgore on 2/5/16.
//  Copyright © 2016 Mobile Makers. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface BikeStationAnnotation : MKPointAnnotation
@property NSNumber *availableBikes;
@property NSNumber *availableDocks;
@property NSNumber *totalDocks;

@property NSString *location;
@property NSString *streetAddress;
@property NSString *stationName;

@property CLLocationDistance distance;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary andLocation:(CLLocation *)location;

@end