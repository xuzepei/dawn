//
//  RCHintMaskView.m
//  VoiceTranslator
//
//  Created by xuzepei on 7/1/13.
//  Copyright (c) 2013 xuzepei. All rights reserved.
//

#import "RCHintMaskView.h"
#import "RCTool.h"
#import <QuartzCore/QuartzCore.h>

#define BG_COLOR [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7]

#define TITLE_COLOR [UIColor colorWithRed:0.03 green:0.51 blue:1.00 alpha:1.0]

@implementation RCHintMaskView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = BG_COLOR;
        
        UIButton* closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        CGFloat y = [RCTool getScreenSize].height - 54;
        if([RCTool isIphone5])
            y = [RCTool getScreenSize].height - 140;
        
        closeButton.frame = CGRectMake([RCTool getScreenSize].width - 110, y, 100, 36);
        [closeButton setTitle:@"Got it!" forState:UIControlStateNormal];
        closeButton.titleLabel.font = [UIFont boldSystemFontOfSize:18];
        closeButton.layer.borderWidth = 1.0;
        closeButton.layer.borderColor = [UIColor whiteColor].CGColor;
        [closeButton setTitleColor:[UIColor whiteColor]
                        forState:UIControlStateNormal];
        [closeButton setTitleColor:[UIColor whiteColor]
                        forState:UIControlStateHighlighted];
        
        [closeButton setShowsTouchWhenHighlighted:YES];
        [closeButton addTarget:self action:@selector(close:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview: closeButton];
        
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    UIImage* bgImage = [RCTool createImage:@"hint_mask"];
    if(bgImage)
    {
        [bgImage drawInRect:CGRectMake(0, 0, bgImage.size.width, bgImage.size.height)];
    }
    [bgImage release];
}

- (void)close:(id)sender
{
    UIStatusBarStyle style = UIStatusBarStyleDefault;
    
    if([RCTool systemVersion] < 6.0)
        style = UIStatusBarStyleBlackOpaque;
    
    [UIView animateWithDuration:1.0 animations:^{
        [[UIApplication sharedApplication] setStatusBarStyle:style animated:YES];
        self.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
}


@end
