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
    frame.origin.x = 20;
    frame.origin.y = 20;
    frame.size.width = self.view.frame.size.width - 40;
    frame.size.height = self.view.frame.size.height - 80;
    self.hostGraphView = [[CPTGraphHostingView alloc]initWithFrame:frame];
    [self.view addSubview:self.hostGraphView];
    
    [self configurePlot];
    [self configurePlotRange];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setDataForGraph:(NSString *)routeName {
    [self.segmentControl setSelectedSegmentIndex:5];
    [self.segmentControl sendActionsForControlEvents:UIControlEventValueChanged];
    
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
    
    CPTBarPlot *plot = [[CPTBarPlot alloc] init];
    plot.dataSource = self;
    plot.identifier = @"TrafficData";
    [graph addPlot:plot];
    
    self.hostGraphView.hostedGraph = graph;
}

- (void)configurePlotRange {
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)self.hostGraphView.hostedGraph.defaultPlotSpace;
    CPTMutablePlotRange *xRange = plotSpace.xRange.mutableCopy;
    CPTMutablePlotRange *yRange = plotSpace.yRange.mutableCopy;
    NSDecimal xRangeDec = [[NSDecimalNumber numberWithDouble:20] decimalValue];
    NSDecimal yRangeDec = [[NSDecimalNumber numberWithDouble:20] decimalValue];
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
        return [[dataDic allKeys] objectAtIndex:index];
    } else {
        return [[dataDic allValues] objectAtIndex:index];
    }
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end