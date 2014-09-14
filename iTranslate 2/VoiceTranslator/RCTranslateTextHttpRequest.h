//
//  RCTranslateTextHttpRequest.h
//  VoiceTranslator
//
//  Created by xuzepei on 12/6/12.
//  Copyright (c) 2012 xuzepei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCHttpRequest.h"

@protocol RCTranslateTextHttpRequestDelegate <NSObject>
@optional
- (void) willStartTranslateTextHttpRequest: (id)token;
- (void) didFinishTranslateTextHttpRequest: (id)result token: (id)token;
- (void) didFailTranslateTextHttpRequest: (id)token;
@end

@interface RCTranslateTextHttpRequest : RCHttpRequest

+ (RCTranslateTextHttpRequest*)sharedInstance;
- (BOOL)request:(NSString*)urlString
	   delegate:(id)delegate
		  token:(id)token;

@end
