//
//  StatusXMLParser.m
//  TwitterViewer
//
//  Created by 中村 薫 on 10/12/21.
//  Copyright 2010 personal. All rights reserved.
//

#import "StatusXMLParser.h"


@implementation StatusXMLParser

@synthesize currentXpath, statuses, currentStatus, textNodeCharacters;

- (void)parserDidStartDocument:(NSXMLParser *)parer {
	self.currentXpath = [[[NSMutableString alloc] init] autorelease];
	self.statuses = [[[NSMutableArray alloc] init] autorelease];
}

- (void) parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
	[self.currentXpath appendString: elementName];
	[self.currentXpath appendString: @"/"];
//	NSLog(@"self.currentXpath = %@", self.currentXpath);
	self.textNodeCharacters = [[[NSMutableString alloc] init] autorelease];
	
	if ([self.currentXpath isEqualToString: @"feed/entry/"]) {
		self.currentStatus = [[[NSMutableDictionary alloc] init] autorelease];
	}
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
	NSString *textData = [self.textNodeCharacters stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	
	if ([self.currentXpath isEqualToString:@"feed/entry/"]) {
		[self.statuses addObject:self.currentStatus];
		self.currentStatus = nil;
	} else if ([self.currentXpath isEqualToString:@"feed/entry/title/"]) {
		[self.currentStatus setValue:textData forKey:@"title"];
	} else if ([self.currentXpath isEqualToString:@"feed/entry/link/"]) {
		[self.currentStatus setValue:textData forKey:@"link"];
	} else if ([self.currentXpath isEqualToString:@"feed/entry/content/"]) {
		[self.currentStatus setValue:textData forKey:@"content"];
	} else if ([self.currentXpath isEqualToString:@"feed/entry/author/name/"]) {
		[self.currentStatus setValue:textData forKey:@"name"];
	} else if ([self.currentXpath isEqualToString:@"feed/entry/updated/"]) {
		[self.currentStatus setValue:textData forKey:@"updated"];
	}

	int delLength = [elementName length] + 1;
	int delIndex = [self.currentXpath length] - delLength;
	
	[self.currentXpath deleteCharactersInRange:NSMakeRange(delIndex,delLength)];
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
	[self.textNodeCharacters appendString:string];
}

- (NSArray *) parseStatuses:(NSData *)xml {
	NSXMLParser *parser = [[[NSXMLParser alloc] initWithData:xml] autorelease];
	[parser setDelegate:self];
	[parser parse];
	
	return self.statuses;
}

- (void) dealloc {
	[currentXpath release];
	[statuses release];
	[currentStatus release];
	[textNodeCharacters release];
	
	[super dealloc];
}

@end
