//
//  VenueListTableViewController.h
//  Fourtweet
//
//  Created by Kosuke Ogawa on 11/10/29.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>


@interface VenueListTableViewController : UITableViewController <CLLocationManagerDelegate>
{
    CLLocationManager		*locationManager_;
	CLLocationCoordinate2D	coordinate_;
    NSMutableArray          *venues_;
    
	UIBarButtonItem			*reloadButton_;
	UIActivityIndicatorView	*indicator_;
    
	BOOL					isInitialized_;
}

@property (nonatomic, retain) NSMutableArray *venues;

@end
