//
//  FAM.m
//  GenerationX
//
//  Created by Nowhere Man on Fri Feb 22 2002.
//  Copyright (c) 2001 Nowhere Man. All rights reserved.
//

#import "GCFile.h"
#import "FAM.h"

@implementation FAM

// class models a FAM record. inherits from GCField

- (id)init: (int) my_level : (NSString*) my_type : (NSString*) my_value
{
  self = [super init: my_level : my_type : my_value];
  
  husband = wife = nil;

  return self;
}

- (void) forget
{
  husband = wife = nil;
}

// get the INDI record pointed to by the WIFE field
- (INDI*) wife: (id) my_ged;
{
  if( wife )
    return wife;
  else
    wife = [my_ged indiWithLabel: [self valueOfSubfieldWithType: @"WIFE"]];
    
  return wife;
}

// get the INDI record pointed to by the HUSB field
- (INDI*) husband: (id) my_ged;
{
  if( husband )
    return husband;
  else
    husband = [my_ged indiWithLabel: [self valueOfSubfieldWithType: @"HUSB"]];
    
  return husband;
}

// returns an array of INDI records. one for each CHIL field
- (NSMutableArray*) children: (id) my_ged
{
  NSMutableArray* result = [[NSMutableArray alloc] init];
  NSMutableArray* child_labels = [self valuesOfSubfieldsWithType: @"CHIL"];
  int i;
  
  for( i = 0; i < [child_labels count]; i++ )
  {
    if( [my_ged indiWithLabel: [child_labels objectAtIndex: i]] )
      [result addObject: [my_ged indiWithLabel: [child_labels objectAtIndex: i]]];
  }
  
  return result;
}

// build the text summary for siaplay in fam view mode
- (NSString*) textSummary: (id) my_ged;
{
  NSMutableString* result = [[NSMutableString alloc] init];
  INDI* father = [my_ged indiWithLabel: [self valueOfSubfieldWithType: @"HUSB"]];
  INDI* mother = [my_ged indiWithLabel: [self valueOfSubfieldWithType: @"WIFE"]];
  NSMutableArray* child_array = [self children: my_ged];
  int i;

  [result setString: @"Father:\t"];
  if( father )
    [result appendString: [father fullName]];
  [result appendString: @"\nMother:\t"];
  if( mother )
    [result appendString: [mother fullName]];
  [result appendString: @"\n\nMarried:\t"];
  if( [[self subfieldWithType: @"MARR"] subfieldWithType: @"DATE"] )
    [result appendString:
             [[self subfieldWithType: @"MARR"] valueOfSubfieldWithType: @"DATE"]];
  [result appendString: @"\n"];
  
  for( i = 0; i < [child_array count]; i++ )
  {
    [result appendString: @"\nChild:\t"];
    [result appendString: [[child_array objectAtIndex: i] fullName]];
  }
    
  [result appendString: @""];
  [result appendString: @""];
  [result appendString: @""];
  [result appendString: @""];
  
  return result;
}

- (NSComparisonResult) compare: (id) my_field
{
  return [value compare: [my_field fieldValue]];
}

@end
