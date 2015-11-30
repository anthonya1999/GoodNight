//
//  FirstViewController.m
//  GoodNight
//
//  Created by Anthony Agatiello on 10/4/15.
//  Copyright © 2015 ADA Tech, LLC. All rights reserved.
//

#import "CreditsViewController.h"
#import "AppDelegate.h"

@implementation CreditsViewController

- (instancetype)init
{
    self = [AppDelegate initWithIdentifier:@"creditsViewController"];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.0") && self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable) {
        [self registerForPreviewingWithDelegate:self sourceView:self.view];
    }
}

- (UIViewController *)previewingContext:(id<UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location
{
    if ([userDefaults boolForKey:@"peekPopEnabled"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];
    
        if (indexPath) {
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            NSString *cellText = [cell.textLabel.text substringFromIndex:1];
            previewingContext.sourceRect = cell.frame;
            SFSafariViewController *safariVC = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://twitter.com/%@", cellText]] entersReaderIfAvailable:NO];
            safariVC.delegate = self;
            username = cell.textLabel.text;
            return safariVC;
        }
    }
    return nil;
}

- (void)previewingContext:(id<UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit {
    [self openTwitterAccount];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView) {
        if (indexPath.section == 0) {
            if (indexPath.row == 0) {
                username = @"tomf64";
            }
            if (indexPath.row == 1) {
                username = @"AAgatiello";
            }
            if (indexPath.row == 2) {
                username = @"GoodNightiOS";
            }
            if (indexPath.row == 3) {
                username = @"sapphirinedream";
            }
            if (indexPath.row == 4) {
                username = @"Emu4iOS";
            }
            if (indexPath.row == 5) {
                username = @"The120thWhisper";
            }
            if (indexPath.row == 6) {
                username = @"lyablin_nikita";
            }
            [self openTwitterAccount];
        }
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

- (void)openTwitterAccount {
    NSString *scheme = @"";
    if ([app canOpenURL:[NSURL URLWithString:@"twitter://"]]) // Twitter
    {
        scheme = [NSString stringWithFormat:@"twitter://user?screen_name=%@",username];
    }
    else if ([app canOpenURL:[NSURL URLWithString:@"tweetbot:"]]) // Tweetbot
    {
        scheme = [NSString stringWithFormat:@"tweetbot:///user_profile/%@",username];
    }
    else if ([app canOpenURL:[NSURL URLWithString:@"twitterrific://"]]) // Twitterrific
    {
        scheme = [NSString stringWithFormat:@"twitterrific:///profile?screen_name=%@",username];
    }
    else
    {
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.0"))
        {
            SFSafariViewController *safariVC = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://twitter.com/%@", username]] entersReaderIfAvailable:NO];
            safariVC.delegate = self;
            webViewShouldAppear = YES;
            [self presentViewController:safariVC animated:YES completion:nil];
        }
        else
        {
            scheme = [NSString stringWithFormat:@"http://twitter.com/%@",username];
        }
    }
    if (webViewShouldAppear == NO) {
        [app openURL:[NSURL URLWithString:scheme]];
    }
}

@end
