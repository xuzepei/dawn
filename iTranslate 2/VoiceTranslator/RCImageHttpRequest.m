//
//  RCImageHttpRequest.m
//  rsscoffee
//
//  Created by xuzepei on 5/9/10.
//  Copyright 2010 Rumtel Co.,Ltd. All rights reserved.
//

//图片下载类

#import "RCImageHttpRequest.h"
#import "RCTool.h"


@implementation RCImageHttpRequest

+ (RCImageHttpRequest*)sharedInstance
{
	static RCImageHttpRequest* sharedInstance = nil;
	if(nil == sharedInstance)
	{
		@synchronized([RCImageHttpRequest class])
		{
            if (nil == sharedInstance)
            {
                sharedInstance = [[RCImageHttpRequest alloc] init];
            }
		}
	}
	
	return sharedInstance;
}

- (id)init
{
	if(self = [super init])
	{
		
	}
	
	return self;
}

- (void)dealloc
{
	[super dealloc];
}

- (void)saveImage: (NSString*)url delegate: (id)delegate token:(id)token
{
	_saveToLocal = YES;
	self._delegate = delegate;
	self._token = token;
	
	NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
	NSString* urlString = url;
	self._requestingURL = urlString;
	urlString = [urlString stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
	[request setURL:[NSURL URLWithString: urlString]];
	[request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
	[request setTimeoutInterval: TIME_OUT];
	[request setHTTPShouldHandleCookies:FALSE];
	[request setHTTPMethod:@"GET"];
	
	NSLog(@"saveImage: %@",urlString);
	
    NSURLConnection * urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
    
	if (urlConnection)
	{
        self._urlConnection = urlConnection;
        
		_isConnecting = YES;
		[_receivedData setLength:0];
		
		NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:
							  self._requestingURL, @"url",
							  self._token,@"token",nil];
		if([_delegate respondsToSelector: @selector(willStartHttpRequest:)])
			[_delegate willStartHttpRequest:dict];
	}
    [urlConnection release];
}

- (void)downloadImage: (NSString*)url delegate:(id)delegate token:(id)token
{
	_saveToLocal = NO;
	self._delegate = delegate;
	self._token = token;
	
	NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
	NSString* urlString = url;
	self._requestingURL = urlString;
	urlString = [urlString stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
	[request setURL:[NSURL URLWithString: urlString]];
	[request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
	[request setTimeoutInterval: TIME_OUT];
	[request setHTTPShouldHandleCookies:FALSE];
	[request setHTTPMethod:@"GET"];
//    [request setValue:@"http://wradio.fm" forHTTPHeaderField:@"Referer"];
//    [request setValue:@"keep-alive" forHTTPHeaderField:@"Connection"];
	
	NSLog(@"downloadImage: %@",urlString);
	
    NSURLConnection * urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
    
	if (urlConnection)
	{
        self._urlConnection = urlConnection;
        
		_isConnecting = YES;
		[_receivedData setLength:0];
		[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
		
		NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:
							  self._requestingURL, @"url",
							  self._token,@"token",nil];
		if([_delegate respondsToSelector: @selector(willStartHttpRequest:)])
			[_delegate willStartHttpRequest:dict];
	}
    [urlConnection release];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	NSLog(@"downloadImage:connectionDidFinishLoading- statusCode:%d",_statusCode);
	
	if(200 == _statusCode)
	{
		UIImage* image = [UIImage imageWithData: _receivedData];
		
		if(image)
		{
			if(_saveToLocal)
			{
				[RCTool saveImage:_receivedData path:self._requestingURL];
			}
			
			NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:
								  self._requestingURL, @"url",
								  [NSNumber numberWithBool:_saveToLocal],@"isSaved",
								  self._token,@"token",nil];
			if([_delegate respondsToSelector: @selector(didFinishHttpRequest:token:)])
				[_delegate didFinishHttpRequest: image token: dict];
		}
	}
	else
	{
		NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:
							  self._requestingURL, @"url",
							  self._token,@"token",nil];
		if([_delegate respondsToSelector: @selector(didFailHttpRequest:)])
			[_delegate didFailHttpRequest:dict];
	}
	
	_isConnecting = NO;
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	[_receivedData setLength:0];
	
    [super connectionDidFinishLoading:connection];
}

- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error
{
	NSLog(@"downloadImage:didFailWithError- statusCode:%d",_statusCode);
	
	NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:
						  self._requestingURL, @"url",
						  self._token,@"token",nil];
	if([_delegate respondsToSelector: @selector(didFailHttpRequest:)])
		[_delegate didFailHttpRequest:dict];
	
	_isConnecting = NO;
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	[_receivedData setLength:0];
    
    
    [super connection:connection didFailWithError:error];
}

@end
