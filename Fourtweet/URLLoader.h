//
//  URLLoader.h
//  VenueViewer
//
//  Created by USER on 10/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface URLLoader : NSObject {
    NSURLConnection *connection;
    NSMutableData   *data;
    NSString        *urlString_;
}

@property(retain, nonatomic) NSURLConnection    *connection;
@property(retain, nonatomic) NSMutableData      *data;
@property(retain, nonatomic) NSString           *urlString;

- (void)loadFromUrlString:(NSString *)url method:(NSString *)method;

@end
