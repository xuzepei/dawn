//
//  RCMagnifyViewController.h
//  Translator
//
//  Created by xuzepei on 9/14/14.
//  Copyright (c) 2014 xuzepei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Translation.h"

@interface RCMagnifyViewController : UIViewController

@property(nonatomic,assign)IBOutlet UITextView* tv;
@property(nonatomic,retain)Translation* translation;
@property(assign)BUBBLE_TYPE bubbleType;
@property(assign)BOOL supportVoice;

- (void)updateContent:(Translation*)translation bubbleType:(BUBBLE_TYPE)bubbleType;

@end
