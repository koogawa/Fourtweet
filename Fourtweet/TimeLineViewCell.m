//
//  TimeLineViewCell.m
//  Fourtweet
//
//  Created by Kosuke Ogawa on 11/04/12.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TimeLineViewCell.h"


@implementation TimeLineViewCell

@synthesize profileImageView	= profileImageView_;
@synthesize dateTextLabel		= dateTextLabel_;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
	{
		// 背景
		UIImageView *imageView = [[[UIImageView alloc] init] autorelease];
		imageView.image = [[UIImage imageNamed:@"cell"] stretchableImageWithLeftCapWidth:15 topCapHeight:15];
		self.backgroundView = imageView;
		
		// プロフィール写真
		CGRect profileRect = CGRectMake(5, 5, 48, 48);
		self.profileImageView = [[UIAsyncImageView alloc] initWithFrame:profileRect];
		[self.contentView addSubview:self.profileImageView];
		
		// アカウント
		self.textLabel.frame = CGRectMake(68, 10, self.frame.size.width - 68 - 10, self.textLabel.frame.size.height);

		// 本文
		self.detailTextLabel.frame = CGRectMake(0, 0, self.textLabel.frame.size.width, self.textLabel.frame.size.height);
		
		// 日付
		CGRect dateTextRect = CGRectZero;
		self.dateTextLabel = [[UILabel alloc] initWithFrame:dateTextRect];
		self.dateTextLabel.font = [UIFont systemFontOfSize:14];
		self.dateTextLabel.textColor = [UIColor darkGrayColor];
		self.dateTextLabel.backgroundColor = [UIColor clearColor];
		self.dateTextLabel.textAlignment = UITextAlignmentRight;
		[self.contentView addSubview:self.dateTextLabel];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
	
    // contentViewの大きさを取得する
//    CGRect bounds;
//    bounds = self.contentView.frame;
	
//	self.imageView.frame = CGRectMake(10, 10, self.imageView.frame.size.width, self.imageView.frame.size.height);
	
	// アカウント
	self.textLabel.frame = CGRectMake(63, 5, self.frame.size.width - 48 - 20, self.textLabel.frame.size.height);

	// 本文
	CGSize rightSize = CGSizeMake(self.frame.size.width - 48 - 20, CGFLOAT_MAX);
	CGSize size = [self.detailTextLabel.text sizeWithFont:self.detailTextLabel.font
										constrainedToSize:rightSize
											lineBreakMode:UILineBreakModeCharacterWrap];
	self.detailTextLabel.frame = CGRectMake(self.textLabel.frame.origin.x, self.textLabel.frame.size.height + 6, size.width, size.height);
	
	CGRect rect = self.detailTextLabel.frame;
	CGRect dateTextRect = self.dateTextLabel.frame;
	dateTextRect.origin.x = 0;
	dateTextRect.origin.y = CGRectGetMaxY(rect) + 5;
	dateTextRect.size.width = self.frame.size.width - 5;
	dateTextRect.size.height = 14;
    self.dateTextLabel.frame = dateTextRect;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state.
}

- (void)dealloc {
    [super dealloc];
}


@end
