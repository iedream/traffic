//
//  GetTrafficViewController.h
//  traffic2
//
//  Created by Catherine Zhao on 2016-09-17.
//  Copyright © 2016 Catherine. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    APPLE_MAP,
    BING_MAP,
} MapType;

@interface GetTrafficViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *startTextField;
@property (weak, nonatomic) IBOutlet UITextField *endTextField;
@property (strong, nonatomic) NSString *currentLocationAddress;
@property (strong, nonatomic) NSString *endPointAddress;
@property (weak, nonatomic) IBOutlet UISegmentedControl *mapTypeSegment;


@end
