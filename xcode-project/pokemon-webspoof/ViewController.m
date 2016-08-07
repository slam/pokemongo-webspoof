//
//  ViewController.m
//  pokemon-webspoof
//
//  Created by iam4x on 15/07/2016.
//  Copyright © 2016 iam4x. All rights reserved.
//

#import "ViewController.h"
#import "AVFoundation/AVFoundation.h"
#import "AudioToolbox/AudioToolbox.h"
@import CoreLocation;

static NSString * const kURLScheme = @"com.googleusercontent.apps.848232511240-dmrj3gba506c9svge2p9gq35p1fg654p://";

@interface ViewController () <AVAudioPlayerDelegate, CLLocationManagerDelegate>

@property (nonatomic, strong)  AVAudioPlayer *backgroundAudioPlayer; //Plays silent audio in the background to keep
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *lastLocation;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (strong, nonatomic) IBOutlet UITextView *gpsText;
- (IBAction)launchPokemonGo:(id)sender;
- (IBAction)backgroundAppSwitchChanged:(id)sender;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSError* catError = nil;
    NSError* activeError = nil;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionMixWithOthers error:&catError]; //Allows the silent audio to play along side iTunes
    [[AVAudioSession sharedInstance] setActive:YES error:&activeError];
    if (!activeError && !catError) {
        [self setupAndPlay];
    }

    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setDateFormat:@"HH:mm:ss"];

    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    [self.locationManager startUpdatingLocation];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    // self.gpsText.text = @"";
}

#pragma mark - Sound Stuff

-(void)setupAndPlay {
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"silent" ofType:@"mp3"]];
    self.backgroundAudioPlayer=[[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    self.backgroundAudioPlayer.numberOfLoops=-1;

    
    [self.backgroundAudioPlayer play];
}
#pragma mark - Actions

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {

    CLLocation *currentlocation = [locations lastObject];
    CLLocationDistance distance = 0.0;
    if (self.lastLocation != nil) {
        distance = [self.lastLocation distanceFromLocation:currentlocation];
    }

    NSString *date = [self.dateFormatter stringFromDate:currentlocation.timestamp];
    NSString *s = [NSString stringWithFormat:@"%@ <%.8f,%.8f,%.0fm> <%.0fm,%.0fm> %.2fm\n",
                   date,
                   currentlocation.coordinate.latitude,
                   currentlocation.coordinate.longitude,
                   currentlocation.horizontalAccuracy,
                   currentlocation.altitude,
                   currentlocation.verticalAccuracy,
                   distance];
    NSString *append = [self.gpsText.text stringByAppendingString:s];
    self.gpsText.text = append;

    // Scroll to bottom
    if (self.gpsText.text.length > 0) {
        NSRange range = NSMakeRange(self.gpsText.text.length - 1, 1);
        [self.gpsText scrollRangeToVisible:range];
    }

    self.lastLocation = currentlocation;
}

- (IBAction)launchPokemonGo:(id)sender {
    
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:kURLScheme]]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kURLScheme]];
    }
}

- (IBAction)backgroundAppSwitchChanged:(id)sender {
    
    if ([(UISwitch*)sender isOn]) {
        [self setupAndPlay];
    }
    else{
        [self.backgroundAudioPlayer stop];
        self.backgroundAudioPlayer = nil;
    }
}
@end
