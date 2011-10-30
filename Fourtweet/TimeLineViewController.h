//
//  TimeLineViewController.h
//  Fourtweet
//
//  Created by koogawa on 11/04/11.
//  Copyright 2010 personal. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
	TimeLineModeTweet = 0
} TimeLineMode;

@interface TimeLineViewController : UITableViewController
{
	TimeLineMode			mode_;
	NSString				*user_;
    NSString                *venueName_;
	
	NSInteger				currentPage_;
	NSInteger				nextPage_;
	NSMutableArray			*statuses_;
	
	UIBarButtonItem			*reloadButton_;
	UIActivityIndicatorView	*indicator_;
}

@property (nonatomic, retain) NSString			*user;
@property (nonatomic, retain) NSString          *venueName_;
@property (nonatomic, retain) NSMutableArray	*statuses;

- (id)initWithMode:(TimeLineMode)mode;
- (void)loadTimeline;
- (void)loadTimelineDidEnd:(NSNotification *)notification;
- (void)loadTimelineFailed:(NSNotification *)notification;
		
@end
