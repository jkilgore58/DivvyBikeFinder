//
//  BikeJsonData.m
//  Assessment4
//
//  Created by Jonathan Kilgore on 2/5/16.
//  Copyright © 2016 Mobile Makers. All rights reserved.
//

#import "BikeJsonData.h"
#import "BikeStationAnnotation.h"

@implementation BikeJsonData

- (void)getBikeStationLocation:(CLLocation *)location {
    NSURL *apiURL = [NSURL URLWithString:@"http://www.divvybikes.com/stations/json/"];
    NSURLRequest *request = [NSURLRequest requestWithURL:apiURL];
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    self.session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];
    
    NSURLSessionDataTask *dataTask = [self.session dataTaskWithRequest:request
                                                     completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error)
    {
        NSDictionary *bikeDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    
        NSArray *bikeStationArray = bikeDictionary[@"stationBeanList"];
        NSMutableArray *bikeStationMutableArray = [NSMutableArray new];
        
        for (NSDictionary *stationDictionary in bikeStationArray) {
            BikeStationAnnotation *station = [[BikeStationAnnotation alloc] initWithDictionary:stationDictionary andLocation:location];
            [bikeStationMutableArray addObject:station];
        }
        
        //Sort by bike distance closest to user
        NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"distance" ascending:YES];
        NSArray *sortArray = [bikeStationMutableArray sortedArrayUsingDescriptors:@[descriptor]];
        
                            
        [self.delegate getArrayOfBikes:[NSArray arrayWithArray:sortArray]];
        
        
        
    //end of NSURLSession completion handler
    }];
    
    [dataTask resume];
    
    
//end of getBikeLocation method
}
@end
