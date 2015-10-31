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
    
    self.enableButton.layer.cornerRadius = 7;
    self.enableButton.layer.backgroundColor = [[UIColor grayColor] CGColor];
    self.enableButton.layer.masksToBounds = YES;
    
    self.disableButton.layer.cornerRadius = 7;
    self.disableButton.layer.backgroundColor = [[UIColor grayColor] CGColor];
    self.disableButton.layer.masksToBounds = YES;
    
    if (self.view.bounds.size.width > 320) {
        self.enableButton.frame = CGRectMake(self.enableButton.frame.origin.x + 30, self.enableButton.frame.origin.y, self.enableButton.frame.size.width, self.enableButton.frame.size.height);
        self.disableButton.frame = CGRectMake(self.disableButton.frame.origin.x + 30, self.disableButton.frame.origin.y, self.disableButton.frame.size.width, self.disableButton.frame.size.height);
        self.temperatureLabel.frame = CGRectMake(self.temperatureLabel.frame.origin.x + 30, self.temperatureLabel.frame.origin.y, self.temperatureLabel.frame.size.width, self.temperatureLabel.frame.size.height);
    }
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