//
//  BikeJsonData.h
//  Assessment4
//
//  Created by Jonathan Kilgore on 2/5/16.
//  Copyright © 2016 Mobile Makers. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@protocol BikeJsonDataDelegate <NSObject>


- (void)getArrayOfBikes:(NSArray *)stops;

@end


@interface BikeJsonData : NSObject <NSURLSessionDataDelegate>

@property (nonatomic, strong) id <BikeJsonDataDelegate> delegate;

@property (nonatomic) NSURLSession *session;

- (void)getBikeStationLocation:(CLLocation *)location;

@end
