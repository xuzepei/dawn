//
//  RCTitleBar.h
//  Translator
//
//  Created by xuzepei on 8/23/14.
//  Copyright (c) 2014 xuzepei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RCTitleBar : UIView

@property(nonatomic,retain)UILabel* fromLabel;
@property(nonatomic,retain)UILabel* toLabel;

- (void)updateContent;

@end
