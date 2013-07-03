//
//  RCMagnifyView.h
//  VoiceTranslator
//
//  Created by xuzepei on 6/28/13.
//  Copyright (c) 2013 xuzepei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RCMagnifyView : UIView

@property(nonatomic,retain)UIButton* closeButton;
@property(nonatomic,retain)NSString* text;

- (void)updateContent:(NSString*)text;

@end
