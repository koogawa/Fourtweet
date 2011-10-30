//
//  URLLoader.m.m
//  VenueViewer
//
//  Created by USER on 10/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "URLLoader.h"


@implementation URLLoader

@synthesize connection;
@synthesize data;
@synthesize urlString = urlString_;

- (void)connection:(NSURLConnection *)connection 
 didReceiveResponse:(NSURLResponse *)response {
    self.data = [NSMutableData data];
}

-(void)connection:(NSURLConnection *)connection 
	didReceiveData:(NSData *)receiveData {
    [self.data appendData:receiveData];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [[NSNotificationCenter defaultCenter] 
	 postNotificationName:@"connectionDidFinishNotification" 
	 object:self];
}

- (void)connection:(NSURLConnection *)connection 
   didFailWithError:(NSError *)error {
    [[NSNotificationCenter defaultCenter] 
	 postNotificationName:@"connectionDidFailWithError" 
	 object:self];
}

- (void)loadFromUrlString:(NSString *)url method:(NSString *)method {
    urlString_ = url;
    NSMutableURLRequest *req = 
	[NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    [req setHTTPMethod:method];
    self.connection = [NSURLConnection connectionWithRequest:req delegate:self];
}

- (void)dealloc {
    [connection release];
    [data release];
    [super dealloc];
}

@end
