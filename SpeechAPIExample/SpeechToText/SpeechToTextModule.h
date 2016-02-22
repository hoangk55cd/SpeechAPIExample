//
//  VoiceAddModule.h
//  AstridiPhone
//
//  Created by Sam Bosley on 10/7/11.
//  Copyright (c) 2011 Todoroo. All rights reserved.
//
//  Modified by Hoang on 22/02/2016

#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import <speex/speex.h>

#define kNumberBuffers 3
#define kNumVolumeSamples 10
#define kSilenceThresholdDB -30.0

#define kVolumeSamplingInterval 0.05
#define kSilenceTimeThreshold 0.9
#define kSilenceThresholdNumSamples kSilenceTimeThreshold / kVolumeSamplingInterval

#define GARBAGE_RESULT_VALUE @"{\"result\":[]}"

// For scaling display
#define kMinVolumeSampleValue 0.01
#define kMaxVolumeSampleValue 1.0
typedef struct AQRecorderState {
    AudioStreamBasicDescription  mDataFormat;
    AudioQueueRef                mQueue;
    AudioQueueBufferRef          mBuffers[kNumberBuffers];
    UInt32                       bufferByteSize;
    SInt64                       mCurrentPacket;
    bool                         mIsRunning;
    
    SpeexBits                    speex_bits;
    void *                       speex_enc_state;
    int                          speex_samples_per_frame;
    __unsafe_unretained NSMutableData *              encodedSpeexData;
    
    __unsafe_unretained id selfRef;
} AQRecorderState;

@protocol SpeechToTextModuleDelegate <NSObject>

// Delegate will need to parse JSON and dismiss loading view if presented
// returns true on success, false on failure
- (BOOL)didReceiveVoiceResponse:(NSDictionary *)data;

@optional
- (void)showLoadingView;
- (void)requestFailedWithError:(NSError *)error;
@end

@interface SpeechToTextModule : NSObject <UIAlertViewDelegate> {
    UIAlertView *status;
    
    AQRecorderState aqData;
    
    BOOL detectedSpeech;
    int samplesBelowSilence;
    
    NSTimer *meterTimer;
    BOOL processing;
    
    NSMutableArray *volumeDataPoints;
    NSThread *processingThread;
}

@property (readonly) BOOL recording;
@property (nonatomic, strong) id<SpeechToTextModuleDelegate> delegate;

/* Caller can pass a non-nil nib name to specify the nib with which to create
 a SineWaveViewController (nib should conform to the spec in the SineWaveViewController
 interface). A nil argument will cause the module to display an alert view instead
 of the custom view controller. */
- (id)initWithCustomDisplay:(NSString *)nibName;

// Begins a voice recording
- (void)beginRecording;

// Stops a voice recording. The startProcessing parameter is intended for internal use,
// so don't pass NO unless you really mean it.
- (void)stopRecording:(BOOL)startProcessing;
@end
