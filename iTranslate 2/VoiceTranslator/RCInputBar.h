//
//  RCInputBar.h
//  Translator
//
//  Created by xuzepei on 9/30/14.
//  Copyright (c) 2014 xuzepei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Translation.h"

@protocol RCInputBarDelegate <NSObject>

- (void)translateText:(Translation*)translation;

@end

@interface RCInputBar : UIView<UITextFieldDelegate>

@property(nonatomic,strong)UITextField* tf;
@property(nonatomic,strong)Translation* translation;
@property(nonatomic,assign)id delegate;
@property(nonatomic,strong)UIButton* sendButton;

- (void)updateContent:(Translation*)translation;

@end
