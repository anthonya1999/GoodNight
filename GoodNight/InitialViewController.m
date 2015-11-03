//
//  InitialViewController.m
//  GoodNight
//
//  Created by Anthony Agatiello on 10/16/15.
//  Copyright © 2015 ADA Tech, LLC. All rights reserved.
//

#import "InitialViewController.h"

@implementation InitialViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.0") && self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable) {
        [self registerForPreviewingWithDelegate:self sourceView:self.view];
    }
}

- (UIViewController *)previewingContext:(id<UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location
{
    if ([userDefaults boolForKey:@"peekPopEnabled"]) {
        CGPoint cellPostion = [self.tableView convertPoint:location fromView:self.view];
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:cellPostion];
        
        if (indexPath) {
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            NSString *identifier = nil;
            
            if (indexPath.section == 0) {
                if (indexPath.row == 0) {
                    identifier = @"mainViewController";
                }
                if (indexPath.row == 1) {
                    identifier = @"brightnessViewController";
                }
                if (indexPath.row == 2) {
                    identifier = @"colorViewController";
                }
            }
            
            if (indexPath.section == 1) {
                if (indexPath.row == 0) {
                    identifier = @"settingsViewController";
                }
            }
            
            if (indexPath.section == 2) {
                identifier = @"creditsViewController";
            }
            
            previewingContext.sourceRect = cell.frame;
            UIViewController *viewController = [AppDelegate initWithIdentifier:identifier];
            return viewController;
        }
    }
    return nil;
}

- (void)previewingContext:(id<UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit {
    [self.navigationController pushViewController:viewControllerToCommit animated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = nil;
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            identifier = @"mainViewController";
        }
        if (indexPath.row == 1) {
            identifier = @"brightnessViewController";
        }
        if (indexPath.row == 2) {
            identifier = @"colorViewController";
        }
    }
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            identifier = @"settingsViewController";
        }
    }
    if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            identifier = @"creditsViewController";
        }
    }
    UIViewController *viewController = [AppDelegate initWithIdentifier:identifier];
    [self.navigationController pushViewController:viewController animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
