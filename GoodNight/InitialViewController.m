//
//  InitialViewController.m
//  GoodNight
//
//  Created by Anthony Agatiello on 10/16/15.
//  Copyright © 2015 ADA Tech, LLC. All rights reserved.
//

#import "InitialViewController.h"
#import "MainViewController.h"
#import "BrightnessViewController.h"
#import "CustomViewController.h"
#import "CreditsViewController.h"
#import "SettingsViewController.h"

@implementation InitialViewController

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            MainViewController *mainVC = [[MainViewController alloc] init];
            [self.navigationController pushViewController:mainVC animated:YES];
        }
        if (indexPath.row == 1) {
            BrightnessViewController *brightnessVC = [[BrightnessViewController alloc] init];
            [self.navigationController pushViewController:brightnessVC animated:YES];
        }
        if (indexPath.row == 2) {
            CustomViewController *customVC = [[CustomViewController alloc] init];
            [self.navigationController pushViewController:customVC animated:YES];
        }
    }
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            SettingsViewController *settingsVC = [[SettingsViewController alloc] init];
            [self.navigationController pushViewController:settingsVC animated:YES];
        }
    }
    if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            CreditsViewController *creditsVC = [[CreditsViewController alloc] init];
            [self.navigationController pushViewController:creditsVC animated:YES];
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
