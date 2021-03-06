//
//  JTCameraEngine.h
//  JTVideoRecorder
//
//  Created by jeremy Templier on 13/07/2013.
//  Copyright (c) 2013 jeremy Templier. All rights reserved.
//



#import <Foundation/Foundation.h>
#import "AVFoundation/AVCaptureSession.h"
#import "AVFoundation/AVCaptureOutput.h"
#import "AVFoundation/AVCaptureDevice.h"
#import "AVFoundation/AVCaptureInput.h"
#import "AVFoundation/AVCaptureVideoPreviewLayer.h"
#import "AVFoundation/AVMediaFormat.h"

@class JTCameraEngine;
@protocol JTCameraEngineDelegate <NSObject>
- (void)cameraEngine:(JTCameraEngine *)engine didProcessImage:(CGImageRef)imageRef;
@end

@interface JTCameraEngine : NSObject

+ (JTCameraEngine*) engine;
- (void) startup;
- (void) shutdown;
- (AVCaptureVideoPreviewLayer*) getPreviewLayer;

- (void) startCapture;
- (void) pauseCapture;
- (void) stopCapture;
- (void) resumeCapture;
- (AVCaptureVideoPreviewLayer*)getFrontCameraPreviewLayerInstance;

@property (nonatomic, assign) id<JTCameraEngineDelegate> delegate;
@property (atomic, readwrite) BOOL isCapturing;
@property (atomic, readwrite) BOOL isPaused;

@end
