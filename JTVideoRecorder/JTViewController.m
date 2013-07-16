//
//  JTViewController.m
//  JTVideoRecorder
//
//  Created by jeremy Templier on 13/07/2013.
//  Copyright (c) 2013 jeremy Templier. All rights reserved.
//

#import "JTViewController.h"
#import "JTCameraEngine.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImage+StackBlur.h"

@interface JTViewController ()
@property (strong, nonatomic) IBOutlet UIView *videoPreviewContainer;
@property (strong, nonatomic) IBOutlet UILabel *statusLabel;
@property (strong, nonatomic) UIImageView *backgroundImageView;
@property (nonatomic, assign) BOOL started;
@end

@implementation JTViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _backgroundImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    [self.view insertSubview:_backgroundImageView belowSubview:_videoPreviewContainer];
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
    [JTCameraEngine engine].delegate = self;
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

#pragma mark Camera bubbles
- (void)addCameraBubble
{
    CALayer *videoLayer = (CALayer *)[[JTCameraEngine engine] getFrontCameraPreviewLayerInstance];
    videoLayer.cornerRadius = 20.f;
    CAReplicatorLayer *xLayer = [CAReplicatorLayer layer];
    xLayer.instanceCount = 3;
    xLayer.instanceDelay = .2;
    xLayer.instanceGreenOffset = -.03;
    xLayer.instanceRedOffset = -.02;
    xLayer.instanceBlueOffset = -.01;
    xLayer.instanceAlphaOffset = -.05;
    xLayer.preservesDepth = YES;
    xLayer.instanceTransform = CATransform3DMakeTranslation(110, 0, 0);
    [xLayer addSublayer:videoLayer];
    [self.view.layer addSublayer:xLayer];
}

#pragma mark - Camera Engine Delegate
- (void)cameraEngine:(JTCameraEngine *)engine didProcessImage:(CGImageRef)imageRef
{
    if (imageRef != nil) {
        UIImage *image= [UIImage imageWithCGImage:imageRef];
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            UIImage *blurImage = [image stackBlur:50];
//            dispatch_async(dispatch_get_main_queue(), ^{
                [_backgroundImageView setImage:blurImage];
//            });
//        });
    }
}

@end
