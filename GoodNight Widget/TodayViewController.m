//
//  TodayViewController.m
//  GoodNight Widget
//
//  Created by Anthony Agatiello on 10/29/15.
//  Copyright © 2015 ADA Tech, LLC. All rights reserved.
//

#import "TodayViewController.h"

@implementation TodayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.preferredContentSize = CGSizeMake(0, 110);
}

- (IBAction)enableButtonClicked {
    [self.extensionContext openURL:[NSURL URLWithString:@"goodnight://enable"] completionHandler:nil];
}

- (IBAction)disableButtonClicked {
    [self.extensionContext openURL:[NSURL URLWithString:@"goodnight://disable"] completionHandler:nil];
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    completionHandler(NCUpdateResultNewData);
}

@end