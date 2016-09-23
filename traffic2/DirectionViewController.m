//
//  DirectionViewController.m
//  traffic2
//
//  Created by Catherine Zhao on 2016-09-22.
//  Copyright © 2016 Catherine. All rights reserved.
//

#import "DirectionViewController.h"

@interface DirectionViewController ()

@end

@implementation DirectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.directionTableView.dataSource = self;
    self.directionTableView.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.directionDataSource count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"directionCell"];
    NSArray *info = self.directionDataSource[indexPath.row];
    if (info.count == 3) {
        [cell.textLabel setText:[NSString stringWithFormat:@"%@(%im, %is)",info[0], (int)[info[1] doubleValue], [info[2] intValue]]];
    }else {
        [cell.textLabel setText:[NSString stringWithFormat:@"%@(%im)",info[0], (int)[info[1] doubleValue]]];
    }
    cell.textLabel.numberOfLines = 4;
    return cell;
}
- (IBAction)back:(id)sender {
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
