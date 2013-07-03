//
//  RCAdView.m
//  RCFang
//
//  Created by xuzepei on 3/10/13.
//  Copyright (c) 2013 xuzepei. All rights reserved.
//

#import "RCAdView.h"
#import "RCTool.h"

#define BG_COLOR [UIColor colorWithRed:0.97 green:0.95 blue:0.95 alpha:1.00]

@implementation RCAdView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = BG_COLOR;
    }
    return self;
}

- (void)dealloc
{
    NSLog(@"%s",__FUNCTION__);
    
    self.item = nil;
    self.imageUrl = nil;
    self.image = nil;
    
    [super dealloc];
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    if(self.image)
    {
        [self.image drawInRect:CGRectMake(0, 0, self.image.size.width, self.image.size.height)];
    }
}

- (void)updateContent:(NSDictionary*)item
{
    NSString* imageName = [item objectForKey:@"image_name"];
    UIImage* image = [RCTool createImage:imageName];
    self.image = image;
    [image release];

    [self setNeedsDisplay];
}

@end
