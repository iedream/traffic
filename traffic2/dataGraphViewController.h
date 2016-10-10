//
//  dataGraphViewController.h
//  traffic2
//
//  Created by Catherine Zhao on 2016-10-06.
//  Copyright © 2016 Catherine. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CorePlot/ios/CorePlot.h>

typedef enum {
    MINUTE,
    HOUR,
    DAY
}TimeCase;

@interface dataGraphViewController : UIViewController <CPTBarPlotDataSource, CPTBarPlotDelegate>
@property (strong, nonatomic) IBOutlet CPTGraphHostingView *hostGraphView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentControl;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (nonatomic, strong) NSArray *dataSource;
@property (nonatomic, strong) NSDictionary *allDataDic;
@property (nonatomic) TimeCase currentCase;
@property (nonatomic, strong) CPTPlotSpaceAnnotation *currentAnnotation;

- (void)setDataForGraph:(NSString *)routeName;

@end
