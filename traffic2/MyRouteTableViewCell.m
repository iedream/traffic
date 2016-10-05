//
//  MyRouteTableViewCell.m
//  traffic2
//
//  Created by Catherine Zhao on 2016-10-04.
//  Copyright © 2016 Catherine. All rights reserved.
//

#import "MyRouteTableViewCell.h"

@implementation MyRouteTableViewCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
    
    self.sourceLabel = [[UILabel alloc]init];
    self.sourceLabel.adjustsFontSizeToFitWidth = YES;
    [self addSubview:self.sourceLabel];
    
    self.destLabel = [[UILabel alloc]init];
    self.destLabel.adjustsFontSizeToFitWidth = YES;
    [self addSubview:self.destLabel];
    
    self.titleLabel = [[UILabel alloc]init];
    self.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.titleLabel];
    
    self.separatorInset = UIEdgeInsetsZero;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    CGRect frame = self.bounds;
    
    CGFloat separatorLine = frame.size.height * 0.6;
    CGFloat halfWidth = frame.size.width *0.4;
    
    CGRect sourceFrame = CGRectMake(10, separatorLine, halfWidth, frame.size.height - separatorLine);
    self.sourceLabel.frame = sourceFrame;
    
    CGRect destFrame = CGRectMake(frame.size.width-halfWidth, separatorLine, halfWidth, frame.size.height - separatorLine);
    self.destLabel.frame = destFrame;
    
    CGRect titleFrame = CGRectMake(10, 0, frame.size.width-10, separatorLine);
    self.titleLabel.frame = titleFrame;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
