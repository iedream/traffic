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
NSOperationQueue *queue;

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
    
    trafficIncidentLevelLock = [[NSLock alloc]init];
    queue = [[NSOperationQueue alloc]init];
    queue.maxConcurrentOperationCount = 5;
    
    self.navigationController.modalPresentationStyle = UIModalPresentationCurrentContext;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveTrafficNotification:) name:@"GetTrafficData" object:nil];
    
    MKPointAnnotation *point = [[MKPointAnnotation alloc]init];
    point.coordinate = CLLocationCoordinate2DMake(38.785835000000001, -121.406517);
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

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    NSLog(@"hello");
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    MKPinAnnotationView *annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"annoView"];
    annotationView.canShowCallout = YES;
    
    
    if ([annotation isKindOfClass:[MyAnnotation class]]) {
        MyAnnotation *pointAnnotation = (MyAnnotation *)annotation;
        if (pointAnnotation.severity == LOW_IMPACT) {
            annotationView.pinTintColor = [UIColor blueColor];
        }else if (pointAnnotation.severity == MINOR) {
            annotationView.pinTintColor = [UIColor yellowColor];
        }else if (pointAnnotation.severity == MODERATE) {
            annotationView.pinTintColor = [UIColor orangeColor];
        }else if (pointAnnotation.severity == SERIOUS) {
            annotationView.pinTintColor = [UIColor redColor];
        }
    }else if ([annotation isKindOfClass:[MKPointAnnotation class]]) {
        annotationView.pinTintColor = [UIColor blackColor];
        annotationView.enabled = YES;
    }else {
        annotationView.pinTintColor = [UIColor greenColor];
    }
    
    annotationView.rightCalloutAccessoryView =  [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    annotationView.frame = CGRectMake(0, 0, 67, 26);
    annotationView.backgroundColor = [UIColor orangeColor];
    [annotationView setAnimatesDrop:YES];
    return annotationView;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control{
    AddressDetailViewController *addressDetailViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"AddressDetailViewController"];
    addressDetailViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    addressDetailViewController.addressString = [view.annotation title];
    self.currentPoint = [view.annotation coordinate];
    addressDetailViewController.mainViewController = self;
    [self addChildViewController:addressDetailViewController];
    [self.view addSubview:addressDetailViewController.view];
}

- (MKPolylineRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(nonnull id<MKOverlay>)overlay {
    MKPolylineRenderer *polyRenderer = [[MKPolylineRenderer alloc] initWithOverlay:overlay];
    if ([overlay isKindOfClass:[MKPolyline class]]) {
        switch (self.trafficIncidentLevel) {
            case SERIOUS:
                polyRenderer.strokeColor = [[UIColor redColor] colorWithAlphaComponent:0.75];
                break;
            case MODERATE:
                polyRenderer.strokeColor = [[UIColor orangeColor] colorWithAlphaComponent:0.75];
                break;
            case MINOR:
                polyRenderer.strokeColor = [[UIColor yellowColor] colorWithAlphaComponent:0.75];
                break;
            case LOW_IMPACT:
                polyRenderer.strokeColor = [[UIColor blueColor] colorWithAlphaComponent:0.75];
                break;
            default:
                break;
        }
        polyRenderer.lineWidth = 5;
    }
    [trafficIncidentLevelLock unlock];
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

- (void)plotTrafficRouteThread:(NSDictionary *)params {
    MKDirectionsRequest *directionRequest = params[@"request"];
    int severity = [params[@"severity"] intValue];
    [trafficIncidentLevelLock lock];
    self.trafficIncidentLevel = severity;
    MKDirections *directions = [[MKDirections alloc] initWithRequest:directionRequest];
    [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *err){
        if (!err) {
            NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"expectedTravelTime" ascending:YES];
            NSArray *sortedArray = [response.routes sortedArrayUsingDescriptors:@[sort]];
            [self plotTrafficOnMap: [sortedArray firstObject]];
        }
    }];
}

- (void)plotTrafficRoute:(NSArray *)trafficDic {
    int i = 0;
    int z = 0;
    for (NSDictionary *incidents in trafficDic) {
        MyAnnotation *trafficIncidentPoint = [[MyAnnotation alloc] init];
        
        NSArray *sourceArray = [[incidents objectForKey:@"point"] objectForKey:@"coordinates"];
        CLLocationCoordinate2D sourcePoint = CLLocationCoordinate2DMake([sourceArray[0] floatValue], [sourceArray[1] floatValue]);
        MKPlacemark *sourcePlaceMark = [[MKPlacemark alloc]initWithCoordinate:sourcePoint addressDictionary:nil];
        MKMapItem *sourceItem = [[MKMapItem alloc]initWithPlacemark:sourcePlaceMark];
        trafficIncidentPoint.coordinate = sourcePoint;
        trafficIncidentPoint.source = sourcePlaceMark;
        
        trafficIncidentPoint.severity = [[incidents objectForKey:@"severity"] intValue];
        trafficIncidentPoint.type = [[incidents objectForKey:@"type"] intValue];
        
        NSString *prefix = @"/Date(";
        NSString *suffic = @")/";
        NSString *startTimeJson = [incidents objectForKey:@"start"];
        if ([startTimeJson hasPrefix:prefix] && [startTimeJson hasSuffix:suffic]){
            startTimeJson = [startTimeJson substringWithRange:NSMakeRange([prefix length], [startTimeJson length]-[suffic length]-[prefix length])];
        }
        NSString *endTimeJson = [incidents objectForKey:@"end"];
        if ([endTimeJson hasPrefix:prefix] && [endTimeJson hasSuffix:suffic]) {
            endTimeJson = [endTimeJson substringWithRange:NSMakeRange([prefix length], [endTimeJson length]-[suffic length]-[prefix length])];
        }
        trafficIncidentPoint.startTime = [NSDate dateWithTimeIntervalSince1970: [startTimeJson doubleValue]/1000.0];
        trafficIncidentPoint.endTime = [NSDate dateWithTimeIntervalSince1970: [endTimeJson doubleValue]/1000.0];
        
        trafficIncidentPoint.roadClosed = [[incidents objectForKey:@"roadClosed"] boolValue];
        trafficIncidentPoint.info = [incidents objectForKey:@"description"];
        trafficIncidentPoint.lane = [incidents objectForKey:@"lane"];
        
        if ([incidents objectForKey:@"toPoint"]) {
            
            NSArray *destinationArray = [[incidents objectForKey:@"toPoint"] objectForKey:@"coordinates"];
            CLLocationCoordinate2D destinationPoint = CLLocationCoordinate2DMake([destinationArray[0] floatValue], [destinationArray[1] floatValue]);
            MKPlacemark *destinationPlaceMark = [[MKPlacemark alloc]initWithCoordinate:destinationPoint addressDictionary:nil];
            MKMapItem *destinationItem = [[MKMapItem alloc]initWithPlacemark:destinationPlaceMark];
            trafficIncidentPoint.destination = destinationPlaceMark;
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^(void){
                [self.mapView addAnnotation:trafficIncidentPoint];
            }];
            
            MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
            request.source = sourceItem;
            request.destination = destinationItem;
            request.requestsAlternateRoutes = true;
            request.transportType = MKDirectionsTransportTypeAutomobile;
        
            NSDictionary *params = @{@"request":request, @"severity":[NSNumber numberWithInt:trafficIncidentPoint.severity]};
            NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(plotTrafficRouteThread:) object:params];
            [queue addOperation:operation];
        }else {
            z++;
        }
        i++;
        if (i == 3) {
            break;
        }
    }
}

- (void)plotTrafficOnMap:(MKRoute *)trafficIncRoute {
    [self.mapView addOverlay:trafficIncRoute.polyline];
    if (self.mapView.overlays.count == 1) {
        [self.mapView setVisibleMapRect:trafficIncRoute.polyline.boundingMapRect edgePadding:UIEdgeInsetsMake(2.0, 2.0, 2.0, 2.0) animated:false];
    }else{
        MKMapRect newRouteBound = MKMapRectUnion(self.mapView.visibleMapRect, trafficIncRoute.polyline.boundingMapRect);
        [self.mapView setVisibleMapRect:newRouteBound edgePadding:UIEdgeInsetsMake(2.0, 2.0, 2.0, 2.0) animated:false];
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
                [self plotTrafficRoute:trafficIncidents];
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
