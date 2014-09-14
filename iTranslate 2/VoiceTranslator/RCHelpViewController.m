//
//  RCHelpViewController.m
//  VoiceTranslator
//
//  Created by xuzepei on 6/28/13.
//  Copyright (c) 2013 xuzepei. All rights reserved.
//

#import "RCHelpViewController.h"

@interface RCHelpViewController ()

@end

@implementation RCHelpViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        self.title = NSLocalizedString(@"Help", @"");
    }
    return self;
}

- (void)dealloc
{
    NSLog(@"%s",__FUNCTION__);
    
    self.scrollView = nil;
    
    NSLog(@"retainCount:%d",[_scrollView retainCount]);
    
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self initScrollView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    self.scrollView = nil;
}

- (void)initScrollView
{
    if(nil == _scrollView)
    {
        CGFloat height = [RCTool getScreenSize].height - STATUS_BAR_HEIGHT - NAVIGATION_BAR_HEIGHT;
        if([RCTool systemVersion] >= 7.0 && ISFORIOS7)
            height = [RCTool getScreenSize].height;
        
        self.scrollView = [[[RCAdScrollView alloc] initWithFrame:CGRectMake(0, 0, [RCTool getScreenSize].width,height)] autorelease];
    }
    
    [self.view addSubview:_scrollView];
    
    NSMutableArray* array = [[NSMutableArray alloc] init];
    NSMutableDictionary* dict = [[[NSMutableDictionary alloc] init] autorelease];
    [dict setObject:@"help" forKey:@"image_name"];
    [array addObject: dict];

    [_scrollView updateContent:array];
    [array release];
}

@end
