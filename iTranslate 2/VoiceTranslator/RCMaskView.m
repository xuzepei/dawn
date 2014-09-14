//
//  RCMaskView.m
//  VoiceTranslator
//
//  Created by xuzepei on 6/29/13.
//  Copyright (c) 2013 xuzepei. All rights reserved.
//

#import "RCMaskView.h"

#define BG_COLOR [UIColor colorWithRed:0.97 green:0.95 blue:0.95 alpha:0.70]

@implementation RCMaskView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        self.backgroundColor = BG_COLOR;
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
