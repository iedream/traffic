//
//  FirstViewController.m
//  traffic2
//
//  Created by Catherine Zhao on 2016-09-01.
//  Copyright © 2016 Catherine. All rights reserved.
//

#import "FirstViewController.h"

@interface FirstViewController ()
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic, strong)CLLocationManager *locationManager;
@property (weak, nonatomic) IBOutlet UITextField *searchText;
@property (nonatomic, assign)CLLocationCoordinate2D oldCurrentLocationValue;
@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    [self.view addGestureRecognizer:longPress];
    
    self.locationManager = [[CLLocationManager alloc]init];
    self.locationManager.delegate = self;
    [self.locationManager requestAlwaysAuthorization];
    
    if ([CLLocationManager locationServicesEnabled]) {
        self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
        [self.locationManager requestLocation];
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(locations.firstObject.coordinate, 800, 800);
    [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"Error: %@", error);
}

- (void) handleLongPress:(UILongPressGestureRecognizer *)recognizer {
    CGPoint point = [recognizer locationInView:self.mapView];
    CLLocationCoordinate2D tapPoint = [self.mapView convertPoint:point toCoordinateFromView:self.view];
    CLLocation *location = [[CLLocation alloc] initWithLatitude:tapPoint.latitude longitude:tapPoint.longitude];
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray* placemarks, NSError* error){
        MKPointAnnotation *point = [[MKPointAnnotation alloc]init];
        point.coordinate = tapPoint;
        
        if ([placemarks count] > 0) {
            CLPlacemark *placeMark = [placemarks firstObject];
            NSArray *address = placeMark.addressDictionary[@"FormattedAddressLines"];
            point.title = [address componentsJoinedByString:@", "];
        }else{
            point.title = @"Drop Pin";
        }

        [self.mapView addAnnotation:point];
    }];
}

- (IBAction)searchMethod:(id)sender {
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder geocodeAddressString:self.searchText.text completionHandler:^(NSArray* placemarks, NSError* error){
        for (CLPlacemark *placeMark in placemarks){
            MKPlacemark *realPlaceMark = [[MKPlacemark alloc]initWithPlacemark:placeMark];
            [self.mapView addAnnotation:realPlaceMark];
            MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(realPlaceMark.coordinate, 800, 800);
            [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
