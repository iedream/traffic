//
//  WeekDayTableViewCell.m
//  traffic2
//
//  Created by Catherine Zhao on 2016-10-03.
//  Copyright © 2016 Catherine. All rights reserved.
//

#import "WeekDayTableViewCell.h"

@implementation WeekDayTableViewCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
    
    self.checkView = [[UIImageView alloc]init];
    self.checkView.image = [UIImage imageNamed:@"checkMark.png"];
    self.checkView.contentMode = UIViewContentModeScaleAspectFit;
    self.checkView.hidden = YES;
    [self addSubview:self.checkView];
    
    self.textView = [[UILabel alloc]init];
    self.textView.adjustsFontSizeToFitWidth = YES;
    [self addSubview:self.textView];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    CGRect frame = self.bounds;
    self.separatorInset = UIEdgeInsetsZero;
    
    CGRect imageframe = CGRectMake(0, 5, 30, frame.size.height-10);
    self.checkView.frame = imageframe;
    
    CGRect textframe = CGRectMake(CGRectGetMaxX(imageframe) + 10, 0, frame.size.width - CGRectGetMaxX(imageframe) - 10, frame.size.height);
    self.textView.frame = textframe;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.checkView.hidden = YES;
}

- (BOOL)didPressedOnCell {
    if (self.isChecked) {
        self.checkView.hidden = YES;
        self.isChecked = NO;
    } else {
        self.checkView.hidden = NO;
        self.isChecked = YES;
    }
    return self.isChecked;
}

@end
