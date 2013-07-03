//
//  RCMagnifyView.m
//  VoiceTranslator
//
//  Created by xuzepei on 6/28/13.
//  Copyright (c) 2013 xuzepei. All rights reserved.
//

#import "RCMagnifyView.h"
#import "RCTool.h"

#define BG_COLOR [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7]
#define TEXT_FONT [UIFont boldSystemFontOfSize:46]

@implementation RCMagnifyView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];

        [self initButtons];
    }
    return self;
}

- (void)dealloc
{
    self.closeButton = nil;
    self.text = nil;
    
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
    
    if([self.text length])
    {
        [[UIColor whiteColor] set];
        CGSize size = [self.text sizeWithFont:TEXT_FONT constrainedToSize:CGSizeMake(self.bounds.size.width - 12, CGFLOAT_MAX) lineBreakMode:NSLineBreakByTruncatingTail];
        if(size.height <= self.bounds.size.height - 12)
        {
            [self.text drawInRect:CGRectMake(6, 6 + (self.bounds.size.height - 12 - size.height - 46)/2.0, self.bounds.size.width - 12, size.height) withFont:TEXT_FONT lineBreakMode:NSLineBreakByTruncatingTail
             alignment:NSTextAlignmentCenter];
        }
        else
        {
            [self.text drawInRect:CGRectMake(6, 6, self.bounds.size.width - 12, self.bounds.size.height - 12) withFont:TEXT_FONT lineBreakMode:NSLineBreakByTruncatingTail
             alignment:NSTextAlignmentCenter];
        }
    }
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

- (void)updateContent:(NSString*)text
{
    self.closeButton.alpha = 0.0;
    self.text = text;
    
    [UIView animateWithDuration:0.5 delay:0 options:0 animations:^{
        
        self.frame = CGRectMake(0,STATUS_BAR_HEIGHT,[RCTool getScreenSize].width,[RCTool getScreenSize].height - STATUS_BAR_HEIGHT);
        
    }
    completion:^(BOOL finished)
    {
        [self setNeedsDisplay];
        _closeButton.frame = CGRectMake(self.bounds.size.width - 26,self.bounds.origin.y - 2, 30, 30);
        self.closeButton.alpha = 1.0;
    }];

}

- (void)clickedCloseButton:(id)sender
{
    self.closeButton.alpha = 0.0;

    [UIView animateWithDuration:0.5 delay:0 options:0 animations:^{
        
        self.frame = CGRectMake([RCTool getScreenSize].width/2.0,[RCTool getScreenSize].height/2.0,0,0);
        
    }
    completion:^(BOOL finished)
     {
         self.text = nil;
         [self setNeedsDisplay];
         
         [self removeFromSuperview];
     }];
}

@end
