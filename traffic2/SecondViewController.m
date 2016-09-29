//
//  SecondViewController.m
//  traffic2
//
//  Created by Catherine Zhao on 2016-09-01.
//  Copyright © 2016 Catherine. All rights reserved.
//

#import "SecondViewController.h"
#import <MapKit/MapKit.h>
#import "MyAnnotation.h"

@interface SecondViewController ()

@end

@implementation SecondViewController
static SecondViewController *sharedInstance = nil;
NSString *path;
NSMutableArray *routeArr;

- (void)viewDidLoad {
    [super viewDidLoad];
    NSDate *date = [NSDate date];
    NSDate *add90Min = [date dateByAddingTimeInterval:(60)];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)initWithPlist {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [[paths firstObject] stringByAppendingString: @"RouteDirectory"];
    path = [path stringByAppendingPathComponent:@"route.plist"];
    
    routeArr = [[NSMutableArray alloc]init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    //[self scheduleNotificationWithTime:[NSDate date]];
    // Dispose of any resources that can be recreated.
}

-(NSMutableDictionary*)addWithAppleDirection:(ApplePolyLine*)route{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
    [dict setValue:[NSNumber numberWithDouble:route.distance] forKey:@"distance"];
    [dict setValue:[NSNumber numberWithInt:route.trafficTravelTime] forKey:@"expectedTime"];
    [dict setValue:route.name forKey:@"name"];
    NSDictionary *startDic = @{@"latitude":[NSNumber numberWithDouble:route.source.latitude], @"longitude":[NSNumber numberWithDouble:route.source.longitude]};
    [dict setValue:startDic forKey:@"source"];
    NSDictionary *endDic = @{@"latitude":[NSNumber numberWithDouble:route.dest.latitude], @"longitude":[NSNumber numberWithDouble:route.dest.longitude]};
    [dict setValue:endDic forKey:@"end"];
    [routeArr addObject:dict];
    return dict;
}

-(NSMutableDictionary*)addWithBingDirection:(BingPolyLine*)route{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
    [dict setValue:[NSNumber numberWithDouble:route.distance] forKey:@"distance"];
    [dict setValue:[NSNumber numberWithInt:route.trafficTravelTime] forKey:@"expectedTime"];
    [dict setValue:[NSNumber numberWithDouble:route.travelTime] forKey:@"actTime"];
    NSDictionary *startDic = @{@"latitude":[NSNumber numberWithDouble:route.source.latitude], @"longitude":[NSNumber numberWithDouble:route.source.longitude]};
    [dict setValue:startDic forKey:@"source"];
    NSDictionary *endDic = @{@"latitude":[NSNumber numberWithDouble:route.dest.latitude], @"longitude":[NSNumber numberWithDouble:route.dest.longitude]};
    [dict setValue:endDic forKey:@"end"];
    [routeArr addObject:dict];
    return dict;
}

-(void)scheduleNotificationWithTime:(NSDate*)date polyLine:(ApplePolyLine *)polyLine{
    UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                    UIUserNotificationTypeBadge |
                                                    UIUserNotificationTypeSound);
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                                                             categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    [[UIApplication sharedApplication] registerForRemoteNotifications];
    
    UILocalNotification *localNotification = [[UILocalNotification alloc]init];
    localNotification.timeZone = [NSTimeZone localTimeZone];
    localNotification.fireDate = date;
    localNotification.alertTitle = @"before";
    localNotification.alertBody = @"init";
    localNotification.alertAction = @"loadTrafficTime";
    localNotification.userInfo = [self addWithAppleDirection:polyLine];
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}

- (void)getTrafficTimeWithAppleMap:(NSDictionary*)userInfo completionHandler:(void(^)(double))completionBlock {
    double sourceLatitude = [[[userInfo valueForKey:@"source"] valueForKey:@"latitude"] doubleValue];
    double sourceLongitude = [[[userInfo valueForKey:@"source"] valueForKey:@"longitude"] doubleValue];
    double endLatitude = [[[userInfo valueForKey:@"end"] valueForKey:@"latitude"] doubleValue];
    double endLongitude = [[[userInfo valueForKey:@"end"] valueForKey:@"longitude"] doubleValue];
    CLLocationCoordinate2D sourcePoint = CLLocationCoordinate2DMake(sourceLatitude, sourceLongitude);
    CLLocationCoordinate2D endPoint = CLLocationCoordinate2DMake(endLatitude, endLongitude);
    MKPlacemark *sourcePlaceMark = [[MKPlacemark alloc] initWithCoordinate:sourcePoint addressDictionary:nil];
    MKPlacemark *endPlaceMark = [[MKPlacemark alloc] initWithCoordinate:endPoint addressDictionary:nil];
    MKMapItem *startItem = [[MKMapItem alloc]initWithPlacemark:sourcePlaceMark];
    MKMapItem *endItem = [[MKMapItem alloc]initWithPlacemark:endPlaceMark];
    
        MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
        request.source = startItem;
        request.destination = endItem;
        request.requestsAlternateRoutes = true;
        request.transportType = MKDirectionsTransportTypeAutomobile;
    [self getAppleDirectionWithRequest:request name:userInfo[@"name"] completionBlock:^(double trafficTime) {
        completionBlock(trafficTime);
    }];
}

-(void)getAppleDirectionWithRequest:(MKDirectionsRequest*)request name:(NSString*)name completionBlock:(void(^)(double))completionBlock {
    MKDirections *directions = [[MKDirections alloc] initWithRequest:request];
    [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *err){
        if (!err) {
            BOOL returnVar = false;
            for(MKRoute *route in response.routes) {
                if ([route.name isEqualToString: name]) {
                    int time = route.expectedTravelTime/60;
                    returnVar = true;
                    completionBlock(time);
                    break;
                }
            }
            if (!returnVar) {
                [self getAppleDirectionWithRequest:request name:name completionBlock:completionBlock];
            }
        };
    }];
}

-(void)readFromPlist {
    if ([[NSFileManager defaultManager]fileExistsAtPath:path]) {
        NSData *data = [[NSData alloc] initWithContentsOfFile:path];
        routeArr = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
}

-(void)writeToPlist {
    [routeArr writeToFile:path atomically:NO];
}

+(SecondViewController*)sharedInstance {
    if (!sharedInstance) {
        sharedInstance = [[self alloc]init];
    }
    return sharedInstance;
}

@end
