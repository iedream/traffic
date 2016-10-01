//
//  DirectionViewController.m
//  traffic2
//
//  Created by Catherine Zhao on 2016-09-22.
//  Copyright © 2016 Catherine. All rights reserved.
//

#import "DirectionViewController.h"
#import "MyAnnotation.h"
#import "SecondViewController.h"
#import "AddRouteWatchViewController.h"

@interface DirectionViewController ()

@end

@implementation DirectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.directionTableView.dataSource = self;
    self.directionTableView.delegate = self;
    
    if (self.mapType == BING_MAP) {
        
        BingPolyLine *bingPolyline = (BingPolyLine*)self.polyLine;
        
        [self.travelTimeLabel setHidden:NO];
        [self.travelTimeText setHidden:NO];
        [self.congestionLabel setHidden:NO];
        [self.congestionText setHidden:NO];
        
        [self.trafficTravelTimeText setText:[NSString stringWithFormat:@"%imin", bingPolyline.trafficTravelTime]];
        [self.travelTimeText setText:[NSString stringWithFormat:@"%imin", bingPolyline.travelTime]];
        
        [self.distanceText setText:[NSString stringWithFormat:@"%ikm", bingPolyline.distance]];
        
        [self.congestionText setText:bingPolyline.congestion];
        
    }else if (self.mapType == APPLE_MAP) {
        
        ApplePolyLine *applePolyline = (ApplePolyLine*)self.polyLine;
        
        [self.travelTimeLabel setHidden:YES];
        [self.travelTimeText setHidden:YES];
        [self.congestionLabel setHidden:YES];
        [self.congestionText setHidden:YES];
        
        if (applePolyline.distance > 1000) {
            double distanceInKilometer = applePolyline.distance/1000.0;
            [self.distanceText setText:[NSString stringWithFormat:@"%.2fkm", distanceInKilometer]];
        }else {
            [self.distanceText setText:[NSString stringWithFormat:@"%im", applePolyline.distance]];
        }
        
        [self.trafficTravelTimeText setText:[NSString stringWithFormat:@"%imin", applePolyline.trafficTravelTime]];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.directionDataSource count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"directionCell"];
    NSArray *info = self.directionDataSource[indexPath.row];
    if (info.count == 3) {
        int distance = (int)[info[1] doubleValue];
        int time = [info[2] intValue]/60;
        if (distance > 1000) {
            [cell.textLabel setText:[NSString stringWithFormat:@"%@(%.2fkm, %imin)",info[0], distance/1000.0, time]];
        }else {
            [cell.textLabel setText:[NSString stringWithFormat:@"%@(%im, %imin)",info[0], distance, time]];
        }
    }else {
        int distance = (int)[info[1] doubleValue];
        if (distance > 1000) {
            [cell.textLabel setText:[NSString stringWithFormat:@"%@(%.2fkm)",info[0], distance/1000.0]];
        }else {
            [cell.textLabel setText:[NSString stringWithFormat:@"%@(%im)",info[0], distance]];
        }
    }
    cell.textLabel.numberOfLines = 4;
    return cell;
}
- (IBAction)back:(id)sender {
    [self removeFromParentViewController];
    [self.view removeFromSuperview];
}
- (IBAction)trafficOnRoute:(id)sender {
    NSDictionary *dict = [[NSDictionary alloc]initWithObjectsAndKeys:
                          self.polyLine, @"polyLine",
                          nil];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"GetOnRouteTrafficData" object:nil userInfo:dict];
}

- (IBAction)trafficAroundRoute:(id)sender {
    NSDictionary *dict = [[NSDictionary alloc]initWithObjectsAndKeys:
                          self.polyLine, @"polyLine",
                          nil];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"GetAroundRouteTrafficData" object:nil userInfo:dict];
}

- (IBAction)addRoute:(id)sender {
//    NSMutableDictionary *dict;
//    if ([self.polyLine isKindOfClass:[ApplePolyLine class]]) {
//        dict = [[SecondViewController sharedInstance] addWithAppleDirection:(ApplePolyLine*)self.polyLine];
//    }else if ([self.polyLine isKindOfClass:[BingPolyLine class]]) {
//        dict = [[SecondViewController sharedInstance] addWithBingDirection:(BingPolyLine*)self.polyLine];
//    }
    NSDate *date = [NSDate date];
    NSTimeInterval secondsInEightHours = 3;
    NSDate *add90Min = [NSDate dateWithTimeIntervalSinceNow:5];
    [[SecondViewController sharedInstance] scheduleRemoteNotification:(ApplePolyLine*)self.polyLine];
     AddRouteWatchViewController *getTrafficViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"AddRouteWatchViewController"];
    [self addChildViewController:getTrafficViewController];
    [self.view addSubview:getTrafficViewController.view];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
