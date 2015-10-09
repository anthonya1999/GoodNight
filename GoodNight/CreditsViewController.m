//
//  FirstViewController.m
//  GoodNight
//
//  Created by Anthony Agatiello on 10/4/15.
//  Copyright © 2015 ADA Tech, LLC. All rights reserved.
//

#import "CreditsViewController.h"

@implementation CreditsViewController

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView) {
        if (indexPath.section == 0) {
            NSString *username = nil;
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
                username = @"Emu4iOS";
            }
            if (indexPath.row == 4) {
                username = @"The120thWhisper";
            }
            if (indexPath.row == 5) {
                username = @"lyablin_nikita";
            }
            [self openTwitterAccountWithUsername:username];
        }
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

- (void)openTwitterAccountWithUsername:(NSString *)username {
    NSString *scheme = @"";
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter://"]]) // Twitter
    {
        scheme = [NSString stringWithFormat:@"twitter://user?screen_name=%@",username];
    }
    else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tweetbot://"]]) // Tweetbot
    {
        scheme = [NSString stringWithFormat:@"tweetbot:///user_profile/%@",username];
    }
    else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitterrific://"]]) // Twitterrific
    {
        scheme = [NSString stringWithFormat:@"twitterrific:///profile?screen_name=%@",username];
    }
    else
    {
        scheme = [NSString stringWithFormat:@"http://twitter.com/%@",username];
    }
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:scheme]];
}

@end