//
//  FAM.h
//  GenerationX
//
//  Created by Nowhere Man on Fri Feb 22 2002.
//  Copyright (c) 2001 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCField.h"
#import "INDI.h"

@interface FAM : GCField
{
  INDI* husband;
  INDI* wife;
}

- (id)init: (NSInteger) my_level : (NSString*) my_type : (NSString*) my_value;
- (void) forget;
- (INDI*) wife: (id) my_ged;
- (INDI*) husband: (id) my_ged;
- (NSMutableArray*) children: (id) my_ged;
- (NSDate*) marriageDate;
- (NSString*) textSummary: (id) my_ged;
- (NSComparisonResult) compare: (id) my_field;
- (void) sortChildren: (id) g;
- (NSComparisonResult) compareHusbandSurname: (id) my_field;
- (NSComparisonResult) compareHusbandSurnameReverse: (id) my_field;
- (NSComparisonResult) compareWifeSurname: (id) my_field;
- (NSComparisonResult) compareWifeSurnameReverse: (id) my_field;
- (NSComparisonResult) compareMarriageDate: (id) a;
- (NSComparisonResult) compareMarriageDateReverse: (id) a;

@end
