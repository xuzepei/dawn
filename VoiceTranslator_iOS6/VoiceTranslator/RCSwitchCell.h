//
//  RCSwitchCell.h
//  VoiceTranslator
//
//  Created by xuzepei on 6/18/13.
//  Copyright (c) 2013 xuzepei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RCSwitchCell : UITableViewCell

@property(nonatomic,retain)UISwitch* switcher;
@property(assign)SWITCH_TYPE type;

- (void)updateContent:(SWITCH_TYPE)type;

@end
