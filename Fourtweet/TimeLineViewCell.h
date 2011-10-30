//
//  TimeLineViewCell.h
//  Fourtweet
//
//  Created by Kosuke Ogawa on 11/04/12.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIAsyncImageView.h"


@interface TimeLineViewCell : UITableViewCell {
	UIAsyncImageView	*profileImageView_;
	UILabel				*dateTextLabel_;
}

@property (nonatomic, retain) UIAsyncImageView	*profileImageView;
@property (nonatomic, retain) UILabel			*dateTextLabel;

@end
