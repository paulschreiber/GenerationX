//
//  INDI.h
//  GenerationX
//
//  Created by Nowhere Man on Thu Feb 21 2002.
//  Copyright (c) 2001 Nowhere Man. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCField.h"
//#import "GCFile.h"

@interface INDI : GCField
{
}

- (id)init: (int) my_level : (NSString*) my_type : (NSString*) my_value;
- (INDI*) father: (id) my_ged;
- (INDI*) mother: (id) my_ged;
- (NSArray*) INDIChildren: (id) my_ged;
- (NSMutableArray*) spouseFamilies: (id) my_ged;
- (NSString*) firstName;
//- (NSString*) middleName;
- (NSString*) lastName;
- (NSString*) nameSuffix;
- (NSString*) fullName;
- (NSString*) sex;
- (NSDate*) birthDate;
- (NSDate*) deathDate;
- (NSString*) lifespan;
- (NSString*) textSummary: (id) my_ged;
- (NSString*) descendantsGEDCOM: (id) my_ged;
- (NSString*) ancestorsGEDCOM: (id) my_ged;
- (NSString*) descendantReportText: (id) my_ged: (int) my_level;
- (NSString*) ancestorsReportText: (id) my_ged: (NSString*) my_prefix;
- (NSString*) htmlSummary: (id) my_ged;
- (NSComparisonResult) compare: (id) my_field;

@end
