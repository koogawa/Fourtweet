//
//  ViewUtil.h
//  VenueMap
//
//  Created by Developer on 11/03/19.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ViewUtil : NSObject {

}

+ (UIView *)createTitleViewWithRect:(CGRect)frame title:(NSString *)title;
+ (UIImage*)resizeImage:(UIImage*)image scaledToSize:(CGSize)newSize;

@end
