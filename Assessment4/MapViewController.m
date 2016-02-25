//
//  MapViewController.m
//  CodeChallenge3
//
//  Created by Vik Denic on 10/16/14.
//  Copyright (c) 2014 Mobile Makers. All rights reserved.
//

#import "MapViewController.h"
#import <MapKit/MapKit.h>

@interface MapViewController () <MKMapViewDelegate, CLLocationManagerDelegate>

//Already provided
@property (strong, nonatomic) IBOutlet MKMapView *mapView;

//Custom properties
@property MKPointAnnotation *bikeStationAnnotation;
@property CLLocationManager *locationManager;
@property CLLocation *userLocation;


@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = self.bikeStation.title;
    
    [self displayUserView];
    [self displayUsersLocation];
    [self setRegionOnMap];
}

- (void)displayUserView {
    
    self.locationManager.delegate = self;
    self.locationManager = [CLLocationManager new];
    [self.locationManager requestWhenInUseAuthorization];
    [self.mapView setMapType:MKMapTypeStandard];
}

- (void)displayUsersLocation {
    self.locationManager.delegate = self;
    self.locationManager = [CLLocationManager new];
    [self.locationManager requestAlwaysAuthorization];
    [self.locationManager startUpdatingLocation];
    self.mapView.showsUserLocation = YES;
    
    // Adds the specified annotation to the map view
    [self.mapView addAnnotation:self.bikeStation];
}

- (void)setRegionOnMap {
    
    //This should scale the span to .05 for latittude and longitude
    MKCoordinateSpan span;
    span.latitudeDelta = 0.05;
    span.longitudeDelta = 0.05;
    
    MKCoordinateRegion region;
    region.center = self.bikeStation.coordinate;
    region.span = span;
    
    [self.mapView setRegion:region animated:NO];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    for (CLLocation *location in locations) {
        if (location.horizontalAccuracy < 1000 && location.verticalAccuracy < 1000) {
            self.userLocation = location;
            [self.locationManager stopUpdatingLocation];
            break;
        }
    }
}

#pragma mark - MapKit Delegate Methods

//This method will set the annotation bike image/pin for the cell/row tapped
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    
    //If the pin location is same as current location
    if ([annotation isEqual:mapView.userLocation]) {
        return nil;
    }
    
    //This should instantiate the pin with a reuseID
    MKPinAnnotationView *pin = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"Pin"];
    
    //The callout will use the title and subtitle text from the annotation object
    pin.canShowCallout = YES;
    pin.image = [UIImage imageNamed:@"bikeImage"];
    pin.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    
    //This adds the bike image to the left callout
    UIImageView *iconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bikeImage"]];
    pin.leftCalloutAccessoryView = iconView;
    
    return pin;
}

/*For when the rightCalloutAccessoryView disclosure is tapped...
 This will show an alert action sheet with directions to bike station*/
-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    
    //This will make a directions request as well as set the current location
    MKDirectionsRequest *request = [MKDirectionsRequest new];
    request.source = [MKMapItem mapItemForCurrentLocation];
    
    //This will set the destination location
    MKPlacemark *placemark = [[MKPlacemark alloc]initWithCoordinate:self.bikeStation.coordinate addressDictionary:nil];
    MKMapItem *mapItem = [[MKMapItem alloc]initWithPlacemark:placemark];
    request.destination = mapItem;
    
    
    //This will get the directions for the specified request
    MKDirections *directions = [[MKDirections alloc]initWithRequest:request];
    [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
        MKRoute *route = response.routes.firstObject;
        
        int counter = 1;
        NSMutableString *directionsString = [NSMutableString string];
        
        for (MKRouteStep *step in route.steps) {
            
            [directionsString appendFormat:@"%d: %@\n", counter, step.instructions];
            counter++;
        }
        
        //Alert Action Sheet to display the directions on the disclosure icon tapped
        UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"Directions:"
                                                                            message:directionsString
                                                                     preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            NSLog(@"Dismiss button tapped");
        }];
        
        [controller addAction:alertAction];
        [self presentViewController:controller animated:YES completion:nil];

        
        [self.mapView addOverlay:route.polyline level:MKOverlayLevelAboveRoads];
    }];
    
    [self.mapView showAnnotations:self.mapView.annotations animated:YES];
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    
    if ([overlay isKindOfClass:[MKPolyline class]]) {
        
        MKPolyline *route = overlay;
        MKPolylineRenderer *rendered = [[MKPolylineRenderer alloc] initWithPolyline:route];
        rendered.strokeColor = [UIColor colorWithRed:0.42 green:0.27 blue:0.89 alpha:1.00];
        rendered.lineWidth = 5.0;
        return rendered;
    } else {
        return nil;
    }
}


@end
