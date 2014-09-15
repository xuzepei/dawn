//
//  RCImageHttpRequest.h
//  rsscoffee
//
//  Created by xuzepei on 5/9/10.
//  Copyright 2010 Rumtel Co.,Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCHttpRequest.h"

@interface RCImageHttpRequest : RCHttpRequest {
	
	BOOL _saveToLocal;
	
}

- (void)saveImage: (NSString*)url delegate: (id)delegate token:(id)token;
- (void)downloadImage: (NSString*)url delegate: (id)delegate token:(id)token;

@end
