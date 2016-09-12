//
//  FirstViewController.h
//  traffic2
//
//  Created by Catherine Zhao on 2016-09-01.
//  Copyright © 2016 Catherine. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "MyAnnotation.h"

@interface FirstViewController : UIViewController<CLLocationManagerDelegate,MKMapViewDelegate, MKAnnotation>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@end

