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
#import "RCMagnifyViewController.h"

#define RECORD_BUTTON_WIDTH 60.0
#define RECORD_BUTTON_HEIGHT 60.0

#define LEVEL_METER_HEIGHT 12.0

#define DELETE_ITEM_TAG 200
#define SHARE_TAG 201

#define EDIT_VIEW_RECT CGRectMake(0,-100,[RCTool getScreenSize].width,126)

//#define BG_COLOR [UIColor colorWithRed:0.97 green:0.95 blue:0.95 alpha:1.00]
#define BG_COLOR [UIColor whiteColor]

#define AD_HEIGHT kGADAdSizeBanner.size.height

#define INPUT_BAR_HEIGHT 45.0f

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
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeAD:) name:REMOVE_AD_NOTIFICATION object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addAD:) name:ADD_AD_NOTIFICATION object:nil];
        
        
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
    self.inputBar = nil;
    
    self.magnifyView = nil;
    self.loadingImageView = nil;
    
    self.tipLabel = nil;
    
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if(_titleBar)
        [_titleBar updateContent];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = BG_COLOR;
    
    [self.navigationController.navigationBar addSubview:_settingButton];

    [self initTableView];
    
    [self initTitleBar];
    
    [self initInputBar];
}

- (void)didReceiveMemoryWarning
{
    NSLog(@"%s",__FUNCTION__);
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
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
        //screen with: 320,375,414
        
        CGFloat width = 240.0f;
        if([RCTool getScreenSize].width >= 414)
            width = 360.0f;
        else if([RCTool getScreenSize].width > 320)
            width = 295.0f;
        
        _titleBar = [[RCTitleBar alloc] initWithFrame:CGRectMake(0, 0, width, 44)];
    }
    
    self.navigationItem.titleView = _titleBar;
}

- (void)clickLeftBarButton:(id)sender
{
    NSLog(@"clickLeftBarButton");
    
    RCSettingViewController* temp = [[[RCSettingViewController alloc] initWithNibName:nil bundle:nil] autorelease];
    temp.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    
    UINavigationController* temp1 = [[UINavigationController alloc] initWithRootViewController:temp];
    [self presentViewController:temp1 animated:YES completion:^{
        
        self.goToSettings = YES;
    }];
    [temp1 release];
}

#pragma mark - UITableView

- (void)initTableView
{
    if(nil == _tableView)
    {
        CGFloat height = [RCTool getScreenSize].height - STATUS_BAR_HEIGHT - NAVIGATION_BAR_HEIGHT - INPUT_BAR_HEIGHT;
        if([RCTool systemVersion] >= 7.0)
            height = [RCTool getScreenSize].height - INPUT_BAR_HEIGHT;
        
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
        
//        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapOnTableView:)];
//        [self.tableView addGestureRecognizer:tap];
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
    {
        if([RCTool isIpad])
            return 110.0f;
        else
            return 70.0;
    }
    
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

- (void)didTapOnTableView:(UIGestureRecognizer*)recognizer
{
    CGPoint tapLocation = [recognizer locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:tapLocation];
    
    if (indexPath) { //we are in a tableview cell, let the gesture be handled by the view
        recognizer.cancelsTouchesInView = NO;
    } else {
        //[self editText:nil];
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
    
    NSString* errorString = NSLocalizedString(@"Sorry,translate failed.", @"");
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
        CGFloat y = [RCTool getScreenSize].height - 16 -  STATUS_BAR_HEIGHT - NAVIGATION_BAR_HEIGHT - self.adHeight;
        if([RCTool systemVersion] >= 7.0 && ISFORIOS7)
            y = [RCTool getScreenSize].height - 16 - self.adHeight;
        
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
    
    self.selectedBubbleType = type;
    self.selectedTranslation = translation;
    [[UIMenuController sharedMenuController] setMenuVisible:YES animated:YES];
    //    [self addActionMenu:point];
    //    [_actionMenu updateContent:type translation:translation orientation:orientation];
}

- (void)clickedSpaceArea:(id)token
{
    if(_inputBar)
        [_inputBar.tf resignFirstResponder];
}

- (void)clickedMenuItem:(ACTION_TYPE)actionType bubbleType:(BUBBLE_TYPE)bubbleType translation:(Translation*)translation
{
    NSLog(@"clickedMenuItem");
    
    if(_actionMenu)
        [_actionMenu fold];
    
    if(AT_COPY == actionType)
    {
        
        NSString* text = nil;
        if(BT_FROM == bubbleType)
            text = translation.fromText;
        else if(BT_TO == bubbleType)
            text = translation.toText;
        
        [self copyText:text];
    }
    else if(AT_SPEAK == actionType)
    {
        
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
        
        if(BT_FROM == bubbleType)
        {
            [self editText:translation];
        }
    }
    else if(AT_MAGNIFY == actionType)
    {
        
        [self magnify:translation type:bubbleType];
    }
    else if(AT_DELETE == actionType)
    {
        
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
    [[UIMenuController sharedMenuController] setMenuItems:nil];
    
    if(translation && NO == [translation.isLoading boolValue])
    {
        self.isEditing = YES;
        self.settingButton.enabled = NO;
        [_inputBar updateContent:translation];
    }
    else
    {
        Translation* translation = [RCTool insertEntityObjectForName:@"Translation" managedObjectContext:[RCTool getManagedObjectContext]];
        if(translation)
        {
            NSDate* date = [NSDate date];
            NSTimeInterval interval = [date timeIntervalSince1970];
            translation.time = [NSNumber numberWithDouble:interval];
            translation.fromCode = [RCTool getLeftLanguage];
            translation.toCode = [RCTool getRightLanguage];
        }
        
        self.isEditing = YES;
        [_inputBar updateContent:translation];
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
    //    if(nil == _magnifyView)
    //    {
    //        _magnifyView = [[RCMagnifyView alloc] initWithFrame:CGRectZero];
    //    }
    //
    //    _magnifyView.frame = CGRectMake([RCTool getScreenSize].width/2.0, [RCTool getScreenSize].height/2.0,0,0);
    //    [_magnifyView updateContent:translation type:type];
    //    [[RCTool frontWindow] addSubview:_magnifyView];
    
    
    if(translation)
    {
        RCMagnifyViewController* vc = [[[RCMagnifyViewController alloc] initWithNibName:nil bundle:nil] autorelease];
        [vc updateContent:translation bubbleType:type];
        UINavigationController* nv = [[[UINavigationController alloc] initWithRootViewController:vc] autorelease];
        nv.navigationBar.barTintColor = [UIColor blackColor];
        [self presentViewController:nv animated:YES completion:nil];
    }
    
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
    
    [self presentViewController:compose animated:YES completion:^{
        
    }];
    //[[[[compose viewControllers] lastObject] navigationItem] setTitle:@"SomethingElse"];//修改短信界面标题
    [compose release];
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    //关键的一句   不能为YES
    [controller dismissViewControllerAnimated:NO completion:^{
        
    }];
    
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
            [self presentViewController:mailComposeViewController animated:YES completion:nil];
            [mailComposeViewController release];
        }
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if(MFMailComposeResultSent == result)
    {
        [RCTool showAlert:@"Hint" message:@"Send email successfully."];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(SHARE_TAG == actionSheet.tag)
    {
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

#pragma mark - Keyboard notification

- (void)keyboardWillShow: (NSNotification*)notification
{
    NSDictionary *userInfo = [notification userInfo];
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    
    [UIView animateWithDuration:0.3 animations:^{
        
        CGRect rect = _inputBar.frame;
        CGFloat y = [RCTool getScreenSize].height - keyboardRect.size.height - rect.size.height - STATUS_BAR_HEIGHT - NAVIGATION_BAR_HEIGHT;
        if([RCTool systemVersion] >= 7.0 && ISFORIOS7)
            y = [RCTool getScreenSize].height - keyboardRect.size.height - rect.size.height;
        rect.origin.y = y;
        _inputBar.frame = rect;
        
        UIView* adView = [RCTool getAdView];
        if(adView.alpha > 0 && adView.superview)
        {
            CGRect adRect = adView.frame;
            adRect.origin.y = rect.origin.y - adRect.size.height;
            adView.frame = adRect;
        }
        
        
    } completion:^(BOOL finished) {
        
    }];
}

- (void)keyboardWillHide: (NSNotification*)notification
{
    //    NSDictionary *userInfo = [notification userInfo];
    //	NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    //	CGRect keyboardRect = [aValue CGRectValue];
    
    if(_inputBar)
    {
        self.isEditing = NO;
        [UIView animateWithDuration:0.3 animations:^{
            
            CGRect rect = _inputBar.frame;
            CGFloat y = [RCTool getScreenSize].height - rect.size.height - STATUS_BAR_HEIGHT - NAVIGATION_BAR_HEIGHT;
            if([RCTool systemVersion] >= 7.0 && ISFORIOS7)
                y = [RCTool getScreenSize].height - rect.size.height;
            rect.origin.y = y;
            _inputBar.frame = rect;
            
            UIView* adView = [RCTool getAdView];
            if(adView.alpha > 0 && adView.superview)
            {
                CGRect adRect = adView.frame;
                adRect.origin.y = rect.origin.y - adRect.size.height;
                adView.frame = adRect;
            }
            
        } completion:^(BOOL finished) {

            _isEditing = NO;
        }];
    }
}

- (void)addAD:(NSNotification*)notifcation
{
    UIView* adView = [RCTool getAdView];
    CGRect adRect = adView.frame;
    adRect.origin.y = _inputBar.frame.origin.y - adRect.size.height;
    adView.frame = adRect;
}


#pragma mark - MenuItem

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (BOOL)canPerformAction:(SEL)action
              withSender:(id)sender
{
    if(action == @selector(menuAction0:) || action == @selector(menuAction1:)||action == @selector(menuAction2:)||action == @selector(menuAction3:)||action == @selector(menuAction4:)||action == @selector(menuAction5:)||action == @selector(menuAction6:))
        return YES;
    
    return [super canPerformAction:action withSender:sender];
}

- (IBAction)menuAction0:(id)sender
{
    [self clickedMenuItem:AT_COPY bubbleType:self.selectedBubbleType translation:self.selectedTranslation];
}

- (IBAction)menuAction1:(id)sender
{
    [self clickedMenuItem:AT_EDIT bubbleType:self.selectedBubbleType translation:self.selectedTranslation];
}

- (IBAction)menuAction2:(id)sender
{
    [self clickedMenuItem:AT_SHARE bubbleType:self.selectedBubbleType translation:self.selectedTranslation];
}

- (IBAction)menuAction3:(id)sender
{
    [self clickedMenuItem:AT_DELETE bubbleType:self.selectedBubbleType translation:self.selectedTranslation];
}

- (IBAction)menuAction4:(id)sender
{
    [self clickedMenuItem:AT_SPEAK bubbleType:self.selectedBubbleType translation:self.selectedTranslation];
}

- (IBAction)menuAction5:(id)sender
{
    [self clickedMenuItem:AT_MAGNIFY bubbleType:self.selectedBubbleType translation:self.selectedTranslation];
}

- (IBAction)menuAction6:(id)sender
{
    NSLog(@"test");
}

#pragma mark - Input Bar

- (void)initInputBar
{
    if(nil == _inputBar)
    {
        CGFloat y = [RCTool getScreenSize].height - STATUS_BAR_HEIGHT - NAVIGATION_BAR_HEIGHT - INPUT_BAR_HEIGHT;
        if([RCTool systemVersion] >= 7.0)
            y = [RCTool getScreenSize].height - INPUT_BAR_HEIGHT;
        
        _inputBar = [[RCInputBar alloc] initWithFrame:CGRectMake(0, y, [RCTool getScreenSize].width, INPUT_BAR_HEIGHT)];
        _inputBar.delegate = self;
    }
    
    [self.view addSubview:_inputBar];
}

@end
