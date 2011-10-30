//
//  UIAsyncImageView.h
//  AsyncImage
//
//  Created by ntaku on 09/10/31.
//  Copyright 2009 http://d.hatena.ne.jp/ntaku/. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIAsyncImageView : UIImageView {
	NSURLConnection	*conn_;
	NSMutableData	*data_;
	NSURL			*url_;
//	UIActivityIndicatorView *indicator;
}

-(void)loadImage:(NSString *)url;
-(void)abort;

@end
