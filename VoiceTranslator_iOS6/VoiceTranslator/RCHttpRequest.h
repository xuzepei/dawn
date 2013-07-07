//
//  RCHttpRequest.h
//  rsscoffee
//
//  Created by beer on 8/11/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol RCHttpRequestDelegate <NSObject>
@optional
- (void) willStartHttpRequest: (id)token;
- (void) didFinishHttpRequest: (id)result token: (id)token;
- (void) didFailHttpRequest: (id)token;
- (void) updatePercentage: (float)percentage token: (id)token;
@end


@interface RCHttpRequest : NSObject {
	
	NSMutableData* _receivedData;
	BOOL _isConnecting;
	id _delegate;
	int _statusCode;
	int _contentType;
	int _requestType;
	NSString* _requestingURL;
	id _token;
	long long _expectedContentLength;
	long long _currentLength;
	NSURLConnection* _urlConnection;

}

@property (nonatomic, retain) NSMutableData* _receivedData;
@property (nonatomic, assign) BOOL _isConnecting; 
@property (nonatomic, assign) id _delegate;
@property (assign) int _statusCode;
@property (assign) int _contentType;
@property (assign) int _requestType;
@property (nonatomic, retain) NSString* _requestingURL;
@property (nonatomic, retain) id _token;
@property (assign) long long _expectedContentLength;
@property (assign) long long _currentLength;
@property (nonatomic, retain) NSURLConnection* _urlConnection;

@property(assign)SEL _resultSelector;

+ (RCHttpRequest*)sharedInstance;
- (BOOL)request:(NSString*)urlString
	   delegate:(id)delegate
 resultSelector:(SEL)resultSelector
		  token:(id)token;
- (BOOL)post:(NSString*)urlString delegate:(id)delegate resultSelector:(SEL)resultSelector token:(id)token;
- (void)cancel;

@end
