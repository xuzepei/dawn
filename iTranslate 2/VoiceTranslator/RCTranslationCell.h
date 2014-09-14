//
//  RCTranslationCell.h
//  VoiceTranslator
//
//  Created by xuzepei on 6/19/13.
//  Copyright (c) 2013 xuzepei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RCTranslationCellContentView.h"
#import "Translation.h"

@interface RCTranslationCell : UITableViewCell

@property(nonatomic,retain)RCTranslationCellContentView* myContentView;
@property(assign)id delegate;

- (void)updateContent:(Translation*)translation;

@end
