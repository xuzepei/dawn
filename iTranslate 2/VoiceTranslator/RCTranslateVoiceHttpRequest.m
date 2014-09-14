//
//  RCTranslateVoiceHttpRequest.m
//  VoiceTranslator
//
//  Created by xuzepei on 11/10/12.
//  Copyright (c) 2012 xuzepei. All rights reserved.
//

#import "RCTranslateVoiceHttpRequest.h"
#import "RCTool.h"

@implementation RCTranslateVoiceHttpRequest

+ (RCTranslateVoiceHttpRequest*)sharedInstance
{
	static RCTranslateVoiceHttpRequest* sharedInstance = nil;
	if(nil == sharedInstance)
	{
		@synchronized([RCTranslateVoiceHttpRequest class])
		{
            if(nil == sharedInstance)
                sharedInstance = [[RCTranslateVoiceHttpRequest alloc] init];
		}
	}
	
	return sharedInstance;
}

- (BOOL)request:(NSString*)urlString delegate:(id)delegate token:(NSDictionary*)token
{
    if(_isConnecting || _urlConnection)
        return NO;
    
	self._delegate = delegate;
	self._token = token;
    
	NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
	self._requestingURL = urlString;
	urlString = [urlString stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
	[request setURL:[NSURL URLWithString: urlString]];
	[request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
	[request setTimeoutInterval: TIME_OUT];
	[request setHTTPShouldHandleCookies:FALSE];
	[request setHTTPMethod:@"POST"];
    [request setValue:@"audio/x-speex-with-header-byte;rate=16000" forHTTPHeaderField:@"Content-Type"];

    NSData* recordFileData = [NSData dataWithContentsOfFile:[RCTool getRecordFilePath:[token objectForKey:@"filename"]]];
    if(recordFileData)
      [request setHTTPBody: recordFileData];
    else
        return NO;
    
    NSLog(@"translate voice: %@",urlString);
	
    _urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
	if(_urlConnection)
	{
		_isConnecting = YES;
		[_receivedData setLength: 0];
        
		[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
		
        NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
        [dict setObject:self._requestingURL forKey:@"url"];
        if(self._token)
            [dict addEntriesFromDictionary:self._token];
        
		if([_delegate respondsToSelector: @selector(willStartTranslateVoiceHttpRequest:)])
			[_delegate willStartTranslateVoiceHttpRequest:dict];
        
        [dict release];
		
        return YES;
	}
    
    return NO;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	NSLog(@"translate voice:connectionDidFinishLoading- statusCode:%d",_statusCode);
	
	if(200 == _statusCode)
	{
		NSString* jsonString = [[NSString alloc] initWithData:_receivedData encoding:NSUTF8StringEncoding];
		
        NSDictionary* data = [RCTool parseJSON:jsonString];
		[jsonString release];
		
		_isConnecting = NO;
		[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
		[_receivedData setLength:0];
		self._urlConnection = nil;
		
        NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
        [dict setObject:self._requestingURL forKey:@"url"];
        if(self._token)
            [dict addEntriesFromDictionary:self._token];
        
		if([_delegate respondsToSelector: @selector(didFinishTranslateVoiceHttpRequest:token:)])
			[_delegate didFinishTranslateVoiceHttpRequest:data token:dict];
        
        [dict release];
	}
	else
	{
		
		_isConnecting = NO;
		[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
		[_receivedData setLength:0];
		self._urlConnection = nil;
		
        NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
        [dict setObject:self._requestingURL forKey:@"url"];
        if(self._token)
            [dict addEntriesFromDictionary:self._token];
        
		if([_delegate respondsToSelector: @selector(didFailTranslateVoiceHttpRequest:)])
			[_delegate didFailTranslateVoiceHttpRequest:dict];
        
        [dict release];
	}
	
    
}

- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error
{
	NSLog(@"translate voice:didFailWithError - statusCode:%d",_statusCode);
	
	_isConnecting = NO;
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	[_receivedData setLength: 0];
    self._urlConnection = nil;
	
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    [dict setObject:self._requestingURL forKey:@"url"];
    if(self._token)
        [dict addEntriesFromDictionary:self._token];
	
    if(_delegate && [_delegate respondsToSelector:@selector(didFailTranslateVoiceHttpRequest:)])
    {
        [_delegate didFailTranslateVoiceHttpRequest:dict];
    }
    
    [dict release];
}

@end
