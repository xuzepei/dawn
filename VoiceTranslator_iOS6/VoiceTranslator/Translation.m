//
//  Translation.m
//  VoiceTranslator
//
//  Created by xuzepei on 6/19/13.
//  Copyright (c) 2013 xuzepei. All rights reserved.
//

#import "Translation.h"
#import "RCTool.h"



@implementation Translation

@dynamic fromCode;
@dynamic toCode;
@dynamic fromText;
@dynamic fromTextDetail;
@dynamic toText;
@dynamic toTextDetail;
@dynamic fromVoice;
@dynamic toVoice;
@dynamic time;
@dynamic isHidden;
@dynamic align;
@dynamic isLoading;
@dynamic textUrl;
@dynamic ttsUrl;
@dynamic showTime;
@synthesize isExisting;

- (CGFloat)getHeightForCell:(BOOL)redo
{
    if(redo || 0.0 == _heightForCell)
    {
        _heightForCell = 0.0;
        
        if([self.fromText length])
        {
            _heightForCell += [self getMarginTop] + [self getFromBubbleSize].height + BUBBLE_MARGIN_BOTTOM;
            
            if(0 == [self.toText length])
            {
                _heightForCell += BUBBLE_FROM_TO_INTERVAL+BUBBLE_LOADING_HEIGHT;
            }
            else
            {
                _heightForCell += BUBBLE_FROM_TO_INTERVAL+[self getToBubbleSize].height;
            }
        }
        
    }
    
    return _heightForCell;
}

- (CGSize)getFromBubbleSize
{
    CGSize textSize = [self getFromTextSize];
    
    return CGSizeMake(MAX(MIN_BUBBLE_WIDTH,textSize.width+BUBBLE_PADDING_LEFT+BUBBLE_PADDING_RIGHT), MAX(MIN_BUBBLE_HEIGHT,textSize.height+BUBBLE_PADDING_TOP+BUBBLE_PADDING_BOTTOM));
}

- (CGSize)getToBubbleSize
{
    CGSize textSize = [self getToTextSize];
    
    return CGSizeMake(MAX(MIN_BUBBLE_WIDTH,textSize.width+BUBBLE_PADDING_RIGHT+BUBBLE_PADDING_RIGHT), MAX(MIN_BUBBLE_HEIGHT,textSize.height+BUBBLE_PADDING_TOP+BUBBLE_PADDING_BOTTOM));
}

- (CGSize)getFromTextSize
{
    return [self getTextSize:self.fromText font:[self fontForType:BFT_FROMTEXT]];
}

- (CGSize)getToTextSize
{
    return [self getTextSize:self.toText font:[self fontForType:BFT_TOTEXT]];
}

- (CGSize)getTextSize:(NSString*)text font:(UIFont*)font
{
    if(0 == [text length])
        return CGSizeZero;
    
    CGFloat width = [RCTool getScreenSize].width * 0.65f;
    return [text sizeWithFont:font
           constrainedToSize:CGSizeMake(width, CGFLOAT_MAX)
               lineBreakMode:NSLineBreakByWordWrapping];
}

- (UIFont*)fontForType:(BUBBLE_FONT_TYPE)type
{
    switch (type) {
        case BFT_FROMTEXT:
        {
            return [UIFont systemFontOfSize:17];
        }
        case BFT_TOTEXT:
        {
            return [UIFont systemFontOfSize:17];
        }
        case BFT_TIME:
        {
            return [UIFont systemFontOfSize:10];
        }
        default:
            break;
    }

    return [UIFont systemFontOfSize:17];
}

- (CGFloat)getMarginTop
{
    if([self.showTime boolValue])
        return BUBBLE_MARGIN_TOP + BUBBLE_TIME_HEIGHT;
    
    return BUBBLE_MARGIN_TOP;
}

@end
