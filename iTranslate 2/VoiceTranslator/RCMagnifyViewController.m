//
//  RCMagnifyViewController.m
//  Translator
//
//  Created by xuzepei on 9/14/14.
//  Copyright (c) 2014 xuzepei. All rights reserved.
//

#import "RCMagnifyViewController.h"
#import "RCTool.h"
#import "ASIHTTPRequest.h"

@interface RCMagnifyViewController ()

@end

@implementation RCMagnifyViewController

- (void)dealloc
{
    if(_tv)
        [self.tv removeObserver:self forKeyPath:@"contentSize"];
    self.tv = nil;
    
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if(self.supportVoice)
    {
        UIBarButtonItem* rightBarItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"speaker_button"] style:UIBarButtonItemStylePlain target:self action:@selector(clickedSpeakerButton:)];
        self.navigationItem.rightBarButtonItem = rightBarItem;
        [rightBarItem release];
    }
    else
    {
        self.navigationItem.rightBarButtonItem = nil;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    UIBarButtonItem* leftBarItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(clickedBackButton:)];
    self.navigationItem.leftBarButtonItem = leftBarItem;
    [leftBarItem release];
    
    if(_tv)
    {
        [self.tv addObserver:self forKeyPath:@"contentSize" options:(NSKeyValueObservingOptionNew) context:NULL];
        
        if([RCTool isIpad])
            self.tv.font = [UIFont boldSystemFontOfSize:100];
    }
        
    
    [self updateContent:self.translation bubbleType:self.bubbleType];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)clickedBackButton:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)clickedSpeakerButton:(id)sender
{
    if(BT_FROM == self.bubbleType)
    {
        if(0 == [self.translation.fromVoice length])
        {
            NSString* urlString = [RCTool getTTSUrl:self.translation.fromCode text:self.translation.fromText];
            self.translation.fromVoice = urlString;
        }
        
        if([self.translation.fromVoice hasPrefix:@"http"])
            [self playTTS:self.translation.fromVoice];
        else
            [RCTool playTTS:self.translation.fromVoice];
    }
    else if(BT_TO == self.bubbleType)
        [self playTTS:self.translation.ttsUrl];
}

- (void)updateContent:(Translation*)translation bubbleType:(BUBBLE_TYPE)bubbleType
{
    self.translation = translation;
    self.bubbleType = bubbleType;
    
    NSString* text = nil;
    if(BT_FROM == self.bubbleType)
    {
        text = translation.fromText;
        
        self.supportVoice = [RCTool isSupportedTTS:translation.fromCode];
    }
    else
    {
        text = translation.toText;
        self.supportVoice = [RCTool isSupportedTTS:translation.toCode];
    }
    
    if(_tv)
    {
        _tv.text = text;
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    UITextView *tv = object;
    CGFloat topoffset = ([tv bounds].size.height - [tv contentSize].height * [tv zoomScale])/2.0;
    topoffset = ( topoffset < 0.0 ? 0.0 : topoffset );
    tv.contentOffset = (CGPoint){.x = 0, .y = -topoffset};
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

@end
