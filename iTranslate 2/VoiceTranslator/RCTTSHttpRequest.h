//
//  RCTTSHttpRequest.h
//  VoiceTranslator
//
//  Created by xuzepei on 12/6/12.
//  Copyright (c) 2012 xuzepei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCHttpRequest.h"

@protocol RCTTSHttpRequestDelegate <NSObject>
@optional
- (void) willStartTTSHttpRequest: (id)token;
- (void) didFinishTTSHttpRequest: (id)result token: (id)token;
- (void) didFailTTSHttpRequest: (id)token;
@end

@interface RCTTSHttpRequest : RCHttpRequest

+ (RCTTSHttpRequest*)sharedInstance;
- (BOOL)request:(NSString*)urlString
	   delegate:(id)delegate
		  token:(id)token;

@end
