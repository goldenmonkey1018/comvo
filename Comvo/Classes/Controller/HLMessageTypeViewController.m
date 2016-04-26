//
//  HLMessageTypeViewController.m
//  Comvo
//
//  Created by Max Broeckel on 2/4/15.
//  Copyright (c) 2015 Max Broeckel. All rights reserved.
//

#import "HLMessageTypeViewController.h"

#import "Constants_Comvo.h"

#import "HLUserSearchViewController.h"

@interface HLMessageTypeViewController () <UITableViewDataSource, UITableViewDelegate>

@end

@implementation HLMessageTypeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initNavigation];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

//==========================================================================================================================

#pragma mark -
#pragma mark - Initialize

- (void)initNavigation {
    [self.navigationController setNavigationBarHidden: NO];
    
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    self.navigationController.navigationBar.barTintColor = UIColorFromRGB(0x00AFF0);
    self.navigationController.navigationBar.translucent = NO;
    
    self.title = @"Message Type";
    [self.navigationController.navigationBar
     setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
    UIButton *btnBack = [UIButton buttonWithType: UIButtonTypeSystem];
    [btnBack setFrame: CGRectMake(0, 0, 30, 30)];
    [btnBack setTintColor: [UIColor whiteColor]];
    [btnBack setImage: [UIImage imageNamed: @"common_img_back.png"] forState: UIControlStateNormal];
    [btnBack addTarget: self action: @selector(onTouchBtnBack :) forControlEvents: UIControlEventTouchUpInside];

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView: btnBack];
}

//==========================================================================================================================

#pragma mark -
#pragma mark - Touch Event

- (IBAction)onTouchBtnBack: (id)sender {
    [self.navigationController popViewControllerAnimated: YES];
}

//==========================================================================================================================

#pragma mark -
#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        HLUserSearchViewController *userSearchView = (HLUserSearchViewController *)[self.storyboard instantiateViewControllerWithIdentifier: @"HLUserSearchViewController"];
        [self.navigationController pushViewController: userSearchView animated: YES];
    }
    else if (indexPath.row == 1) {
        
    }
}

@end
