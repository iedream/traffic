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
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)getTrafficData:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"GetTrafficData" object:nil];
    [self presentViewController:self.mainViewController animated:true completion:nil];
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
