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

const NSString *plotIdentifier = @"TrafficData";

- (void)viewDidLoad {
    [super viewDidLoad];
    CGRect frame;
    frame.origin.x = -10;
    frame.origin.y = CGRectGetMaxY(self.segmentControl.bounds) + 40;
    frame.size.width = self.view.bounds.size.width;
    frame.size.height = self.view.bounds.size.height - frame.origin.y - 60;
    self.hostGraphView = [[CPTGraphHostingView alloc]initWithFrame:frame];
    [self.view addSubview:self.hostGraphView];
    
    [self configurePlot];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setDataForGraph:(NSString *)routeName {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basicPath = [paths firstObject];
    NSString *routePath = [basicPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist", routeName]];
    
    NSArray *data;
    if ([[NSFileManager defaultManager]fileExistsAtPath:routePath]) {
        data = [[NSArray alloc] initWithContentsOfFile:routePath];
    } else {
        data = @[];
    }
    self.allDataDic = [self processData:data];
    [self setGraphData];
}

- (void)setGraphData {
    self.dataSource = [self.allDataDic objectForKey:[self getSegmentKey]];
    CPTPlot *plot = [self.hostGraphView.hostedGraph plotWithIdentifier:plotIdentifier];
    [self configurePlotDetail];
    [plot reloadData];
}

- (NSDictionary *)processData:(NSArray*)dataArr {
    NSMutableDictionary *dataByWeekDay = [[NSMutableDictionary alloc]init];
    for (NSDictionary *dictByDay in dataArr) {
        NSString *weekDayString = [dictByDay objectForKey:@"weekday"];
        NSMutableArray *arr;
        if ([dataByWeekDay objectForKey:weekDayString]) {
            arr = [[NSMutableArray alloc]initWithArray:[dataByWeekDay objectForKey:weekDayString]];
        }else {
            arr = [[NSMutableArray alloc]init];
        }
        [arr addObject:dictByDay];
        [dataByWeekDay setObject:[arr copy] forKey:weekDayString];
    }
    NSDictionary *finalResultData = [self getWeekDayData:dataByWeekDay];
    return finalResultData;
}

- (NSDictionary *)getWeekDayData:(NSDictionary *)weekDayDic {
    NSMutableDictionary *finalDic = [[NSMutableDictionary alloc]init];
    for (NSString *weekDay in [weekDayDic allKeys]) {
        NSArray *weekDayArr = [weekDayDic objectForKey:weekDay];
        NSArray *resultHourArr = [self getAverageOfData:weekDayArr];
        [finalDic setObject:resultHourArr forKey:weekDay];
    }
    return [finalDic copy];
}

- (NSArray *)getAverageOfData:(NSArray*)weekDayArr {
    NSMutableDictionary *resultDic = [[NSMutableDictionary alloc]init];
    for (NSDictionary *iDict in weekDayArr) {
        
        NSString *timeString = [iDict objectForKey:@"time"];
        NSString *amString = @" AM";
        NSString *pmString = @" PM";
        NSArray *timeArr;
        if ([timeString containsString:amString]) {
            timeArr = [timeString componentsSeparatedByString:amString];
            NSString *actTimeComp = [timeArr firstObject];
            timeArr = [actTimeComp componentsSeparatedByString:@":"];
        } else if ([timeString containsString:pmString]) {
            timeArr = [timeString componentsSeparatedByString:pmString];
            NSString *actTimeComp = [timeArr firstObject];
            timeArr = [actTimeComp componentsSeparatedByString:@":"];
        }
        
        int hour = [[timeArr firstObject] intValue];
        int minute = [[timeArr lastObject] intValue];
        if (minute >= 30) {
            hour += 1;
        }
        
        NSString *resultDicKey = [NSString stringWithFormat:@"%i", hour];
        NSDictionary *timeDic = [resultDic objectForKey:resultDicKey];
        
        int totalValue = [[timeDic objectForKey:@"Value"] intValue];
        totalValue += [[iDict objectForKey:@"trafficTime"] intValue];
        int totalCount = [[timeDic objectForKey:@"Count"] intValue];
        totalCount += 1;
        
        [resultDic setObject:@{@"Value":@(totalValue), @"Count":@(totalCount)} forKey:resultDicKey];
    }
    
    NSMutableArray *finalArr = [[NSMutableArray alloc]init];
    for (NSString *key in [resultDic allKeys]) {
        NSDictionary *dict = [resultDic objectForKey:key];
        if ([dict objectForKey:@"Count"] > 0) {
            int average = [[dict objectForKey:@"Value"] intValue] / [[dict objectForKey:@"Count"] intValue];
            NSDictionary *resDict = @{key:@(average)};
            [finalArr addObject:resDict];
        }
    }
    return [finalArr copy];
}

- (void)configurePlot {
    CPTXYGraph *graph = [[CPTXYGraph alloc]initWithFrame:CGRectZero];
    graph.title = @"Traffic Data";
    self.hostGraphView.hostedGraph = graph;

    [[self.hostGraphView.hostedGraph plotAreaFrame] setPaddingLeft:50.0f];
    [[self.hostGraphView.hostedGraph plotAreaFrame] setPaddingTop:10.0f];
    [[self.hostGraphView.hostedGraph plotAreaFrame] setPaddingBottom:120.0f];
    [[self.hostGraphView.hostedGraph plotAreaFrame] setPaddingRight:20.0f];
    [[self.hostGraphView.hostedGraph plotAreaFrame] setBorderLineStyle:nil];
    
    CPTBarPlot *plot = [[CPTBarPlot alloc] initWithFrame:self.hostGraphView.hostedGraph.bounds];
    plot.dataSource = self;
    plot.delegate = self;
    plot.identifier = @"TrafficData";
    [graph addPlot:plot];
    
    plot.barWidth = [[NSDecimalNumber numberWithDouble:0.5] decimalValue];
    plot.barOffset = [[NSDecimalNumber numberWithDouble:0.25] decimalValue];
}

- (int)getPlotRange {
    int maxRange = 0;
    for (NSDictionary *detailDic in self.dataSource) {
        int value = [[[detailDic allValues] firstObject] intValue];
        if (value > maxRange) {
            maxRange = value;
        }
    }
    
    if (maxRange > 1400) {
        self.currentCase = DAY;
    } else if (maxRange > 60) {
        self.currentCase = HOUR;
    } else {
        self.currentCase = MINUTE;
    }
    
    return maxRange;
}

- (void)configurePlotDetail {
    int maxRange = [self getPlotRange];
    
    [[self.hostGraphView.hostedGraph plotAreaFrame] setPaddingLeft:50.0f];
    [[self.hostGraphView.hostedGraph plotAreaFrame] setPaddingTop:10.0f];
    [[self.hostGraphView.hostedGraph plotAreaFrame] setPaddingBottom:120.0f];
    [[self.hostGraphView.hostedGraph plotAreaFrame] setPaddingRight:0.0f];
    [[self.hostGraphView.hostedGraph plotAreaFrame] setBorderLineStyle:nil];
    
    CPTMutableTextStyle *textStyle = [CPTMutableTextStyle textStyle];
    [textStyle setFontSize:12.0f];
    [textStyle setColor:[CPTColor colorWithCGColor:[[UIColor grayColor] CGColor]]];
    
    CPTXYAxisSet *axesSet = (CPTXYAxisSet*)[self.hostGraphView.hostedGraph axisSet];
    CPTXYAxis *xAxis = [axesSet xAxis];
    [xAxis setMajorIntervalLength:CPTDecimalFromInt(5)];
    [xAxis setMinorTicksPerInterval:5];
    [xAxis setLabelingPolicy:CPTAxisLabelingPolicyFixedInterval];
    [xAxis setLabelTextStyle:textStyle];
    CPTXYAxis *yAxis = [axesSet yAxis];
    
    if (self.currentCase == DAY) {
        maxRange = maxRange / 60;
        [yAxis setMajorIntervalLength:CPTDecimalFromInt(5)];
        [yAxis setMinorTicksPerInterval:5];
    } else if (self.currentCase == HOUR) {
        maxRange = maxRange / 60;
        [yAxis setMajorIntervalLength:CPTDecimalFromInt(30)];
        [yAxis setMinorTicksPerInterval:10];
    } else if (self.currentCase == MINUTE) {
        maxRange = 10;
        [yAxis setMajorIntervalLength:CPTDecimalFromInt(10)];
        [yAxis setMinorTickLength:2];
    }
    [yAxis setLabelingPolicy:CPTAxisLabelingPolicyFixedInterval];
    [yAxis setLabelTextStyle:textStyle];
    
    
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)self.hostGraphView.hostedGraph.defaultPlotSpace;
    CPTMutablePlotRange *xRange = plotSpace.xRange.mutableCopy;
    CPTMutablePlotRange *yRange = plotSpace.yRange.mutableCopy;
    NSDecimal xRangeDec = [[NSDecimalNumber numberWithDouble:24] decimalValue];
    NSDecimal yRangeDec = [[NSDecimalNumber numberWithDouble:maxRange] decimalValue];
    [xRange setLength:xRangeDec];
    [yRange setLength:yRangeDec];
    plotSpace.xRange = xRange;
    plotSpace.yRange = yRange;
}

- (NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot {
    return self.dataSource.count;
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    NSDictionary *dataDic = [self.dataSource objectAtIndex:index];
    if (fieldEnum == CPTScatterPlotFieldX) {
        int value = [[[dataDic allKeys] firstObject] intValue];
        return  @(value);
    } else {
        int value = [[[dataDic allValues] firstObject] intValue];
        if (self.currentCase == DAY) {
            value = value / 60;
        } else {
            value = value;
        }
        return @(value);
    }
}

- (void)barPlot:(CPTBarPlot *)plot barWasSelectedAtRecordIndex:(NSUInteger)idx withEvent:(CPTNativeEvent *)event {
    CPTMutableTextStyle *textStyle = [[CPTMutableTextStyle alloc]init];
    textStyle.fontName = @"HelveticaNeue-Bold";
    textStyle.fontSize = 12;
    
    int currentValue = [[[[self.dataSource objectAtIndex:idx] allValues] firstObject] intValue];
    if (self.currentCase == DAY) {
        currentValue = currentValue / 60;
    }
    NSString *currentValueString = [NSString stringWithFormat:@"%i", currentValue];
    [self.currentAnnotation.annotationHostLayer removeAnnotation:self.currentAnnotation];
    self.currentAnnotation = [[CPTPlotSpaceAnnotation alloc] initWithPlotSpace:plot.plotSpace anchorPlotPoint:@[@0,@0]];
    CPTTextLayer *textLayer = [[CPTTextLayer alloc] initWithText:currentValueString style:textStyle];
    self.currentAnnotation.contentLayer = textLayer;
    
    CGFloat x = (CGFloat)[[[[self.dataSource objectAtIndex:idx] allKeys] firstObject] intValue];
    CGFloat y = (CGFloat)currentValue + 0.05;
    self.currentAnnotation.anchorPlotPoint = @[@(x), @(y)];
    [self.hostGraphView.hostedGraph.plotAreaFrame.plotArea addAnnotation:self.currentAnnotation];
}

-(NSString *)getSegmentKey {
    NSString *key = [self.segmentControl titleForSegmentAtIndex:self.segmentControl.selectedSegmentIndex];
    if ([key isEqualToString:@"Mon"]) {
        return @"Monday";
    } else if ([key isEqualToString:@"Tue"]) {
        return @"Tuesday";
    } else if ([key isEqualToString:@"Wed"]) {
        return @"Wednesday";
    } else if ([key isEqualToString:@"Thu"]) {
        return @"Thursday";
    } else if ([key isEqualToString:@"Fri"]) {
        return @"Friday";
    } else if ([key isEqualToString:@"Sat"]) {
        return @"Saturday";
    } else if ([key isEqualToString:@"Sun"]) {
        return @"Sunday";
    }
    return @"";
}
- (IBAction)segmentChanged:(id)sender {
    [self setGraphData];
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
