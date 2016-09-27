//
//  MyAnnotation.h
//  traffic2
//
//  Created by Catherine Zhao on 2016-09-11.
//  Copyright © 2016 Catherine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

typedef enum {
    NO_SEVERITY,
    LOW_IMPACT,
    MINOR,
    MODERATE,
    SERIOUS
} SEVERITY;

typedef enum {
    NO_TRAFFIC_TYPE,
    ACCIDENT,
    CONGESTION,
    DISABLED_VEHICLE,
    MASS_TRANSIT,
    MISCELLANEOUS,
    OTHER_NEWS,
    PLANNED_EVENT,
    ROAD_HAZARD,
    CONSTRUCTION,
    ALERT,
    WEATHER
} TRAFFIC_TYPE;

@interface MyPolyLine : MKPolyline

@property (nonatomic, assign) CLLocationCoordinate2D source;
@property (nonatomic, assign) CLLocationCoordinate2D destination;

@property (nonatomic, retain, nonnull) NSDate *startTime;
@property (nonatomic, retain, nonnull) NSDate *endTime;

@property (nonatomic, assign) SEVERITY severity;
@property (nonatomic, assign) TRAFFIC_TYPE type;
@property (nonatomic, assign) BOOL roadClosed;

@property (nonatomic, retain, nullable) NSString *info;
@property (nonatomic, retain, nullable) NSString *lane;
@property (nonatomic, retain, nullable) NSString *congestion;
@property (nonatomic, retain, nullable) NSString *detour;

@end

@interface BingPolyLine : MKPolyline

@property (nonatomic, assign) int travelTime;
@property (nonatomic, assign) int trafficTravelTime;
@property (nonatomic, assign) int distance;
@property (nonatomic, retain, nonnull) NSString *congestion;
@property (nonatomic, retain, nonnull) NSArray *directionDataSource;
@property (nonatomic, assign) CLLocationCoordinate2D source;
@property (nonatomic, assign) CLLocationCoordinate2D dest;

@end

@interface ApplePolyLine : MKPolyline

@property (nonatomic, retain, nonnull) NSArray *directionDataSource;
@property (nonatomic, assign) int trafficTravelTime;
@property (nonatomic, assign) int distance;
@property (nonatomic, assign) CLLocationCoordinate2D source;
@property (nonatomic, assign) CLLocationCoordinate2D dest;

@end
