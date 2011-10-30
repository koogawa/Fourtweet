//
//  UIAsyncImageView.m
//  AsyncImage
//
//  Created by ntaku on 09/10/31.
//  Copyright 2009 http://d.hatena.ne.jp/ntaku/. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "UIAsyncImageView.h"

@implementation UIAsyncImageView

- (NSString *)getTempPath
{
	NSString *fileName = [[url_ path] stringByReplacingOccurrencesOfString:@"/" withString:@"~"];
	NSString *tempPath = [NSHomeDirectory() stringByAppendingPathComponent:@"tmp/icon"];
	tempPath = [tempPath stringByAppendingPathComponent:fileName];
	return tempPath;
}

- (void)loadImage:(NSString *)url
{
	url_ = [[NSURL URLWithString:url] retain];
	
	// 消えてないインディケータ削除
	UIActivityIndicatorView *indicator = (UIActivityIndicatorView *)[self viewWithTag:1];
	if (indicator) {
		[indicator stopAnimating];
		[indicator removeFromSuperview];
		indicator = nil; 
	}
	
	[self abort];
	self.image = nil;
	
	// キャッシュされてるならそれ使う
	NSString *tempPath = [self getTempPath];
	if ([[NSFileManager defaultManager] fileExistsAtPath:tempPath]) {
		NSData *data = [NSData dataWithContentsOfFile:tempPath];
		self.image = [UIImage imageWithData:data];
		return;
	}		
	
	self.backgroundColor = [UIColor whiteColor];
	indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	indicator.frame = self.bounds;
	indicator.tag = 1;
	indicator.hidesWhenStopped = TRUE;
	indicator.contentMode = UIViewContentModeCenter;
	[indicator startAnimating];
	[self addSubview:indicator];
	data_ = [[NSMutableData alloc] initWithCapacity:0];

	NSURLRequest *req = [NSURLRequest 
						 requestWithURL:[NSURL URLWithString:url] 
						 cachePolicy:NSURLRequestUseProtocolCachePolicy
						 timeoutInterval:30.0];
	conn_ = [[NSURLConnection alloc] initWithRequest:req delegate:self];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
//	NSLog(@"connection didRecieveResponse");
	[data_ setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)nsdata{
//	NSLog(@"connection didReceiveData len=%d", [nsdata length]);
	[data_ appendData:nsdata];	
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
	NSLog(@"connection didFailWithError - %@ %@", [error localizedDescription], [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
	UIActivityIndicatorView *indicator = (UIActivityIndicatorView *)[self viewWithTag:1];
	if (indicator) {
		[indicator stopAnimating];
		[indicator removeFromSuperview];
		indicator = nil; 
	}
	[self abort];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	self.contentMode = UIViewContentModeScaleAspectFit;
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.image = [UIImage imageWithData:data_];
	
	// キャッシュに書き込む
	NSData *pngData = [[[NSData alloc] initWithData:UIImagePNGRepresentation(self.image)] autorelease];
	[pngData writeToFile:[self getTempPath] atomically:YES];
	
	UIActivityIndicatorView *indicator = (UIActivityIndicatorView *)[self viewWithTag:1];
	if (indicator) {
		[indicator stopAnimating];
		[indicator removeFromSuperview];
		indicator = nil; 
	}
	[self abort];
}

-(void)abort{
	if(conn_ != nil){
		[conn_ cancel];
		[conn_ release];
		conn_ = nil;
	}
	if(data_ != nil){
		[data_ release];
		data_ = nil;
	}
}

- (void)dealloc {
	[conn_ cancel];
    [conn_ release];
    [data_ release];
	[url_ release];
    [super dealloc];
}

@end
