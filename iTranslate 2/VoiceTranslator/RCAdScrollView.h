//
//  RCAdScrollView.h
//  RCFang
//
//  Created by xuzepei on 3/10/13.
//  Copyright (c) 2013 xuzepei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RCAdView.h"

@protocol RCAdScrollViewDelegate <NSObject>

@end

@interface RCAdScrollView : UIView<UIScrollViewDelegate,RCAdViewDelegate>


@property(nonatomic,retain)UIScrollView* scrollView;
@property(nonatomic,retain)NSMutableArray* itemArray;
@property(nonatomic,retain)UIPageControl* pageControl;
@property(nonatomic,retain)NSTimer* timer;
@property(assign)int currentIndex;


- (void)updateContent:(NSArray*)itemArray;
- (void)goToIndex:(int)index;

@end
