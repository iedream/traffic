//
//  dataGraphViewController.h
//  traffic2
//
//  Created by Catherine Zhao on 2016-10-06.
//  Copyright © 2016 Catherine. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CorePlot/ios/CorePlot.h>

@interface dataGraphViewController : UIViewController <CPTPlotDataSource, CPTPlotDelegate>
@property (nonatomic, strong) CPTGraphHostingView *hostGraphView;
@property (nonatomic, strong) CPTXYGraph *graph;

@end
