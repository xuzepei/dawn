//
//  RCTranslationCell.m
//  VoiceTranslator
//
//  Created by xuzepei on 6/19/13.
//  Copyright (c) 2013 xuzepei. All rights reserved.
//

#import "RCTranslationCell.h"

@implementation RCTranslationCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.accessoryType = UITableViewCellAccessoryNone;
        self.accessoryView = nil;
        
        self.imageView.image = nil;
        self.imageView.hidden = YES;
        self.textLabel.text = nil;
        self.textLabel.hidden = YES;
        self.detailTextLabel.text = nil;
        self.detailTextLabel.hidden = YES;
        
        _myContentView = [[RCTranslationCellContentView alloc] initWithFrame:CGRectMake(0.0f,
                                            0.0f,
                            self.contentView.frame.size.width,
                            self.contentView.frame.size.height)];
        
        _myContentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        [self.contentView addSubview:_myContentView];
        [self.contentView sendSubviewToBack:_myContentView];
        
    }
    return self;
}

- (void)dealloc
{
    self.myContentView = nil;
    self.delegate = nil;
    
    [super dealloc];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)updateContent:(Translation*)translation
{
    if(_myContentView)
    {
        _myContentView.delegate = self.delegate;
        [_myContentView updateContent:translation];
    }
}

@end
