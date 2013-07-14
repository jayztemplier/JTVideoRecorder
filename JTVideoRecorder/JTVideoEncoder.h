//
//  JTVideoEncoder.h
//  JTVideoRecorder
//
//  Created by jeremy Templier on 13/07/2013.
//  Copyright (c) 2013 jeremy Templier. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "AVFoundation/AVAssetWriter.h"
#import "AVFoundation/AVAssetWriterInput.h"
#import "AVFoundation/AVMediaFormat.h"
#import "AVFoundation/AVVideoSettings.h"
#import "AVFoundation/AVAudioSettings.h"

@interface JTVideoEncoder : NSObject
{
    AVAssetWriter* _writer;
    AVAssetWriterInput* _videoInput;
    AVAssetWriterInput* _audioInput;
    NSString* _path;
}

@property NSString* path;

+ (JTVideoEncoder*) encoderForPath:(NSString*) path Height:(int) cy width:(int) cx channels: (int) ch samples:(Float64) rate;

- (void) initPath:(NSString*)path Height:(int) cy width:(int) cx channels: (int) ch samples:(Float64) rate;
- (void) finishWithCompletionHandler:(void (^)(void))handler;
- (BOOL) encodeFrame:(CMSampleBufferRef) sampleBuffer isVideo:(BOOL) bVideo;
- (void)cropVideoAtURL:(NSURL *)url completion:(void (^)(void))handler;
@end
