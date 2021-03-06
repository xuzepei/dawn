//
//  RCTranslatorViewController.h
//  VoiceTranslator
//
//  Created by xuzepei on 11/10/12.
//  Copyright (c) 2012 xuzepei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RCRecordButton.h"
#import <AVFoundation/AVFoundation.h>
#import "RCTitleBar.h"
#import "RCActionMenu.h"
#import "Translation.h"
#import "ASIHTTPRequest.h"
#import "RCEditView.h"
#import "RCMagnifyView.h"
#import "RCMaskView.h"
#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "RCInputBar.h"

@class RCRecordController;
@class AQLevelMeter;

@interface RCTranslatorViewController : UIViewController<AVAudioPlayerDelegate,UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate,UIActionSheetDelegate,MFMailComposeViewControllerDelegate,MFMessageComposeViewControllerDelegate>

@property(nonatomic,retain)RCTitleBar* titleBar;
@property(nonatomic,strong)RCRecordController* recordController;
@property(nonatomic,strong)RCRecordButton* firstRecordButton;
@property(nonatomic,strong)RCRecordButton* secondRecordButton;
@property(assign)BOOL isTranslating;
@property(assign)BOOL isRecording;
@property(nonatomic,retain)AQLevelMeter* leftLevelMeter;
@property(nonatomic,retain)AQLevelMeter* rightLevelMeter;
@property(nonatomic,retain)AVAudioPlayer* mp3Player;

@property(nonatomic,retain)UITableView* tableView;
@property(nonatomic,retain)NSMutableArray* itemArray;
@property(nonatomic,retain)UIButton* settingButton;
@property(nonatomic,retain)RCActionMenu* actionMenu;
@property(nonatomic,retain)Translation* selectedTranslation;
@property(nonatomic,assign)BUBBLE_TYPE selectedBubbleType;
@property(nonatomic,retain)RCInputBar* inputBar;
@property(assign)BOOL isEditing;
@property(nonatomic,retain)RCMagnifyView* magnifyView;
@property(nonatomic,retain)UIImageView* loadingImageView;
@property(nonatomic,retain)UILabel* tipLabel;
@property(assign)CGFloat adHeight;
@property(nonatomic,assign)BOOL goToSettings;


@end
