//
//  RCActionMenu.h
//  VoiceTranslator
//
//  Created by xuzepei on 6/27/13.
//  Copyright (c) 2013 xuzepei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RNExpandingButtonBar.h"
#import "Translation.h"
#import "RCActionMenuItem.h"

@protocol RCActionMenuDelegate <NSObject>

@optional
- (void)clickedMenuItem:(ACTION_TYPE)actionType bubbleType:(BUBBLE_TYPE)bubbleType translation:(Translation*)translation;

@end

@interface RCActionMenu : RNExpandingButtonBar

@property(assign)BUBBLE_TYPE bubbleType;
@property(nonatomic,retain)Translation* translation;
@property(assign)ORIENTATION_TYPE type;
@property(nonatomic,retain)NSMutableArray* fromBubbleMenuItems;
@property(nonatomic,retain)NSMutableArray* toBubbleMenuItems;
@property(nonatomic,assign)id delegate;

- (id)initWithFrame:(CGRect)frame orientation:(ORIENTATION_TYPE)orientation;
- (void)updateContent:(BUBBLE_TYPE)bubbleType translation:(Translation*)translation orientation:(ORIENTATION_TYPE)orientation;
- (void)fold;


@end
