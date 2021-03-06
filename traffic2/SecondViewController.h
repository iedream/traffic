//
//  SecondViewController.h
//  traffic2
//
//  Created by Catherine Zhao on 2016-09-01.
//  Copyright © 2016 Catherine. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyAnnotation.h"

@interface SecondViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *myRouteTable;
@property (weak, nonatomic) IBOutlet UITableView *WeekDayTable;
@property (weak, nonatomic) IBOutlet UIDatePicker *timePicker;

@property (nonatomic, strong) NSMutableArray *myRouteData;
@property (nonatomic, strong) NSArray *weekDaydata;

@property (nonatomic)int currentDataIndex;

@property (nonatomic, strong) NSString *deviceId;

+(SecondViewController*)sharedInstance;
-(NSMutableDictionary*)addWithBingDirection:(BingPolyLine*)route;
-(NSMutableDictionary*)addWithAppleDirection:(ApplePolyLine*)route;
-(void)getTrafficTimeWithAppleMap:(NSDictionary*)userInfo completionHandler:(void(^)(double))completionBlock;
-(void)scheduleNotificationWithTime:(NSDate*)date polyLine:(ApplePolyLine *)polyLine;
- (void)scheduleRemoteNotification:(ApplePolyLine*)applePolyLine;
- (void)initWithPlist;
- (void)addDataToStorageWithCompletionHandler:(void(^)(NSString*))completionBlock;
@end

