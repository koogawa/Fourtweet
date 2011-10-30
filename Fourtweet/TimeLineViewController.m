//
//  TimeLineViewController.m
//  Fourtweet
//
//  Created by koogawa on 11/04/11.
//  Copyright 2010 personal. All rights reserved.
//

#import "TimeLineViewController.h"
#import "TimeLineViewCell.h"
#import "URLLoader.h"
#import "StatusXMLParser.h"
#import "UIAsyncImageView.h"
#import "ViewUtil.h"


@implementation TimeLineViewController

@synthesize user		= user_;
@synthesize venueName_;
@synthesize statuses	= statuses_;

#pragma mark -
#pragma mark initialize

- (id)initWithMode:(TimeLineMode)mode
{
	if (self = [super init])
	{
		mode_ = mode;
		
		NSString *iconName = @"";
		NSString *titleName;
		switch (mode_)
		{
			case TimeLineModeTweet:
			{
				titleName = @"つぶやき";
				iconName = @"twitter";
				break;
			}
			default:
			{
				NSAssert(NO, @"Unknown TimeLineType");
			}
		}
		
		UIImage *icon = [UIImage imageNamed:iconName];
		self.tabBarItem = [[[UITabBarItem alloc] initWithTitle:titleName image:icon tag:0] autorelease];
		self.user = nil;
		currentPage_ = 0;
		nextPage_ = 1;
	}
	return self;
}


#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.navigationItem.title = venueName_;
	
	// 更新ボタンを追加
	reloadButton_ =
	[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
												  target:self
												  action:@selector(reload:)];
	reloadButton_.enabled = NO;
	self.navigationItem.rightBarButtonItem = reloadButton_;
	
	// アクティビティインジケータ準備
	CGRect indicatorRect = CGRectMake(self.view.frame.size.width / 2 - 20,
									  self.view.frame.size.height / 2 - 20 - TAB_BAR_HEIGHT,
									  40,
									  40);	
	indicator_ =[[UIActivityIndicatorView alloc] initWithFrame:indicatorRect];
	[indicator_ setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
	[self.view addSubview:indicator_];
	
	[self loadTimeline];
}

- (void)viewWillAppear:(BOOL)animated {
	LOG_CURRENT_METHOD;
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
	LOG_CURRENT_METHOD;
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
	LOG_CURRENT_METHOD;
	[super viewWillDisappear:animated];
}

/*
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}
*/

 // Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations.
	return YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	// アクティビティインジケータ位置調整
	CGRect indicatorRect = CGRectMake(self.view.frame.size.width / 2 - 20,
									  self.view.frame.size.height / 2 - 20,
									  40,
									  40);	
	indicator_.frame = indicatorRect;
	
	// もっと読むのサイズ調整
	UILabel *moreLabel = (UILabel *)[self.tableView.tableFooterView viewWithTag:4];
	moreLabel.frame = CGRectMake(0, 0, self.view.frame.size.width, 44);
	UIButton *button = (UIButton *)[self.tableView.tableFooterView viewWithTag:3];
	UIActivityIndicatorView *indicator = (UIActivityIndicatorView *)[self.tableView.tableFooterView viewWithTag:2];
	[indicator setCenter:CGPointMake(button.frame.size.width / 2 - 65, button.frame.size.height / 2)];
}


#pragma mark -
#pragma mark Private Methods

- (void)reload:(id)sender
{
	currentPage_ = 0;
	nextPage_ = 1;
	
	[self loadTimeline];
}

- (void)moreButtonAction
{
	// ボタンを押せなくする
	UIButton *button = (UIButton *)[self.tableView.tableFooterView viewWithTag:3];
	button.enabled = NO;
	reloadButton_.enabled = NO;
	
	UIActivityIndicatorView *indicator = (UIActivityIndicatorView *)[self.tableView.tableFooterView viewWithTag:2];

	// ロード中なら何もしない（連打防止）
	if ([indicator isAnimating]) {
		return;
	}
	
	[indicator startAnimating];
	[self loadTimeline];
	[indicator_ stopAnimating];
}

- (void)loadTimeline
{
	LOG_CURRENT_METHOD;
	
	NSString *urlFormat;
	switch (mode_) {
		case TimeLineModeTweet:
		{
			urlFormat = @"http://search.twitter.com/search.atom?q=(%%40%%20%@&page=%d";
			break;
		}
		default:
		{
			LOG(@"Unknown TimeLineType");
		}
	}

    NSString *q = @"";
	if (venueName_) {
		q = venueName_;
		q = (NSString *)CFURLCreateStringByAddingPercentEscapes(
                                                                kCFAllocatorDefault,
                                                                (CFStringRef)q,
                                                                NULL,
                                                                NULL,
                                                                kCFStringEncodingUTF8
                                                                );
	}

	NSString *urlString = [NSString stringWithFormat:urlFormat, q, nextPage_];
    [q release];
	LOG(@"urlString = %@", urlString);
	URLLoader *loader = [[[URLLoader alloc] init] autorelease];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(loadTimelineDidEnd:)
                                                 name:@"connectionDidFinishNotification"
                                               object:loader];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(loadTimelineFailed:)
                                                 name:@"connectionDidFailWithError"
                                               object:loader];
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	[indicator_ startAnimating];
	reloadButton_.enabled = NO;
	
	[loader loadFromUrlString:urlString method:@"GET"];
}

- (void)loadTimelineDidEnd:(NSNotification *)notification
{
	LOG_CURRENT_METHOD;

    [[NSNotificationCenter defaultCenter] removeObserver:self];

	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	[indicator_ stopAnimating];
	reloadButton_.enabled = YES;
	UIActivityIndicatorView *indicator = (UIActivityIndicatorView *)[self.tableView.tableFooterView viewWithTag:2];
	[indicator stopAnimating];

	URLLoader *loader = (URLLoader *)[notification object];
	NSData *xml = loader.data;
	
	//NSLog( @"%@", [[NSString alloc] initWithData:xml encoding:NSUTF8StringEncoding] );
	StatusXMLParser *parser = [[[StatusXMLParser alloc] init] autorelease];
	if (currentPage_ == 0) {
		[statuses_ release];
		statuses_ = nil;
		self.statuses = [NSMutableArray arrayWithCapacity:1];
	}
	[self.statuses addObjectsFromArray:[parser parseStatuses:xml]];
	
	// ゼロ件の場合
	if ([self.statuses count] == 0) {
		UILabel *zeroLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
		zeroLabel.font = [UIFont boldSystemFontOfSize:14];
		zeroLabel.textAlignment = UITextAlignmentCenter;
		zeroLabel.text = @"ツイートはありません";
		self.tableView.tableFooterView = zeroLabel;
		[zeroLabel release];
		return;
	}
	
	currentPage_ = nextPage_++;
	
	// もっとよむ
	if (self.tableView.tableFooterView == nil) {
		UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
		button.frame = CGRectMake(0, 0, self.view.frame.size.width, 44);
		button.tag = 3;
		[button addTarget:self action:@selector(moreButtonAction) forControlEvents:UIControlEventTouchDown];
		UILabel *moreLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
		moreLabel.font = [UIFont boldSystemFontOfSize:14];
		moreLabel.textAlignment = UITextAlignmentCenter;
		moreLabel.text = @"もっと読む…";
		moreLabel.tag = 4;
		UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
		[indicator setCenter:CGPointMake(button.frame.size.width / 2 - 65, button.frame.size.height / 2)];
		indicator.hidesWhenStopped = TRUE;
		indicator.contentMode = UIViewContentModeCenter;
		indicator.tag = 2;
		[moreLabel addSubview:indicator];
		[indicator release];
		[button addSubview:moreLabel];
		[moreLabel release];
		self.tableView.tableFooterView = button;
	}

	// ボタンを押せるように
	UIButton *button = (UIButton *)[self.tableView.tableFooterView viewWithTag:3];
	button.enabled = YES;
	
	[self.tableView reloadData];
	
	// 一番上までスクロール
	if (currentPage_ == 1 && [self.statuses count] > 0) {
		NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
		[self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
	}
}

- (void)loadTimelineFailed:(NSNotification *)notification
{
	LOG_CURRENT_METHOD;
	
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	[indicator_ stopAnimating];
	reloadButton_.enabled = YES;
	UIActivityIndicatorView *indicator = (UIActivityIndicatorView *)[self.tableView.tableFooterView viewWithTag:2];
	[indicator stopAnimating];

	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"エラー"
													message:@"タイムラインの取得に失敗しました"
												   delegate:self
										  cancelButtonTitle:@"閉じる"
										  otherButtonTitles:nil];
	[alert show];
	[alert release];
}


#pragma mark -
#pragma mark Table view data source

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	LOG(@"numberOfRowsInSection:%d", [self.statuses count]);
    return [self.statuses count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	//NSLog( @"cellForRowAtIndexPath" );
    
    static NSString *CellIdentifier = @"Cell";
    
    TimeLineViewCell *cell = (TimeLineViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[TimeLineViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
//		cell.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		
		// ユーザ名
		cell.textLabel.font = [UIFont boldSystemFontOfSize:16];
		cell.textLabel.textColor = [UIColor blackColor];
		cell.textLabel.backgroundColor = [UIColor whiteColor];

		// 本文
		cell.detailTextLabel.numberOfLines = 0;
		cell.detailTextLabel.backgroundColor = [UIColor whiteColor];
		cell.detailTextLabel.lineBreakMode = UILineBreakModeCharacterWrap;
	}
    
	// Configure the cell.
	int row = [indexPath row];
	
	NSString *name = [[self.statuses objectAtIndex:row] objectForKey:@"name"];
	NSString *text = [[self.statuses objectAtIndex:row] objectForKey:@"title"];
//	NSString *content = [[self.statuses objectAtIndex:row] objectForKey:@"content"];
	NSString *updated = [[self.statuses objectAtIndex:row] objectForKey:@"updated"];
	
	// アイコンURL
	NSString *account = @"";
	NSString *pattern = @"^([0-9a-z_]+) ";
	NSError *error = nil;
	NSRegularExpression *regexp = [NSRegularExpression regularExpressionWithPattern:pattern
																			options:0
																			  error:&error];
	if (error != nil) {
		LOG(@"error = %@", error);
	}	
	NSTextCheckingResult *match = [regexp firstMatchInString:name
													 options:0
													   range:NSMakeRange(0, name.length)];
	if (match.numberOfRanges > 0) {
		account = [name substringWithRange:[match rangeAtIndex:1]];
	}
	NSString *iconUrl = [NSString stringWithFormat:@"http://api.dan.co.jp/twicon/%@/normal", account];
	[(UIAsyncImageView *)[cell profileImageView] loadImage:iconUrl];

	// ユーザー名
	cell.textLabel.text = name;
	
	UIColor *textColor = [UIColor blackColor];
	UIFont *font = [UIFont systemFontOfSize:14];
	
	// 本文
	cell.detailTextLabel.text = text;
	cell.detailTextLabel.textColor = textColor;
	cell.detailTextLabel.font = font;
	
	// 日付を取得
	NSDateFormatter *inputDateFormatter = [[NSDateFormatter alloc] init];
	[inputDateFormatter setLocale:[[[NSLocale alloc] initWithLocaleIdentifier:@"US"] autorelease]];
	[inputDateFormatter setDateFormat:@"YYYY'-'MM'-'dd'T'HH':'mm':'ss'Z'"];
	NSDate *date = [inputDateFormatter dateFromString:updated];
	[inputDateFormatter release];
	
	// 日本時間に変換
	NSDate *jpDate = [NSDate dateWithTimeInterval:9 * 60 * 60
									  sinceDate:date];
	NSDateFormatter *outputDateFormatter = [[NSDateFormatter alloc] init];
//	[outputDateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"JST"]];
	[outputDateFormatter setDateFormat:@"M月d日 H:mm"];
	updated = [outputDateFormatter stringFromDate:jpDate];
	[outputDateFormatter release];
	cell.dateTextLabel.text = [NSString stringWithFormat:@"%@", updated];
	
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	TimeLineViewCell *cell = (TimeLineViewCell *)[self tableView:self.tableView cellForRowAtIndexPath:indexPath];

	CGSize rightSize = CGSizeMake(self.view.frame.size.width - 48 - 20, CGFLOAT_MAX);
	CGSize size = [cell.detailTextLabel.text sizeWithFont:cell.detailTextLabel.font
										constrainedToSize:rightSize
											lineBreakMode:UILineBreakModeCharacterWrap];
    return size.height + 60;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source.
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//	int row = [indexPath row];
	/*
	NSString *name = [[self.statuses objectAtIndex:row] objectForKey:@"author"];
	NSString *link = [[self.statuses objectAtIndex:row] objectForKey:@"link"];
	NSString *title = [[self.statuses objectAtIndex:row] objectForKey:@"title"];
	NSString *description = [[self.statuses objectAtIndex:row] objectForKey:@"description"];
	
	DescriptionViewController *descriptionViewController = [[DescriptionViewController alloc] initWithHtml:description];
	descriptionViewController.name = name;
	descriptionViewController.url = link;
	descriptionViewController.text = title;
	[self.navigationController pushViewController:descriptionViewController animated:YES];
	[descriptionViewController release];
	 */
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
	[indicator_ release];
	[reloadButton_ release];
    [super dealloc];
}


@end

