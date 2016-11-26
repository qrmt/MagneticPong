//
//  GameViewController.m
//  Pong
//
//  Created by Oskar Vuola on 26/11/16.
//  Copyright © 2016 blastly. All rights reserved.
//

#import "GameViewController.h"
#import "GameScene.h"
#import "BLMagManager.h"

@interface GameViewController ()

@property (nonatomic, strong) BLMagManager *magnetometerManager;
@property (nonatomic, strong) GameScene *scene;
@property BOOL flag;

@end

@implementation GameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _flag = YES;
    
    // Initialize Magnetometer manager
    _magnetometerManager = [[BLMagManager alloc] init];
    if (_magnetometerManager != nil) {
        [_magnetometerManager startMagnetometerUpdates];
    }


    // Load the SKScene from 'GameScene.sks'
    GameScene *scene = (GameScene *)[SKScene nodeWithFileNamed:@"GameScene"];
    
    // Set the scale mode to scale to fit the window
    scene.scaleMode = SKSceneScaleModeAspectFill;
    _scene = scene;
    
    SKView *skView = (SKView *)self.view;
    
    // Present the scene
    [skView presentScene:scene];
    
    skView.showsFPS = YES;
    skView.showsNodeCount = YES;

    [NSTimer scheduledTimerWithTimeInterval:0.01
                                     target:self
                                   selector:@selector(updateData)
                                   userInfo:nil
                                    repeats:YES];
    
    // Subscribe to calibration notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(calibrate:)
                                                 name:@"CalibrationNotification"
                                               object:nil];

}

// Calibration notification
- (void) calibrate:(NSNotification *) notification
{
    [_magnetometerManager calibrate];
    
}


- (void)updateData {
    NSArray *latestSmoothedData = [_magnetometerManager latestMagnetometerData];
    //NSLog(@"Rotating: %@", latestSmoothedData[@"rotating"]);
    float x = [latestSmoothedData[0] floatValue];
    float y = [latestSmoothedData[1] floatValue];
    float z = [latestSmoothedData[2] floatValue];
    float total = [latestSmoothedData[3] floatValue];
    float direction = [latestSmoothedData[4] integerValue];
    
    [self updateLatestLocationDataX:x Y:y Z:z total:total direction:direction];
}

// Magnetometer update
- (void)updateLatestLocationDataX:(float)x Y:(float)y Z:(float)z total:(float)total direction:(int)direction {
    if (total != 0 && _flag) {
        _flag = NO;
        [_magnetometerManager calibrate];
    }
    
    total = powf(x, 2);
    total = sqrt(total);
    //NSLog(@"Got magnetometer data: %f, %f, %f, %f", x, y, z, total);
    CGRect frame = _scene.frame;
    float frame_height = frame.size.height;
    float scaler = frame_height / 1000;
    total = total * scaler;
     
    
    [_scene updateYcoord:total];
}


- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskPortrait;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end
