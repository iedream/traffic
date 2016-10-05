//
//  WeekDayTableViewCell.h
//  traffic2
//
//  Created by Catherine Zhao on 2016-10-03.
//  Copyright © 2016 Catherine. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WeekDayTableViewCell : UITableViewCell

@property (nonatomic, strong) UIImageView *checkView;
@property (nonatomic, strong) UILabel *textView;
@property (nonatomic) BOOL isChecked;

- (BOOL)didPressedOnCell;
@end
