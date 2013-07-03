//
//  RCTranslateTextHttpRequest.m
//  VoiceTranslator
//
//  Created by xuzepei on 12/6/12.
//  Copyright (c) 2012 xuzepei. All rights reserved.
//

#import "RCTranslateTextHttpRequest.h"
#import "RCTool.h"
#import "Translation.h"

@implementation RCTranslateTextHttpRequest

+ (RCTranslateTextHttpRequest*)sharedInstance
{
	static RCTranslateTextHttpRequest* sharedInstance = nil;
	if(nil == sharedInstance)
	{
		@synchronized([RCTranslateTextHttpRequest class])
		{
            if(nil == sharedInstance)
                sharedInstance = [[RCTranslateTextHttpRequest alloc] init];
		}
	}
	
	return sharedInstance;
}

- (BOOL)request:(NSString*)urlString delegate:(id)delegate token:(id)token
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
	[request setHTTPMethod:@"GET"];
    
    NSLog(@"translate text: %@",urlString);
	
    _urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
	if(_urlConnection)
	{
		_isConnecting = YES;
		[_receivedData setLength: 0];
        
		[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
		
//        NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
//        if(self._token)
//            [dict addEntriesFromDictionary:self._token];
//        [dict setObject:self._requestingURL forKey:@"url"];
        
		if([_delegate respondsToSelector: @selector(willStartTranslateTextHttpRequest:)])
			[_delegate willStartTranslateTextHttpRequest:self._token];
        //[dict release];
		
        return YES;
	}
    
    return NO;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	NSLog(@"translate text:connectionDidFinishLoading- statusCode:%d",_statusCode);
	
	if(200 == _statusCode)
	{
		NSString* jsonString = [[NSString alloc] initWithData:_receivedData encoding:NSUTF8StringEncoding];
		
        NSDictionary* data = [RCTool parseJSON:jsonString];
		[jsonString release];
        
        if(data && [data isKindOfClass:[NSDictionary class]])
        {
            _isConnecting = NO;
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            [_receivedData setLength:0];
            self._urlConnection = nil;

            Translation* translation = (Translation*)self._token;
            translation.textUrl = self._requestingURL;
            if([_delegate respondsToSelector: @selector(didFinishTranslateTextHttpRequest:token:)])
                [_delegate didFinishTranslateTextHttpRequest:data token:translation];
            return;
        }
	}

		
    _isConnecting = NO;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [_receivedData setLength:0];
    self._urlConnection = nil;

    if([_delegate respondsToSelector: @selector(didFailTranslateTextHttpRequest:)])
        [_delegate didFailTranslateTextHttpRequest:self._token];
}

- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error
{
	NSLog(@"translate text:didFailWithError - statusCode:%d",_statusCode);
	
	_isConnecting = NO;
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	[_receivedData setLength: 0];
    self._urlConnection = nil;

	if([_delegate respondsToSelector: @selector(didFailTranslateTextHttpRequest:)])
		[_delegate didFailTranslateTextHttpRequest:self._token];
}

@end
