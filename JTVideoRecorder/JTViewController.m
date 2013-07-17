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
#import "UIImage+DSP.h"
#import "GPUImagePicture.h"
#import "GPUImageGaussianBlurFilter.h"

#define kBubbleSize 30
#define kTimeBetweenBubbleCreation .5

@interface JTViewController ()
@property (strong, nonatomic) IBOutlet UIView *videoPreviewContainer;
@property (strong, nonatomic) IBOutlet UILabel *statusLabel;
@property (strong, nonatomic) UIImageView *backgroundImageView;
@property (nonatomic, assign) BOOL started;
@property (assign, nonatomic) CGFloat value;
@property (strong, nonatomic) UIImage *nextPhoto;
@property (strong, nonatomic) NSTimer *bubbleTimer;
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

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self startBubbleTimer];
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
    if (!_nextPhoto) {
        if (imageRef != nil) {
            UIImage *image= [UIImage imageWithCGImage:imageRef];
            _nextPhoto = [self bluredImageOfImage:image];
//            [_backgroundImageView setImage:blurImage];
            
        }
    }
}   

- (UIImage *)bluredImageOfImage:(UIImage *)image
{
    GPUImageGaussianBlurFilter *blurFilter =[[GPUImageGaussianBlurFilter alloc] init];
    blurFilter.blurSize = 3.5;
    UIImage *result = [blurFilter imageByFilteringImage:image];
    return result;
}

- (IBAction)sliderValueChanged:(UISlider *)sender {
    _value = sender.value;
}

#pragma mark - Photo Bubble
- (void)startBubbleTimer
{
    if (_bubbleTimer && [_bubbleTimer isValid]) {
        [_bubbleTimer invalidate];
    }
    _bubbleTimer = [NSTimer scheduledTimerWithTimeInterval:kTimeBetweenBubbleCreation target:self selector:@selector(createNewPhotoBubble) userInfo:nil repeats:YES];
}

- (void)createNewPhotoBubble
{
    if (!_nextPhoto) {
        return;
    }
    // Get random value between 0 and 99
    int x = arc4random() % (int)CGRectGetWidth(self.view.bounds);
    // Get random number between 500 and 1000
//    int y =  (arc4random() % 501) + 500;
    
    CALayer *layer = [CALayer layer];
    layer.contents = (id)_nextPhoto.CGImage;
    layer.backgroundColor = [UIColor redColor].CGColor;
    layer.frame = CGRectMake(x, -kBubbleSize, kBubbleSize, kBubbleSize);
    layer.cornerRadius = kBubbleSize/2;
//    CAShapeLayer *circleLayer = [CAShapeLayer layer];
//    circleLayer.path = NSBe
    layer.borderWidth = 1.f;
    layer.masksToBounds = YES;
    layer.borderColor = ([[JTCameraEngine engine] isCapturing] && ![[JTCameraEngine engine] isPaused])? [UIColor redColor].CGColor : [UIColor blackColor].CGColor;
    [_backgroundImageView.layer addSublayer:layer];
    _nextPhoto = nil;
    [CATransaction begin]; {
        [CATransaction setCompletionBlock:^{
            [layer removeFromSuperlayer];
        }];
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
        animation.fromValue = [NSValue valueWithCGPoint:layer.position];
        layer.position = CGPointMake(x, CGRectGetHeight(self.view.bounds) + kBubbleSize); // HERE I UPDATE THE MODEL LAYER'S PROPERTY
        animation.toValue = [NSValue valueWithCGPoint:layer.position];
        animation.duration = 10.0;
        [layer addAnimation:animation forKey:animation.keyPath];
    } [CATransaction commit];
    
}

@end
