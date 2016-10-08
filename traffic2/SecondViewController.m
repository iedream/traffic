//
//  SecondViewController.m
//  traffic2
//
//  Created by Catherine Zhao on 2016-09-01.
//  Copyright © 2016 Catherine. All rights reserved.
//

#import "SecondViewController.h"
#import <MapKit/MapKit.h>
#import "MyAnnotation.h"
#import "WeekDayTableViewCell.h"
#import "MyRouteTableViewCell.h"
#import "dataGraphViewController.h"

@interface SecondViewController ()

@end

@implementation SecondViewController
static SecondViewController *sharedInstance = nil;
NSString *path;
NSMutableArray *routeArr;
NSMutableDictionary *weekDaysDict;
NSMutableDictionary *currentDic;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.WeekDayTable.delegate = self;
    self.myRouteTable.delegate = self;
    self.WeekDayTable.dataSource = self;
    self.myRouteTable.dataSource = self;

    // Do any additional setup after loading the view, typically from a nib.
}

- (void)initWithPlist {
    self.weekDaydata = @[@"MONDAY", @"TUESDAY", @"WEDNESDAY", @"THURSDAY", @"FRIDAY", @"SATURDAY", @"SUNDAY"];
    weekDaysDict = [[NSMutableDictionary alloc]init];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(addToMyRouteDic:) name:@"AddRoute" object:nil];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    path = [paths firstObject];
    path = [path stringByAppendingPathComponent:@"/route.plist"];
    
    if ([[NSFileManager defaultManager]fileExistsAtPath:path]) {
        routeArr = [[NSMutableArray alloc] initWithContentsOfFile:path];
    } else {
        routeArr = [[NSMutableArray alloc]init];
    }
    self.myRouteData = routeArr;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    //[self scheduleNotificationWithTime:[NSDate date]];
    // Dispose of any resources that can be recreated.
}

- (void)removeNotificationWithClock:(NSString*)clock days:(NSString*)days {
    clock = [clock stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
    NSString *name = [[routeArr objectAtIndex:[routeArr indexOfObject:currentDic]] objectForKey:@"routeName"];
    name = [name stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
    
    NSString *deviceToken = @"5060EABE8B8D552B1B06C7855E27B27EB2F1D9F8BDDC640BFE9765BBBD021C72";
    NSString *baseUrl = [NSString stringWithFormat:@"http://trafficpushserver.herokuapp.com/cancelNotification/%@/%@/%@,%@",deviceToken, name, clock, days];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:baseUrl] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:40.0];
    [request setHTTPMethod:@"DELETE"];
    
    NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if(error) {
            NSLog(@"Error: %@", error);
        }else {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
            NSError *err;
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&err];
            
            if ([httpResponse statusCode] == 200){
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Scheduling Successful" message:json[@"message"] preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * action){
                                                               //Do Some action here
                                                               [alert dismissViewControllerAnimated:YES completion:NULL];
                                                           }];
                [alert addAction:ok];
                [self presentViewController:alert animated:YES completion:NULL];
            }
        }
    }];
    [task resume];
}

- (void)scheduleRemoteNotificationWithClock:(NSString*)clock days:(NSString*)days{
    NSString *zoneContinent = @"America";
    NSString *zoneCity = @"Toronto";
    NSString *deviceToken = @"5060EABE8B8D552B1B06C7855E27B27EB2F1D9F8BDDC640BFE9765BBBD021C72";
    
    NSDictionary *timeDict = @{@"clock":clock, @"days":days, @"continent":zoneContinent, @"city":zoneCity};
    NSDictionary *dict = @{@"userInfo":currentDic, @"time":timeDict};
    
    NSError *err;
    NSData *stringDict = [NSJSONSerialization dataWithJSONObject:dict
                                    options:0
                                      error:&err];
    NSString *requestJson = [[NSString alloc] initWithData:stringDict encoding:NSUTF8StringEncoding];
    NSData *requestData = [requestJson dataUsingEncoding:NSUTF8StringEncoding];

    NSString *baseUrl = [NSString stringWithFormat:@"http://trafficpushserver.herokuapp.com/sendNotification/%@",deviceToken];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:baseUrl] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:40.0];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[requestData length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:requestData];
    
    NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if(error) {
            NSLog(@"Error: %@", error);
        }else {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
            NSError *err;
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&err];
            
            if ([httpResponse statusCode] == 200){
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Cancel Successful" message:json[@"message"] preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * action){
                                                               //Do Some action here
                                                               [alert dismissViewControllerAnimated:YES completion:NULL];
                                                           }];
                [alert addAction:ok];
                [self presentViewController:alert animated:YES completion:NULL];
            }
        }
    }];
    [task resume];
}

- (void)addToMyRouteDic:(NSNotification *)notif {
    MKPolyline *polyline = notif.userInfo[@"polyLine"];
    NSString *name = notif.userInfo[@"name"];
    
    NSMutableDictionary *dict;
    if ([polyline isKindOfClass:[ApplePolyLine class]]) {
        ApplePolyLine *applyLine = (ApplePolyLine *)polyline;
        dict = [self addWithAppleDirection:applyLine];
        dict[@"routeName"] = name;
        [self convertlocationIntoString:applyLine.source completionHandler:^(NSString *sourceString) {
            [self convertlocationIntoString:applyLine.dest completionHandler:^(NSString *destString) {
                dict[@"sourceString"] = sourceString;
                dict[@"destString"] = destString;
                dict[@"notification"] = [[NSMutableArray alloc]init];
                [routeArr addObject:dict];
                [self writeToPlist];
                [self.myRouteTable reloadData];
            }];
        }];
    } else if ([polyline isKindOfClass:[BingPolyLine class]]) {
        BingPolyLine *applyLine = (BingPolyLine *)polyline;
        dict = [self addWithBingDirection:applyLine];
        dict[@"routenName"] = name;
        [self convertlocationIntoString:applyLine.source completionHandler:^(NSString *sourceString) {
            [self convertlocationIntoString:applyLine.dest completionHandler:^(NSString *destString) {
                dict[@"sourceString"] = sourceString;
                dict[@"destString"] = destString;
                dict[@"notification"] = [[NSMutableArray alloc]init];
                [routeArr addObject:dict];
                [self writeToPlist];
                [self.myRouteTable reloadData];
            }];
        }];
    }
}

-(NSMutableDictionary*)addWithAppleDirection:(ApplePolyLine*)route{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
    [dict setValue:[NSNumber numberWithDouble:route.distance] forKey:@"distance"];
    [dict setValue:[NSNumber numberWithInt:route.trafficTravelTime] forKey:@"expectedTime"];
    [dict setValue:route.name forKey:@"name"];
    NSDictionary *startDic = @{@"latitude":[NSNumber numberWithDouble:route.source.latitude], @"longitude":[NSNumber numberWithDouble:route.source.longitude]};
    [dict setValue:startDic forKey:@"source"];
    NSDictionary *endDic = @{@"latitude":[NSNumber numberWithDouble:route.dest.latitude], @"longitude":[NSNumber numberWithDouble:route.dest.longitude]};
    [dict setValue:endDic forKey:@"end"];
    [dict setValue:@"Apple" forKey:@"type"];
    return dict;
}

-(NSMutableDictionary*)addWithBingDirection:(BingPolyLine*)route{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
    [dict setValue:[NSNumber numberWithDouble:route.distance] forKey:@"distance"];
    [dict setValue:[NSNumber numberWithInt:route.trafficTravelTime] forKey:@"expectedTime"];
    [dict setValue:[NSNumber numberWithDouble:route.travelTime] forKey:@"actTime"];
    NSDictionary *startDic = @{@"latitude":[NSNumber numberWithDouble:route.source.latitude], @"longitude":[NSNumber numberWithDouble:route.source.longitude]};
    [dict setValue:startDic forKey:@"source"];
    NSDictionary *endDic = @{@"latitude":[NSNumber numberWithDouble:route.dest.latitude], @"longitude":[NSNumber numberWithDouble:route.dest.longitude]};
    [dict setValue:endDic forKey:@"end"];
    return dict;
}

- (void)convertlocationIntoString:(CLLocationCoordinate2D)point completionHandler:(void(^)(NSString*))completionBlock {
    CLLocation *location = [[CLLocation alloc] initWithLatitude:point.latitude longitude:point.longitude];
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray* placemarks, NSError* error){
        if ([placemarks count] > 0) {
            CLPlacemark *placeMark = [placemarks firstObject];
            NSArray *address = placeMark.addressDictionary[@"FormattedAddressLines"];
            completionBlock([address firstObject]);
        }else{
            completionBlock(nil);
        }
    }];
}

- (void)getTrafficTimeWithAppleMap:(NSDictionary*)userInfo completionHandler:(void(^)(double))completionBlock {
    double sourceLatitude = [[[userInfo valueForKey:@"source"] valueForKey:@"latitude"] doubleValue];
    double sourceLongitude = [[[userInfo valueForKey:@"source"] valueForKey:@"longitude"] doubleValue];
    double endLatitude = [[[userInfo valueForKey:@"end"] valueForKey:@"latitude"] doubleValue];
    double endLongitude = [[[userInfo valueForKey:@"end"] valueForKey:@"longitude"] doubleValue];
    CLLocationCoordinate2D sourcePoint = CLLocationCoordinate2DMake(sourceLatitude, sourceLongitude);
    CLLocationCoordinate2D endPoint = CLLocationCoordinate2DMake(endLatitude, endLongitude);
    MKPlacemark *sourcePlaceMark = [[MKPlacemark alloc] initWithCoordinate:sourcePoint addressDictionary:nil];
    MKPlacemark *endPlaceMark = [[MKPlacemark alloc] initWithCoordinate:endPoint addressDictionary:nil];
    MKMapItem *startItem = [[MKMapItem alloc]initWithPlacemark:sourcePlaceMark];
    MKMapItem *endItem = [[MKMapItem alloc]initWithPlacemark:endPlaceMark];
    
        MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
        request.source = startItem;
        request.destination = endItem;
        request.requestsAlternateRoutes = true;
        request.transportType = MKDirectionsTransportTypeAutomobile;
    [self getAppleDirectionWithRequest:request name:userInfo[@"name"] completionBlock:^(double trafficTime) {
        completionBlock(trafficTime);
    }];
}

-(void)getAppleDirectionWithRequest:(MKDirectionsRequest*)request name:(NSString*)name completionBlock:(void(^)(double))completionBlock {
    MKDirections *directions = [[MKDirections alloc] initWithRequest:request];
    [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *err){
        if (!err) {
            BOOL returnVar = false;
            for(MKRoute *route in response.routes) {
                if ([route.name isEqualToString: name]) {
                    int time = route.expectedTravelTime/60;
                    returnVar = true;
                    completionBlock(time);
                    break;
                }
            }
            if (!returnVar) {
                [self getAppleDirectionWithRequest:request name:name completionBlock:completionBlock];
            }
        };
    }];
}

-(void)writeToPlist {
    [routeArr writeToFile:path atomically:YES];
}

- (IBAction)addWatchTime:(id)sender {
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setDateFormat:@"HH:mm a"];
    NSString *time = [outputFormatter stringFromDate:self.timePicker.date];
    NSArray *timeArray = [time componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@": "]];
    NSString *finalTimeString = [NSString stringWithFormat:@"00 %@ %@",timeArray[1],timeArray[0]];
    NSString *dateString = [self getSelectedDates];
    
    NSMutableArray *clockArray = [currentDic objectForKey:@"notification"];
    [clockArray addObject:@[finalTimeString, dateString]];
    [currentDic setObject:clockArray forKey:@"notification"];
    [self writeToPlist];
    [self.myRouteTable reloadData];
    [self scheduleRemoteNotificationWithClock:finalTimeString days:dateString];
}

- (NSString *)getSelectedDates {
    NSString *dateString = @"";
    if ([weekDaysDict[@"MONDAY"] boolValue]) {
        dateString = [NSString stringWithFormat:@"%@,%@", dateString, @"1"];
    }
    if ([weekDaysDict[@"TUESDAY"] boolValue]) {
        dateString = [NSString stringWithFormat:@"%@,%@", dateString, @"2"];
    }
    if ([weekDaysDict[@"WEDNESDAY"] boolValue]) {
        dateString = [NSString stringWithFormat:@"%@,%@", dateString, @"3"];
    }
    if ([weekDaysDict[@"THURSDAY"] boolValue]) {
        dateString = [NSString stringWithFormat:@"%@,%@", dateString, @"4"];
    }
    if ([weekDaysDict[@"FRIDAY"] boolValue]) {
        dateString = [NSString stringWithFormat:@"%@,%@", dateString, @"5"];
    }
    if ([weekDaysDict[@"SATURDAY"] boolValue]) {
        dateString = [NSString stringWithFormat:@"%@,%@", dateString, @"6"];
    }
    if ([weekDaysDict[@"SUNDAY"] boolValue]) {
        dateString = [NSString stringWithFormat:@"%@,%@", dateString, @"7"];
    }
    if (dateString.length > 1) {
        dateString = [dateString substringFromIndex:1];
    }
    return dateString;
}

- (void)cancelAllNotif {
    NSArray *notif = currentDic[@"notification"];
    for (NSArray *arr in notif) {
        [self removeNotificationWithClock:[arr firstObject] days:[arr lastObject]];
    }
}

- (IBAction)backToMap:(id)sender {
    dataGraphViewController *dataGraphViewCont= [self.storyboard instantiateViewControllerWithIdentifier:@"dataGraphViewController"];
    [self addChildViewController:dataGraphViewCont];
    [self.view addSubview:dataGraphViewCont.view];
    [dataGraphViewCont setDataForGraph:currentDic[@"routeName"]];
}

- (IBAction)backToMainList:(id)sender {
    self.myRouteData = routeArr;
    [self.myRouteTable reloadData];
}

- (void)addDataToStorageWithCompletionHandler:(void(^)(NSString*))completionBlock {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basicPath = [paths firstObject];
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    [timeFormatter setDateFormat:@"hh:mm a"];
    NSDateFormatter *weekFormatter = [[NSDateFormatter alloc] init];
    [weekFormatter setDateFormat: @"EEEE"];
    

    for (NSDictionary *dict in routeArr) {
        NSString *routeName = dict[@"routeName"];
        NSString *routePath = [basicPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist", routeName]];
        NSMutableArray *timeDic = [[NSMutableArray alloc]init];
        if ([[NSFileManager defaultManager]fileExistsAtPath:routePath]) {
            timeDic = [[NSMutableArray alloc] initWithContentsOfFile:routePath];
        } else {
            timeDic = [[NSMutableArray alloc]init];
        }
        [self getTrafficTimeWithAppleMap:dict completionHandler:^(double trafficTime) {
            completionBlock(@"success");
            if (trafficTime) {
                NSString *timeString = [timeFormatter stringFromDate:[NSDate date]];
                NSString *weekString = [[weekFormatter stringFromDate:[NSDate date]] capitalizedString];
                NSDictionary *dict = @{@"trafficTime":@(trafficTime), @"time":timeString, @"weekday":weekString};
                [timeDic addObject:dict];
                [timeDic writeToFile:routePath atomically:NO];
            }
        }];
    }
}

#pragma mark LocationManager Delegate Method

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.myRouteTable) {
        return self.myRouteData.count;
    } else if (tableView == self.WeekDayTable) {
        return self.weekDaydata.count;
    } else {
        return 0;
    }
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.WeekDayTable) {
        WeekDayTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WeekDayTableCell"];
        cell.textView.text = [self.weekDaydata objectAtIndex:indexPath.row];
        if ([[weekDaysDict objectForKey:cell.textView.text] boolValue]) {
            cell.checkView.hidden = NO;
        }
        return cell;
    } else if (tableView == self.myRouteTable && self.myRouteData == routeArr) {
        MyRouteTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyRouteTableCell"];
        NSDictionary *dict = [self.myRouteData objectAtIndex:indexPath.row];
        cell.titleLabel.text = dict[@"routeName"];
        cell.sourceLabel.text = dict[@"sourceString"];
        cell.destLabel.text = dict[@"destString"];
        return cell;
    } else if (tableView == self.myRouteTable && self.myRouteData != routeArr) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BasicCell"];
        if (!cell) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"BasicCell"];
        }
        NSArray *array = [self.myRouteData objectAtIndex:indexPath.row];
        NSString *string = [NSString stringWithFormat:@"Time:%@ Date:%@", array.firstObject, array.lastObject];
        cell.textLabel.text = string;
        return cell;
    }
    return nil;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.WeekDayTable) {
        WeekDayTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        BOOL isChecked = [cell didPressedOnCell];
        [weekDaysDict setObject:[NSNumber numberWithBool:isChecked] forKey:cell.textView.text];
    } else if (tableView == self.myRouteTable && self.myRouteData == routeArr) {
        currentDic = [self.myRouteData objectAtIndex:indexPath.row];
        self.myRouteData = [[routeArr objectAtIndex:indexPath.row] objectForKey:@"notification"];
        [self.myRouteTable reloadData];
    }
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if (tableView == self.myRouteTable && self.myRouteData != routeArr) {
            NSArray *arr = [self.myRouteData objectAtIndex:indexPath.row];
            [self removeNotificationWithClock:[arr firstObject] days:[arr lastObject]];
            [self.myRouteData removeObjectAtIndex:indexPath.row];
            [self writeToPlist];
            [self.myRouteTable deleteRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationFade];
        } else if (tableView == self.myRouteTable && self.myRouteData == routeArr) {
            [self cancelAllNotif];
            [self.myRouteData removeObjectAtIndex:indexPath.row];
            [self writeToPlist];
            [self.myRouteTable deleteRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationFade];
        }
    }
}


+(SecondViewController*)sharedInstance {
    if (!sharedInstance) {
        sharedInstance = [[self alloc]init];
    }
    return sharedInstance;
}

@end
