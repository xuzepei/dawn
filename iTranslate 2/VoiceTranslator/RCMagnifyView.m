//
//  RCMagnifyView.m
//  VoiceTranslator
//
//  Created by xuzepei on 6/28/13.
//  Copyright (c) 2013 xuzepei. All rights reserved.
//

#import "RCMagnifyView.h"
#import "RCTool.h"

//#define BG_COLOR [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7]
#define BG_COLOR [UIColor colorWithRed:0.99 green:0.97 blue:0.54 alpha:1.00]
#define TEXT_FONT [UIFont boldSystemFontOfSize:46]

@implementation RCMagnifyView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        
    }
    return self;
}

- (void)dealloc
{
    self.closeButton = nil;
    self.translation = nil;
    
    if(_webView)
        _webView.delegate = nil;
    self.webView = nil;
    
    self.indicatorView = nil;
    
    [super dealloc];
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CGRect temp = CGRectMake(4, 8, self.bounds.size.width - 8, self.bounds.size.height - 16);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctx);
    CGPathRef clippath = [UIBezierPath bezierPathWithRoundedRect:temp cornerRadius:7].CGPath;
    CGContextAddPath(ctx, clippath);
    CGContextClip(ctx);
    CGContextSetFillColorWithColor(ctx, BG_COLOR.CGColor);
    CGContextFillRect(ctx, temp);
    CGContextRestoreGState(ctx);
    
//    if([self.text length])
//    {
//        [[UIColor whiteColor] set];
//        CGSize size = [self.text sizeWithFont:TEXT_FONT constrainedToSize:CGSizeMake(self.bounds.size.width - 12, CGFLOAT_MAX) lineBreakMode:NSLineBreakByTruncatingTail];
//        if(size.height <= self.bounds.size.height - 12)
//        {
//            [self.text drawInRect:CGRectMake(6, 6 + (self.bounds.size.height - 12 - size.height - 46)/2.0, self.bounds.size.width - 12, size.height) withFont:TEXT_FONT lineBreakMode:NSLineBreakByTruncatingTail
//             alignment:NSTextAlignmentCenter];
//        }
//        else
//        {
//            [self.text drawInRect:CGRectMake(6, 6, self.bounds.size.width - 12, self.bounds.size.height - 12) withFont:TEXT_FONT lineBreakMode:NSLineBreakByTruncatingTail
//             alignment:NSTextAlignmentCenter];
//        }
//    }
}

- (void)initWebView
{
    if(nil == _webView)
    {
        _webView = [[UIWebView alloc] initWithFrame:CGRectMake(4,4,8,8)];
        _webView.delegate = self;
        _webView.opaque = NO;
        _webView.backgroundColor = [UIColor clearColor];
        _webView.alpha = 0.0;
        //_webView.scalesPageToFit = YES;
        
        //隐藏UIWebView shadow
        [RCTool hidenWebViewShadow:_webView];
    }
    
    [self addSubview: _webView];
    
    if(nil == _indicatorView)
    {
        _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    }
    
    _indicatorView.center = CGPointMake(self.bounds.size.width/2.0, self.bounds.size.height/2.0);
    [_webView addSubview:_indicatorView];
}

- (void)initButtons
{
    if(nil == _closeButton)
    {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeButton setImage:[UIImage imageNamed:@"close_button"] forState:UIControlStateNormal];
        [_closeButton addTarget:self action:@selector(clickedCloseButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    [self addSubview:_closeButton];
}

- (void)updateContent:(Translation*)translation type:(BUBBLE_TYPE)type
{
    [self initWebView];
    
    [self initButtons];
    
    self.type = type;
    self.closeButton.alpha = 0.0;
    self.translation = translation;
    self.webView.alpha = 0.0;
    _webView.frame = CGRectMake(4,4,10,10);
    
    if(NO == [self showContent])
    {
        [self requestDetail];
    }
    
    [UIView animateWithDuration:0.5 delay:0 options:0 animations:^{
        
        self.frame = CGRectMake(0,STATUS_BAR_HEIGHT,[RCTool getScreenSize].width,[RCTool getScreenSize].height - STATUS_BAR_HEIGHT);
        
    }
    completion:^(BOOL finished)
    {
        [self setNeedsDisplay];
        
        _webView.frame = CGRectMake(6,10,self.bounds.size.width - 12,self.bounds.size.height - 20);
        
        _closeButton.frame = CGRectMake(self.bounds.size.width - 26,self.bounds.origin.y - 2, 30, 30);
        
        _indicatorView.center = CGPointMake(self.bounds.size.width/2.0, self.bounds.size.height/2.0);
        
        self.closeButton.alpha = 1.0;
        self.webView.alpha = 1.0;
    }];

}

- (BOOL)showContent
{
    NSString* body = nil;
    if(BT_FROM == self.type)
    {
        body = self.translation.fromTextDetail;
    }
    else if(BT_TO == self.type)
    {
        body = self.translation.toTextDetail;
    }
    
    
    BOOL b = NO;
    if(0 == [body length])
    {
        b =  NO;
        
        NSString* text = nil;
        if(BT_FROM == self.type)
        {
            text = self.translation.fromText;
        }
        else if(BT_TO == self.type)
        {
            text = self.translation.toText;
        }
        
        if(0 == [text length])
            text = @"";
        body = [NSString stringWithFormat:@"<div class=\"magnify\">%@</div>",text];
    }
    else
    {
        b = YES;
    }
    
    
    NSString* htmlString = [NSString stringWithFormat:@"<html>"
							"<head>"
							"<link rel=\"stylesheet\" type=\"text/css\" href=\"translate.css\"/>"
                            "<script src=\"translate.js\"></script>"
							"</head>"
							"<body>"
							"%@"
							"</body>"
							"</html>",body];
    
    NSString *path = [[NSBundle mainBundle] resourcePath];
    path = [path stringByReplacingOccurrencesOfString:@"/" withString:@"//"];
	path = [path stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    
    if([htmlString length])
    {
        [_webView loadHTMLString:htmlString
                         baseURL:[NSURL URLWithString: [NSString stringWithFormat:@"file:/%@//",path]]];
    }
    
    return b;
}

- (void)requestDetail
{
    NSString* text = nil;
    NSString* code = nil;
    if(BT_FROM == self.type)
    {
        text = self.translation.fromText;
        code = self.translation.fromCode;
    }
    else if(BT_TO == self.type)
    {
        text = self.translation.toText;
        code = self.translation.toCode;
    }
    
    NSString* urlString = [NSString stringWithFormat:@"http://www.google.com/dictionary/json?callback=dict_api.callbacks.id100&q=%@&sl=%@&tl=%@&client=te",text,code,code];
    
    NSDictionary* token = [NSDictionary dictionaryWithObjectsAndKeys:self.translation,@"translation",[NSNumber numberWithInt:self.type],@"type",nil];

    RCHttpRequest* temp = [[[RCHttpRequest alloc] init] autorelease];
    BOOL b = [temp request:urlString delegate:self resultSelector:@selector(finishedDetailRequest:) token:token];
    
    if(b)
    {
        [_indicatorView startAnimating];
    }

}

- (void)finishedDetailRequest:(NSDictionary*)token
{
    [_indicatorView stopAnimating];
    
    if(nil == token)
        return;
    
    NSDictionary* tokenDict = (NSDictionary*)[token objectForKey:@"token"];
    Translation* translation = [tokenDict objectForKey:@"translation"];
    NSNumber* typeNum = [tokenDict objectForKey:@"type"];
    if(nil == translation || nil == typeNum)
        return;
    
    BUBBLE_TYPE type = [typeNum intValue];
    NSString* jsonString = [token objectForKey:@"content"];

    NSDictionary* result = [RCTool parseToDetail: jsonString];
    NSString* body = [RCTool createBody:result];
    
    if([body length])
    {
        if(BT_FROM == type)
            translation.fromTextDetail = body;
        else if(BT_TO == type)
            translation.toTextDetail = body;
    }
    
    [RCTool saveCoreData];

    if([translation.time doubleValue] == [self.translation.time doubleValue] && self.type == type)
    {
        [self showContent];
    }
}

- (void)clickedCloseButton:(id)sender
{
    self.closeButton.alpha = 0.0;
    self.webView.alpha = 0.0;

    [UIView animateWithDuration:0.5 delay:0 options:0 animations:^{
        
        self.frame = CGRectMake([RCTool getScreenSize].width/2.0,[RCTool getScreenSize].height/2.0,0,0);
        
    }
    completion:^(BOOL finished)
     {
         self.translation = nil;
         if(_webView)
         {
             [_webView removeFromSuperview];
             _webView.delegate = nil;
         }
         self.webView = nil;
         [self removeFromSuperview];
     }];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if(UIWebViewNavigationTypeLinkClicked == navigationType)
    {
        NSString* urlString = [[request URL] absoluteString];
        [self playTTS:urlString];
        
        return NO;
    }
    
    return YES;
}

- (void)playTTS:(NSString*)ttsUrl
{
    if(0 == [ttsUrl length])
        return;
    
    NSString* ttsPath = nil;
    if([ttsUrl hasPrefix:@"http"] || [ttsUrl hasPrefix:@"https"])
    {
        ttsPath = [RCTool getTTSPath:ttsUrl];
        if([RCTool isExistingFile:ttsPath])
        {
            [RCTool playTTS:ttsUrl];
        }
        else
        {
            NSURL* url = [NSURL URLWithString:ttsUrl];
            ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
            [request setDelegate:self];
            NSMutableDictionary* dict = [[[NSMutableDictionary alloc] init] autorelease];
            [dict setObject:@"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_3) AppleWebKit/537.31 (KHTML, like Gecko) Chrome/26.0.1410.65 Safari/537.31" forKey:@"User-Agent"];
            [request setRequestHeaders:dict];
            [request setDownloadDestinationPath:[RCTool getTTSPath:ttsUrl]];
            NSDictionary* userInfo = [NSDictionary dictionaryWithObject:ttsUrl forKey:@"ttsUrl"];
            [request setUserInfo:userInfo];
            [request startAsynchronous];
        }
    }
    
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    NSLog(@"requestFinished");
    
    NSDictionary* userInfo = [request userInfo];
    if(userInfo && [userInfo isKindOfClass:[NSDictionary class]])
    {
        NSString* ttsUrl = [userInfo objectForKey:@"ttsUrl"];
        if([ttsUrl length])
            [RCTool playTTS:ttsUrl];
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSLog(@"requestFailed");
}

@end
