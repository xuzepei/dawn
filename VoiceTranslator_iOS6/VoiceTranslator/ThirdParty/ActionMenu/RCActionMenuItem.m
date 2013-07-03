//
//  RCActionMenuItem.m
//  VoiceTranslator
//
//  Created by xuzepei on 6/27/13.
//  Copyright (c) 2013 xuzepei. All rights reserved.
//

#import "RCActionMenuItem.h"
#import "RCTool.h"

@implementation RCActionMenuItem

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
    }
    return self;
}

- (void)dealloc
{
    self.delegate = nil;
    self.image = nil;
    
    [super dealloc];
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    if(_image)
    {
        [_image drawInRect:CGRectMake((self.bounds.size.width - _image.size.width)/2.0, (self.bounds.size.height - _image.size.height)/2.0, _image.size.width, _image.size.height)];
    }
}


- (void)updateContent:(ACTION_TYPE)type
{
    self.type = type;
    
    NSString* imageName = @"";
    switch (_type) {
        case AT_COPY:
            imageName = @"action_copy";
            break;
        case AT_EDIT:
            imageName = @"action_edit";
            break;
        case AT_SHARE:
            imageName = @"action_share";
            break;
        case AT_MAGNIFY:
            imageName = @"action_magnify";
            break;
        case AT_DELETE:
            imageName = @"action_delete";
            break;
        case AT_SIRI:
            imageName = @"action_siri";
            break;
        case AT_SPEAK:
            imageName = @"action_speak";
            break;
            
        default:
            break;
    }
    
    UIImage* image = [RCTool createImage:imageName];
    self.image = image;
    [image release];
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(_delegate && [_delegate respondsToSelector:@selector(clickedItem:)])
    {
        [_delegate clickedItem:self.type];
    }
    
    [super touchesEnded:touches withEvent:event];
}

@end
