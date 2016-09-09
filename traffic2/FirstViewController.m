//
//  FirstViewController.m
//  traffic2
//
//  Created by Catherine Zhao on 2016-09-01.
//  Copyright © 2016 Catherine. All rights reserved.
//

#import "FirstViewController.h"
#import "AddressDetailViewController.h"

@interface FirstViewController ()
@property (nonatomic, strong)CLLocationManager *locationManager;
@property (weak, nonatomic) IBOutlet UITextField *searchText;
@property (nonatomic, assign)CLLocationCoordinate2D oldCurrentLocationValue;
@property (nonatomic, assign)CLLocationCoordinate2D currentPoint;
@property (nonatomic, assign)int trafficIncidentLevel;
@end

const NSString *bingMapKey = @"AsHdhDvy5ci5JminQIzQLu3Wgl6pLToeZ-vkDoLkc_SHD2KferVhJ_v_VEz8jSfd";
NSLock *trafficIncidentLevelLock;
const NSString *TapPoint = @"TapPoint";
const NSString *SearchPoint = @"SearchPoint";
const NSString *TrafficPoint = @"TrafficPoint";

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.trafficIncidentLevel = 0;
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    [self.view addGestureRecognizer:longPress];
    
    self.locationManager = [[CLLocationManager alloc]init];
    self.locationManager.delegate = self;
    [self.locationManager requestAlwaysAuthorization];
    
    if ([CLLocationManager locationServicesEnabled]) {
        self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
        [self.locationManager requestLocation];
    }
    
    self.mapView.delegate = self;
    
    self.navigationController.modalPresentationStyle = UIModalPresentationCurrentContext;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveTrafficNotification:) name:@"GetTrafficData" object:nil];
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
        point.subtitle = TapPoint;
        
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

//- (MKAnnotationView *)retur

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    MKPinAnnotationView *annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"annoView"];
    annotationView.canShowCallout = YES;
    
    if ([annotation isKindOfClass:[MKPointAnnotation class]]) {
        MKPointAnnotation *pointAnnotation = (MKPointAnnotation *)annotation;
        if ([pointAnnotation.subtitle isEqualToString:TapPoint]) {
            annotationView.pinTintColor = [UIColor greenColor];
        }else if ([pointAnnotation.subtitle isEqualToString:TrafficPoint]) {
            annotationView.pinTintColor = [UIColor redColor];
        }
    }else {
        annotationView.pinTintColor = [UIColor blueColor];
    }
    
    annotationView.rightCalloutAccessoryView =  [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    return annotationView;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control{
    //UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    AddressDetailViewController *addressDetailViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"AddressDetailViewController"];
    addressDetailViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    addressDetailViewController.addressString = [view.annotation title];
    self.currentPoint = [view.annotation coordinate];
    addressDetailViewController.mainViewController = self;
    self.navigationController.modalPresentationStyle = UIModalPresentationCurrentContext;
    [self presentViewController:addressDetailViewController animated:YES completion:nil];
}

- (MKPolylineRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(nonnull id<MKOverlay>)overlay {
    MKPolylineRenderer *polyRenderer = [[MKPolylineRenderer alloc] initWithOverlay:overlay];
    if ([overlay isKindOfClass:[MKPolyline class]]) {
        switch (self.trafficIncidentLevel) {
            case 4:
                polyRenderer.strokeColor = [[UIColor redColor] colorWithAlphaComponent:0.75];
                break;
            case 3:
                polyRenderer.strokeColor = [[UIColor orangeColor] colorWithAlphaComponent:0.75];
                break;
            case 2:
                polyRenderer.strokeColor = [[UIColor yellowColor] colorWithAlphaComponent:0.75];
                break;
            case 1:
                polyRenderer.strokeColor = [[UIColor blueColor] colorWithAlphaComponent:0.75];
                break;
            default:
                break;
        }
        polyRenderer.lineWidth = 5;
    }
    return polyRenderer;
}

- (void)receiveTrafficNotification:(NSNotification *)notif {
    NSArray *pointsArray = [self.mapView overlays];
    [self.mapView removeOverlays:pointsArray];
    [self downloadAccident:self.currentPoint];
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

- (void)plotTrafficRoute:(NSArray *)trafficDic {
    MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
    
    for (NSDictionary *incidents in trafficDic) {
        
        if ([incidents objectForKey:@"point"] && [incidents objectForKey:@"toPoint"]) {
            
            NSArray *sourceArray = [[incidents objectForKey:@"point"] objectForKey:@"coordinates"];
            NSArray *destinationArray = [[incidents objectForKey:@"toPoint"] objectForKey:@"coordinates"];
            CLLocationCoordinate2D sourcePoint = CLLocationCoordinate2DMake([sourceArray[0] floatValue], [sourceArray[1] floatValue]);
            CLLocationCoordinate2D destinationPoint = CLLocationCoordinate2DMake([destinationArray[0] floatValue], [destinationArray[1] floatValue]);
            MKPlacemark *sourcePlaceMark = [[MKPlacemark alloc]initWithCoordinate:sourcePoint addressDictionary:nil];
            MKPlacemark *destinationPlaceMark = [[MKPlacemark alloc]initWithCoordinate:destinationPoint addressDictionary:nil];
            MKMapItem *sourceItem = [[MKMapItem alloc]initWithPlacemark:sourcePlaceMark];
            MKMapItem *destinationItem = [[MKMapItem alloc]initWithPlacemark:destinationPlaceMark];
            
            request.source = sourceItem;
            request.destination = destinationItem;
            self.trafficIncidentLevel = [[incidents objectForKey:@"severity"] intValue];
            
            MKPointAnnotation *trafficIncidentPoint = [[MKPointAnnotation alloc] init];
            trafficIncidentPoint.coordinate = sourcePoint;
            trafficIncidentPoint.subtitle = TrafficPoint;
            [self.mapView addAnnotation:trafficIncidentPoint];
            
            request.requestsAlternateRoutes = true;
            request.transportType = MKDirectionsTransportTypeAutomobile;
            
            MKDirections *directions = [[MKDirections alloc] initWithRequest:request];
            [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *err){
                if (!err) {
                    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"expectedTravelTime" ascending:YES];
                    NSArray *sortedArray = [response.routes sortedArrayUsingDescriptors:@[sort]];
                    [self plotTrafficOnMap: [sortedArray firstObject]];
                }
            }];
        }
    }
}

- (void)plotTrafficOnMap:(MKRoute *)trafficIncRoute {
    [self.mapView addOverlay:trafficIncRoute.polyline];
    if (self.mapView.overlays.count == 1) {
        [self.mapView setVisibleMapRect:trafficIncRoute.polyline.boundingMapRect edgePadding:UIEdgeInsetsMake(10.0, 10.0, 10.0, 10.0) animated:false];
    }else{
        MKMapRect newRouteBound = MKMapRectUnion(self.mapView.visibleMapRect, trafficIncRoute.polyline.boundingMapRect);
        [self.mapView setVisibleMapRect:newRouteBound edgePadding:UIEdgeInsetsMake(10.0, 10.0, 10.0, 10.0) animated:false];
    }
}

- (void)downloadAccident:(CLLocationCoordinate2D )address{
    NSString *addressLine =  [NSString stringWithFormat:@"%i,%i,%i,%i", (int)address.latitude-5, (int)address.longitude-5, (int)address.latitude+5, (int)address.longitude+5];
   
    NSString *url = [NSString stringWithFormat:@"http://dev.virtualearth.net/REST/v1/Traffic/Incidents/%@/true?t=1,8,9&s=2,3,4&key=%@",addressLine, bingMapKey];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:40.0];
    [request setHTTPMethod:@"GET"];
    
    NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if(error) {
            NSLog(@"Error: %@", error);
        }else {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
            NSError *err;
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&err];
            if ([httpResponse statusCode] == 200){
                NSArray *trafficIncidents = [[[json valueForKey:@"resourceSets"] valueForKey:@"resources"] firstObject];
                [trafficIncidentLevelLock lock];
                [self plotTrafficRoute:trafficIncidents];
                [trafficIncidentLevelLock unlock];
            }else {
                int i = 5;
            }
            
        }
    }];
    [task resume];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
