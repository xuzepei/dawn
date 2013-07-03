//
//  WRTitleBar.h
//  KTV
//
//  Created by zepei xu on 7/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WRTitleBar : UIView

@property(nonatomic,retain)UILabel* titleLabel;
@property(nonatomic,retain)UIButton* leftButton;
@property(nonatomic,retain)UIButton* rightButton;
@property(assign)id target;
@property(assign)SEL clickedLeftButtonSelector;
@property(assign)SEL clickedRightButtonSelector;

- (void)addTarget:(id)target 
clickedLeftButtonSelector:(SEL)clickedLeftButtonSelector
clickedRightButtonSelector:(SEL)clickedRightButtonSelector;


@end
