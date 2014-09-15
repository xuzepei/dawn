//
//  RCTitleBar.m
//  Translator
//
//  Created by xuzepei on 8/23/14.
//  Copyright (c) 2014 xuzepei. All rights reserved.
//

#import "RCTitleBar.h"
#import "RCTool.h"

@implementation RCTitleBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        self.backgroundColor = [UIColor clearColor];
        
        _fromLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, (self.bounds.size.width - 50)/2.0, frame.size.height)];
        _fromLabel.backgroundColor = [UIColor clearColor];
        _fromLabel.font = [UIFont systemFontOfSize:16];
        _fromLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _fromLabel.textAlignment = NSTextAlignmentRight;
        [self addSubview:_fromLabel];
        
        
        _toLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.bounds.size.width/2.0 + 25, 0, (self.bounds.size.width - 50)/2.0, frame.size.height)];
        _toLabel.backgroundColor = [UIColor clearColor];
        _toLabel.font = [UIFont systemFontOfSize:16];
        _toLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [self addSubview:_toLabel];
        
        [self updateContent];
    }
    return self;
}

- (void)dealloc
{
    self.fromLabel = nil;
    self.toLabel = nil;
    
    [super dealloc];
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    UIImage* image = [UIImage imageNamed:@"arrow"];
    if(image)
        [image drawInRect:CGRectMake((self.bounds.size.width - 40)/2.0, 2, 40, 40)];
}


- (void)updateContent
{
    NSString* code = [RCTool getLeftLanguage];
    NSDictionary* language = [RCTool getLangaugeByCode:code];
    
    if(_fromLabel)
        _fromLabel.text = [language objectForKey:@"name"];
    
    code = [RCTool getRightLanguage];
    language = [RCTool getLangaugeByCode:code];
    if(_toLabel)
        _toLabel.text = [language objectForKey:@"name"];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    
    UITouch* endTouch = [touches anyObject];
    CGPoint point = [endTouch locationInView:self];
    
    CGRect switchButtonRect = CGRectMake((self.bounds.size.width - 40)/2.0, 2, 40, 40);
    if(CGRectContainsPoint(switchButtonRect, point))
    {
        [UIView animateWithDuration:0.3 animations:^{
            
            NSString* fromeCode = [RCTool getLeftLanguage];
            NSString* toCode = [RCTool getRightLanguage];
            
            [RCTool setLeftLanguage:toCode];
            [RCTool setRightLanguage:fromeCode];
            
            CGRect leftLabelRect = _fromLabel.frame;
            CGRect rightLabelRect = _toLabel.frame;
            
            _toLabel.frame = leftLabelRect;
            if(_toLabel.textAlignment == NSTextAlignmentLeft)
                _toLabel.textAlignment = NSTextAlignmentRight;
            else if(_toLabel.textAlignment == NSTextAlignmentRight)
                _toLabel.textAlignment = NSTextAlignmentLeft;
            
            _fromLabel.frame = rightLabelRect;
            if(_fromLabel.textAlignment == NSTextAlignmentLeft)
                _fromLabel.textAlignment = NSTextAlignmentRight;
            else if(_fromLabel.textAlignment == NSTextAlignmentRight)
                _fromLabel.textAlignment = NSTextAlignmentLeft;
            
        }completion:^(BOOL finished) {
            
        }];
    }

}

@end
