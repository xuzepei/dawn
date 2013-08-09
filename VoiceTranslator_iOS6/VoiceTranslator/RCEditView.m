//
//  RCEditView.m
//  VoiceTranslator
//
//  Created by xuzepei on 6/28/13.
//  Copyright (c) 2013 xuzepei. All rights reserved.
//

#import "RCEditView.h"
#import "RCTool.h"

#define TEXTVIEW_RECT CGRectMake(12,6,292,114)
#define BG_COLOR [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7]

#define ROUND_CORNER_RECT CGRectMake(10,2,300,120)

@implementation RCEditView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

        self.backgroundColor = [UIColor clearColor];
                
        [self initTextView];
        
        [self initButtons];
    }
    return self;
}

- (void)dealloc
{
    self.textView = nil;
    self.closeButton = nil;
    self.translation = nil;
    self.delegate = nil;
    
    [super dealloc];
}


- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctx);
    CGPathRef clippath = [UIBezierPath bezierPathWithRoundedRect:ROUND_CORNER_RECT cornerRadius:7].CGPath;
    CGContextAddPath(ctx, clippath);
    CGContextClip(ctx);
    CGContextSetFillColorWithColor(ctx, BG_COLOR.CGColor);
    CGContextFillRect(ctx, ROUND_CORNER_RECT);
    CGContextRestoreGState(ctx);
}

- (void)initTextView
{
    if(nil == _textView)
    {
        _textView = [[UITextView alloc] initWithFrame:TEXTVIEW_RECT];
        _textView.textColor = [UIColor whiteColor];
        _textView.backgroundColor = [UIColor clearColor];
        _textView.font = [UIFont systemFontOfSize:16];
        _textView.delegate = self;
        _textView.returnKeyType = UIReturnKeyDone;
    }
    
    [self addSubview:_textView];
}

- (void)initButtons
{
    if(nil == _closeButton)
    {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _closeButton.frame = CGRectMake(self.bounds.size.width - 30,self.bounds.origin.y - 10, 30, 30);
        [_closeButton setImage:[UIImage imageNamed:@"close_button"] forState:UIControlStateNormal];
        [_closeButton addTarget:self action:@selector(clickedCloseButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    [self addSubview:_closeButton];
}

- (void)updateContent:(Translation*)translation
{
    self.translation = translation;
    
    if(_textView)
    {
        [_textView setText:self.translation.fromText];
        
        if([RCTool needSetTextRightAlignment:translation.fromCode])
            _textView.textAlignment = NSTextAlignmentRight;
        else
            _textView.textAlignment = NSTextAlignmentLeft;
        
        [_textView becomeFirstResponder];
    }
}

- (void)translate:(NSString*)text
{
    if(0 == [text length])
    {
        if(_delegate && [_delegate respondsToSelector:@selector(translateText:)])
        {
            [_delegate translateText:nil];
        }
        
        return;
    }
    
    self.translation.fromText = text;
    self.translation.fromVoice = nil;
    self.translation.fromTextDetail = nil;
    self.translation.toText = nil;
    self.translation.toVoice = nil;
    self.translation.toTextDetail = nil;
    
    if(_delegate && [_delegate respondsToSelector:@selector(translateText:)])
    {
        [_delegate translateText:self.translation];
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)text
{
    if([text isEqualToString:@"\n"]) {

        [textView resignFirstResponder];
        
        [self translate:_textView.text];

        return NO;
    }

    return YES;
}

- (void)clickedCloseButton:(id)sender
{
    [_textView resignFirstResponder];
    
    if(_delegate && [_delegate respondsToSelector:@selector(translateText:)])
    {
        [_delegate translateText:nil];
    }
}

@end
