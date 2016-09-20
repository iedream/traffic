//
//  AddressDetailViewController.h
//  traffic2
//
//  Created by Catherine Zhao on 2016-09-07.
//  Copyright © 2016 Catherine. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FirstViewController.h"
#import "GetTrafficViewController.h"

@interface AddressDetailViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextView *textView;

@property (nonatomic, assign) CLLocationCoordinate2D addressPoint;
@property (nonatomic, strong) NSString *addressString;
@property (nonatomic, strong) NSString *currentLocationString;
@property (nonatomic, retain) FirstViewController *mainViewController;

@end
