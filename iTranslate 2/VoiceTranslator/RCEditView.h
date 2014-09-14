//
//  RCEditView.h
//  VoiceTranslator
//
//  Created by xuzepei on 6/28/13.
//  Copyright (c) 2013 xuzepei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Translation.h"

@protocol RCEditViewDelegate <NSObject>

- (void)translateText:(Translation*)translation;

@end

@interface RCEditView : UIView<UITextViewDelegate>

@property(nonatomic,retain)UITextView* textView;
@property(nonatomic,retain)UIButton* closeButton;
@property(nonatomic,retain)Translation* translation;
@property(assign)id delegate;

- (void)updateContent:(Translation*)translation;

@end
