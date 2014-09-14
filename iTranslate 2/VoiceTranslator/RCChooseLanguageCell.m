//
//  RCChooseLanguageCell.m
//  Translator
//
//  Created by xuzepei on 9/13/14.
//  Copyright (c) 2014 xuzepei. All rights reserved.
//

#import "RCChooseLanguageCell.h"
#import "RCTool.h"

@implementation RCChooseLanguageCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)dealloc{
    
    self.myImageView = nil;
    
    [super dealloc];
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)updateContent:(NSDictionary*)item
{
    NSString* code = [item objectForKey:@"code"];
    NSString* imageName = [NSString stringWithFormat:@"flag_%@",code];
    UIImage* image = [UIImage imageNamed:imageName];
    self.imageView.image = image;
    
    NSString* name = [item objectForKey:@"name"];
    self.textLabel.text = name;
    
    if([[item objectForKey:@"tts"] boolValue])
    {
        CGSize size = [name sizeWithFont:[UIFont systemFontOfSize:17] constrainedToSize:CGSizeMake(CGFLOAT_MAX, 20) lineBreakMode:NSLineBreakByWordWrapping];
        
        if(nil == _myImageView)
        {
            _myImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
            _myImageView.image = [UIImage imageNamed:@"speaker"];
        }
        
        _myImageView.frame = CGRectMake(size.width + 80, (self.bounds.size .height- 12)/2.0, 12, 12);
        [self.contentView addSubview:_myImageView];
    }
    else{
        if(_myImageView && _myImageView.superview)
            [_myImageView removeFromSuperview];
    }
}

@end
