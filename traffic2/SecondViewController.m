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
    // Dispose of any resources that can be recreated.
}

-(NSMutableDictionary*)addWithAppleDirection:(ApplePolyLine*)route{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
    [dict setValue:[NSNumber numberWithDouble:route.distance] forKey:@"distance"];
    [dict setValue:[NSNumber numberWithInt:route.trafficTravelTime] forKey:@"expectedTime"];
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
