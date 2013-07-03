//
//  RCAdView.h
//  RCFang
//
//  Created by xuzepei on 3/10/13.
//  Copyright (c) 2013 xuzepei. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RCAdViewDelegate <NSObject>

@optional
- (void)clickedAd:(id)token;

@end

@interface RCAdView : UIView

@property(nonatomic,retain)NSDictionary* item;
@property(nonatomic,retain)NSString* imageUrl;
@property(nonatomic,retain)UIImage* image;

- (void)updateContent:(NSDictionary*)item;

@end
