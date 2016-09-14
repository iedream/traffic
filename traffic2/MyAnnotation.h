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
    NONE,
    LOW_IMPACT,
    MINOR,
    MODERATE,
    SERIOUS
} SEVERITY;

typedef enum {
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

@property (nonatomic, assign, nonnull) MKPlacemark *source;
@property (nonatomic, assign, nullable) MKPlacemark *destination;

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
