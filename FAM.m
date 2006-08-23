//
//  FAM.m
//  GenerationX
//
//  Created by Nowhere Man on Fri Feb 22 2002.
//  Copyright (c) 2001 Nowhere Man. All rights reserved.
//

#import "GCFile.h"
#import "FAM.h"

#define currentDoc [[NSDocumentController sharedDocumentController] currentDocument]

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

- (NSDate*) marriageDate
{
//NSLog( @"INDI::birthDate" );
  NSString* birth_str = [[self subfieldWithType: @"MARR"] valueOfSubfieldWithType: @"DATE"];
  NSMutableString* date_str = [[NSMutableString alloc] initWithString: @""];
  NSString* tmp;
  NSScanner* s;
  int i;
  
  [birth_str stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
  
  if( !birth_str )
    return nil;
  if( [birth_str isEqualToString: @""] )
    return nil;
    
  s = [NSScanner scannerWithString: birth_str];
  [s setCharactersToBeSkipped: [NSCharacterSet letterCharacterSet]];
  [s scanInt: &i];
  
  // if the DATE field starts with an int between 1 and 31
  // assume we have a full DATE
  if( i > 0 && i <= 31 )
    return [NSDate dateWithNaturalLanguageString: birth_str];
  // otherwise we must have "MON YEAR" or just "YEAR"
  else
    [date_str appendString: @"1 "];

  // reset the scanner
  [s setScanLocation: 0];
  [s setCharactersToBeSkipped: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
  // if DATE starts with letters, we maust have "MON YEAR"
  if( [s scanCharactersFromSet: [NSCharacterSet letterCharacterSet] intoString: &tmp] )
    [date_str appendString: birth_str];
  // otherwise we just have "YEAR"
  else
  {
    [date_str appendString: @"JAN "];
    [date_str appendString: birth_str];
  }
  
//NSLog( date_str );
  return [NSDate dateWithNaturalLanguageString: date_str];  
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

- (void) sortChildren: (id) g
{
  int i;
  GCField* f;
  NSMutableArray* children = [self children: g];
  [children sortUsingSelector: @selector( compareBirthdays: )];
  
  // remove the children
  for( i = 0; i < [subfields count]; i++ )
  {
    f = [subfields objectAtIndex: i];
    if( [[f fieldType] isEqualToString: @"CHIL"] )
    {
      [subfields removeObject: f];
      i--;
    }
  }
  // and replace them in the correct order
  for( i = 0; i < [children count]; i++ )
  {
    f = [children objectAtIndex: i];
    [subfields addObject: [[GCField alloc] init: 1 : @"CHIL" : [f fieldValue]]];
  }
}

- (NSComparisonResult) compare: (id) my_field
{
  return [value compare: [my_field fieldValue]];
}

- (NSComparisonResult) compareHusbandSurname: (id) my_field
{
  if( [self husband: [currentDoc ged]] && [my_field husband: [currentDoc ged]] )
	{
    if( [[[self husband: [currentDoc ged]] lastName] compare: [[my_field husband: [currentDoc ged]] lastName]] == NSOrderedSame )
	  {
      if( [[[self wife: [currentDoc ged]] lastName] compare: [[my_field wife: [currentDoc ged]] lastName]] == NSOrderedSame )
			  return NSOrderedSame;
			else
  	    return [self compareWifeSurname: my_field];
		}
		
    return [[[self husband: [currentDoc ged]] lastName] compare: [[my_field husband: [currentDoc ged]] lastName]];
	}
	else if( ![self husband: [currentDoc ged]] && ![my_field husband: [currentDoc ged]] )
	{
    if( [[[self wife: [currentDoc ged]] lastName] compare: [[my_field wife: [currentDoc ged]] lastName]] == NSOrderedSame )
			return NSOrderedSame;
		else
			return [self compareWifeSurname: my_field];
	}
	else if( [self husband: [currentDoc ged]] )
	  return NSOrderedAscending;
	else
	  return NSOrderedDescending;
}

- (NSComparisonResult) compareHusbandSurnameReverse: (id) my_field
{
  NSComparisonResult r = [self compareHusbandSurname: my_field];
	
	if( r == NSOrderedAscending )
	  return NSOrderedDescending;
	else if( r == NSOrderedDescending )
	  return NSOrderedAscending;
	else
	  return NSOrderedSame;
}

- (NSComparisonResult) compareWifeSurname: (id) my_field
{
  if( [self wife: [currentDoc ged]] && [my_field wife: [currentDoc ged]] )
	{
    if( [[[self wife: [currentDoc ged]] lastName] compare: [[my_field wife: [currentDoc ged]] lastName]] == NSOrderedSame )
	  {
      if( [[[self husband: [currentDoc ged]] lastName] compare: [[my_field husband: [currentDoc ged]] lastName]] == NSOrderedSame )
			  return NSOrderedSame;
			else
  	    return [self compareHusbandSurname: my_field];
		}
		
    return [[[self wife: [currentDoc ged]] lastName] compare: [[my_field wife: [currentDoc ged]] lastName]];
	}
	else if( ![self wife: [currentDoc ged]] && ![my_field wife: [currentDoc ged]] )
	{
    if( [[[self husband: [currentDoc ged]] lastName] compare: [[my_field husband: [currentDoc ged]] lastName]] == NSOrderedSame )
			return NSOrderedSame;
		else
			return [self compareHusbandSurname: my_field];
	}
	else if( [self wife: [currentDoc ged]] )
	  return NSOrderedAscending;
	else
	  return NSOrderedDescending;
}

- (NSComparisonResult) compareWifeSurnameReverse: (id) my_field
{
  NSComparisonResult r = [self compareWifeSurname: my_field];
	
	if( r == NSOrderedAscending )
	  return NSOrderedDescending;
	else if( r == NSOrderedDescending )
	  return NSOrderedAscending;
	else
	  return NSOrderedSame;
}

- (NSComparisonResult) compareMarriageDate: (id) a
{
  NSDate* date1, *date2;
  NSString* date1_str, *date2_str;

  if( (date1_str = [[self subfieldWithType: @"MARR"] valueOfSubfieldWithType: @"DATE"])
   && (date2_str = [[a subfieldWithType: @"MARR"] valueOfSubfieldWithType: @"DATE"]) )
  {
    date1 = [NSDate dateWithNaturalLanguageString: date1_str];
    date2 = [NSDate dateWithNaturalLanguageString: date2_str];
    return [date1 compare: date2];
  }
  else if( date1_str = [[self subfieldWithType: @"MARR"] valueOfSubfieldWithType: @"DATE"] )
    return NSOrderedAscending;
  else if( date2_str = [[a subfieldWithType: @"MARR"] valueOfSubfieldWithType: @"DATE"] )
    return NSOrderedDescending;
  else
  {
    return NSOrderedSame;
  }
}

- (NSComparisonResult) compareMarriageDateReverse: (id) a
{
  NSDate* date1, *date2;
  NSString* date1_str, *date2_str;

  if( (date1_str = [[self subfieldWithType: @"MARR"] valueOfSubfieldWithType: @"DATE"])
   && (date2_str = [[a subfieldWithType: @"MARR"] valueOfSubfieldWithType: @"DATE"]) )
  {
    date1 = [NSDate dateWithNaturalLanguageString: date1_str];
    date2 = [NSDate dateWithNaturalLanguageString: date2_str];
    return [date2 compare: date1];
  }
  else if( date1_str = [[self subfieldWithType: @"MARR"] valueOfSubfieldWithType: @"DATE"] )
    return NSOrderedDescending;
  else if( date2_str = [[a subfieldWithType: @"MARR"] valueOfSubfieldWithType: @"DATE"] )
    return NSOrderedAscending;
  else
  {
    return NSOrderedSame;
  }
}

@end
