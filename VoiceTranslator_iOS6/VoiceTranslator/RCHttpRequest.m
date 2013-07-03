//
//  RCHttpRequest.m
//  rsscoffee
//
//  Created by beer on 8/11/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "RCHttpRequest.h"


@implementation RCHttpRequest
@synthesize _receivedData;
@synthesize _isConnecting;
@synthesize _delegate;
@synthesize _statusCode;
@synthesize _contentType;
@synthesize _requestType;
@synthesize _requestingURL;
@synthesize _token;
@synthesize _expectedContentLength;
@synthesize _currentLength;
@synthesize _urlConnection;

- (id)init
{
	if(self = [super init])
	{
		_receivedData = [[NSMutableData alloc] init];
		_isConnecting = NO;
		_contentType = CT_UNKNOWN;
		_requestType = -1;
		_expectedContentLength = 0;
		_currentLength = 0;
	}
	
	return self;
}

- (void)dealloc
{
	_isConnecting = NO;
	[_receivedData release];
	self._delegate = nil;
	[_requestingURL release];
	[_token release];
	self._urlConnection = nil;
	
	[super dealloc];
}

#pragma mark -
#pragma mark  NSURLConnection delegate

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [_receivedData appendData: data];
}

- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error
{
	_isConnecting = NO;
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	[_receivedData setLength:0];
    [connection release];
	
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	self._statusCode = [(NSHTTPURLResponse*)response statusCode];
	NSDictionary* header = [(NSHTTPURLResponse*)response allHeaderFields];
	NSString *content_type = [header valueForKey:@"Content-Type"];
	_contentType = CT_UNKNOWN;
	if (content_type) 
	{
		if ([content_type rangeOfString:@"xml"].location != NSNotFound) 
			_contentType = CT_XML;
		else if ([content_type rangeOfString:@"json"].location != NSNotFound)
			_contentType = CT_JSON;
	}
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	_isConnecting = NO;
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	[_receivedData setLength:0];
	[connection release];
}

- (void)cancel
{
    if(self._urlConnection)
    {
        [_urlConnection cancel];
    }
}

@end
