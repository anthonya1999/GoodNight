//
//  TodayViewController.m
//  GoodNight Widget
//
//  Created by Anthony Agatiello on 10/29/15.
//  Copyright © 2015 ADA Tech, LLC. All rights reserved.
//

#import "TodayViewController.h"
#import "GammaController.h"

@implementation TodayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *defaultsPath = [[NSBundle mainBundle] pathForResource:@"Defaults" ofType:@"plist"];
    NSDictionary *appDefaults = [NSDictionary dictionaryWithContentsOfFile:defaultsPath];
    [groupDefaults registerDefaults:appDefaults];
    
    self.preferredContentSize = CGSizeMake(320, 80);

    self.toggleButton.layer.cornerRadius = 7;
    self.toggleButton.layer.backgroundColor = [[UIColor grayColor] CGColor];
    self.toggleButton.layer.masksToBounds = YES;
    self.toggleButton.clipsToBounds = YES;
    
    self.darkroomButton.layer.cornerRadius = 7;
    self.darkroomButton.layer.backgroundColor = [[UIColor grayColor] CGColor];
    self.darkroomButton.layer.masksToBounds = YES;
    
    NSUserDefaults *defaults = userDefaults;
    [defaults addSuiteNamed:appGroupID];
    
    [defaults addObserver:self forKeyPath:@"currentOrange" options:NSKeyValueObservingOptionNew context:NULL];
    
    [self updateUI];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self updateUI];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    [self updateUI];
}

- (void)updateUI {
    BOOL enabled = [groupDefaults boolForKey:@"enabled"];
    self.toggleButton.selected = enabled;
    self.toggleButton.layer.backgroundColor = enabled ? [[UIColor colorWithRed:0.8f green:0.495f blue:0.09f alpha:1.0] CGColor] : [[UIColor grayColor] CGColor];
    
    BOOL darkroomEnabled = [groupDefaults boolForKey:@"darkroomEnabled"];
    
    self.darkroomButton.selected = darkroomEnabled;
    self.darkroomButton.layer.backgroundColor = darkroomEnabled ? [[UIColor colorWithRed:0.8f green:0.0f blue:0.0f alpha:1.0] CGColor] : [[UIColor grayColor] CGColor];
    
    self.temperatureLabel.text = darkroomEnabled ? @"Darkroom mode enabled" : [NSString stringWithFormat:@"Current Temperature: %dK", (int)(([groupDefaults floatForKey:@"currentOrange"] * 45 + 20) * 10)*10];
}

- (IBAction)toggleButtonClicked {
    BOOL enabled = [groupDefaults boolForKey:@"enabled"];
    
    if (enabled){
        [GammaController disableOrangeness];
    }
    else{
        [GammaController setDarkroomEnabled:NO];
        [NSThread sleepForTimeInterval:0.1];
        [GammaController enableOrangenessWithDefaults:YES transition:YES];
        [groupDefaults setBool:NO forKey:@"dimEnabled"];
        [groupDefaults setBool:NO forKey:@"rgbEnabled"];
        [groupDefaults setBool:NO forKey:@"whitePointEnabled"];
        [groupDefaults setBool:NO forKey:@"darkroomEnabled"];
    }

    [groupDefaults setBool:YES forKey:@"manualOverride"];
    
    [self updateUI];
}

- (IBAction)darkroomButtonClicked {
    BOOL darkroomEnabled = [groupDefaults boolForKey:@"darkroomEnabled"];
    
    if (darkroomEnabled){
        [groupDefaults setBool:NO forKey:@"enabled"];
        [groupDefaults setBool:NO forKey:@"dimEnabled"];
        [groupDefaults setBool:NO forKey:@"darkroomEnabled"];
        [groupDefaults setBool:NO forKey:@"rgbEnabled"];
        [groupDefaults setBool:NO forKey:@"whitePointEnabled"];
        [groupDefaults setBool:NO forKey:@"manualOverride"];
        
        [GammaController setDarkroomEnabled:NO];
        [NSThread sleepForTimeInterval:0.1];
        [GammaController autoChangeOrangenessIfNeededWithTransition:YES];
    }
    else{
        [GammaController setDarkroomEnabled:YES];
        [groupDefaults setBool:NO forKey:@"enabled"];
        [groupDefaults setBool:NO forKey:@"dimEnabled"];
        [groupDefaults setBool:NO forKey:@"rgbEnabled"];
        [groupDefaults setBool:NO forKey:@"whitePointEnabled"];
        [groupDefaults setBool:YES forKey:@"darkroomEnabled"];
        [groupDefaults setBool:YES forKey:@"manualOverride"];
    }
    
    [self updateUI];
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    completionHandler(NCUpdateResultNewData);
}

- (void)dealloc {
    NSUserDefaults *defaults = userDefaults;
    [defaults addSuiteNamed:appGroupID];
    [defaults removeObserver:self forKeyPath:@"currentOrange"];
}

- (UIEdgeInsets)widgetMarginInsetsForProposedMarginInsets:(UIEdgeInsets)defaultMarginInsets
{
    return UIEdgeInsetsZero;
}

@end