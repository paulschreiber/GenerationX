//
//  GenXUtil.h
//  GenerationX
//
//  Created by Nowhere Man on Tue Jun 11 2002.
//  Copyright (c) 2001 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GenXUtil : NSObject
{
  NSMutableDictionary* eventDict;
  NSMutableArray* recent_places;
}

+ (GenXUtil*) sharedUtil;

- (GenXUtil*) init;
- (NSString*) eventStringFromGEDCOM: (NSString*) my_gedcom;
- (NSDate*) dateFromGEDCOM: (NSString*) str;

- (void) updateRecentPlacesWithString: (NSString*) s;
- (NSString*) recentPlaceWithPrefix: (NSString*) s;

@end
