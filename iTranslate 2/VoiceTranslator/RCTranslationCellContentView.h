//
//  RCTranslationCellContentView.h
//  VoiceTranslator
//
//  Created by xuzepei on 6/20/13.
//  Copyright (c) 2013 xuzepei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Translation.h"
#import "RCActionMenu.h"
#import "RCTranslatorViewController.h"

@protocol RCTranslationCellContentViewDelegate <NSObject>

@optional
- (void)clickedBubble:(BUBBLE_TYPE)type translation:(Translation*)translation actionMenuPoint:(CGPoint)point orientation:(ORIENTATION_TYPE)orientation;
- (void)clickedSpaceArea:(id)token;

@end

@interface RCTranslationCellContentView : UIView

@property(nonatomic,retain)Translation* translation;
@property(nonatomic,retain)UIImageView* loadingImageView;
@property(assign)CGRect fromBubbleRect;
@property(assign)CGRect toBubbleRect;
@property(assign)id delegate;
@property(nonatomic,retain)RCActionMenu* actionMenu;
@property(nonatomic,retain)NSArray* allMenuItems;

- (void)updateContent:(Translation*)translation;

@end
