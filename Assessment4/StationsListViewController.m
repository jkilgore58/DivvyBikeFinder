//
//  StationsListViewController.m
//  CodeChallenge3
//
//  Created by Vik Denic on 10/16/14.
//  Copyright (c) 2014 Mobile Makers. All rights reserved.
//

#import "StationsListViewController.h"
#import "BikeJsonData.h"
#import "BikeStationAnnotation.h"
#import "MapViewController.h"

@interface StationsListViewController () <UITableViewDelegate, UITableViewDataSource, BikeJsonDataDelegate, CLLocationManagerDelegate, UISearchBarDelegate>

//Already provided in the zip file
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;

//Array properties
@property NSMutableArray *bikeStationArray;
@property NSMutableArray *searchArray;

//Location properties
@property CLLocationManager *locationManager;
@property CLLocation *userLocation;

//Custom properties
@property BikeJsonData *bikeData;
@property BOOL isFiltered;

@end

@implementation StationsListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.searchBar.delegate = self;
    
    //Initializing the bikeStationArray and locationManager
    self.bikeStationArray = [NSMutableArray new];
    self.locationManager = [CLLocationManager new];
    
    //Initializing the BikeJsonData class
    self.bikeData = [BikeJsonData new];
    
    //Setting the nav bar title
    [self.navigationItem setTitle:[NSString stringWithFormat:@"Chicago Divvy Stations"]];
    
    //setting the delegate methods
    self.bikeData.delegate = self;
    self.locationManager.delegate = self;
    
    
    //Calling the locationManager updated location and authorization
    [self.locationManager requestWhenInUseAuthorization];
    [self.locationManager startUpdatingLocation];
    
    
//end of viewDidLoad
}


#pragma mark - UITableView

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.isFiltered == YES) {
        return self.searchArray.count;
    } else  {
        return self.bikeStationArray.count;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 65;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellID"];
    
    if (self.isFiltered == YES) {
        BikeStationAnnotation *bikes = [self.searchArray objectAtIndex:indexPath.row];
        cell.textLabel.text = bikes.title;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"Available bikes: %@ <> Distance: %.2f miles", bikes.availableBikes, bikes.distance/1000];
    } else {
        BikeStationAnnotation *bikes = [self.bikeStationArray objectAtIndex:indexPath.row];
        cell.textLabel.text = bikes.title;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"Available bikes: %@ <> Distance: %.2f miles", bikes.availableBikes, bikes.distance/1000];
    }
    return cell;
    
}

#pragma mark - CLLocation Delegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"ERROR:: %@", error);
    //In the event the user location cannot be found
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"Location not found"
                                                                        message:@"Please update your settings for location services"
                                                                 preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"Dismiss button tapped");
    }];
    
    [controller addAction:alertAction];
    [self presentViewController:controller animated:YES completion:nil];
    
    
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    for (CLLocation *location in locations) {
        if (location.horizontalAccuracy < 1000 && location.verticalAccuracy < 1000) {
            self.userLocation = location;
            [self.bikeData getBikeStationLocation:self.userLocation];
            [self.locationManager stopUpdatingLocation];
            break;
        }
    }
}

#pragma mark - BikeStation Delegate

- (void) getArrayOfBikes:(NSMutableArray *)stations {
    self.bikeStationArray = stations;
    
    dispatch_async(dispatch_get_main_queue(), ^{

    [self.tableView reloadData];
     });
}


#pragma mark - UIStoryboardSegue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(UITableViewCell *)cell {
    MapViewController *mapVC = segue.destinationViewController;
    
    if (self.searchBar.text.length != 0) {
        mapVC.bikeStation = self.searchArray[[[self.tableView indexPathForCell:cell] row]];
    } else {
        mapVC.bikeStation = self.bikeStationArray[[[self.tableView indexPathForCell:cell] row]];
    }
    
    MKPointAnnotation *user = [MKPointAnnotation new];
    user.coordinate = self.userLocation.coordinate;
}

#pragma mark - UISearchBar

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    if (searchText.length == 0) {
        self.isFiltered = NO;
        
    } else {
        self.isFiltered = YES;
        self.searchArray = [NSMutableArray new];
        
        //Predocate method to identify the filter the station name
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.stationName CONTAINS %@", searchText];
        self.searchArray = [NSMutableArray arrayWithArray:[self.bikeStationArray filteredArrayUsingPredicate:predicate]];
    }
    [self.tableView reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self.searchBar resignFirstResponder];
}

@end
