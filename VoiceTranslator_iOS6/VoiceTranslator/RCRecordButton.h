//
//  RCRecordButton.h
//  VoiceTranslator
//
//  Created by xuzepei on 12/6/12.
//  Copyright (c) 2012 xuzepei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface RCRecordButton : UIButton

@property(assign)id delegate;
@property(nonatomic,retain)NSString* language;
@property(nonatomic,retain)NSString* toLanguage;
@property(assign)BOOL isTouchDown;
@property(assign)BOOL isRecording;
@property(assign)SEL selector;
@property(nonatomic,retain)CALayer* indicatorLayer;

- (void)updateContent;
- (void)startIndicator;
- (void)stopIndicator;

@end
