//
//  StatusXMLParser.h
//  TwitterViewer
//
//  Created by 中村 薫 on 10/12/21.
//  Copyright 2010 personal. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface StatusXMLParser : NSObject <NSXMLParserDelegate> {
	NSMutableString	*currentXpath;
	NSMutableArray	*statuses;
	NSMutableDictionary	*currentStatus;
	NSMutableString	*textNodeCharacters;
}

@property(nonatomic,retain) NSMutableString	*currentXpath;
@property(nonatomic,retain) NSMutableArray	*statuses;
@property(nonatomic,retain) NSMutableDictionary	*currentStatus;
@property(nonatomic,retain) NSMutableString	*textNodeCharacters;

- (NSArray *) parseStatuses: (NSData *)xml;

@end
