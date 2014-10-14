//
//  RCInputBar.m
//  Translator
//
//  Created by xuzepei on 9/30/14.
//  Copyright (c) 2014 xuzepei. All rights reserved.
//

#import "RCInputBar.h"
#import "RCTool.h"

#define OFFSET_X_HEAD 10.0f
#define OFFSET_X_END 80.0f
#define HEIGHT 27.0f
#define OFFSET_Y_TOP 9.0f

@implementation RCInputBar

- (void)dealloc
{
    self.tf = nil;
    self.translation = nil;
    self.delegate = nil;
    self.sendButton = nil;
    
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame])
    {
        self.backgroundColor = [RCTool colorWithHex:0xf7f7f7];
        
        _tf = [[UITextField alloc] initWithFrame:CGRectMake(OFFSET_X_HEAD, OFFSET_Y_TOP, [RCTool getScreenSize].width - (OFFSET_X_HEAD + OFFSET_X_END), HEIGHT)];
        _tf.font = [UIFont systemFontOfSize:18];
        _tf.backgroundColor = [RCTool colorWithHex:0xfafafa];
        _tf.placeholder = @"Text Input";
        _tf.clearButtonMode = UITextFieldViewModeWhileEditing;
        _tf.borderStyle = UITextBorderStyleRoundedRect;
        _tf.returnKeyType = UIReturnKeyDone;
        _tf.delegate = self;
        [self addSubview:_tf];
        
        self.sendButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [self.sendButton removeConstraints:self.sendButton.constraints];
        self.sendButton.frame = CGRectMake([RCTool getScreenSize].width - OFFSET_X_END, frame.size.height - 42, OFFSET_X_END, 40);
        [self.sendButton setTitle:@"Translate" forState:UIControlStateNormal];
        [self.sendButton addTarget:self action:@selector(clickedTranslateButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.sendButton setTranslatesAutoresizingMaskIntoConstraints:YES];
        if([RCTool isOpenAll])
            [self.sendButton setTitleColor:[RCTool colorWithHex:0x00cc47] forState:UIControlStateNormal];
        [self addSubview:self.sendButton];
        
    }
    
    return self;
}

//- (void)setFrame:(CGRect)frame
//{
//    [super setFrame:frame];
//    
//    self.sendButton.frame = CGRectMake([RCTool getScreenSize].width - OFFSET_X_END, frame.size.height - 40, OFFSET_X_END, 40);
//}


 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
 
 [[RCTool colorWithHex:0xadadad] set];
 
 CGRect topLineRect = CGRectMake(0, 0, self.bounds.size.width, 0.5);
 UIRectFill(topLineRect);
}

- (void)updateContent:(Translation*)translation
{
    self.translation = translation;
    
    if(_tf && self.translation)
    {
        [_tf setText:self.translation.fromText];
        
        if([RCTool needSetTextRightAlignment:translation.fromCode])
            _tf.textAlignment = NSTextAlignmentRight;
        else
            _tf.textAlignment = NSTextAlignmentLeft;
        
        [_tf becomeFirstResponder];
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
    
    Translation* translation = nil;
    if(nil == self.translation)
    {
        translation = [RCTool insertEntityObjectForName:@"Translation" managedObjectContext:[RCTool getManagedObjectContext]];
        if(translation)
        {
            NSDate* date = [NSDate date];
            NSTimeInterval interval = [date timeIntervalSince1970];
            translation.time = [NSNumber numberWithDouble:interval];
            translation.fromCode = [RCTool getLeftLanguage];
            translation.toCode = [RCTool getRightLanguage];
        }
    }
    
    if(nil == translation)
        translation = self.translation;
    translation.fromText = text;
    translation.fromVoice = nil;
    translation.fromTextDetail = nil;
    translation.toText = nil;
    translation.toVoice = nil;
    translation.toTextDetail = nil;
    
    if(_delegate && [_delegate respondsToSelector:@selector(translateText:)])
    {
        self.translation = nil;
        [_delegate translateText:translation];
    }
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)clickedTranslateButton:(id)sender
{
    NSLog(@"clickedTranslateButton");
    
    if([self.tf.text length]) {
        
        [self.tf resignFirstResponder];
        
        [self translate:self.tf.text];
        
        self.tf.text = @"";
    }
}

@end
