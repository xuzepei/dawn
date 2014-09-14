//
//  RCTranslateProcess.h
//  VoiceTranslator
//
//  Created by xuzepei on 12/6/12.
//  Copyright (c) 2012 xuzepei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCTranslateVoiceHttpRequest.h"
#import "RCTranslateTextHttpRequest.h"
#import "RCTTSHttpRequest.h"
#import "Translation.h"

@protocol RCTranslateProcessDelegate <NSObject>

@optional
- (void) willStartTranslateProcess: (id)token;
- (void) didFinishTranslateProcess: (id)result token: (id)token;
- (void) didFailTranslateProcess:(int)errorType token:(id)token;

- (void) didFinishedTranslateVoiceToText:(Translation*)translation;
- (void) didFinishedTranslateFromText:(Translation*)translation;
- (void) didFailedTranslateFromText:(Translation*)translation;
@end

@interface RCTranslateProcess : NSObject

@property (assign)id delegate;
@property (nonatomic,retain)NSString* recordFilePath;
@property (nonatomic,retain)NSString* fromLanguage;
@property (nonatomic,retain)NSString* toLanguage;
@property (nonatomic,retain)NSDictionary* token;
@property (assign)BOOL isTranslating;
@property (nonatomic,retain)RCTranslateVoiceHttpRequest* translateVoiceHttpRequest;
@property (nonatomic,retain)RCTranslateTextHttpRequest* translateTextHttpRequest;
@property (nonatomic,retain)RCTTSHttpRequest* ttsHttpRequest;

+ (RCTranslateProcess*)sharedInstance;
- (BOOL)translate:(NSString*)recordFilePath fromLanguage:(NSString*)fromLanguage toLanguage:(NSString*)toLanguage delegate:(id)delegate token:(NSDictionary*)token;
- (BOOL)translateText:(Translation*)translation delegate:(id)delegate;

@end
