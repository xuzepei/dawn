//
//  RCMagnifyView.h
//  VoiceTranslator
//
//  Created by xuzepei on 6/28/13.
//  Copyright (c) 2013 xuzepei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Translation.h"
#import "RCHttpRequest.h"
#import "ASIHTTPRequest.h"

@interface RCMagnifyView : UIView<UIWebViewDelegate>

@property(nonatomic,retain)UIButton* closeButton;
@property(nonatomic,retain)Translation* translation;
@property(nonatomic,retain)UIWebView* webView;
@property(assign)BUBBLE_TYPE type;
@property(nonatomic,retain)UIActivityIndicatorView* indicatorView;

- (void)updateContent:(Translation*)translation type:(BUBBLE_TYPE)type;

@end
