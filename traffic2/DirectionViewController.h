//
//  DirectionViewController.h
//  traffic2
//
//  Created by Catherine Zhao on 2016-09-22.
//  Copyright © 2016 Catherine. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DirectionViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *directionTableView;
@property (nonatomic, strong) NSArray *directionDataSource;

@end
