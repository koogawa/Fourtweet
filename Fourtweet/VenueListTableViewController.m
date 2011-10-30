//
//  VenueListTableViewController.m
//  Fourtweet
//
//  Created by Kosuke Ogawa on 11/10/29.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "VenueListTableViewController.h"
#import "TimeLineViewController.h"
#import "CJSONDeserializer.h"
#import "URLLoader.h"


@interface VenueListTableViewController (Private)
- (void)loadVenueList;
- (void)loadVenueListDidEnd:(NSNotification *)notification;
- (void)loadVenueListFailed:(NSNotification *)notification;
@end

@implementation VenueListTableViewController

@synthesize venues = venues_;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self)
    {
        // Custom initialization
        venues_ = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)dealloc {
	[indicator_ release];
	[reloadButton_ release];
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"周辺のべニュー";

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    // 更新ボタンを追加
	reloadButton_ =
	[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
												  target:self
												  action:@selector(reload:)];
	reloadButton_.enabled = NO;
	self.navigationItem.rightBarButtonItem = reloadButton_;

    // アクティビティインジケータ準備
	CGRect indicatorRect = CGRectMake(self.view.frame.size.width / 2 - 30,
									  self.view.frame.size.height / 2 - 30 - TAB_BAR_HEIGHT,
									  60,
									  60);	
	indicator_ =[[UIActivityIndicatorView alloc] initWithFrame:indicatorRect];
    NSLog(@"inidicator = %@", indicator_);
	[indicator_ setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
	[self.view addSubview:indicator_];

    // 現在地取得
    locationManager_ = [[CLLocationManager alloc] init];
    [locationManager_ setDelegate:self];  
    [locationManager_ setDesiredAccuracy:kCLLocationAccuracyBest];  
    [locationManager_ setDistanceFilter:kCLDistanceFilterNone];  
    [locationManager_ startUpdatingLocation];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Private method

- (void)reload:(id)sender
{
	[self loadVenueList];
}

- (void)loadVenueList
{
    LOG_CURRENT_METHOD;
    
	// 緯度・経度取得
	CLLocationDegrees latitude = coordinate_.latitude;
	CLLocationDegrees longitude = coordinate_.longitude;
    
    // デバッグ用
#ifdef DEBUG
//    latitude = 35.690165;
//    longitude = 139.699643;
    // Roppongi
//        latitude = 35.666;
  //        longitude = 139.731;
#endif
    
	static NSString *urlFormat = @"https://api.foursquare.com/v2/venues/search?ll=%f,%f&limit=%d&client_id=%@&client_secret=%@&v=20110918";
	
    NSString *url = [NSString stringWithFormat:urlFormat, latitude, longitude, 50, CLIENT_ID, CLIENT_SECRET];
    
    URLLoader *loder = [[[URLLoader alloc] init] autorelease];
    
    [[NSNotificationCenter defaultCenter] addObserver:self                         
                                             selector:@selector(loadVenueListDidEnd:)
                                                 name:@"connectionDidFinishNotification"
                                               object:loder];
	
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadVenueListFailed:)
                                                 name:@"connectionDidFailWithError"
                                               object:loder];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
	LOG(@"url = %@", url);
	[indicator_ startAnimating];
	reloadButton_.enabled = NO;
    
    [loder loadFromUrlString:url method:@"GET"];
}

// ベニューが取れた
- (void)loadVenueListDidEnd:(NSNotification *)notification
{
    LOG_CURRENT_METHOD;

    [[NSNotificationCenter defaultCenter] removeObserver:self];
    	
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [indicator_ stopAnimating];
	reloadButton_.enabled = YES;
	
    URLLoader *loder = (URLLoader *)[notification object];
    NSData *jsonData = loder.data;
	
    // TouchJSONを使ったJSONデータのパース処理
    NSDictionary *jsonDic = [[CJSONDeserializer deserializer] deserializeAsDictionary:jsonData error:nil];
	NSInteger errorCode = [[[jsonDic objectForKey:@"meta"] objectForKey:@"code"] intValue];
	LOG(@"errorCode = %d", errorCode);
    
    if (errorCode != 200) {
        [self loadVenueListFailed:nil];
        return;
    }
    
    //    LOG(@"jsonDic = %@", jsonDic);
	NSArray *venues = [[jsonDic objectForKey:@"response"] objectForKey:@"venues"];
    self.venues = [NSMutableArray arrayWithArray:venues];
    
    [self.tableView reloadData];
}

- (void)loadVenueListFailed:(NSNotification *)notification
{
	LOG_CURRENT_METHOD;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	[indicator_ stopAnimating];
	reloadButton_.enabled = YES;
    	
    UIAlertView *alert = [[UIAlertView alloc]  
                          initWithTitle:@"Error"  
						  message:@"Couldn't get venue list"  
						  delegate:self
						  cancelButtonTitle:@"Close"  
						  otherButtonTitles:nil];
    [alert show];
    [alert release];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.venues count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    NSDictionary *venueDic = [venues_ objectAtIndex:indexPath.row];
//    LOG(@"venueDic = %@", venueDic);
    cell.textLabel.text = [venueDic objectForKey:@"name"];

    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = [indexPath row];
    NSString *vName = [[self.venues objectAtIndex:row] objectForKey:@"name"];

    TimeLineViewController *detailViewController = [[TimeLineViewController alloc] initWithMode:TimeLineModeTweet];
    detailViewController.venueName_ = vName;
    [self.navigationController pushViewController:detailViewController animated:YES];
    [detailViewController release];
}

#pragma mark - CLLocationManager delegate

// 位置が更新されたら呼ばれる
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
		   fromLocation:(CLLocation *)oldLocation
{
//    LOG_CURRENT_METHOD;
    
	coordinate_ = newLocation.coordinate;
    
    // 初回起動時はベニュー情報取得
	if (!isInitialized_) {
		
		[self loadVenueList];
		
		// 初期化済み
		isInitialized_ = YES;
    }
}

@end
