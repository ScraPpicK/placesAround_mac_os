//
//  MainViewController.m
//  MPlacesAround
//
//  Created by Patalakh Vadim on 3/4/18.
//  Copyright © 2018 Patalakh Vadim. All rights reserved.
//

#import "MainViewController.h"
#import "MapKit/MapKit.h"
#import "DownloadManager.h"
#import "PlacesTableCellView.h"
#import "Place.h"
#import "PVAsyncImageView.h"
#import <CoreLocation/CoreLocation.h>

#define kPlaceholderLocation @"52.531,13.3843"

@interface MainViewController () <NSTableViewDelegate, NSTableViewDataSource, DownloadManagerDelegate, CLLocationManagerDelegate, NSTextViewDelegate>

@property (weak) IBOutlet       NSTableView         *tableView;
@property (weak) IBOutlet       MKMapView           *mapView;
@property (weak) IBOutlet       NSTextField         *coordinatesTextField;

@property (atomic, strong)      NSArray<Place *>    *places;
@property (nonatomic, strong)   MKPointAnnotation   *annotation;
@property (nonatomic, assign)   MKCoordinateSpan    zoom;
@property (nonatomic, strong)   CLLocationManager   *locationManager;

- (IBAction)findPlacesNear:(id)sender;
- (IBAction)searchForCoordinates:(id)sender;

@end

@implementation MainViewController

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    
    if (self)
    {
        self.annotation = [[MKPointAnnotation alloc] init];
        self.zoom = MKCoordinateSpanMake(.1f, .1f);
        
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.distanceFilter = kCLDistanceFilterNone;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        self.locationManager.delegate = self;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    NSNib *cellNib = [[NSNib alloc] initWithNibNamed:@"PlacesTableCellView" bundle:nil];
    [self.tableView registerNib:cellNib forIdentifier:@"PlacesTableCellView"];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    DownloadManager *manager = [DownloadManager shared];
    manager.delegate = self;
    [manager downloadPlacesForLocation:kPlaceholderLocation];
}

- (void)findPlacesNear:(id)sender
{
    [self enableLocationService];
}

- (void)enableLocationService
{
    switch ([CLLocationManager authorizationStatus])
    {
        case kCLAuthorizationStatusNotDetermined:
            [self.locationManager startUpdatingLocation];
            [self.locationManager stopUpdatingLocation];
            break;
            
        case kCLAuthorizationStatusDenied:
            break;
            
        case kCLAuthorizationStatusRestricted:
            break;
            
        case kCLAuthorizationStatusAuthorized:
            [self.locationManager startUpdatingLocation];
            break;
            
        default:
            break;
    }
}

- (IBAction)searchForCoordinates:(id)sender
{
    NSString *locationString = self.coordinatesTextField.stringValue;
    [[DownloadManager shared] downloadPlacesForLocation:locationString];
}

#pragma mark - Table view data source

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return self.places.count;
}

#pragma mark - Table view delegate

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    Place *place = [self.places objectAtIndex:row];
    
    PlacesTableCellView *cellView = (PlacesTableCellView *)[self.tableView makeViewWithIdentifier:@"PlacesTableCellView" owner:nil];
    
    cellView.nameTextField.stringValue = place.name;
    cellView.addressTextField.stringValue = place.address;
    cellView.coordinatesTextField.stringValue = place.location;
    [cellView.iconImageView downloadImageFromURL:place.image.absoluteString withPlaceholderImage:[NSImage imageNamed:@"PlaceholderImage"]];
    
    return cellView;
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
    Place *place = [self.places objectAtIndex:[[notification object] selectedRow]];
    NSArray *coordinates = [place.location componentsSeparatedByString:@","];
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(
                                                                   ((NSString *)coordinates[0]).doubleValue,
                                                                   ((NSString*)coordinates[1]).doubleValue);
    
    
    [self.annotation setCoordinate:coordinate];
    [self.annotation setTitle:place.name];
    [self.mapView addAnnotation:self.annotation];
    
    MKCoordinateRegion myRegion;
    myRegion.center = coordinate;
    myRegion.span = self.zoom;
    
    [self.mapView setRegion:myRegion animated:YES];
}

#pragma mark - Download manager delegate

- (void)didFinishLoadingPlaces:(NSArray *)places
{
    self.places = places;
    [self.tableView reloadData];
    [self.tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:NO];
}

- (void)couldNotDownloadPlaces:(NSInteger)error
{
    NSString *errorMessage = @"Oops, something went wrong.";
    switch (error) {
        case notValidUrl:
            errorMessage = @"Oops, we could find places for this location, check coordinates please.";
            break;
            
        case couldNotDownloadData:
            errorMessage = @"Oops, we could connect to the server, check your internet connection or try later.";
            
        case couldNotParseData:
            errorMessage = @"Oops, we couldn`t find places for you. Try another coordinates please.";
            
        default:
            break;
    }
    
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"Error"];
    [alert setMessageText:errorMessage];
    [alert runModal];
}

#pragma mark - Location manager delegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    CLLocation *location = [locations lastObject];
    double x = (double)location.coordinate.latitude;
    double y = (double)location.coordinate.longitude;
    NSString *locationString = [NSString stringWithFormat:@"%f,%f", x, y];
    [[DownloadManager shared] downloadPlacesForLocation:locationString];
    [self.locationManager stopUpdatingLocation];
}

@end
