//
//  RCTranslatorViewController.m
//  VoiceTranslator
//
//  Created by xuzepei on 11/10/12.
//  Copyright (c) 2012 xuzepei. All rights reserved.
//

#import "RCTranslatorViewController.h"
#import "RCRecordController.h"
#import "RCTranslateProcess.h"
#import "RCTool.h"
#import "AQLevelMeter.h"
#import "RCSettingViewController.h"
#import "RCTranslationCell.h"
#import "RCHintMaskView.h"

#define RECORD_BUTTON_WIDTH 60.0
#define RECORD_BUTTON_HEIGHT 60.0

#define LEVEL_METER_HEIGHT 12.0

#define DELETE_ITEM_TAG 200
#define SHARE_TAG 201

#define EDIT_VIEW_RECT CGRectMake(0,-200,320,126)

//#define BG_COLOR [UIColor colorWithRed:0.97 green:0.95 blue:0.95 alpha:1.00]
#define BG_COLOR [UIColor whiteColor]

#define AD_HEIGHT kGADAdSizeBanner.size.height

@interface RCTranslatorViewController ()

@end

@implementation RCTranslatorViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        _itemArray = [[NSMutableArray alloc] init];
        
        self.settingButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
        _settingButton.frame = CGRectMake(4, 2, 40, 40);
        _settingButton.showsTouchWhenHighlighted = YES;
        [_settingButton addTarget:self action:@selector(clickedSettingButton:) forControlEvents:UIControlEventTouchUpInside];
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(detectEndOfSpeech:) name:DETECT_END_OF_SPEECH_NOTIFICATION object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clearUpHistory:) name:CLEAR_UP_NOTIFICATION object:nil];
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillShow:)
                                                     name:UIKeyboardWillShowNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillHide:)
                                                     name:UIKeyboardWillHideNotification
                                                   object:nil];
        
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [_recordController release];
    _recordController = nil;
    
    [_firstRecordButton release];
    _firstRecordButton = nil;
    
    [_secondRecordButton release];
    _secondRecordButton = nil;
    
    [_mp3Player release];
    _mp3Player = nil;
    
    self.leftLevelMeter = nil;
    self.rightLevelMeter = nil;
    self.titleBar = nil;
    
    self.tableView = nil;
    self.itemArray = nil;
    
    self.actionMenu = nil;
    self.selectedTranslation = nil;
    self.editView = nil;
    
    self.magnifyView = nil;
    self.loadingImageView = nil;
    
    self.tipLabel = nil;
    self.bannerView = nil;
    
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if(_firstRecordButton)
        [_firstRecordButton updateContent];
    
    if(_secondRecordButton)
        [_secondRecordButton updateContent];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.view.backgroundColor = BG_COLOR;
    self.title = NSLocalizedString(@"Bubble Translate", @"");
    
    [self.navigationController.navigationBar addSubview:_settingButton];

    [self initTableView];
    
    [self initRecordController];
    
    [self initRecordButton];
    
    [self initLevelMeter];
    
    [self initTipLabel];
    
    
    if([RCTool getShowHintMask])
    {
        [RCTool setShowHintMask:NO];
        
        RCHintMaskView* maskView = [[[RCHintMaskView alloc] initWithFrame:[RCTool getScreenRect]] autorelease];
        [[RCTool frontWindow] addSubview:maskView];
        
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent animated:YES];
    }
    
    [self initAD];
}

- (void)didReceiveMemoryWarning
{
    NSLog(@"%s",__FUNCTION__);
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
//    self.firstRecordButton = nil;
//    self.secondRecordButton = nil;
//    self.titleBar = nil;
//    self.leftLevelMeter = nil;
//    self.rightLevelMeter = nil;
//    self.tableView = nil;
}

#pragma mark - NaviagionBar

- (void)clickedSettingButton:(id)sender
{
    [self clickLeftBarButton:nil];
}

#pragma mark - Title Bar

- (void)initTitleBar
{
    if(nil == _titleBar)
    {
        CGFloat statusBarHeight = 0.0;
//        if([RCTool isIOS7])
//            statusBarHeight = STATUS_BAR_HEIGHT;
        
        _titleBar = [[WRTitleBar alloc] initWithFrame:CGRectMake(0, statusBarHeight, [RCTool getScreenSize].width, NAVIGATION_BAR_HEIGHT)];
        
        _titleBar.titleLabel.text = @"Translate Voice";
        
        [_titleBar.leftButton setImage:[UIImage imageNamed:@"setting"] forState:UIControlStateNormal];
        //        [_titleBar.leftButton setImage:[UIImage imageNamed:@"globa_bt_cancel_d.png"] forState:UIControlStateHighlighted];
        //
        //        [_titleBar.rightButton setImage:[UIImage imageNamed:@"globa_bt_ok.png"]
        //                                 forState:UIControlStateNormal];
        //        [_titleBar.rightButton setImage:[UIImage imageNamed:@"globa_bt_ok_d"] forState:UIControlStateHighlighted];
        
        [_titleBar addTarget:self
   clickedLeftButtonSelector:@selector(clickLeftBarButton:)
  clickedRightButtonSelector:@selector(clickRightBarButton:)];
    }
    
    [self.view addSubview:_titleBar];
}

- (void)clickLeftBarButton:(id)sender
{
    NSLog(@"clickLeftBarButton");
    
    RCSettingViewController* temp = [[RCSettingViewController alloc] initWithNibName:nil bundle:nil];
    temp.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    
    UINavigationController* temp1 = [[UINavigationController alloc] initWithRootViewController:temp];
    temp1.navigationBar.tintColor = NAVIGATION_BAR_COLOR;
    [temp release];
    [self presentModalViewController:temp1 animated:YES];
    [temp1 release];
}

- (void)clickRightBarButton:(id)sender
{
    
}

#pragma mark - UITableView

- (void)initTableView
{
    if(nil == _tableView)
    {
        CGFloat height = [RCTool getScreenSize].height - STATUS_BAR_HEIGHT - NAVIGATION_BAR_HEIGHT - AD_HEIGHT;
        if([RCTool systemVersion] >= 7.0 && ISFORIOS7)
            height = [RCTool getScreenSize].height - AD_HEIGHT;
        
        _tableView = [[UITableView alloc] initWithFrame: CGRectMake(0,0,[RCTool getScreenSize].width,height)
                                                  style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor = [UIColor clearColor];
        [_tableView setBackgroundView: nil];
        
        [_itemArray removeAllObjects];
        
        NSArray* translations = [RCTool getAllTranslations];
        if([translations count])
            [_itemArray addObjectsFromArray:translations]
            ;
    }
	
    [_tableView reloadData];
    [self scrollToBottomAnimated:YES];
	[self.view addSubview:_tableView];
}

- (id)getCellDataAtIndexPath:(NSIndexPath*)indexPath
{
    if(indexPath.row < [_itemArray count])
        return [_itemArray objectAtIndex: indexPath.row];
    
	return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [_itemArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Translation* translation = [self getCellDataAtIndexPath:indexPath];
    if(translation)
    {
        return [translation getHeightForCell:YES];
    }
    
	return 0.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if(0 == section)
        return RECORD_BUTTON_HEIGHT + 20.0;
    
    return 0.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	static NSString *cellId = @"cellId";
	
	UITableViewCell *cell = nil;
    cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if(nil == cell)
    {
        cell = [[[RCTranslationCell alloc] initWithStyle: UITableViewCellStyleDefault
                                         reuseIdentifier: cellId] autorelease];
        
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    Translation* translation = (Translation*)[self getCellDataAtIndexPath:indexPath];
    if(translation)
    {
        RCTranslationCell* temp = (RCTranslationCell*)cell;
        if(temp)
        {
            temp.delegate = self;
            [temp updateContent:translation];
        }
    }
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	[tableView deselectRowAtIndexPath: indexPath animated: YES];
}

- (void)scrollToBottomAnimated:(BOOL)animated
{
    NSInteger rows = [self.tableView numberOfRowsInSection:0];
    
    if(rows > 0) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:rows - 1 inSection:0]
                              atScrollPosition:UITableViewScrollPositionBottom
                                      animated:animated];
    }
}

#pragma mark - Level Meter

- (void)initLevelMeter
{
    CGFloat y = [RCTool getScreenSize].height - 62 -  STATUS_BAR_HEIGHT - NAVIGATION_BAR_HEIGHT - AD_HEIGHT;
    if([RCTool systemVersion] >= 7.0 && ISFORIOS7)
        y = [RCTool getScreenSize].height - 62 - AD_HEIGHT;
    
    if(nil == _leftLevelMeter)
    {
        _leftLevelMeter = [[AQLevelMeter alloc] initWithFrame:CGRectMake(0, 0, RECORD_BUTTON_WIDTH, LEVEL_METER_HEIGHT)];
        
        _leftLevelMeter.center = CGPointMake([RCTool getScreenSize].width/2.0, y);
        
        UIColor *bgColor = [[UIColor alloc] initWithRed:.39 green:.44 blue:.57 alpha:0];
        [_leftLevelMeter setBackgroundColor:bgColor];
        [_leftLevelMeter setBorderColor:bgColor];
        [bgColor release];
    }
    
    [self.view addSubview: _leftLevelMeter];
    
//    if(nil == _rightLevelMeter)
//    {
//        _rightLevelMeter = [[AQLevelMeter alloc] initWithFrame:CGRectMake(0, 0, RECORD_BUTTON_WIDTH, LEVEL_METER_HEIGHT)];
//        
//        _rightLevelMeter.center = CGPointMake([RCTool getScreenSize].width/2.0, y);
//        
//        UIColor *bgColor = [[UIColor alloc] initWithRed:.39 green:.44 blue:.57 alpha:0];
//        [_rightLevelMeter setBackgroundColor:bgColor];
//        [_rightLevelMeter setBorderColor:bgColor];
//        [bgColor release];
//        
////        _rightLevelMeter.layer.transform = CATransform3DMakeRotation(180.0 / 180.0 * M_PI, 0.0, 0.0, 1.0);
//    }
//    
//    [self.view addSubview: _rightLevelMeter];
}

- (void)willStartRecording:(id)token
{
    if(_recordController)
    {
        if(_recordController.recorder)
        {
            if(RBT_LEFT == _recordController.type)
            {
                [_leftLevelMeter setAq:_recordController.recorder->Queue()];
            }
            else if(RBT_RIGHT == _recordController.type)
            {
                [_leftLevelMeter setAq:_recordController.recorder->Queue()];
            }
        }
    }
}

- (void)willStopRecording:(id)token
{
    if(_recordController)
    {
        if(RBT_LEFT == _recordController.type)
        {
            [_leftLevelMeter setAq:nil];
        }
        else if(RBT_RIGHT == _recordController.type)
        {
            [_leftLevelMeter setAq:nil];
        }
    }
}

#pragma mark - Record Button

- (void)initRecordButton
{
//    RCMaskView* maskView = [[[RCMaskView alloc] initWithFrame:CGRectMake(0, [RCTool getScreenSize].height - STATUS_BAR_HEIGHT - NAVIGATION_BAR_HEIGHT - RECORD_BUTTON_HEIGHT - 20 , [RCTool getScreenSize].width, RECORD_BUTTON_HEIGHT + 20)] autorelease];
//    [self.view addSubview: maskView];
    
    CGFloat y = [RCTool getScreenSize].height - RECORD_BUTTON_HEIGHT - STATUS_BAR_HEIGHT - NAVIGATION_BAR_HEIGHT - 4 - AD_HEIGHT;
    if([RCTool systemVersion] >= 7.0 && ISFORIOS7)
        y = [RCTool getScreenSize].height - RECORD_BUTTON_HEIGHT - 4 - AD_HEIGHT;
    
    if(nil == _firstRecordButton)
    {
        _firstRecordButton = [[RCRecordButton alloc] initWithFrame:CGRectZero];
        _firstRecordButton.tag = RBT_LEFT;
        _firstRecordButton.delegate = self;
        _firstRecordButton.selector = @selector(clickedFirstRecordButton:);
        _firstRecordButton.frame = CGRectMake(60, y, RECORD_BUTTON_WIDTH, RECORD_BUTTON_HEIGHT);
    }
    
    [self.view addSubview: _firstRecordButton];
    
    
    if(nil == _secondRecordButton)
    {
        _secondRecordButton = [[RCRecordButton alloc] initWithFrame:CGRectZero];
        _secondRecordButton.tag = RBT_RIGHT;
        _secondRecordButton.delegate = self;
        _secondRecordButton.selector = @selector(clickedSecondRecordButton:);
        _secondRecordButton.frame = CGRectMake([RCTool getScreenSize].width - RECORD_BUTTON_WIDTH - 60, y, RECORD_BUTTON_WIDTH, RECORD_BUTTON_HEIGHT);
    }
    
    [self.view addSubview: _secondRecordButton];
}

- (void)initRecordController
{
    if(nil == _recordController)
    {
        _recordController = [[RCRecordController alloc] init];
        [_recordController initRecorder];
        _recordController.delegate = self;
    }
}

- (void)clickedRecordButton:(NSString*)fromLanguage toLanguage:(NSString*)toLanguage buttonTag:(RECORD_BUTTON_TYPE)buttonTag
{
    NSLog(@"clickedRecordButton");
    
    if(self.isTranslating)
        return;
    
    if(_recordController)
    {
        _settingButton.enabled = YES;
        if([_recordController isRecording])
        {    
            NSString* recordFilename = [_recordController.filename copy];
            [_recordController stop];
            
            [RCTool playSound:@"record_end.wav"];
            
            [self updateTipLabelByStep:2];
            
            if(_recordController.type != buttonTag)
            {
                if(recordFilename)
                    [recordFilename release];
            }
            else
            {
                if(NO == [_recordController isRecording])
                {
                    if(RBT_LEFT == _recordController.type)
                    {
                        _firstRecordButton.isRecording = NO;
                        [_firstRecordButton setNeedsDisplay];
                    }
                    else if(RBT_RIGHT == _recordController.type)
                    {
                        _secondRecordButton.isRecording = NO;
                        [_secondRecordButton setNeedsDisplay];
                    }
                }
                
                RCTranslateProcess* temp = [RCTranslateProcess sharedInstance];
                NSMutableDictionary* token = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:_recordController.type],@"type",recordFilename,@"filename",nil];
                BOOL b = [temp translate:[RCTool getRecordFilePath:recordFilename] fromLanguage:fromLanguage toLanguage:toLanguage delegate:self token:token];
                if(b)
                {
                    if(RBT_LEFT == _recordController.type)
                    {
                        _firstRecordButton.isRecording = NO;
                        [_firstRecordButton setNeedsDisplay];
                    }
                    else if(RBT_RIGHT == _recordController.type)
                    {
                        _secondRecordButton.isRecording = NO;
                        [_secondRecordButton setNeedsDisplay];
                    }
                }
                
                if(recordFilename)
                    [recordFilename release];
                return;
            }
            
        }
        
        [RCTool playSound:@"record_begin.wav"];
        
        NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:fromLanguage,@"code",[NSNumber numberWithInt:buttonTag],@"tag",nil];
        [self performSelector:@selector(startToRecord:) withObject:dict afterDelay:0.5];
    }
}

- (void)startToRecord:(id)agrument
{
    NSDictionary* dict = (NSDictionary*)agrument;
    AVAudioSession * sharedSession = [AVAudioSession sharedInstance];
    [sharedSession setCategory:AVAudioSessionCategoryRecord error:NULL];
    [sharedSession setActive:YES error:NULL];
    
    _recordController.language = [dict objectForKey:@"code"];
    _recordController.type = (RECORD_BUTTON_TYPE)[[dict objectForKey:@"tag"] intValue];
    [_recordController record:[RCTool createRecordFilename]];
    
    if([_recordController isRecording])
    {
        _settingButton.enabled = NO;
        if(RBT_LEFT == _recordController.type)
        {
            _firstRecordButton.isRecording = YES;
            [_firstRecordButton setNeedsDisplay];
            
            _secondRecordButton.isRecording = NO;
            [_secondRecordButton setNeedsDisplay];
        }
        else if(RBT_RIGHT == _recordController.type)
        {
            _firstRecordButton.isRecording = NO;
            [_firstRecordButton setNeedsDisplay];
            
            _secondRecordButton.isRecording = YES;
            [_secondRecordButton setNeedsDisplay];
        }
        
    }
}

- (void)detectEndOfSpeech:(NSNotification*)notification
{
    [self updateTipLabelByStep:2];
    
    if(_recordController)
    {
        _settingButton.enabled = YES;
        if([_recordController isRecording])
        {
            NSString* fromLanguage = @"";
            NSString* toLanguage = @"";
            NSString* recordFilename = [_recordController.filename copy];
            [_recordController stop];
            
            [RCTool playSound:@"record_end.wav"];
            
            if(NO == [_recordController isRecording])
            {
                if(RBT_LEFT == _recordController.type)
                {
                    fromLanguage = _firstRecordButton.language;
                    toLanguage = _firstRecordButton.toLanguage;
                    _firstRecordButton.isRecording = NO;
                    [_firstRecordButton setNeedsDisplay];
                }
                else if(RBT_RIGHT == _recordController.type)
                {
                    fromLanguage = _secondRecordButton.language;
                    toLanguage = _secondRecordButton.toLanguage;
                    _secondRecordButton.isRecording = NO;
                    [_secondRecordButton setNeedsDisplay];
                }
            }
            
            RCTranslateProcess* temp = [RCTranslateProcess sharedInstance];
            NSMutableDictionary* token = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:_recordController.type],@"type",recordFilename,@"filename",nil];
            BOOL b = [temp translate:[RCTool getRecordFilePath:recordFilename] fromLanguage:fromLanguage toLanguage:toLanguage delegate:self token:token];
            if(b)
            {
                if(RBT_LEFT == _recordController.type)
                {
                    _firstRecordButton.isRecording = NO;
                    [_firstRecordButton setNeedsDisplay];
                }
                else if(RBT_RIGHT == _recordController.type)
                {
                    _secondRecordButton.isRecording = NO;
                    [_secondRecordButton setNeedsDisplay];
                }
            }
            
            if(recordFilename)
                [recordFilename release];
            return;  
        }
        
    }
}

#pragma mark - RCRecordButtonSelector

- (void)clickedFirstRecordButton:(id)token
{
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker sendEventWithCategory:@"Action"
                        withAction:@"button_press"
                         withLabel:@"left_record"
                         withValue:nil];
    
    NSDictionary* dict = (NSDictionary*)token;
    NSString* touchEvent = [dict objectForKey:@"touch_event"];
    NSString* fromLanguage = [dict objectForKey:@"language"];
    NSString* toLanguage = [dict objectForKey:@"to_language"];
    if([touchEvent length] && [touchEvent isEqualToString:@"touch_end"])
    {
        [self updateTipLabelByStep:1];
        NSLog(@"clickedFirstRecordButton");
        [self clickedRecordButton:fromLanguage toLanguage:toLanguage buttonTag:RBT_LEFT];
    }
}

- (void)clickedSecondRecordButton:(id)token
{
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker sendEventWithCategory:@"Action"
                        withAction:@"button_press"
                         withLabel:@"right_record"
                         withValue:nil];
    
    NSDictionary* dict = (NSDictionary*)token;
    NSString* touchEvent = [dict objectForKey:@"touch_event"];
    NSString* fromLanguage = [dict objectForKey:@"language"];
    NSString* toLanguage = [dict objectForKey:@"to_language"];
    
    if([touchEvent length] && [touchEvent isEqualToString:@"touch_end"])
    {
        [self updateTipLabelByStep:1];
        NSLog(@"clickedSecondRecordButton");
        [self clickedRecordButton:fromLanguage toLanguage:toLanguage buttonTag:RBT_RIGHT];
    }
}

#pragma mark - TTS

- (void)playTTS:(NSString*)ttsUrl
{
    if(0 == [ttsUrl length])
        return;
    
    NSString* ttsPath = nil;
    if([ttsUrl hasPrefix:@"http"])
    {
        ttsPath = [RCTool getTTSPath:ttsUrl];
        if([RCTool isExistingFile:ttsPath])
        {
            [RCTool playTTS:ttsUrl];
        }
        else
        {
            NSURL* url = [NSURL URLWithString:ttsUrl];
            ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
            [request setDelegate:self];
            NSMutableDictionary* dict = [[[NSMutableDictionary alloc] init] autorelease];
            [dict setObject:@"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_3) AppleWebKit/537.31 (KHTML, like Gecko) Chrome/26.0.1410.65 Safari/537.31" forKey:@"User-Agent"];
            [request setRequestHeaders:dict];
            [request setDownloadDestinationPath:[RCTool getTTSPath:ttsUrl]];
            NSDictionary* userInfo = [NSDictionary dictionaryWithObject:ttsUrl forKey:@"ttsUrl"];
            [request setUserInfo:userInfo];
            [request startAsynchronous];
        }
    }
    
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    NSLog(@"requestFinished");
    
    NSDictionary* userInfo = [request userInfo];
    if(userInfo && [userInfo isKindOfClass:[NSDictionary class]])
    {
        NSString* ttsUrl = [userInfo objectForKey:@"ttsUrl"];
        if([ttsUrl length])
            [RCTool playTTS:ttsUrl];
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSLog(@"requestFailed");
}

#pragma mark - RCTranslateProcessDelegate

- (void)setShowTime:(Translation*)translation lastTranslation:(Translation*)lastTranslation
{
    NSTimeInterval timeInterval = [translation.time doubleValue];
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    
    timeInterval = [lastTranslation.time doubleValue];
    NSDate* lastDate = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    
    unsigned unitFlags = NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit;
    NSDateComponents *comps = [[NSCalendar currentCalendar] components:unitFlags fromDate: date];
    NSDateComponents *last_comps = [[NSCalendar currentCalendar] components:unitFlags fromDate: lastDate];
    
    if(comps.year != last_comps.year || comps.month != last_comps.month || comps.day != last_comps.day)
    {
        translation.showTime = [NSNumber numberWithBool:YES];
    }
}

//from_voice to from_text
- (void)didFinishedTranslateVoiceToText:(Translation*)translation
{
    NSLog(@"didFinishedTranslateVoiceToText");
    [self removeLoadingView];
    
    if(translation)
    {
        translation.isLoading = [NSNumber numberWithBool:YES];
        
        BOOL isExisting = NO;
        for(Translation* temp in _itemArray)
        {
            if([temp.time doubleValue] == [translation.time doubleValue])
            {
                isExisting = YES;
                break;
            }
        }
        
        if(NO == isExisting)
        {
            translation.isExisting = NO;
            
            //设置是否显示时间
            if(0 == [_itemArray count])
            {
                translation.showTime = [NSNumber numberWithBool:YES];
            }
            else
            {
                Translation* lastTraslation = [_itemArray lastObject];
                [self setShowTime:translation lastTranslation:lastTraslation];
            }
            
            [RCTool playSound:@"sent.aiff"];
            
            [_itemArray addObject: translation];
            [_tableView reloadData];
            [self scrollToBottomAnimated:YES];
        }
        else
        {
            translation.isExisting = YES;
            [_tableView reloadData];
        }
    }
}

//from_text to to_text
- (void)didFinishedTranslateFromText:(Translation*)translation
{
    NSLog(@"didFinishedTranslateFromText");
    
    if(translation)
    {
        translation.isLoading = [NSNumber numberWithBool:NO];
        [_tableView reloadData];
        
        if(NO == translation.isExisting)
            [self scrollToBottomAnimated:YES];
    }
}

- (void)didFaiedTranslateFromText:(Translation*)translation
{
    NSLog(@"didFaiedTranslateFromText");
    
    if(translation)
    {
        translation.isLoading = [NSNumber numberWithBool:NO];
        [_tableView reloadData];
    }
}

- (void)willStartTranslateProcess: (id)token
{
    NSLog(@"willStartTranslateProcess");
    self.isTranslating = YES;
    
    NSDictionary* dict = (NSDictionary*)token;
    if(dict)
    {
        int type = [[dict objectForKey:@"type"] intValue];
        if(RBT_LEFT == type)
        {
//            if(_firstRecordButton)
//                [_firstRecordButton startIndicator];
            
            [self addLoadingView];
            
        }
        else if(RBT_RIGHT == type)
        {
//            if(_secondRecordButton)
//                [_secondRecordButton startIndicator];
            
            [self addLoadingView];
        }
    }
}

- (void)didFinishTranslateProcess: (id)result token: (id)token
{
    NSLog(@"didFinishTranslateProcess");
    self.isTranslating = NO;
    [self removeLoadingView];
    
    if(_tableView)
    {
        [_tableView reloadData];
    }
    
    Translation* translation = (Translation*)token;
    if(translation)
    {
        translation.isLoading = [NSNumber numberWithBool:NO];
        
        if(RBT_LEFT == [translation.align intValue])
        {
            if(_firstRecordButton)
                [_firstRecordButton stopIndicator];
        }
        else if(RBT_RIGHT == [translation.align intValue])
        {
            if(_secondRecordButton)
                [_secondRecordButton stopIndicator];
        }
        
        if([RCTool getAutoSpeak])
            [RCTool playTTS:translation.ttsUrl];
    }
    
    [RCTool saveCoreData];
}

- (void)didFailTranslateProcess:(int)errorType token:(id)token
{
    NSLog(@"didFailTranslateProcess");
    self.isTranslating = NO;
    [self removeLoadingView];
    
    if(_tableView)
    {
        [_tableView reloadData];
    }
    
    if([token isKindOfClass:[NSDictionary class]])
    {
        NSDictionary* dict = (NSDictionary*)token;
        if(dict)
        {
            int type = [[dict objectForKey:@"type"] intValue];
            if(RBT_LEFT == type)
            {
                if(_firstRecordButton)
                    [_firstRecordButton stopIndicator];
            }
            else if(RBT_RIGHT == type)
            {
                if(_secondRecordButton)
                    [_secondRecordButton stopIndicator];
            }
        }
    }
    else if([token isKindOfClass:[Translation class]])
    {
        
        Translation* translation = (Translation*)token;
        if(translation)
        {
            translation.isLoading = [NSNumber numberWithBool:NO];
            
            if(RBT_LEFT == [translation.align intValue])
            {
                if(_firstRecordButton)
                    [_firstRecordButton stopIndicator];
            }
            else if(RBT_RIGHT == [translation.align intValue])
            {
                if(_secondRecordButton)
                    [_secondRecordButton stopIndicator];
            }
        }
    }
    
    [RCTool saveCoreData];
    
    NSString* errorString = NSLocalizedString(@"Translate Failed. Please check the internet connection.", @"");
    switch (errorType) {
        case ET_UTTERANCE:
            errorString = NSLocalizedString(@"I'm not sure what you said.", @"");
            break;
        case ET_TTS:
            errorString = NSLocalizedString(@"Can't convert to voice.", @"");
            break;
            
        default:
            break;
    }
    
    [RCTool showAlert:NSLocalizedString(@"Hint",@"") message:errorString];
    
}

- (void)addLoadingView
{
    if(nil == _loadingImageView)
    {
        CGFloat y = [RCTool getScreenSize].height - 66 -  STATUS_BAR_HEIGHT - NAVIGATION_BAR_HEIGHT;
        if([RCTool systemVersion] >= 7.0 && ISFORIOS7)
            y = [RCTool getScreenSize].height - 66;
        
        _loadingImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 60, 11)];
        
        _loadingImageView.center = CGPointMake([RCTool getScreenSize].width/2.0, y);
        
        NSMutableArray* images = [[NSMutableArray alloc] init];
        
        for(int i = 0; i < 3; i++)
        {
            [images addObject:[UIImage imageNamed:[NSString stringWithFormat:@"translating_loading_%d",i]]];
        }
        
        _loadingImageView.animationImages = images;
        [images release];
        _loadingImageView.animationDuration = 0.5;
        
        [_loadingImageView startAnimating];
    }
    
    [self.view addSubview: _loadingImageView];
}

- (void)removeLoadingView
{
    if(_loadingImageView)
    {
        [_loadingImageView stopAnimating];
        [_loadingImageView removeFromSuperview];
        self.loadingImageView = nil;
    }
}

#pragma mark - Action

- (void)addActionMenu:(CGPoint)actionMenuPoint
{
    if(nil == _actionMenu)
    {
        _actionMenu = [[RCActionMenu alloc] initWithFrame:CGRectMake(0, 0, 30, 30) orientation:OT_TOP];
        _actionMenu.delegate = self;
    }
    
    [_actionMenu fold];
    
    CGRect rect = _actionMenu.frame;
    rect.origin.x = actionMenuPoint.x;
    rect.origin.y = actionMenuPoint.y;
    _actionMenu.frame = rect;
    
    [self.tableView addSubview:_actionMenu];
}

- (void)clickedBubble:(BUBBLE_TYPE)type translation:(Translation*)translation actionMenuPoint:(CGPoint)point orientation:(ORIENTATION_TYPE)orientation
{
    if(self.isEditing)
        return;
    
    [self addActionMenu:point];
    [_actionMenu updateContent:type translation:translation orientation:orientation];
}

- (void)clickedSpaceArea:(id)token
{
    if(self.isEditing)
        return;
    
    if(_actionMenu)
        [_actionMenu fold];
}

- (void)clickedMenuItem:(ACTION_TYPE)actionType bubbleType:(BUBBLE_TYPE)bubbleType translation:(Translation*)translation
{
    NSLog(@"clickedMenuItem");
    
    if(_actionMenu)
        [_actionMenu fold];
    
    if(AT_COPY == actionType)
    {
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        [tracker sendEventWithCategory:@"Action"
                            withAction:@"button_press"
                             withLabel:@"copy"
                             withValue:nil];
        
        NSString* text = nil;
        if(BT_FROM == bubbleType)
            text = translation.fromText;
        else if(BT_TO == bubbleType)
            text = translation.toText;
        
        [self copyText:text];
    }
    else if(AT_SPEAK == actionType)
    {
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        [tracker sendEventWithCategory:@"Action"
                            withAction:@"button_press"
                             withLabel:@"speak"
                             withValue:nil];
        
        if(BT_FROM == bubbleType)
        {
            if(0 == [translation.fromVoice length])
            {
                NSString* urlString = [RCTool getTTSUrl:translation.fromCode text:translation.fromText];
                translation.fromVoice = urlString;
            }
            
            if([translation.fromVoice hasPrefix:@"http"])
                [self playTTS:translation.fromVoice];
            else
                [RCTool playTTS:translation.fromVoice];
        }
        else if(BT_TO == bubbleType)
            [self playTTS:translation.ttsUrl];
    }
    else if(AT_EDIT == actionType)
    {
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        [tracker sendEventWithCategory:@"Action"
                            withAction:@"button_press"
                             withLabel:@"edit"
                             withValue:nil];
        
        if(BT_FROM == bubbleType)
        {
            [self editText:translation];
        }
    }
    else if(AT_MAGNIFY == actionType)
    {
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        [tracker sendEventWithCategory:@"Action"
                            withAction:@"button_press"
                             withLabel:@"magnify"
                             withValue:nil];
        
        [self magnify:translation type:bubbleType];
    }
    else if(AT_DELETE == actionType)
    {
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        [tracker sendEventWithCategory:@"Action"
                            withAction:@"button_press"
                             withLabel:@"delete"
                             withValue:nil];
        
        self.selectedTranslation = translation;
        
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Hint", @"")
                                                        message: NSLocalizedString(@"Are you sure delete this translation?","")
                                                       delegate:self
                                              cancelButtonTitle: NSLocalizedString(@"Cancel",@"")
                                              otherButtonTitles:NSLocalizedString(@"OK",@""), nil];
        alert.tag = DELETE_ITEM_TAG;
        [alert show];
        [alert release];
        

    }
    else if(AT_SHARE == actionType)
    {
        self.selectedTranslation = translation;
        
        if([RCTool systemVersion] >= 6.0)
        {
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Share to"
                                                                     delegate:self
                                                            cancelButtonTitle:@"Cancel"
                                                       destructiveButtonTitle:nil
                                                            otherButtonTitles:@"Facebook",@"Twitter",@"Sina Weibo",@"Message",@"Email",nil];
            actionSheet.delegate = self;
            actionSheet.tag = SHARE_TAG;
            actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
            [actionSheet showInView:self.view];
            [actionSheet release];
        }
        else
        {
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Share to"
                                                                     delegate:self
                                                            cancelButtonTitle:@"Cancel"
                                                       destructiveButtonTitle:nil
                                                            otherButtonTitles:@"Message",@"Email",nil];
            actionSheet.delegate = self;
            actionSheet.tag = SHARE_TAG;
            actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
            [actionSheet showInView:self.view];
            [actionSheet release];
        }
    }
}

- (void)clearUpHistory:(NSNotification*)notification
{
    [_itemArray removeAllObjects];
    [_tableView reloadData];
    
    if(_actionMenu)
        [_actionMenu fold];
}

- (void)editText:(Translation*)translation
{
    if(NO == [translation.isLoading boolValue])
    {
        self.isEditing = YES;
        self.settingButton.enabled = NO;
        
        [self initEditView];
        [self.view addSubview:_editView];
        [_editView updateContent:translation];
    }
}

- (void)translateText:(Translation*)translation
{
    self.isEditing = NO;
    [_tableView reloadData];
    self.settingButton.enabled = YES;
    
    if(translation)
    {
        [[RCTranslateProcess sharedInstance] translateText:translation delegate:self];
    }
}

- (void)copyText:(NSString*)text
{
    if(0 == [text length])
        return;
    
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    [pasteboard setString:text];
}

- (void)magnify:(Translation*)translation type:(BUBBLE_TYPE)type
{
    if(nil == translation)
        return;
    
    if(nil == _magnifyView)
    {
        _magnifyView = [[RCMagnifyView alloc] initWithFrame:CGRectZero];
    }
    
    _magnifyView.frame = CGRectMake([RCTool getScreenSize].width/2.0, [RCTool getScreenSize].height/2.0,0,0);
    [_magnifyView updateContent:translation type:type];
    [[RCTool frontWindow] addSubview:_magnifyView];
}

- (void)deleteItem:(Translation*)translation
{
    if(nil == translation)
        return;
    
    for(Translation* temp in _itemArray)
    {
        if([temp.time doubleValue] == [translation.time doubleValue])
        {
            translation.isHidden = [NSNumber numberWithBool:YES];
            [RCTool saveCoreData];
            
            [_itemArray removeObject:temp];
            [_tableView reloadData];
            
            break;
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(DELETE_ITEM_TAG == alertView.tag)
    {
        if(1 == buttonIndex)
        {
            [self deleteItem:_selectedTranslation];
        }
    }
}

- (void)shareToFacebook:(Translation*)translation
{
    if(nil == translation)
        return;
    
    NSString* text = [NSString stringWithFormat:@"source text: %@\ntranslated text: %@",translation.fromText,translation.toText];
    
    if([RCTool systemVersion] >= 6.0)
    {
//        if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook])
        {
            SLComposeViewController* slComposerSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
            
            [slComposerSheet setInitialText:text];
            [self presentViewController:slComposerSheet animated:YES completion:nil];
            
            [slComposerSheet setCompletionHandler:^(SLComposeViewControllerResult result) {

                if (result != SLComposeViewControllerResultCancelled)
                {
                    [RCTool showAlert:@"Facebook Message" message:@"Post Successfully."];
                }
            }];
        }
    }
}

- (void)shareToTwitter:(Translation*)translation
{
    if(nil == translation)
        return;
    
    NSString* text = [NSString stringWithFormat:@"source text: %@\ntranslated text: %@",translation.fromText,translation.toText];
    
    if([RCTool systemVersion] >= 6.0)
    {
        {
            SLComposeViewController* slComposerSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
            
            [slComposerSheet setInitialText:text];
            [self presentViewController:slComposerSheet animated:YES completion:nil];
            
            [slComposerSheet setCompletionHandler:^(SLComposeViewControllerResult result) {
                
                if (result != SLComposeViewControllerResultCancelled)
                {
                    [RCTool showAlert:@"Twitter Message" message:@"Post Successfully."];
                }
            }];
        }
    }
}

- (void)shareToSinaWeibo:(Translation*)translation
{
    if(nil == translation)
        return;
    
    NSString* text = [NSString stringWithFormat:@"source text: %@\ntranslated text: %@",translation.fromText,translation.toText];
    
    if([RCTool systemVersion] >= 6.0)
    {
        {
            SLComposeViewController* slComposerSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeSinaWeibo];
            
            [slComposerSheet setInitialText:text];
            [self presentViewController:slComposerSheet animated:YES completion:nil];
            
            [slComposerSheet setCompletionHandler:^(SLComposeViewControllerResult result) {
                
                if (result != SLComposeViewControllerResultCancelled)
                {
                    [RCTool showAlert:@"Sina Weibo Message" message:@"Post Successfully."];
                }
            }];
        }
    }
}

- (void)shareToMessage:(Translation*)translation
{
    if(nil == translation)
        return;
    
    NSString* text = [NSString stringWithFormat:@"source text: %@\ntranslated text: %@",translation.fromText,translation.toText];
    
    Class messageClass = (NSClassFromString(@"MFMessageComposeViewController"));
    
    if(messageClass)
    {
        if(NO == [MFMessageComposeViewController canSendText])
        {
            return;
        }
    }
    else
    {
        return;
    }
    
    MFMessageComposeViewController* compose = [[MFMessageComposeViewController alloc] init];
    compose.navigationBar.tintColor = NAVIGATION_BAR_COLOR;
    compose.messageComposeDelegate = self;
    compose.body = text;
    
    [self presentModalViewController:compose animated:YES];
    //[[[[compose viewControllers] lastObject] navigationItem] setTitle:@"SomethingElse"];//修改短信界面标题
    [compose release];
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    [controller dismissModalViewControllerAnimated:NO];//关键的一句   不能为YES
    switch ( result ) {
        case MessageComposeResultCancelled:
            break;
        case MessageComposeResultFailed:
            break;
        case MessageComposeResultSent:
        {
            [RCTool showAlert:@"Hint" message:@"Post message successfully."];
            break;
        }
        default:
            break;
    }
    
}

- (void)shareToEmail:(Translation*)translation
{
    if(nil == translation)
        return;
    
    NSString* text = [NSString stringWithFormat:@"source text: %@\ntranslated text: %@",translation.fromText,translation.toText];
    
    Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
    if (mailClass != nil)
    {
        // We must always check whether the current device is configured for sending emails
        if ([mailClass canSendMail])
        {
    MFMailComposeViewController *mailComposeViewController = [[MFMailComposeViewController alloc] init];
            mailComposeViewController.navigationBar.tintColor = NAVIGATION_BAR_COLOR;
            mailComposeViewController.mailComposeDelegate = self;
            [mailComposeViewController setSubject:@""];
            
            // Fill out the email body text
            
            NSMutableString *mailContent = [[NSMutableString alloc] init];
            [mailContent appendString:text];
            
            [mailComposeViewController setMessageBody:mailContent isHTML:NO];
            [mailContent release];
            [self presentModalViewController:mailComposeViewController animated:YES];
            [mailComposeViewController release];
        }
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller
		  didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
	[self dismissModalViewControllerAnimated:YES];
    
    if(MFMailComposeResultSent == result)
    {
        [RCTool showAlert:@"Hint" message:@"Send email successfully."];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(SHARE_TAG == actionSheet.tag)
    {
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        [tracker sendEventWithCategory:@"Action"
                            withAction:@"button_press"
                             withLabel:@"share"
                             withValue:[NSNumber numberWithInt:buttonIndex]];
        
        if([RCTool systemVersion] >= 6.0)
        {
            if(0 == buttonIndex)//facebook
            {
                [self shareToFacebook:_selectedTranslation];
            }
            else if(1 == buttonIndex)//twitter
            {
                [self shareToTwitter:_selectedTranslation];
            }
            else if(2 == buttonIndex)//sina weibo
            {
                [self shareToSinaWeibo:_selectedTranslation];
            }
            else if(3 == buttonIndex)//message
            {
                [self shareToMessage:_selectedTranslation];
            }
            else if(4 == buttonIndex)//email
            {
                [self shareToEmail:_selectedTranslation];
            }
        }
        else
        {
            if(0 == buttonIndex)//message
            {
                [self shareToMessage:_selectedTranslation];
            }
            else if(1 == buttonIndex)//email
            {
                [self shareToEmail:_selectedTranslation];
            }
        }
    }
}

#pragma mark - EditView

- (void)initEditView
{
    if(nil == _editView)
    {
        _editView = [[RCEditView alloc] initWithFrame:EDIT_VIEW_RECT];
        _editView.delegate = self;
    }
}

#pragma mark - Tip Label

- (void)initTipLabel
{
    if(NO == [RCTool getShowTipLabel])
        return;
    
    [RCTool setShowTipLabel:NO];
    
    CGFloat y = [RCTool getScreenSize].height - 82 -  STATUS_BAR_HEIGHT - NAVIGATION_BAR_HEIGHT - AD_HEIGHT;
    if([RCTool systemVersion] >= 7.0 && ISFORIOS7)
        y = [RCTool getScreenSize].height - 82 - AD_HEIGHT;
    
    if(nil == _tipLabel)
    {
        _tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 20)];
        _tipLabel.backgroundColor = [UIColor clearColor];
        _tipLabel.center = CGPointMake([RCTool getScreenSize].width/2.0, y);
        _tipLabel.font = [UIFont systemFontOfSize:14];
        _tipLabel.textAlignment = UITextAlignmentCenter;
        [self updateTipLabelByStep:0];
    }
    
    [self.view addSubview: _tipLabel];
}

- (void)updateTipLabelByStep:(int)stepIndex
{
    if(nil == _tipLabel)
        return;
    
    NSString* tip = nil;
    
    switch (stepIndex) {
        case 0:
            tip = @"Click any language button below";
            break;
        case 1:
            tip = @"Say to the microphone";
            break;
        case 2:
        {
            tip = @"";
            [_tipLabel removeFromSuperview];
            self.tipLabel = nil;
            break;
        }
        default:
            break;
    }
    
    _tipLabel.text = tip;
}

#pragma mark - Keyboard notification

- (void)keyboardWillShow: (NSNotification*)notification
{
	NSDictionary *userInfo = [notification userInfo];
	NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
	CGRect keyboardRect = [aValue CGRectValue];
	
    if(_isEditing)
    {
        _editView.alpha = 1.0;
        [UIView animateWithDuration:0.3 animations:^{
            
            CGRect rect = _editView.frame;
            CGFloat y = [RCTool getScreenSize].height - keyboardRect.size.height - rect.size.height - STATUS_BAR_HEIGHT - NAVIGATION_BAR_HEIGHT;
            if([RCTool systemVersion] >= 7.0 && ISFORIOS7)
                y = [RCTool getScreenSize].height - keyboardRect.size.height - rect.size.height;
            rect.origin.y = y;
            _editView.frame = rect;
            
        } completion:^(BOOL finished) {

        }];
    }
}

- (void)keyboardWillHide: (NSNotification*)notification
{
//    NSDictionary *userInfo = [notification userInfo];
//	NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
//	CGRect keyboardRect = [aValue CGRectValue];

    if(_editView && _editView.alpha)
    {
        [UIView animateWithDuration:0.3 animations:^{
            _editView.frame = EDIT_VIEW_RECT;
        } completion:^(BOOL finished) {
            [_editView removeFromSuperview];
            _isEditing = NO;
            _editView.alpha = 0.0;
        }];
    }
}

#pragma mark - AD

- (void)initAD
{
    // Create a view of the standard size at the top of the screen.
    // Available AdSize constants are explained in GADAdSize.h.
    if(nil == _bannerView)
    {
        _bannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner];
        
        _bannerView.adUnitID = AD_ID;
        _bannerView.rootViewController = self;
        _bannerView.delegate = self;
    }
    

    [self.view addSubview:_bannerView];
    
    [self updateAd:nil];
}

- (void)updateAd:(id)argument
{
    // Initiate a generic request to load it with an ad.
    [_bannerView loadRequest:[GADRequest request]];
}

- (void)adViewDidReceiveAd:(GADBannerView *)bannerView
{
    [UIView beginAnimations:@"BannerSlide" context:nil];
    bannerView.frame = CGRectMake(0.0,
                                  self.view.frame.size.height -
                                  bannerView.frame.size.height,
                                  bannerView.frame.size.width,
                                  bannerView.frame.size.height);
    [UIView commitAnimations];
}

- (void)adView:(GADBannerView *)bannerView
didFailToReceiveAdWithError:(GADRequestError *)error
{
    [self performSelector:@selector(updateAd:) withObject:nil afterDelay:20];
}

@end
