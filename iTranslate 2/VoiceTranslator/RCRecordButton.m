//
//  RCRecordButton.m
//  VoiceTranslator
//
//  Created by xuzepei on 12/6/12.
//  Copyright (c) 2012 xuzepei. All rights reserved.
//

#import "RCRecordButton.h"
#import "RCTool.h"

@implementation RCRecordButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        [self updateContent];
    }
    return self;
}

- (void)dealloc
{
    self.delegate = nil;
    self.language = nil;
    self.toLanguage = nil;
    self.indicatorLayer = nil;
    
    [super dealloc];
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    if([self.language length])
    {
        NSString* imageName = [NSString stringWithFormat:@"round_flag_%@",self.language];
        UIImage* image = [UIImage imageNamed:imageName];
        if(image)
        {
            [image drawInRect:self.bounds];
        }
    }
    
}

- (void)updateContent
{
    if(RBT_LEFT == self.tag)
    {
        self.language = [RCTool getLeftLanguage];
        self.toLanguage = [RCTool getRightLanguage];
    }
    else if(RBT_RIGHT == self.tag)
    {
        self.language = [RCTool getRightLanguage];
        self.toLanguage = [RCTool getLeftLanguage];
    }
    
    [self setNeedsDisplay];
}

#pragma mark - Touch Event

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.isTouchDown = YES;
    
    if(_delegate && [_delegate respondsToSelector:self.selector])
    {
       NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
       [dict setObject:@"touch_began" forKey:@"touch_event"];
        if([self.language length])
            [dict setObject:self.language forKey:@"language"];
        if([self.toLanguage length])
            [dict setObject:self.toLanguage forKey:@"to_language"];
       [_delegate performSelector:self.selector withObject:dict];
       [dict release];
    }
    
    [self setNeedsDisplay];
    [super touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.isTouchDown = NO;
    
    if(_delegate && [_delegate respondsToSelector:self.selector])
    {
        NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
        [dict setObject:@"touch_end" forKey:@"touch_event"];
        if([self.language length])
            [dict setObject:self.language forKey:@"language"];
        if([self.toLanguage length])
            [dict setObject:self.toLanguage forKey:@"to_language"];
        [_delegate performSelector:self.selector withObject:dict];
        [dict release];
    }
    
    [self setNeedsDisplay];
    [super touchesEnded:touches withEvent:event];
}


- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.isTouchDown = NO;
    
    if(_delegate && [_delegate respondsToSelector:self.selector])
    {
        NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
        [dict setObject:@"touch_cancel" forKey:@"touch_event"];
        if([self.language length])
            [dict setObject:self.language forKey:@"language"];
        if([self.toLanguage length])
            [dict setObject:self.toLanguage forKey:@"to_language"];
        [_delegate performSelector:self.selector withObject:dict];
        [dict release];
    }

    [self setNeedsDisplay];
    [super touchesCancelled:touches withEvent:event];
}

- (void)startIndicator
{
    [self stopIndicator];
    
    self.indicatorLayer = [CALayer layer];
    self.indicatorLayer.contentsScale = [[UIScreen mainScreen] scale];
    UIImage* image = [UIImage imageNamed:@"loading"];
    self.indicatorLayer.contents = (id)image.CGImage;
    self.indicatorLayer.frame = CGRectMake(0, 0, image.size.width, image.size.height);
    self.indicatorLayer.backgroundColor = [[UIColor clearColor] CGColor];
    self.layer.masksToBounds = YES;
    [self.layer addSublayer:self.indicatorLayer];
    

    CGFloat duration = 3.0;
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 /* full rotation*/ * duration];
    rotationAnimation.duration = duration;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = YES;
    
    [self.indicatorLayer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}

- (void)stopIndicator
{
    if(self.indicatorLayer)
    {
        [self.indicatorLayer removeAllAnimations];
        [self.indicatorLayer removeFromSuperlayer];
    }
}

@end
