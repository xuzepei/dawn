//
//  RCChooseLanguageCell.h
//  Translator
//
//  Created by xuzepei on 9/13/14.
//  Copyright (c) 2014 xuzepei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RCChooseLanguageCell : UITableViewCell

@property(nonatomic,retain)UIImageView* myImageView;

- (void)updateContent:(NSDictionary*)item;

@end
