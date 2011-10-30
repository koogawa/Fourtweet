//
//  ViewUtil.m
//  VenueMap
//
//  Created by Developer on 11/03/19.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ViewUtil.h"


@implementation ViewUtil

+ (UIView *)createTitleViewWithRect:(CGRect)frame title:(NSString *)title {
	CGFloat width = frame.size.width - 150;
	CGFloat height = frame.size.height;
	UIView *view = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, width, height)] autorelease];
	view.backgroundColor = [UIColor clearColor];
	
	UILabel *label = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, height)] autorelease];
	label.textAlignment	= UITextAlignmentLeft;
	label.font			= [UIFont boldSystemFontOfSize:20];
	label.lineBreakMode	= UILineBreakModeWordWrap;
	label.textColor		= [UIColor whiteColor];
	label.backgroundColor	= [UIColor clearColor];
	label.text				= title;
	label.adjustsFontSizeToFitWidth = YES;
	label.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
	[view addSubview:label];
	return view;
}

+ (UIImage*)resizeImage:(UIImage*)image scaledToSize:(CGSize)newSize;
{
	UIGraphicsBeginImageContext(newSize);
	[image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
	UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return newImage;
}

@end
