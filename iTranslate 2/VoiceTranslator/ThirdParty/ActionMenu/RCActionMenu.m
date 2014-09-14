//
//  RCActionMenu.m
//  VoiceTranslator
//
//  Created by xuzepei on 6/27/13.
//  Copyright (c) 2013 xuzepei. All rights reserved.
//

#import "RCActionMenu.h"
#import "RCTool.h"

#define MENU_ITEM_WIDTH 30.0

@implementation RCActionMenu

- (id)initWithFrame:(CGRect)frame orientation:(ORIENTATION_TYPE)orientation
{
    if(self = [super initWithFrame:frame])
    {
        self.backgroundColor = [UIColor clearColor];
        self.type = orientation;
        
        [self setDefaults];
    }
    
    return self;
}

- (void)dealloc
{
    self.translation = nil;
    self.fromBubbleMenuItems = nil;
    self.toBubbleMenuItems = nil;
    self.delegate = nil;
    
    [super dealloc];
}

- (void)updateContent:(BUBBLE_TYPE)bubbleType translation:(Translation*)translation orientation:(ORIENTATION_TYPE)orientation
{
    self.translation = translation;
    self.type = orientation;
    self.bubbleType = bubbleType;
    
    if(BT_FROM == bubbleType)
    {
        [self initFromBubbleMenuItems];
        [self setItems:_fromBubbleMenuItems];
    }
    else if(BT_TO == bubbleType)
    {
        [self initToBubbleMenuItems];
        [self setItems:_toBubbleMenuItems];
    }
}

- (void)initFromBubbleMenuItems
{
    if(nil == _fromBubbleMenuItems)
    {
        _fromBubbleMenuItems = [[NSMutableArray alloc] init];
    }
    
    if(0 == [_fromBubbleMenuItems count])
    {
        RCActionMenuItem* item = [[[RCActionMenuItem alloc] initWithFrame:CGRectMake(0, 0,MENU_ITEM_WIDTH,MENU_ITEM_WIDTH)] autorelease];
        item.delegate = self;
        [item updateContent:AT_COPY];
        [_fromBubbleMenuItems addObject:item];
        
        item = [[[RCActionMenuItem alloc] initWithFrame:CGRectMake(0, 0,MENU_ITEM_WIDTH,MENU_ITEM_WIDTH)] autorelease];
        item.delegate = self;
        [item updateContent:AT_EDIT];
        [_fromBubbleMenuItems addObject:item];
        
        item = [[[RCActionMenuItem alloc] initWithFrame:CGRectMake(0, 0,MENU_ITEM_WIDTH,MENU_ITEM_WIDTH)] autorelease];
        item.delegate = self;
        [item updateContent:AT_SPEAK];
        [_fromBubbleMenuItems addObject:item];
        
        item = [[[RCActionMenuItem alloc] initWithFrame:CGRectMake(0, 0,MENU_ITEM_WIDTH,MENU_ITEM_WIDTH)] autorelease];
        item.delegate = self;
        [item updateContent:AT_MAGNIFY];
        [_fromBubbleMenuItems addObject:item];
        
        item = [[[RCActionMenuItem alloc] initWithFrame:CGRectMake(0, 0,MENU_ITEM_WIDTH,MENU_ITEM_WIDTH)] autorelease];
        item.delegate = self;
        [item updateContent:AT_DELETE];
        [_fromBubbleMenuItems addObject:item];
    }
    
    RCActionMenuItem* speakItem = [_fromBubbleMenuItems objectAtIndex:2];
    if(speakItem)
    {
        BOOL b = [RCTool isSupportedTTS:self.translation.fromCode];
        speakItem.disableSpeak = !b;
        [speakItem updateContent:AT_SPEAK];
    }
}

- (void)initToBubbleMenuItems
{
    if(nil == _toBubbleMenuItems)
    {
        _toBubbleMenuItems = [[NSMutableArray alloc] init];
    }
    
    if(0 == [_toBubbleMenuItems count])
    {
        RCActionMenuItem* item = [[[RCActionMenuItem alloc] initWithFrame:CGRectMake(0, 0,MENU_ITEM_WIDTH,MENU_ITEM_WIDTH)] autorelease];
        item.delegate = self;
        [item updateContent:AT_COPY];
        [_toBubbleMenuItems addObject:item];
        
        item = [[[RCActionMenuItem alloc] initWithFrame:CGRectMake(0, 0,MENU_ITEM_WIDTH,MENU_ITEM_WIDTH)] autorelease];
        item.delegate = self;
        [item updateContent:AT_SHARE];
        [_toBubbleMenuItems addObject:item];
        
        item = [[[RCActionMenuItem alloc] initWithFrame:CGRectMake(0, 0,MENU_ITEM_WIDTH,MENU_ITEM_WIDTH)] autorelease];
        item.delegate = self;
        [item updateContent:AT_SPEAK];
        [_toBubbleMenuItems addObject:item];
        
        item = [[[RCActionMenuItem alloc] initWithFrame:CGRectMake(0, 0,MENU_ITEM_WIDTH,MENU_ITEM_WIDTH)] autorelease];
        item.delegate = self;
        [item updateContent:AT_MAGNIFY];
        [_toBubbleMenuItems addObject:item];
        
        item = [[[RCActionMenuItem alloc] initWithFrame:CGRectMake(0, 0,MENU_ITEM_WIDTH,MENU_ITEM_WIDTH)] autorelease];
        item.delegate = self;
        [item updateContent:AT_DELETE];
        [_toBubbleMenuItems addObject:item];
    }
    
    RCActionMenuItem* speakItem = [_toBubbleMenuItems objectAtIndex:2];
    if(speakItem)
    {
        BOOL b = [RCTool isSupportedTTS:self.translation.toCode];
        speakItem.disableSpeak = !b;
        [speakItem updateContent:AT_SPEAK];
    }
}

- (void)setItems:(NSArray*)items
{
    for(UIView* subView in self.subviews)
        [subView removeFromSuperview];
    
    for(int i = [items count] -1; i >= 0; i--)
    {
        UIView* subView = [items objectAtIndex:i];
        subView.alpha = 0.0;
        [self addSubview:subView];
    }
    
    [self setButtons:items];
    
    if([items count])
    {
        if(_toggled)
            [self unfold];
        else
            [self fold];
    }
}


- (void)fold
{
    if(self.superview)
    {
        [self hideButtonsAnimated:NO];
        [self removeFromSuperview];
    }
}

- (void)unfold
{
    [self showButtonsAnimated:self.type];
}

- (void)clickedItem:(ACTION_TYPE)type
{
    if(_delegate && [_delegate respondsToSelector:@selector(clickedMenuItem:bubbleType:translation:)])
    {
        [_delegate clickedMenuItem:type bubbleType:self.bubbleType translation:self.translation];
    }
}

@end
