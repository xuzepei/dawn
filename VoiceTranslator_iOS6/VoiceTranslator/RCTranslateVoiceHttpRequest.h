//
//  RCTranslateVoiceHttpRequest.h
//  VoiceTranslator
//
//  Created by xuzepei on 11/10/12.
//  Copyright (c) 2012 xuzepei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCHttpRequest.h"

@protocol RCTranslateVoiceHttpRequestDelegate <NSObject>
@optional
- (void) willStartTranslateVoiceHttpRequest: (id)token;
- (void) didFinishTranslateVoiceHttpRequest: (id)result token: (id)token;
- (void) didFailTranslateVoiceHttpRequest: (id)token;
@end

@interface RCTranslateVoiceHttpRequest : RCHttpRequest

+ (RCTranslateVoiceHttpRequest*)sharedInstance;
- (BOOL)request:(NSString*)urlString
	   delegate:(id)delegate
		  token:(NSDictionary*)token;

@end
