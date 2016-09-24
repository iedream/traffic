//
//  DirectionViewController.h
//  traffic2
//
//  Created by Catherine Zhao on 2016-09-22.
//  Copyright © 2016 Catherine. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GetTrafficViewController.h"
#import <MapKit/MapKit.h>

@interface DirectionViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *directionTableView;
@property (nonatomic, strong) NSArray *directionDataSource;
@property (nonatomic, assign) MapType mapType;
@property (nonatomic, strong) MKPolyline *polyLine;

@property (weak, nonatomic) IBOutlet UILabel *trafficTravelTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *travelTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *congestionLabel;

@property (weak, nonatomic) IBOutlet UITextField *trafficTravelTimeText;
@property (weak, nonatomic) IBOutlet UITextField *distanceText;
@property (weak, nonatomic) IBOutlet UITextField *travelTimeText;
@property (weak, nonatomic) IBOutlet UITextField *congestionText;

@end
