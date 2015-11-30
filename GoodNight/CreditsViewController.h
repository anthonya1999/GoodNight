//
//  FirstViewController.h
//  GoodNight
//
//  Created by Anthony Agatiello on 10/4/15.
//  Copyright © 2015 ADA Tech, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <SafariServices/SFSafariViewController.h>

static NSString *username = nil;
static BOOL webViewShouldAppear = NO;

@interface CreditsViewController : UITableViewController <SFSafariViewControllerDelegate, UIViewControllerPreviewingDelegate>

@end