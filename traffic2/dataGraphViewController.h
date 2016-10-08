//
//  dataGraphViewController.h
//  traffic2
//
//  Created by Catherine Zhao on 2016-10-06.
//  Copyright © 2016 Catherine. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CorePlot/ios/CorePlot.h>

@interface dataGraphViewController : UIViewController <CPTBarPlotDataSource, CPTBarPlotDelegate>
@property (strong, nonatomic) IBOutlet CPTGraphHostingView *hostGraphView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentControl;
@property (nonatomic, strong) NSArray *dataSource;
@property (nonatomic, strong) NSDictionary *allDataDic;

- (void)setDataForGraph:(NSString *)routeName;

@end