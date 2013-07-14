//
//  JTViewController.m
//  JTVideoRecorder
//
//  Created by jeremy Templier on 13/07/2013.
//  Copyright (c) 2013 jeremy Templier. All rights reserved.
//

#import "JTViewController.h"
#import "JTCameraEngine.h"

@interface JTViewController ()
@property (strong, nonatomic) IBOutlet UIView *videoPreviewContainer;
@property (strong, nonatomic) IBOutlet UILabel *statusLabel;
@property (nonatomic, assign) BOOL started;
@end

@implementation JTViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self startPreview];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(saveVideo )];
    tapGesture.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:tapGesture];
    
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGestureHandler:)];
    longPressGesture.minimumPressDuration = 0.3;
    [self.view addGestureRecognizer:longPressGesture];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Video
- (void) startPreview
{
    AVCaptureVideoPreviewLayer* preview = [[JTCameraEngine engine] getPreviewLayer];
    [preview removeFromSuperlayer];
    preview.frame = _videoPreviewContainer.bounds;
    [[preview connection] setVideoOrientation:AVCaptureVideoOrientationPortrait];
    [_videoPreviewContainer.layer addSublayer:preview];
}

#pragma mark Gestures
- (void)longPressGestureHandler:(UILongPressGestureRecognizer *)gesture
{
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
            [self startOrResumeRecording];
            break;
        case UIGestureRecognizerStateEnded:
            [self pauseRecording];
            break;
        case UIGestureRecognizerStateCancelled:
            [self pauseRecording];
            break;
        default:
            break;
    }
}

- (void)startOrResumeRecording
{
    if (_started) {
        [[JTCameraEngine engine] resumeCapture];
    } else {
        _started = YES;
        [[JTCameraEngine engine] startCapture];
    }
    _statusLabel.text = @"Recording";
}

- (void)pauseRecording
{
    [[JTCameraEngine engine] pauseCapture];
    _statusLabel.text = @"Pause";
}

- (void)saveVideo
{
    _started = NO;
    [[JTCameraEngine engine] stopCapture];
    _statusLabel.text = @"Saved!";
}

@end
