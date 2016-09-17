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

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    if (self.infoDic) {
        
        [self.severityTextField setText:[self convertSeverityCode:[self.infoDic[@"severity"]intValue]]];
        [self setTextFieldProperties:self.severityTextField];
        
        [self.typeTextField setText:[self convertTypeCode:[self.infoDic[@"type"]intValue]]];
        [self setTextFieldProperties:self.typeTextField];
        
        [self.roadClosedTextField setText:[self convertRoadClosed:self.infoDic[@"roadClosed"]]];
        [self setTextFieldProperties:self.roadClosedTextField];
        
        [self.startTimeTextField setText:[self convertTime:self.infoDic[@"startTime"]]];
        [self setTextFieldProperties:self.startTimeTextField];
        
        [self.endTimeTextField setText:[self convertTime:self.infoDic[@"endTime"]]];
        [self setTextFieldProperties:self.endTimeTextField];
        
        [self.startLocationTextField setText:self.infoDic[@"startLocation"]];
        [self setTextFieldProperties:self.startLocationTextField];
        
        if (self.infoDic[@"endLocation"]) {
            [self.endLocationTextField setText:self.infoDic[@"endLocation"]];
        }else {
            [self.endLocationTextField setText:@"No End Location Info"];
        }
        [self setTextFieldProperties:self.endLocationTextField];
        
        if (self.infoDic[@"description"]) {
            [self.descriptionTextView setText:self.infoDic[@"description"]];
        }else {
            [self.descriptionTextView setText:@"No Traffic Description Available"];
        }
        [self setTextViewProperties:self.descriptionTextView];
        
        if (self.infoDic[@"detour"]) {
            [self.detourTextView setText:self.infoDic[@"detour"]];
        }else {
            [self.detourTextView setText:@"No Traffic Detour Info Available"];
        }
        [self setTextViewProperties:self.detourTextView];
        
        if (self.infoDic[@"lane"]) {
            [self.laneTextField setText:self.infoDic[@"lane"]];
        }else {
            [self.laneTextField setText:@"No Traffic Lane Info Available"];
        }
        [self setTextFieldProperties:self.laneTextField];
        
        if (self.infoDic[@"congestion"]) {
            [self.congestionTextField setText:self.infoDic[@"congestion"]];
        }else {
            [self.congestionTextField setText:@"No Traffic Congestion Info Available"];
        }
        [self setTextFieldProperties:self.congestionTextField];
    }
    
}

-(void)setTextFieldProperties:(UITextField*)textField {
    [textField setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    [textField setContentHuggingPriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    textField.userInteractionEnabled = false;
}



-(void)setTextViewProperties:(UITextView*)textView {
    [textView setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    [textView setContentHuggingPriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
}

- (NSString *)convertTime:(NSDate *)date {
    NSString *dateString = [NSDateFormatter localizedStringFromDate:[NSDate date]
                                                          dateStyle:NSDateFormatterMediumStyle
                                                          timeStyle:NSDateFormatterMediumStyle];
    return dateString;
}

- (NSString *)convertRoadClosed:(NSString*)roadClosed {
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

- (NSString *)convertTypeCode:(TRAFFIC_TYPE)trafficType {
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

