//
//  dataGraphViewController.m
//  traffic2
//
//  Created by Catherine Zhao on 2016-10-06.
//  Copyright © 2016 Catherine. All rights reserved.
//

#import "dataGraphViewController.h"

@interface dataGraphViewController ()

@end

@implementation dataGraphViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    CGRect frame;
    frame.size.width = self.view.bounds.size.width - 40;
    frame.size.height = self.view.bounds.size.height - 80;
    frame.origin.y = 20;
    frame.origin.x = 20;
    self.hostGraphView = [[CPTGraphHostingView alloc]initWithFrame:frame];
    self.hostGraphView.layer.borderWidth = 5.0f;
    self.hostGraphView.layer.borderColor = [[UIColor blackColor] CGColor];
    [self.view addSubview:self.hostGraphView];
    [self configureHostView];
    [self configureFrameSize];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)configureHostView {
    self.graph = [[CPTXYGraph alloc]initWithFrame:self.view.bounds];
    self.hostGraphView.hostedGraph = self.graph;
    self.graph.paddingLeft = 0.0;
    self.graph.paddingTop = 0.0;
    self.graph.paddingRight = 0.0;
    self.graph.paddingBottom = 0.0;
    self.graph.axisSet = nil;
    
    CPTMutableTextStyle *textStyle = [[CPTMutableTextStyle alloc]init];
    textStyle.color = [CPTColor blackColor];
    textStyle.fontSize = 16.0;
    textStyle.textAlignment = CPTTextAlignmentCenter;
    
    self.graph.title = @"Traffic Data";
    self.graph.titleTextStyle = textStyle;
    self.graph.titlePlotAreaFrameAnchor = CPTRectAnchorTop;
    
    CPTScatterPlot *plot = [[CPTScatterPlot alloc] initWithFrame:CGRectZero];
    plot.dataSource = self;
    plot.delegate = self;
    [self.graph addPlot:plot toPlotSpace:self.graph.defaultPlotSpace];
}

- (void)configureFrameSize {
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)self.hostGraphView.hostedGraph.defaultPlotSpace;
    NSDecimal xStart = [[NSDecimalNumber decimalNumberWithString:@"0"] decimalValue];
    NSDecimal xLength = [[NSDecimalNumber decimalNumberWithString:@"8"] decimalValue];
    NSDecimal yStart = [[NSDecimalNumber decimalNumberWithString:@"13.0"] decimalValue];
    NSDecimal yLength = [[NSDecimalNumber decimalNumberWithString:@"17.0"] decimalValue];
    [plotSpace setXRange:[CPTPlotRange plotRangeWithLocation:xStart length:xLength]];
    [plotSpace setYRange:[CPTPlotRange plotRangeWithLocation:yStart length:yLength]];
}

- (NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot {
    return 3;
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    // We need to provide an X or Y (this method will be called for each) value for every index
    int x = 2;
    
    // This method is actually called twice per point in the plot, one for the X and one for the Y value
    if(fieldEnum == CPTScatterPlotFieldX)
    {
        // Return x value, which will, depending on index, be between -4 to 4
        return [NSNumber numberWithInt: x];
    } else {
        // Return y value, for this example we'll be plotting y = x * x
        return [NSNumber numberWithInt: 15];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
