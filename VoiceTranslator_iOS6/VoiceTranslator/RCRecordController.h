//
//  RCRecordController.h
//  VoiceTranslator
//
//  Created by xuzepei on 11/10/12.
//  Copyright (c) 2012 xuzepei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AQPlayer.h"
#import "AQRecorder.h"

@protocol RCRecordControllerDelegate <NSObject>

@optional
- (void)willStartRecording:(id)token;
- (void)willStopRecording:(id)token;

@end

@interface RCRecordController : NSObject

@property (readonly)AQPlayer *player;
@property (readonly)AQRecorder *recorder;
@property (nonatomic,retain)NSString* language;
@property (assign)RECORD_BUTTON_TYPE type;
@property (assign)id delegate;
@property (nonatomic,retain)NSString* filename;

- (void)initRecorder;
- (void)record:(NSString*)filename;
- (void)stop;
- (BOOL)isRecording;

@end
