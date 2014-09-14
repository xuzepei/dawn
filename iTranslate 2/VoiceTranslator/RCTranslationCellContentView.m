//
//  RCTranslationCellContentView.m
//  VoiceTranslator
//
//  Created by xuzepei on 6/20/13.
//  Copyright (c) 2013 xuzepei. All rights reserved.
//

#import "RCTranslationCellContentView.h"
#import "RCTool.h"
#import "ASIHTTPRequest.h"
#import "UIMenuItem+CXAImageSupport.h"

#define OFFSET_X 22.0f

#define FLAG_OFFSET_X 6.0
#define FLAG_SIZE CGSizeMake(15.0,10.0)

#define ACTION_MENU_BAR_WIDTH 160.0

@implementation RCTranslationCellContentView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        
        UIMenuItem *item0 = [[[UIMenuItem alloc] initWithTitle:nil action:@selector(menuAction0:)] autorelease];
        [item0 cxa_setImage:[UIImage imageNamed:@"action_copy"] hidesShadow:NO forTitle:@"1"] ;
        UIMenuItem *item1 = [[[UIMenuItem alloc] initWithTitle:nil action:@selector(menuAction1:)]autorelease];
        [item1 cxa_setImage:[UIImage imageNamed:@"action_edit"] hidesShadow:NO forTitle:@"2"];
        UIMenuItem *item2 = [[[UIMenuItem alloc] initWithTitle:nil action:@selector(menuAction2:)]autorelease];
        [item2 cxa_setImage:[UIImage imageNamed:@"action_share"] hidesShadow:NO forTitle:@"3"];
        UIMenuItem *item3 = [[[UIMenuItem alloc] initWithTitle:nil action:@selector(menuAction3:)]autorelease];
        [item3 cxa_setImage:[UIImage imageNamed:@"action_delete"] hidesShadow:NO forTitle:@"4"];
        UIMenuItem *item4 = [[[UIMenuItem alloc] initWithTitle:nil action:@selector(menuAction4:)]autorelease];
        [item4 cxa_setImage:[UIImage imageNamed:@"action_speak"] hidesShadow:NO forTitle:@"5"];
        UIMenuItem *item5 = [[[UIMenuItem alloc] initWithTitle:nil action:@selector(menuAction5:)]autorelease];
        [item5 cxa_setImage:[UIImage imageNamed:@"action_magnify"] hidesShadow:NO forTitle:@"6"];
        self.allMenuItems = @[item0, item1, item2,item3,item4,item5];
        
        //add gesture recognizers to the image view
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
        [singleTap setNumberOfTapsRequired:1];
        
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
        [doubleTap setNumberOfTapsRequired:2];

        [self addGestureRecognizer:singleTap];
        [self addGestureRecognizer:doubleTap];
        
        [singleTap requireGestureRecognizerToFail:doubleTap];
        
        [singleTap release];
        [doubleTap release];
    }
    return self;
}

- (void)dealloc
{
    self.translation = nil;
    self.loadingImageView = nil;
    self.delegate = nil;
    self.actionMenu = nil;
    self.allMenuItems = nil;
    
    [super dealloc];
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    if(nil == _translation)
        return;
    
    NSTextAlignment alignment = NSTextAlignmentLeft;
    UIImage* bubbleImage = nil;
    
    //From
    CGFloat marginTop = BUBBLE_MARGIN_TOP;
    if([_translation.showTime boolValue])
        marginTop += BUBBLE_TIME_HEIGHT;
    
    CGSize fromBubbleSize = [_translation getFromBubbleSize];
    CGFloat bubble_x = OFFSET_X; //气泡的起点X坐标
    CGFloat flag_x = 0.0; //国旗的起点X坐标 
    CGFloat text_x = BUBBLE_PADDING_LEFT; //文字的起点X坐标
    int type = [_translation.align intValue];
    if(CLT_LEFT == type)
    {
        bubbleImage = [UIImage imageNamed:@"lbf_0"];
        if([RCTool systemVersion] >= 6.0)
            bubbleImage = [bubbleImage resizableImageWithCapInsets:BUBBLE_EDGE_INSETS resizingMode:UIImageResizingModeStretch];
        else
            bubbleImage = [bubbleImage resizableImageWithCapInsets:BUBBLE_EDGE_INSETS];
        
        if([RCTool needSetTextRightAlignment:_translation.fromCode])
            alignment = NSTextAlignmentRight;
    }
    else if(CLT_RIGHT == type)
    {
        bubbleImage = [UIImage imageNamed:@"rbf_0"];
        if([RCTool systemVersion] >= 6.0)
            bubbleImage = [bubbleImage resizableImageWithCapInsets:BUBBLE_EDGE_INSETS resizingMode:UIImageResizingModeStretch];
        else
            bubbleImage = [bubbleImage resizableImageWithCapInsets:BUBBLE_EDGE_INSETS];
        
        bubble_x = self.bounds.size.width - fromBubbleSize.width - OFFSET_X;
        alignment = NSTextAlignmentRight;
        
        text_x = BUBBLE_PADDING_RIGHT;
    }
    
    NSString* fromText = _translation.fromText;
    if([fromText length])
    {
        //气泡
        CGRect bubbleFrame = CGRectMake(bubble_x, marginTop, ceil(fromBubbleSize.width), ceil(fromBubbleSize.height));
        _fromBubbleRect = bubbleFrame;
        [bubbleImage drawInRect:bubbleFrame];
        
        //国旗
        UIImage* flagImage = [UIImage imageNamed:[NSString stringWithFormat:@"flag_%@",_translation.fromCode]];
        
        if(CLT_LEFT == type)
        {
//            flag_x = bubbleFrame.origin.x + bubbleFrame.size.width + FLAG_OFFSET_X;
            flag_x = 4.0;
        }
        else if(CLT_RIGHT == type)
        {
//            flag_x = bubbleFrame.origin.x - FLAG_OFFSET_X - FLAG_SIZE.width;
            flag_x = self.bounds.size.width - 4.0 - FLAG_SIZE.width;
        }
        
        [flagImage drawInRect:CGRectMake(flag_x, bubbleFrame.origin.y + bubbleFrame.size.height - FLAG_SIZE.height, FLAG_SIZE.width, FLAG_SIZE.height)];
        
        //文字
        UIFont* fromTextFont = [_translation fontForType:BFT_FROMTEXT];
        CGSize fromTextSize = [_translation getFromTextSize];
        
        if(CLT_LEFT == type)
        {
            text_x = MAX(BUBBLE_PADDING_LEFT,(MIN_BUBBLE_WIDTH - fromTextSize.width)/2.0);
        }
        else if(CLT_RIGHT == type)
        {
            text_x = MAX(BUBBLE_PADDING_RIGHT,(MIN_BUBBLE_WIDTH - fromTextSize.width)/2.0);
        }
        

        CGRect fromTextRect = CGRectMake(bubble_x + text_x, marginTop +BUBBLE_PADDING_TOP, fromTextSize.width, fromTextSize.height);
        [fromText drawInRect:fromTextRect withFont:fromTextFont lineBreakMode:NSLineBreakByWordWrapping alignment:alignment];
    }
    
    //To
    alignment = NSTextAlignmentLeft;
    NSString* toText = _translation.toText;
    if([toText length])
    {
        //气泡
        CGSize toBubbleSize = [_translation getToBubbleSize];
        CGFloat bubble_x = OFFSET_X; //气泡的起点X坐标
        CGFloat text_x = BUBBLE_PADDING_RIGHT; //文字的起点
            bubble_x = self.bounds.size.width - toBubbleSize.width - OFFSET_X;
            alignment = NSTextAlignmentRight;
            text_x = BUBBLE_PADDING_RIGHT;
        
        bubbleImage = [UIImage imageNamed:@"bt_0"];
        bubbleImage = [bubbleImage resizableImageWithCapInsets:BUBBLE_EDGE_INSETS resizingMode:UIImageResizingModeStretch];
        
        CGRect toBubbleFrame = CGRectMake(bubble_x, marginTop + fromBubbleSize.height + BUBBLE_FROM_TO_INTERVAL, ceil(toBubbleSize.width), ceil(toBubbleSize.height));
        _toBubbleRect = toBubbleFrame;
        [bubbleImage drawInRect:toBubbleFrame];
        
        //国旗
        UIImage* flagImage = [UIImage imageNamed:[NSString stringWithFormat:@"flag_%@",_translation.toCode]];
        flag_x = self.bounds.size.width - 4.0 - FLAG_SIZE.width;
        [flagImage drawInRect:CGRectMake(flag_x, toBubbleFrame.origin.y + toBubbleFrame.size.height - FLAG_SIZE.height, FLAG_SIZE.width, FLAG_SIZE.height)];
        
        //文字
        UIFont* toTextFont = [_translation fontForType:BFT_TOTEXT];
        CGSize toTextSize = [_translation getToTextSize];
        text_x = MAX(BUBBLE_PADDING_RIGHT,(MIN_BUBBLE_WIDTH - toTextSize.width - 4)/2.0);
        
        CGRect toTextRect = CGRectMake(bubble_x + text_x, marginTop + fromBubbleSize.height + BUBBLE_FROM_TO_INTERVAL + BUBBLE_PADDING_TOP, toTextSize.width, toTextSize.height);
        [toText drawInRect:toTextRect withFont:toTextFont lineBreakMode:NSLineBreakByWordWrapping alignment:alignment];
    }

    //画时间
    if([_translation.showTime boolValue])
    {
        NSDate* date = [NSDate dateWithTimeIntervalSince1970:[_translation.time doubleValue]];
        
        NSString* dateString = [RCTool getDateString:date];
        if([dateString length])
        {
            [[UIColor grayColor] set];
            UIFont* font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12];
            CGRect rect = CGRectMake(10, BUBBLE_MARGIN_TOP - 8, [RCTool getScreenSize].width - 20, 20);
            NSString* temp = [NSString stringWithFormat:@"%@",dateString];
            [temp drawInRect:rect withFont:font lineBreakMode:NSLineBreakByTruncatingTail alignment:NSTextAlignmentCenter];
        }
    }
}


- (void)updateContent:(Translation*)translation
{
    self.translation = translation;
    self.fromBubbleRect = CGRectZero;
    self.toBubbleRect = CGRectZero;
    
    NSString* toText = _translation.toText;
    if(0 == [toText length])
    {
        if([_translation.isLoading boolValue])
        {
            [self addLoadingView];
            
            CGFloat marginTop = BUBBLE_MARGIN_TOP;
            if([_translation.showTime boolValue])
                marginTop += BUBBLE_TIME_HEIGHT;
            CGSize fromBubbleSize = [_translation getFromBubbleSize];
            CGFloat offset_x = 0.0;
            CGFloat offset_y = 0.0;
            CGRect rect = _loadingImageView.frame;
            offset_x = [RCTool getScreenSize].width - OFFSET_X - rect.size.width;
            offset_y = marginTop + fromBubbleSize.height + BUBBLE_FROM_TO_INTERVAL;
            
            rect.origin.x = offset_x;
            rect.origin.y = offset_y;
            _loadingImageView.frame = rect;
            
            [self addSubview:_loadingImageView];
        }
    }
    else{
        [self removeLoadingView];
    }
    
    [self setNeedsDisplay];
}

- (void)addLoadingView
{
    if(nil == _loadingImageView)
    {
        _loadingImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 60, 11)];
        NSMutableArray* images = [[NSMutableArray alloc] init];
        
        for(int i = 0; i < 3; i++)
        {
            [images addObject:[UIImage imageNamed:[NSString stringWithFormat:@"translating_loading_%d",i]]];
        }
        
        _loadingImageView.animationImages = images;
        [images release];
        _loadingImageView.animationDuration = 0.5;
        
        [_loadingImageView startAnimating];
    }
}

- (void)removeLoadingView
{
    if(_loadingImageView)
    {
        [_loadingImageView stopAnimating];
        [_loadingImageView removeFromSuperview];
        self.loadingImageView = nil;
    }
}

- (void)playTTS:(NSString*)ttsUrl
{
    if(0 == [ttsUrl length])
        return;
    
    NSString* ttsPath = nil;
    if([ttsUrl hasPrefix:@"http"])
    {
        ttsPath = [RCTool getTTSPath:ttsUrl];
        if([RCTool isExistingFile:ttsPath])
        {
            [RCTool playTTS:ttsUrl];
        }
        else
        {
            NSURL* url = [NSURL URLWithString:ttsUrl];
            ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
            [request setDelegate:self];
            NSMutableDictionary* dict = [[[NSMutableDictionary alloc] init] autorelease];
            [dict setObject:@"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_3) AppleWebKit/537.31 (KHTML, like Gecko) Chrome/26.0.1410.65 Safari/537.31" forKey:@"User-Agent"];
            [request setRequestHeaders:dict];
            [request setDownloadDestinationPath:[RCTool getTTSPath:ttsUrl]];
            NSDictionary* userInfo = [NSDictionary dictionaryWithObject:ttsUrl forKey:@"ttsUrl"];
            [request setUserInfo:userInfo];
            [request startAsynchronous];
        }
    }

}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    NSLog(@"requestFinished");
    
    NSDictionary* userInfo = [request userInfo];
    if(userInfo && [userInfo isKindOfClass:[NSDictionary class]])
    {
        NSString* ttsUrl = [userInfo objectForKey:@"ttsUrl"];
        if([ttsUrl length])
            [RCTool playTTS:ttsUrl];
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSLog(@"requestFailed");
}

- (void)clickedBubble:(BUBBLE_TYPE)type translation:(Translation*)translation bubbleFrame:(CGRect)bubbleFrame
{
    ORIENTATION_TYPE orientation = OT_MIDDLE;
    CGPoint point;
    if(BT_FROM == type)
    {
        point.x = bubbleFrame.origin.x + bubbleFrame.size.width + 6.0;
        point.y = bubbleFrame.origin.y;
        
        if(point.x <= [RCTool getScreenSize].width - ACTION_MENU_BAR_WIDTH)
        {
            orientation = OT_RIGHT;
        }
    }
    else if(BT_TO == type)
    {
        point.x = bubbleFrame.origin.x - 36.0;
        point.y = bubbleFrame.origin.y;
        
        if(point.x + 30 >= ACTION_MENU_BAR_WIDTH)
        {
            orientation = OT_LEFT;
        }
    }

    RCTranslatorViewController* temp = (RCTranslatorViewController*)_delegate;
    point = [temp.tableView convertPoint:point fromView:self];
    
    if(OT_MIDDLE == orientation)
    {
        if(point.y < ACTION_MENU_BAR_WIDTH)
            orientation = OT_BOTTOM;
        else
        {
            CGSize contentSize = temp.tableView.contentSize;
            
            if(contentSize.height - point.y < ACTION_MENU_BAR_WIDTH)
                orientation = OT_TOP;
        }
    }
    
    if(_delegate && [_delegate respondsToSelector:@selector(clickedBubble:translation:actionMenuPoint:orientation:)])
    {
        NSMutableArray* array = [[[NSMutableArray alloc] init] autorelease];
        if(BT_FROM == type)
        {
            [array addObject:_allMenuItems[0]];
            [array addObject:_allMenuItems[1]];
            NSString* code = self.translation.fromCode;
            if([RCTool isSupportedTTS:code])
                [array addObject:_allMenuItems[4]];
            
            [array addObject:_allMenuItems[5]];
            [array addObject:_allMenuItems[3]];

        }
        else
        {
            [array addObject:_allMenuItems[0]];
            [array addObject:_allMenuItems[2]];
            NSString* code = self.translation.toCode;
            if([RCTool isSupportedTTS:code])
                [array addObject:_allMenuItems[4]];
            
            [array addObject:_allMenuItems[5]];
            [array addObject:_allMenuItems[3]];
        }
        
        [[UIMenuController sharedMenuController] setMenuItems:array];
        [[UIMenuController sharedMenuController] setTargetRect:bubbleFrame inView:self];
        
        [_delegate clickedBubble:type translation:translation actionMenuPoint:point orientation:orientation];
    }
}

//- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    UITouch* touch = [touches anyObject];
//    CGPoint point = [touch locationInView:self];
//    
//    if(CGRectContainsPoint(_fromBubbleRect, point))
//    {
//        if(touch.tapCount > 1)
//        {
//            if(0 == [_translation.fromVoice length])
//            {
//                NSString* urlString = [RCTool getTTSUrl:_translation.fromCode text:_translation.fromText];
//                _translation.fromVoice = urlString;
//            }
//        
//            if([_translation.fromVoice hasPrefix:@"http"])
//                [self playTTS:_translation.fromVoice];
//            else
//                [RCTool playTTS:_translation.fromVoice];
//        }
//        else if(touch.tapCount == 1)
//        {
//            [self clickedBubble:BT_FROM translation:_translation bubbleFrame:_fromBubbleRect];
//        }
//    }
//    else if(CGRectContainsPoint(_toBubbleRect, point))
//    {
//        if(touch.tapCount > 1)
//        {
//            [self playTTS:_translation.ttsUrl];
//        }
//        else if(touch.tapCount == 1)
//        {
//            [self clickedBubble:BT_TO translation:_translation bubbleFrame:_toBubbleRect];
//        }
//    }
//    
//    [super touchesEnded:touches withEvent:event];
//}

- (void)handleSingleTap:(UIGestureRecognizer *)gestureRecognizer {

    CGPoint point = [gestureRecognizer locationInView:self];
    if(CGRectContainsPoint(_fromBubbleRect, point))
    {
        [self clickedBubble:BT_FROM translation:_translation bubbleFrame:_fromBubbleRect];
    }
    else if(CGRectContainsPoint(_toBubbleRect, point))
    {
        [self clickedBubble:BT_TO translation:_translation bubbleFrame:_toBubbleRect];
    }
    else{
        
        if(_delegate && [_delegate respondsToSelector:@selector(clickedSpaceArea:)])
        {
            [_delegate clickedSpaceArea:nil];
        }
    }
}

- (void)handleDoubleTap:(UIGestureRecognizer *)gestureRecognizer {

    CGPoint point = [gestureRecognizer locationInView:self];
    if(CGRectContainsPoint(_fromBubbleRect, point))
    {
        if(0 == [_translation.fromVoice length])
        {
            NSString* urlString = [RCTool getTTSUrl:_translation.fromCode text:_translation.fromText];
            _translation.fromVoice = urlString;
        }

        if([_translation.fromVoice hasPrefix:@"http"])
            [self playTTS:_translation.fromVoice];
        else
            [RCTool playTTS:_translation.fromVoice];
    }
    else if(CGRectContainsPoint(_toBubbleRect, point))
    {
        [self playTTS:_translation.ttsUrl];
    }
}



@end
