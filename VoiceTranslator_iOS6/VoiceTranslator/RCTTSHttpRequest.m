//
//  RCTTSHttpRequest.m
//  VoiceTranslator
//
//  Created by xuzepei on 12/6/12.
//  Copyright (c) 2012 xuzepei. All rights reserved.
//

#import "RCTTSHttpRequest.h"
#import "RCTool.h"

@implementation RCTTSHttpRequest

+ (RCTTSHttpRequest*)sharedInstance
{
	static RCTTSHttpRequest* sharedInstance = nil;
	if(nil == sharedInstance)
	{
		@synchronized([RCTTSHttpRequest class])
		{
            if(nil == sharedInstance)
                sharedInstance = [[RCTTSHttpRequest alloc] init];
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
    
    [RCTool removeTTSFile:urlString];
    
	NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
	self._requestingURL = urlString;
	urlString = [urlString stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
	[request setURL:[NSURL URLWithString: urlString]];
	[request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
	[request setTimeoutInterval: TIME_OUT];
	[request setHTTPShouldHandleCookies:FALSE];
	[request setHTTPMethod:@"GET"];
    
    NSLog(@"tts: %@",urlString);
	
    _urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
	if(_urlConnection)
	{
		_isConnecting = YES;
		[_receivedData setLength: 0];
        
		[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
		
        NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
        if(self._token)
            [dict addEntriesFromDictionary:self._token];
        [dict setObject:self._requestingURL forKey:@"tts_url"];

		if([_delegate respondsToSelector: @selector(willStartTTSHttpRequest:)])
			[_delegate willStartTTSHttpRequest:dict];
        
        [dict release];
		
        return YES;
	}
    
    return NO;
}

- (void)updatePercentage
{
	_currentLength += [_receivedData length];
	
	float percentage = 0;
	if(_currentLength >= 0 && self._expectedContentLength >= 0)
		percentage = _currentLength / (long double) self._expectedContentLength;
	
	NSDictionary* dict = [[NSDictionary alloc] initWithObjectsAndKeys:_requestingURL, @"url", self._token, @"delegate",nil];
	if([_delegate respondsToSelector: @selector(updatePercentage:token:)])
		[_delegate updatePercentage: percentage token:dict];
	[dict release];
}

- (void)writeSumLengthToFile
{
	NSString* sumLengthFilePath = [RCTool getTTSSumLengthFilePath:_requestingURL];
	char* fileName = (char*)[sumLengthFilePath UTF8String];
	FILE* fp;
	fp = fopen(fileName,"w");
	if(fp)
	{
		if(fwrite(&_expectedContentLength, sizeof(long long), 1, fp))
		{
			//NSLog(@"offset:%@",[NSString stringWithFormat:@"%qi",_currentLength]);
			fclose(fp);
		}
		else
		{
			fclose(fp);
			//NSLog(@"write SumLength file failed!");
		}
	}
	else
	{
		NSLog(@"open SumLength file failed!");
	}
}

- (void)writeDataToFile
{
	if([_receivedData length])
	{
        NSString* tempPath = [RCTool getTTSTempPath:_requestingURL];
		char* fileName = (char*)[tempPath UTF8String];
		FILE* fp;
		fp = fopen(fileName,"ab");
		if(fp)
		{
			//NSLog(@"begin:%@",[NSString stringWithFormat:@"%qi",(long long)ftell(fp)]);
			if(fwrite([_receivedData bytes], [_receivedData length], 1, fp))
			{
				//NSLog(@"end:%@",[NSString stringWithFormat:@"%qi",(long long)ftell(fp)]);
				fclose(fp);
				
				[self updatePercentage];
				[_receivedData setLength:0];
			}
			else
			{
				fclose(fp);
				NSLog(@"write file failed!");
			}
		}
		else
		{
			NSLog(@"open file failed!");
		}
        
	}
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
	
	self._expectedContentLength = [response expectedContentLength] + _currentLength;
	[self writeSumLengthToFile];
	NSLog(@"_expectedContentLength:%@",[NSString stringWithFormat:@"%qi",self._expectedContentLength]);
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	[_receivedData appendData: data];
	[self writeDataToFile];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	NSLog(@"tts:connectionDidFinishLoading- statusCode:%d",_statusCode);
	
    BOOL isSuccessful = NO;
	if(200 == _statusCode || 206 == _statusCode)
	{
        [self writeDataToFile];
		
        NSLog(@"%lld,%lld",_currentLength,_expectedContentLength);
		if(_currentLength == _expectedContentLength)
        {
            NSString* ttsPath = [RCTool getTTSPath:_requestingURL];
			NSString* ttsTempPath = [RCTool getTTSTempPath:_requestingURL];
            
            if(0 == rename([ttsTempPath UTF8String],[ttsPath UTF8String]))
			{
                isSuccessful = YES;
                
                _isConnecting = NO;
                [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                [_receivedData setLength:0];
                self._urlConnection = nil;
                
                NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
                if(self._token)
                    [dict addEntriesFromDictionary:self._token];
                [dict setObject:self._requestingURL forKey:@"tts_url"];
                
                if([_delegate respondsToSelector: @selector(didFinishTTSHttpRequest:token:)])
                    [_delegate didFinishTTSHttpRequest:nil token:dict];
                
                [dict release];
                
                return;
			}
        }

	}
    
    
    //没有下载成功
	if(NO == isSuccessful)
	{
        [RCTool removeTTSFile:_requestingURL];
		_isConnecting = NO;
		[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
		[_receivedData setLength:0];
		self._urlConnection = nil;
		
        NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
        if(self._token)
            [dict addEntriesFromDictionary:self._token];
        [dict setObject:self._requestingURL forKey:@"tts_url"];
        
		if([_delegate respondsToSelector: @selector(didFailTTSHttpRequest:)])
			[_delegate didFailTTSHttpRequest:dict];
        
        [dict release];
	}
	
    
}

- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error
{
	NSLog(@"tts:didFailWithError - statusCode:%d",_statusCode);
	
	[RCTool removeTTSFile:self._requestingURL];
    
	_isConnecting = NO;
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	[_receivedData setLength: 0];
    self._urlConnection = nil;
	
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    if(self._token)
        [dict addEntriesFromDictionary:self._token];
    [dict setObject:self._requestingURL forKey:@"tts_url"];
	
	if([_delegate respondsToSelector: @selector(didFailTTSHttpRequest:)])
		[_delegate didFailTTSHttpRequest: dict];
    
    [dict release];
}

@end
