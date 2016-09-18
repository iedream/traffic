//
//  GetTrafficViewController.m
//  traffic2
//
//  Created by Catherine Zhao on 2016-09-17.
//  Copyright © 2016 Catherine. All rights reserved.
//

#import "GetTrafficViewController.h"

@interface GetTrafficViewController ()

@end

@implementation GetTrafficViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.startTextField setText:self.currentLocationAddress];
    [self.endTextField setText:self.endPointAddress];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)reversePoints:(id)sender {
    NSString *newStart = self.endTextField.text;
    NSString *newEnd = self.startTextField.text;
    [self.startTextField setText:newStart];
    [self.endTextField setText:newEnd];
}

- (IBAction)getDirection:(id)sender {
    NSDictionary *directionData = [[NSDictionary alloc] initWithObjectsAndKeys:
                                   self.startTextField.text, @"start",
                                   self.endTextField.text, @"end",
                                   nil];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"GetDirectionData" object:nil userInfo:directionData];
    [self removeFromParentViewController];
    [self.view removeFromSuperview];
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
