//
//  AddressDetailViewController.m
//  traffic2
//
//  Created by Catherine Zhao on 2016-09-07.
//  Copyright © 2016 Catherine. All rights reserved.
//

#import "AddressDetailViewController.h"

@interface AddressDetailViewController ()
@end

@implementation AddressDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.textView setText:self.addressString];
    
    self.navigationController.modalPresentationStyle = UIModalPresentationCurrentContext;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)getTrafficData:(id)sender {
    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:
                            [NSNumber numberWithDouble:self.addressPoint.latitude], @"latitude",
                            [NSNumber numberWithDouble:self.addressPoint.longitude], @"longitude",
                            nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"GetTrafficData" object:params];
    [self removeFromParentViewController];
    [self.view removeFromSuperview];
}
- (IBAction)backToMap:(id)sender {
    [self removeFromParentViewController];
    [self.view removeFromSuperview];
}
- (IBAction)removePin:(id)sender {
    for (MKPointAnnotation *pointAnno in self.mainViewController.mapView.annotations) {
        if ([pointAnno.title isEqualToString:self.addressString]) {
            [self.mainViewController.mapView removeAnnotation:pointAnno];
        }
    }
}
- (IBAction)getDirection:(id)sender {
    GetTrafficViewController *getTrafficViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"GetTrafficViewController"];
    getTrafficViewController.endPointAddress = self.addressString;
    getTrafficViewController.currentLocationAddress = self.currentLocationString;
    [self addChildViewController:getTrafficViewController];
    [self.view addSubview:getTrafficViewController.view];
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
