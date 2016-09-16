//
//  TrafficRouteViewController.m
//  traffic2
//
//  Created by Catherine Zhao on 2016-09-15.
//  Copyright © 2016 Catherine. All rights reserved.
//

#import "TrafficRouteViewController.h"
#import "MyAnnotation.h"

@interface TrafficRouteViewController ()

@end

@implementation TrafficRouteViewController

- (void)initWithTraficInfoDic:(NSDictionary*)dict {
    [self.severityTextField setText:[self convertSeverityCode:[dict[@"severity"]intValue]]];
    [self.typeTextField setText:[self convertTypeCode:[dict[@"type"]intValue]]];
    [self.roadClosedTextField setText:[self convertRoadClosed:dict[@"roadClosed"]]];
    [self.startTimeTextField setText:dict[@"startTime"]];
    [self.endTimeTextField setText:dict[@"endTime"]];
    
    [self.startLocationTextField setText:dict[@"startLocation"]];
    
    if (dict[@"endLocation"]) {
        [self.endLocationTextField setText:dict[@"endLocation"]];
    }else {
        [self.endLocationTextField setText:@"No End Location Info"];
    }
    if (dict[@"description"]) {
        [self.descriptionTextView setText:dict[@"description"]];
    }else {
        [self.descriptionTextView setText:@"No Traffic Description Available"];
    }
    
    if (dict[@"detour"]) {
        [self.detourTextField setText:dict[@"detour"]];
    }else {
        [self.detourTextField setText:@"No Traffic Detour Info Available"];
    }
    
    if (dict[@"lane"]) {
        [self.laneTextField setText:dict[@"lane"]];
    }else {
        [self.laneTextField setText:@"No Traffic Lane Info Available"];
    }
    
    if (dict[@"congestion"]) {
        [self.congestionTextField setText:dict[@"congestion"]];
    }else {
        [self.congestionTextField setText:@"No Traffic Congestion Info Available"];
    }
    
}

- (NSString*)convertRoadClosed:(NSString*)roadClosed {
    return [NSString stringWithFormat:@" %s", [roadClosed boolValue]? "true" : "false"];
}

- (NSString *)convertSeverityCode:(SEVERITY)severity {
    switch (severity) {
        case 1:
            return @"Low Impact";
            break;
        case 2:
            return @"Minor Impact";
            break;
        case 3:
            return @"Moderate Impact";
            break;
        case 4:
            return @"Serious Impact";
            break;
        default:
            return @"No Traffic Severity Info Available";
            break;
    }
}

- (NSString*)convertTypeCode:(TRAFFIC_TYPE)trafficType {
    switch (trafficType) {
        case 1:
            return @"Accident";
            break;
        case 2:
            return @"Congestion";
            break;
        case 3:
            return @"Disabled Vehicle";
            break;
        case 4:
            return @"Mass Transit";
            break;
        case 5:
            return @"Miscellaneous";
            break;
        case 6:
            return @"Other News";
            break;
        case 7:
            return @"Planned Event";
            break;
        case 8:
            return @"Road Hazard";
            break;
        case 9:
            return @"Construction";
            break;
        case 10:
            return @"Alert";
            break;
        case 11:
            return @"Weather";
            break;
        default:
            return @"No Traffic Type Info Available";
            break;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
