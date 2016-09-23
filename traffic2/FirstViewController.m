//
//  FirstViewController.m
//  traffic2
//
//  Created by Catherine Zhao on 2016-09-01.
//  Copyright © 2016 Catherine. All rights reserved.
//
#import "FirstViewController.h"
#import "AddressDetailViewController.h"
#import "DirectionViewController.h"


@interface FirstViewController ()
@property (nonatomic, strong)CLLocationManager *locationManager;
@property (weak, nonatomic) IBOutlet UITextField *searchText;
@property (nonatomic, assign)CLLocationCoordinate2D oldCurrentLocationValue;
@property (nonatomic, assign)CLLocationCoordinate2D currentPoint;
@end


const NSString *bingMapKey = @"ArlTvq-7ghxO_UPCB12CJ73UldCOmuA5DQF9C7ryWi1rmRlhQYhgBKOncFa4iXz2";
NSLock *allPointSetLock;
const NSString *TapPoint = @"TapPoint";
const NSString *SearchPoint = @"SearchPoint";
const NSString *TrafficPoint = @"TrafficPoint";
const long tapArea = 20;
NSOperationQueue *queue;
NSString *sourceAddress;
NSString *destinationAddress;

UITapGestureRecognizer *labelTap;
NSMutableDictionary *labelDic;

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
    
    self.mapView.delegate = self;
    
    allPointSetLock = [[NSLock alloc]init];
    queue = [[NSOperationQueue alloc]init];
    queue.maxConcurrentOperationCount = 5;
    
    UITapGestureRecognizer *overlayTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleOverlayTap:)];
    [overlayTap setDelegate:self];
    [self.mapView addGestureRecognizer:overlayTap];
    
    labelTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleLabelTap:)];
    [labelTap setDelegate:self];
    labelDic = [[NSMutableDictionary alloc]init];

    self.navigationController.modalPresentationStyle = UIModalPresentationCurrentContext;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveTrafficNotification:) name:@"GetTrafficData" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveDirectionNotification:) name:@"GetDirectionData" object:nil];
    
}

- (void) handleLabelTap:(UIGestureRecognizer *)tap {
    if ([tap.view isKindOfClass:[UILabel class]]) {
        UILabel *label = (UILabel *)tap.view;
        
        if ([labelDic[label.accessibilityIdentifier] isKindOfClass:[BingPolyLine class]]) {
            BingPolyLine *polyline = (BingPolyLine *)labelDic[label.accessibilityIdentifier];
            [label removeGestureRecognizer:labelTap];
            
            DirectionViewController *directionViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"DirectionViewController"];
            directionViewController.directionDataSource = polyline.directionDataSource;
            [self addChildViewController:directionViewController];
            [self.view addSubview:directionViewController.view];
        }else if ([labelDic[label.accessibilityIdentifier] isKindOfClass:[ApplePolyLine class]]) {
            ApplePolyLine *polyline = (ApplePolyLine *)labelDic[label.accessibilityIdentifier];
            [label removeGestureRecognizer:labelTap];
            
            DirectionViewController *directionViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"DirectionViewController"];
            directionViewController.directionDataSource = polyline.directionDataSource;
            [self addChildViewController:directionViewController];
            [self.view addSubview:directionViewController.view];
        }
        
    }
}

- (void) handleOverlayTap:(UIGestureRecognizer*)tap {
    NSArray *subviews = [self.mapView.subviews copy];
    for(int i = 0; i < subviews.count; i++){
        if ([subviews[i] isKindOfClass:[UILabel class]]) {
            UILabel *label = (UILabel*)subviews[i];
            [label removeFromSuperview];
        }
    }
    
    CGPoint tapPoint = [tap locationInView:self.mapView];
    CLLocationCoordinate2D tapCoord = [self.mapView convertPoint:tapPoint toCoordinateFromView:self.mapView];
    MKMapPoint tapMapPoint = MKMapPointForCoordinate(tapCoord);
    for (id<MKOverlay> overlay in self.mapView.overlays) {
        if ([overlay isKindOfClass:[MyPolyLine class]]) {
            MyPolyLine *polygon = (MyPolyLine*)overlay;
            if ([self distanceOfPoint:tapMapPoint toPoly:overlay] < 50) {
                TrafficRouteViewController *trafficRouteViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"TrafficRouteViewController"];
                [self convertlocationIntoString:polygon.source completionHandler:^(NSString *address) {
                    sourceAddress = address;
                    [self convertlocationIntoString:polygon.destination completionHandler:^(NSString *address) {
                        destinationAddress = address;
                        NSDictionary *trafficDic = [[NSDictionary alloc] initWithObjectsAndKeys:
                                                    [NSNumber numberWithInt:polygon.severity], @"severity",
                                                    [NSNumber numberWithInt:polygon.type], @"type",
                                                    [NSNumber numberWithBool:polygon.roadClosed], @"roadClosed",
                                                    polygon.startTime, @"startTime",
                                                    polygon.endTime, @"endTime",
                                                    sourceAddress, @"source",
                                                    destinationAddress, @"destination",
                                                    polygon.info, @"description",
                                                    polygon.detour, @"detour",
                                                    polygon.lane, @"lane",
                                                    polygon.congestion, @"congestion", nil];
                        trafficRouteViewController.infoDic = trafficDic;
                        [self addChildViewController:trafficRouteViewController];
                        [self.view addSubview:trafficRouteViewController.view];
                    }];
                }];
            }
        } else if ([overlay isKindOfClass:[BingPolyLine class]]) {
            BingPolyLine *pointOverlay = (BingPolyLine*)overlay;
            if ([self distanceOfPoint:tapMapPoint toPoly:overlay] < 50){
                MKMapPoint middlePoint = pointOverlay.points[pointOverlay.pointCount/2];
                CLLocationCoordinate2D middleCoor = MKCoordinateForMapPoint(middlePoint);
                CGPoint actualPoint = [self.mapView convertCoordinate:middleCoor toPointToView:self.mapView];
                UILabel *timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(actualPoint.x-20, actualPoint.y-10, 40, 20)];
                [timeLabel setBackgroundColor:[UIColor lightGrayColor]];
                
                NSString *key = [NSString stringWithFormat:@"%i", arc4random_uniform(100000)];
                while (labelDic[key]) {
                    key = [NSString stringWithFormat:@"%i", arc4random_uniform(100000)];
                }
                labelDic[key] = pointOverlay;
                [timeLabel setAccessibilityIdentifier:key];
                
                [timeLabel setAlpha:0.4];
                [timeLabel setText: [NSString stringWithFormat:@"%imin", pointOverlay.trafficTravelTime]];
                timeLabel.adjustsFontSizeToFitWidth = YES;
                [timeLabel setUserInteractionEnabled:YES];
                [timeLabel addGestureRecognizer:labelTap];
                [self.mapView addSubview:timeLabel];

            }
        } else if ([overlay isKindOfClass:[ApplePolyLine class]]) {
            MKPolyline *pointOverlay = (MKPolyline*)overlay;
            if ([self distanceOfPoint:tapMapPoint toPoly:overlay] < 50){
                MKMapPoint middlePoint = pointOverlay.points[pointOverlay.pointCount/2];
                CLLocationCoordinate2D middleCoor = MKCoordinateForMapPoint(middlePoint);
                CGPoint actualPoint = [self.mapView convertCoordinate:middleCoor toPointToView:self.mapView];
                UILabel *timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(actualPoint.x-20, actualPoint.y-10, 40, 20)];
                
                NSString *key = [NSString stringWithFormat:@"%i", arc4random_uniform(100000)];
                while (labelDic[key]) {
                    key = [NSString stringWithFormat:@"%i", arc4random_uniform(100000)];
                }
                labelDic[key] = pointOverlay;
                [timeLabel setAccessibilityIdentifier:key];

                [timeLabel setBackgroundColor:[UIColor lightGrayColor]];
                [timeLabel setAlpha:0.4];
                [timeLabel setText:pointOverlay.title];
                timeLabel.adjustsFontSizeToFitWidth = YES;
                [timeLabel setUserInteractionEnabled:YES];
                [timeLabel addGestureRecognizer:labelTap];
                [self.mapView addSubview:timeLabel];
            }
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(locations.firstObject.coordinate, 800, 800);
    self.currentPoint = locations.firstObject.coordinate;
    [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"Error: %@", error);
}

- (void) handleLongPress:(UILongPressGestureRecognizer *)recognizer {
    CGPoint point = [recognizer locationInView:self.mapView];
    CLLocationCoordinate2D tapPoint = [self.mapView convertPoint:point toCoordinateFromView:self.view];
    
    MKPointAnnotation *resultPoint = [[MKPointAnnotation alloc]init];
    resultPoint.coordinate = tapPoint;
    
    [self convertlocationIntoString:tapPoint completionHandler:^(NSString *address){
        resultPoint.title = address;
        [self.mapView addAnnotation:resultPoint];
    }];
}

- (void)convertlocationIntoString:(CLLocationCoordinate2D)point completionHandler:(void(^)(NSString*))completionBlock {
    CLLocation *location = [[CLLocation alloc] initWithLatitude:point.latitude longitude:point.longitude];
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray* placemarks, NSError* error){
        if ([placemarks count] > 0) {
            CLPlacemark *placeMark = [placemarks firstObject];
            NSArray *address = placeMark.addressDictionary[@"FormattedAddressLines"];
            completionBlock([address componentsJoinedByString:@", "]);
        }else{
            completionBlock(nil);
        }
    }];
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    NSLog(@"hello");
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    MKPinAnnotationView *annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"annoView"];
    annotationView.canShowCallout = YES;
    
    if ([annotation isKindOfClass:[MKPointAnnotation class]]) {
        annotationView.pinTintColor = [UIColor blackColor];
        annotationView.enabled = YES;
    }else {
        annotationView.pinTintColor = [UIColor greenColor];
    }
    
    annotationView.rightCalloutAccessoryView =  [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    return annotationView;
}

- (UIImage *)imageFromColor:(UIColor *)color {
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control{
    AddressDetailViewController *addressDetailViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"AddressDetailViewController"];
    addressDetailViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    addressDetailViewController.addressString = [view.annotation title];
    addressDetailViewController.addressPoint = view.annotation.coordinate;
    addressDetailViewController.mainViewController = self;
    [self convertlocationIntoString:self.currentPoint completionHandler:^(NSString *address){
        addressDetailViewController.currentLocationString = address;
    }];
    [self addChildViewController:addressDetailViewController];
    [self.view addSubview:addressDetailViewController.view];
}

- (MKPolylineRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(nonnull id<MKOverlay>)overlay {
    MKPolylineRenderer *polyRenderer = [[MKPolylineRenderer alloc] initWithOverlay:overlay];
    if ([overlay isKindOfClass:[MyPolyLine class]]) {
        MyPolyLine *polyLine = (MyPolyLine*)overlay;
        switch (polyLine.severity) {
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
                polyRenderer.strokeColor = [[UIColor purpleColor] colorWithAlphaComponent:0.75];
                break;
        }
    }else {
        int count = [self countRouteCount];
        if (count == 1) {
            polyRenderer.strokeColor = [[UIColor greenColor] colorWithAlphaComponent:0.75];
        }else if (count == 2) {
            polyRenderer.strokeColor = [[UIColor purpleColor] colorWithAlphaComponent:0.75];
        }else if (count == 3) {
            polyRenderer.strokeColor = [[UIColor whiteColor] colorWithAlphaComponent:0.75];
        }else if (count == 4) {
            polyRenderer.strokeColor = [[UIColor grayColor] colorWithAlphaComponent:0.75];
        }
    }
    polyRenderer.lineWidth = 5;
    return polyRenderer;
}

- (int)countRouteCount {
    NSArray *overlays = self.mapView.overlays;
    int count = 0;
    for (int i = 0; i < overlays.count; i++) {
        if (![overlays[i] isKindOfClass:[MyPolyLine class]]) {
            count++;
        }
    }
    return count;
}

- (void)receiveTrafficNotification:(NSNotification *)notif {
    CLLocationCoordinate2D currentP = CLLocationCoordinate2DMake([notif.object[@"latitude"] doubleValue], [notif.object[@"longitude"] doubleValue]);
    NSArray *pointsArray = [self.mapView overlays];
    [self.mapView removeOverlays:pointsArray];
    [self downloadAccident:currentP];
}

- (void)plotOverlayOnMap:(MKPolyline*)polyline {
    [[NSOperationQueue mainQueue] addOperationWithBlock:^(void){
        [self.mapView addOverlay:polyline];
        //[self.mapView addOverlay:polyline level:MKOverlayLevelAboveRoads];
        [self.mapView setNeedsDisplay];
        if (self.mapView.overlays.count == 1) {
            [self.mapView setVisibleMapRect:polyline.boundingMapRect edgePadding:UIEdgeInsetsMake(2.0, 2.0, 2.0, 2.0) animated:false];
        }else{
            MKMapRect newRouteBound = MKMapRectUnion(self.mapView.visibleMapRect, polyline.boundingMapRect);
            [self.mapView setVisibleMapRect:newRouteBound edgePadding:UIEdgeInsetsMake(2.0, 2.0, 2.0, 2.0) animated:false];
        }
    }];
}

- (void)directionWithAppleMap:(MKPlacemark *)startPlaceMark endPlaceMark:(MKPlacemark *)endPlaceMark {
    MKMapItem *startItem = [[MKMapItem alloc]initWithPlacemark:startPlaceMark];
    MKMapItem *endItem = [[MKMapItem alloc]initWithPlacemark:endPlaceMark];
    MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
    request.source = startItem;
    request.destination = endItem;
    request.requestsAlternateRoutes = true;
    request.transportType = MKDirectionsTransportTypeAutomobile;
            
    MKDirections *directions = [[MKDirections alloc] initWithRequest:request];
    [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *err){
        if (!err) {
            for(MKRoute *route in response.routes) {
                int time = route.expectedTravelTime/60;
                
                CLLocationCoordinate2D *polyLineCoord = malloc(route.polyline.pointCount*sizeof(CLLocationCoordinate2D));
                [route.polyline getCoordinates:polyLineCoord range:NSMakeRange(0, route.polyline.pointCount)];
                ApplePolyLine *applePolyLine = [ApplePolyLine polylineWithCoordinates:polyLineCoord count:route.polyline.pointCount];
                
                [applePolyLine setTitle:[NSString stringWithFormat:@"%imin",time]];
                
                NSMutableArray *directionDataSource = [[NSMutableArray alloc]init];
                for (MKRouteStep *routeStep in route.steps) {
                    NSString *instruction = routeStep.instructions;
                    NSArray *array = @[instruction, [NSNumber numberWithDouble:routeStep.distance]];
                    [directionDataSource addObject:array];
                }
                applePolyLine.directionDataSource = directionDataSource;
            
                [self plotOverlayOnMap:applePolyLine];
            }
        };
    }];
}

- (void)directionWithBingMap:(MKPlacemark *)startPlaceMark endPlaceMark:(MKPlacemark *)endPlaceMark {
    NSString *url = [NSString stringWithFormat:@"http://dev.virtualearth.net/REST/v1/Routes/Driving?wp.1=%f,%f&wp.2=%f,%f&ra=routePath&maxSolns=2&key=%@",(float)startPlaceMark.coordinate.latitude, (float)startPlaceMark.coordinate.longitude, (float)endPlaceMark.coordinate.latitude, (float)endPlaceMark.coordinate.longitude, bingMapKey];
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
                NSDictionary *routeInfo = [[[[json valueForKey:@"resourceSets"] valueForKey:@"resources"] firstObject] firstObject];
                
                NSArray *allPoints = [[[routeInfo objectForKey:@"routePath"] objectForKey:@"line"] objectForKey:@"coordinates"];
                NSUInteger length = allPoints.count;
                MKMapPoint pathRouteArray[32];
                for (int i = 0; i < length; i++) {
                    NSArray *currentPoint = allPoints[i];
                    CLLocationCoordinate2D currentCoord = CLLocationCoordinate2DMake([currentPoint[0] floatValue], [currentPoint[1] floatValue]);
                    MKMapPoint mapPoint = MKMapPointForCoordinate(currentCoord);
                    pathRouteArray[i] = mapPoint;
                }
                BingPolyLine *polyLine = [BingPolyLine polylineWithPoints:pathRouteArray count:length];
                
                NSMutableArray *directionDataSource = [[NSMutableArray alloc]init];
                NSArray *routeLegs = [routeInfo objectForKey:@"routeLegs"];
                for (NSDictionary *routeLegDic in routeLegs) {
                    NSDictionary *subRouteDic = [routeLegDic objectForKey:@"itineraryItems"];
                    for (NSDictionary *directionDic in subRouteDic) {
                        NSString *direction = [[directionDic objectForKey:@"instruction"] objectForKey:@"text"];
                        int duration = [directionDic[@"travelDuration"] intValue];
                        double distance = [directionDic[@"travelDistance"] doubleValue]*1000;
                        [directionDataSource addObject:@[direction, [NSNumber numberWithDouble:distance], [NSNumber numberWithInt:duration]]];
                    }
                }
                polyLine.directionDataSource = [directionDataSource copy];
                
                if ([routeInfo[@"durationUnit"] isEqualToString:@"Second"]) {
                    int travelTime = [routeInfo[@"travelDuration"] intValue]/60;
                    int trafficTravelTime = [routeInfo[@"travelDurationTraffic"] intValue]/60;
                    polyLine.travelTime = travelTime;
                    polyLine.trafficTravelTime = trafficTravelTime;
                }
                
                if ([routeInfo[@"distanceUnit"] isEqualToString:@"Kilometer"]) {
                    polyLine.distance = [routeInfo[@"travelDistance"] intValue];
                }
                polyLine.congestion = routeInfo[@"trafficCongestion"];
                
                [self plotOverlayOnMap:polyLine];
            }
        }
    }];
    [task resume];

}

- (void)receiveDirectionNotification:(NSNotification *)notif{
    NSArray *pointsArray = [self.mapView overlays];
    [self.mapView removeOverlays:pointsArray];
    
    NSString *startString = notif.userInfo[@"start"];
    NSString *endString = notif.userInfo[@"end"];
    
    [self convertStringIntoLocation:startString completionHandler:^(MKPlacemark *startPlaceMark){
        [self convertStringIntoLocation:endString completionHandler:^(MKPlacemark *endPlaceMark){
            if ([notif.userInfo[@"mapType"] integerValue] == APPLE_MAP) {
                [self directionWithAppleMap:startPlaceMark endPlaceMark:endPlaceMark];
            }else {
                [self directionWithBingMap:startPlaceMark endPlaceMark:endPlaceMark];
            }
        }];
    }];

    
    //[self directionWithAppleMap:startString endString:endString];
}

- (IBAction)searchMethod:(id)sender {
    [self convertStringIntoLocation:self.searchText.text completionHandler:^(MKPlacemark *placeMark){
        if (placeMark) {
            [self.mapView addAnnotation:placeMark];
            MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(placeMark.coordinate, 800, 800);
            [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
        }
    }];
}

- (void)convertStringIntoLocation:(NSString *)string completionHandler:(void(^)(MKPlacemark *))completionBlock{
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    
    [geocoder geocodeAddressString:string completionHandler:^(NSArray* placemarks, NSError* error){
        for (CLPlacemark *placeMark in placemarks){
            MKPlacemark *realPlaceMark = [[MKPlacemark alloc]initWithPlacemark:placeMark];
            completionBlock(realPlaceMark);
        }
        completionBlock(nil);
    }];
}

//- (void)plotTrafficRouteThread:(NSDictionary *)params {

//    MKDirectionsRequest *directionRequest = params[@"request"];

//    int severity = [params[@"severity"] intValue];

//    [trafficIncidentLevelLock lock];

//    self.trafficIncidentLevel = severity;

//    MKDirections *directions = [[MKDirections alloc] initWithRequest:directionRequest];

//    [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *err){

//        if (!err) {

//            NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"distance" ascending:YES];

//            NSArray *sortedArray = [response.routes sortedArrayUsingDescriptors:@[sort]];

//            [self plotTrafficOnMap: [sortedArray firstObject]];

//        }

//    }];

//}

- (void)plotTrafficRoute:(NSArray *)trafficDic {
    NSMutableSet *pointSet = [[NSMutableSet alloc]init];
    for (NSDictionary *incidents in trafficDic) {
        if ([incidents objectForKey:@"toPoint"] && [incidents objectForKey:@"point"]) {
            NSDictionary *param = @{@"incidentDic":incidents, @"pointSet":pointSet};
            NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(plotTrafficRouteThread:) object:param];
            [queue addOperation:operation];
        }
    }
}

- (void)plotTrafficRouteThread:(NSDictionary *)incident {
    NSDictionary *incidentDic = [incident objectForKey:@"incidentDic"];
    NSMutableSet *allPoints = [incident objectForKey:@"pointSet"];
    BOOL pointExisted;
    
    NSArray *sourceArray = [[incidentDic objectForKey:@"point"] objectForKey:@"coordinates"];
    CLLocationCoordinate2D sourcePoint = CLLocationCoordinate2DMake([sourceArray[0] floatValue], [sourceArray[1] floatValue]);
    
    NSArray *destinationArray = [[incidentDic objectForKey:@"toPoint"] objectForKey:@"coordinates"];
    CLLocationCoordinate2D destinationPoint = CLLocationCoordinate2DMake([destinationArray[0] floatValue], [destinationArray[1] floatValue]);
    
    [allPointSetLock lock];
    pointExisted = [self pointExistAlready:allPoints coordinate:sourcePoint];
    if (pointExisted) {
        [allPointSetLock unlock];
        return;
    }
    pointExisted = [self pointExistAlready:allPoints coordinate:destinationPoint];
    if (pointExisted) {
        [allPointSetLock unlock];
        return;
    }
    [allPointSetLock unlock];
    
    CLLocationCoordinate2D trafficCoorArray[2];
    trafficCoorArray[0] = sourcePoint;
    trafficCoorArray[1] = destinationPoint;
    MyPolyLine *trafficLane = [MyPolyLine polylineWithCoordinates:trafficCoorArray count:2];
    trafficLane.source = sourcePoint;
    trafficLane.destination = destinationPoint;
    
    trafficLane.severity = [[incidentDic objectForKey:@"severity"] intValue];
    trafficLane.type = [[incidentDic objectForKey:@"type"] intValue];
    
    NSString *prefix = @"/Date(";
    NSString *suffic = @")/";
    NSString *startTimeJson = [incidentDic objectForKey:@"start"];
    if ([startTimeJson hasPrefix:prefix] && [startTimeJson hasSuffix:suffic]){
        startTimeJson = [startTimeJson substringWithRange:NSMakeRange([prefix length], [startTimeJson length]-[suffic length]-[prefix length])];
    }
    NSString *endTimeJson = [incidentDic objectForKey:@"end"];
    if ([endTimeJson hasPrefix:prefix] && [endTimeJson hasSuffix:suffic]) {
        endTimeJson = [endTimeJson substringWithRange:NSMakeRange([prefix length], [endTimeJson length]-[suffic length]-[prefix length])];
    }
    trafficLane.startTime = [NSDate dateWithTimeIntervalSince1970: [startTimeJson doubleValue]/1000.0];
    trafficLane.endTime = [NSDate dateWithTimeIntervalSince1970: [endTimeJson doubleValue]/1000.0];
    
    trafficLane.roadClosed = [[incidentDic objectForKey:@"roadClosed"] boolValue];
    trafficLane.info = [incidentDic objectForKey:@"description"];
    trafficLane.lane = [incidentDic objectForKey:@"lane"];
    
    [self plotOverlayOnMap:trafficLane];
}

- (BOOL)pointExistAlready:(NSMutableSet*)pointsSet coordinate:(CLLocationCoordinate2D)newPoint{
    NSValue *newPointValue = [NSValue valueWithBytes:&newPoint objCType:@encode(CLLocationCoordinate2D)];
    if ([pointsSet containsObject:newPointValue]) {
        return true;
    }else {
        [pointsSet addObject:newPointValue];
        return false;
    }
}

- (void)downloadRouteTraffic:(CLLocationCoordinate2D)source destination:(CLLocationCoordinate2D)destination completionHandler:(void(^)(int,int,NSArray*))completionBlock {
    NSString *url = [NSString stringWithFormat:@"http://dev.virtualearth.net/REST/v1/Routes/Driving?wp.1=%f,%f&wp.2=%f,%f&ra=routePath&key=%@",(float)source.latitude, (float)source.longitude, (float)destination.latitude, (float)destination.longitude, bingMapKey];
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
                NSDictionary *routeInfo = [[[[json valueForKey:@"resourceSets"] valueForKey:@"resources"] firstObject] firstObject];
                int travelTime = [routeInfo[@"travelDuration"] intValue]/60;
                int trafficTravelTime = [routeInfo[@"travelDurationTraffic"]intValue]/60;
                NSArray *allPoints = [[[routeInfo objectForKey:@"routePath"] objectForKey:@"line"] objectForKey:@"coordinates"];
                completionBlock(travelTime, trafficTravelTime, allPoints);
            }
        }
    }];
    [task resume];
}

- (void)downloadAccident:(CLLocationCoordinate2D )address{
    NSString *addressLine =  [NSString stringWithFormat:@"%f,%f,%f,%f", (int)address.latitude-0.5, (int)address.longitude-0.5, (int)address.latitude+0.5, (int)address.longitude+0.5];
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
            }
        }
    }];
    [task resume];
}


- (double)distanceOfPoint:(MKMapPoint)pt toPoly:(MKPolyline *)poly
{
    double distance = MAXFLOAT;
    for (int n = 0; n < poly.pointCount - 1; n++) {
        
        MKMapPoint ptA = poly.points[n];
        MKMapPoint ptB = poly.points[n + 1];
        
        double xDelta = ptB.x - ptA.x;
        double yDelta = ptB.y - ptA.y;
        
        if (xDelta == 0.0 && yDelta == 0.0) {
            
            // Points must not be equal
            continue;
        }
        
        double u = ((pt.x - ptA.x) * xDelta + (pt.y - ptA.y) * yDelta) / (xDelta * xDelta + yDelta * yDelta);
        MKMapPoint ptClosest;
        if (u < 0.0) {
            
            ptClosest = ptA;
        }
        else if (u > 1.0) {
            
            ptClosest = ptB;
        }
        else {
            
            ptClosest = MKMapPointMake(ptA.x + u * xDelta, ptA.y + u * yDelta);
        }
        
        distance = MIN(distance, MKMetersBetweenMapPoints(ptClosest, pt));
    }
    
    return distance;
}


/** Converts |px| to meters at location |pt| */
- (double)metersFromPixel:(NSUInteger)px atPoint:(CGPoint)pt
{
    CGPoint ptB = CGPointMake(pt.x + px, pt.y);
    
    CLLocationCoordinate2D coordA = [self.mapView convertPoint:pt toCoordinateFromView:self.mapView];
    CLLocationCoordinate2D coordB = [self.mapView convertPoint:ptB toCoordinateFromView:self.mapView];
    
    return MKMetersBetweenMapPoints(MKMapPointForCoordinate(coordA), MKMapPointForCoordinate(coordB));
}


-(void)traffic {
    
    //            MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
    
    //            request.source = sourceItem;
    
    //            request.destination = destinationItem;
    
    //            request.requestsAlternateRoutes = true;
    
    //            request.transportType = MKDirectionsTransportTypeAutomobile;
    
}



- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
    
}



@end