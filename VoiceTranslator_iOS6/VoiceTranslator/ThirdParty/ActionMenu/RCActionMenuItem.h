//
//  RCActionMenuItem.h
//  VoiceTranslator
//
//  Created by xuzepei on 6/27/13.
//  Copyright (c) 2013 xuzepei. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RCActionMenuItemDelegate <NSObject>

- (void)clickedItem:(ACTION_TYPE)type;

@end

@interface RCActionMenuItem : UIView

@property(assign)ACTION_TYPE type;
@property(nonatomic,retain)UIImage* image;
@property(assign)id delegate;

- (void)updateContent:(ACTION_TYPE)type;

@end
