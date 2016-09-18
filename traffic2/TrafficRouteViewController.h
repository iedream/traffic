//
//  TrafficRouteViewController.h
//  traffic2
//
//  Created by Catherine Zhao on 2016-09-15.
//  Copyright © 2016 Catherine. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TrafficRouteViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *severityTextField;
@property (weak, nonatomic) IBOutlet UITextField *typeTextField;
@property (weak, nonatomic) IBOutlet UITextField *roadClosedTextField;
@property (weak, nonatomic) IBOutlet UITextField *startTimeTextField;
@property (weak, nonatomic) IBOutlet UITextField *endTimeTextField;

@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (strong, nonatomic) UITextView *descriptionTextView;
@property (weak, nonatomic) IBOutlet UILabel *startLocationLabel;
@property (strong, nonatomic) UITextView *startLocationTextView;
@property (weak, nonatomic) IBOutlet UILabel *endLocationLabel;
@property (strong, nonatomic) UITextView *endLocationTextView;
@property (weak, nonatomic) IBOutlet UILabel *detourLabel;
@property (strong, nonatomic) UITextView *detourTextView;

@property (weak, nonatomic) IBOutlet UITextField *laneTextField;
@property (weak, nonatomic) IBOutlet UITextField *congestionTextField;

@property (strong, nonatomic) NSDictionary *infoDic;
@end
