//
//  XHImageLoader.m
//  XinHua
//
//  Created by xuzepei on 09-9-8.
//  Copyright 2009 Rumtel Co.,Ltd. All rights reserved.
//

/*
 图片批量下载类
 */

#import "RCImageLoader.h"
#import "RCTool.h"



@implementation RCImageLoader
@synthesize _imageArray;
@synthesize _requestingURLArray;
@synthesize _failedURLArray;

+ (RCImageLoader*)sharedInstance
{
	static RCImageLoader* sharedInstance = nil;
	if (nil == sharedInstance)
	{
		@synchronized([RCImageLoader class])
		{
            if (nil == sharedInstance)
            {
                sharedInstance = [[RCImageLoader alloc] init];
            }
		}
	}
	
	return sharedInstance;
}

- (id)init
{
	if(self = [super init])
	{
		_imageArray = [[NSMutableArray alloc] init];
		_requestingURLArray = [[NSMutableArray alloc] init];
		_failedURLArray = [[NSMutableArray alloc] init];
	}
	
	return self;
}

- (void)dealloc
{
	[_imageArray release];
	[_requestingURLArray release];
	[_failedURLArray release];
	
	[super dealloc];
}

- (BOOL)isRequestingURL: (NSString*)urlString
{
	BOOL isRequesting = NO;
	for(NSString* temp in _requestingURLArray)
	{
		if([temp isEqualToString: urlString])
		{
			isRequesting = YES;
			break;
		}
	}
	
	return isRequesting;
}

- (void)removeRequestingURL:(NSString*)urlString
{
	NSInteger index = -1;
	NSUInteger i = 0;
	for(NSString* temp in _requestingURLArray)
	{
		if([temp isEqualToString: urlString])
		{
			index = i;
			break;
		}
		
		i++;
	}
	
	if(index != -1)
		[_requestingURLArray removeObjectAtIndex: index];
}

- (BOOL)isFailedRequestingURL:(NSString*)urlString
{
	int i = 0;
	for(NSString* temp in _failedURLArray)
	{
		if([temp isEqualToString: urlString])
		{
			i++;
		}
	}
	
	if(i >= 3)
		return YES;
	
	return NO;
}

- (void)downloadImage:(NSString*)url delegate:(id)delegate token:(id)token
{
	if(0 == [url length])
		return;
	
	if([self isRequestingURL: url])
		return;
	
	if([self isFailedRequestingURL: url])
		return;
	
	NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys: url, @"url", 
						  delegate, @"delegate", 
						  token, @"token", nil];
	
	RCImageHttpRequest* imageHttpRequest = [[[RCImageHttpRequest alloc] init] autorelease];
	[imageHttpRequest downloadImage: url delegate: self token: dict];
	[_requestingURLArray addObject: url];
}


- (void)saveImage:(NSString*)url delegate:(id)delegate token:(id)token
{
	if(0 == [url length])
		return;
	
	if([self isRequestingURL: url])
		return;
	
	if([self isFailedRequestingURL: url])
		return;
	
	NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys: url, @"url", 
						  delegate, @"delegate", 
						  token, @"token", nil];
	
	RCImageHttpRequest* imageHttpRequest = [[[RCImageHttpRequest alloc] init] autorelease];
	[imageHttpRequest saveImage: url delegate: self token: dict];
	[_requestingURLArray addObject: url];
}

- (UIImage*)getImage:(NSString*)imagePath
{
	UIImage* image = nil;
	for(NSDictionary* dict in self._imageArray)
	{
		NSString* urlString = [dict objectForKey: @"url"];
		if([urlString isEqualToString: imagePath])
		{
			image = [dict objectForKey: @"image"];
			break;
		}
	}
	
	return image;
}

#pragma mark -
#pragma mark RCHttpRequestDelegate

- (void) willStartHttpRequest: (id)token
{
	NSDictionary* dict = (NSDictionary*)token;
	NSDictionary* temp = (NSDictionary*)[dict objectForKey:@"token"];
	id delegate = [temp objectForKey:@"delegate"];
	
	if([delegate respondsToSelector: @selector(startLoad:)])
		[delegate startLoad:nil];
}

- (void)didFinishHttpRequest: (id)result token: (id)token
{
	NSDictionary* dict = (NSDictionary*)token;
	NSString* urlString = [dict objectForKey: @"url"];
	NSDictionary* params = (NSDictionary*)[dict objectForKey:@"token"];
	id delegate = [params objectForKey:@"delegate"];
	UIImage* image = (UIImage*)result;
	
	BOOL isSaved = NO;
	NSNumber* isSavedNum = [dict objectForKey:@"isSaved"];
	if(isSavedNum)
		isSaved = [isSavedNum boolValue];
	
	[self removeRequestingURL: urlString];
	
	if([urlString length] && image)
	{
		NSDictionary* temp = [NSDictionary dictionaryWithObjectsAndKeys: urlString, @"url", image, @"image", nil];
		
		if(NO == isSaved)
			[_imageArray addObject: temp];
		
		if([delegate respondsToSelector: @selector(succeedLoad:token:)])
			[delegate succeedLoad:temp token:params];
	}
}

- (void) didFailHttpRequest:(id)token
{
	NSDictionary* dict = (NSDictionary*)token;
	NSString* urlString = [dict objectForKey: @"url"];
	NSDictionary* params = (NSDictionary*)[dict objectForKey:@"token"];
	id delegate = [params objectForKey:@"delegate"];
	[self removeRequestingURL: urlString];
	[_failedURLArray addObject: urlString];
	
	if([delegate respondsToSelector: @selector(failedLoadWithError:)])
		[delegate failedLoadWithError:params];
}


@end
