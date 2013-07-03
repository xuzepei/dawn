//
//  WRTitleBar.m
//  KTV
//
//  Created by zepei xu on 7/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WRTitleBar.h"

@implementation WRTitleBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bar_bg.png"]];

        if (nil == _titleLabel) {
            _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 2, 200, 40)];
            _titleLabel.font = [UIFont boldSystemFontOfSize:20];
            _titleLabel.backgroundColor = [UIColor clearColor];
            _titleLabel.textAlignment = UITextAlignmentCenter;
            _titleLabel.textColor = [UIColor whiteColor];
            _titleLabel.text = @"";
            _titleLabel.shadowColor = [UIColor blackColor];
            _titleLabel.shadowOffset = CGSizeMake(0,-1);
            [self addSubview: _titleLabel];
        }
        
        if (nil == _leftButton) {
            self.leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
            _leftButton.frame = CGRectMake(6, 2, 40, 40);
            _leftButton.showsTouchWhenHighlighted = YES;
            [self addSubview: _leftButton];
        }
        
        if (nil == _rightButton) {
            self.rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
            _rightButton.frame = CGRectMake(320 - 40 - 2, 2, 40, 40);
            _leftButton.showsTouchWhenHighlighted = YES;
            [self addSubview: _rightButton];
        }
        
    }
    return self;
}

- (void)dealloc
{
    self.titleLabel = nil;
    self.leftButton = nil;
    self.rightButton = nil;
    self.target = nil;
    self.clickedLeftButtonSelector = nil;
    self.clickedRightButtonSelector = nil;
    
    [super dealloc];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)addTarget:(id)target 
clickedLeftButtonSelector:(SEL)clickedLeftButtonSelector
clickedRightButtonSelector:(SEL)clickedRightButtonSelector
{
    self.target = target;
    self.clickedLeftButtonSelector = clickedLeftButtonSelector;
    self.clickedRightButtonSelector = clickedRightButtonSelector;
    
    if(_clickedLeftButtonSelector && _leftButton)
    {
        [_leftButton addTarget:_target
                        action:_clickedLeftButtonSelector
              forControlEvents:UIControlEventTouchUpInside];
    }
    else
        self.leftButton = nil;
    
    if(_clickedRightButtonSelector && _rightButton)
    {
        [_rightButton addTarget:_target
                        action:_clickedRightButtonSelector
              forControlEvents:UIControlEventTouchUpInside];
    }
    else
        self.rightButton = nil;
}

@end
