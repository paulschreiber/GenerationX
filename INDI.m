//
//  INDI.m
//  GenerationX
//
//  Created by Nowhere Man on Thu Feb 21 2002.
//  Copyright (c) 2001 Nowhere Man. All rights reserved.
//

#import "INDI.h"
#import "GCFile.h"

@implementation INDI

// class models an INDI record. inherits from GCField

- (id)init: (int) my_level : (NSString*) my_type : (NSString*) my_value
{
  self = [super init: my_level : my_type : my_value];

  return self;
}

// return this INDI's father
- (INDI*) father: (id) my_ged
{
  INDI* result;
  NSString* famc_label;
  NSString* father_label;
  
  famc_label = [self valueOfSubfieldWithType: @"FAMC"];
  father_label = [[my_ged famWithLabel: famc_label] valueOfSubfieldWithType: @"HUSB"];
  result = [my_ged indiWithLabel: father_label];
  
  return result;
}

// return this INDI's mother
- (INDI*) mother: (id) my_ged
{
  INDI* result;
  NSString* famc_label;
  NSString* mother_label;
  
  famc_label = [self valueOfSubfieldWithType: @"FAMC"];
  mother_label = [[my_ged famWithLabel: famc_label] valueOfSubfieldWithType: @"WIFE"];
  result = [my_ged indiWithLabel: mother_label];
  
  return result;
}

// return an array of FAM records. one for each of this person's spouses
- (NSMutableArray*) spouseFamilies: (id) my_ged
{
  NSMutableArray* result = [[NSMutableArray alloc] init];
  int i = 0;
  
  for( i = 0; i < num_subfields; i++ )
  {    if( [[[subfields objectAtIndex: i] fieldType] isEqual: @"FAMS"] 
     && [my_ged famWithLabel: [[subfields objectAtIndex: i] fieldValue]] )
      [result addObject: [my_ged famWithLabel: [[subfields objectAtIndex: i] fieldValue]]];
  }
  
  return result;
}

- (NSString*) firstName
{
  NSString* result = @"?";
  NSScanner* name_scanner;
  
  if( ! [self valueOfSubfieldWithType: @"NAME"] )
    return @"?";
    
  // if this record has a NAME -> GIVN field, just use that
  if( [[self subfieldWithType: @"NAME"] subfieldWithType: @"GIVN"] )
    result = [[self subfieldWithType: @"NAME"] valueOfSubfieldWithType: @"GIVN"];
  else
  {
    // otherwise we have to extract it from the NAME field
    name_scanner = [NSScanner scannerWithString:
                  [self valueOfSubfieldWithType: @"NAME"]];
  
    [name_scanner setCharactersToBeSkipped:
      [[NSCharacterSet alphanumericCharacterSet] invertedSet]];                   
  
    // 020818 fix for bug 596872
    // for NAME first/last/ scanning for " /" doesn't work
    // so look for a space first, then if there are any /'s
    // in the result, scan again up to the /
    [name_scanner scanUpToString: @" "
      intoString: &result];
    [name_scanner initWithString: result];
    [name_scanner scanUpToString: @"/"
      intoString: &result];
  }
        
  if( [result isEqual: @""] )
    return @"?";
    
  return result;
}

- (NSString*) lastName
{
  NSString* result = @"";
  NSScanner* name_scanner;
  
  if( ! [self valueOfSubfieldWithType: @"NAME"] )
    return @"?";
    
  // if this person has a NAME -> SURN field, just use that
  if( [[self subfieldWithType: @"NAME"] subfieldWithType: @"SURN"] )
    result = [[self subfieldWithType: @"NAME"] valueOfSubfieldWithType: @"SURN"];
  else
  {
    // otherwise we have to extract it from the NAME field
    name_scanner = [NSScanner scannerWithString:
                              [self valueOfSubfieldWithType: @"NAME"]];                            
    [name_scanner setCharactersToBeSkipped:
      [[NSCharacterSet alphanumericCharacterSet] invertedSet]];                   
    [name_scanner scanUpToString: @"/"
      intoString: nil];
    [name_scanner scanCharactersFromSet: [NSCharacterSet alphanumericCharacterSet]
      intoString: &result];
  }
            
  if( [result isEqual: @""] )
    return @"?";
    
  return result;
}

- (NSString*) nameSuffix
{
  NSString* result = @"";
  
  if( ! [self valueOfSubfieldWithType: @"NAME"] )
    return @"";
    
  // if this person has a NAME -> SURN field, just use that
  if( [[self subfieldWithType: @"NAME"] subfieldWithType: @"NSFX"] )
    result = [[self subfieldWithType: @"NAME"] valueOfSubfieldWithType: @"NSFX"];
            
  return result;
}

- (NSString*) sex
{
  return [self valueOfSubfieldWithType: @"SEX"];
}

// return this person's first, middle, and last names.
// and a suffix (Jr, III, etc.) if any
- (NSString*) fullName
{
  NSMutableString* result = [[NSMutableString alloc] init];

  if( ! [self valueOfSubfieldWithType: @"NAME"] )
    return @"";
      
  [result setString: [self firstName]];
  [result appendString: @" "];
  [result appendString: [self lastName]];
  if( [[self subfieldWithType: @"NAME"] subfieldWithType: @"NSFX"] )
  {
    [result appendString: @" "];
    [result appendString:
             [[self subfieldWithType: @"NAME"] valueOfSubfieldWithType: @"NSFX"]];
  }
  
  return result;
}

// return this persono's birth and death years
// formatted as (xxxx-yyyy)
- (NSString*) lifespan
{
  NSMutableString* result = [[NSMutableString alloc] initWithString: @"("];
  int birt_year = 0;
  int deat_year = 0;
  NSString* birt, *deat;
  NSScanner* birt_scanner, *deat_scanner;
  
  if( birt = [[self subfieldWithType: @"BIRT"] valueOfSubfieldWithType: @"DATE"] )
  {
    if( ![birt isEqual: @""] && ![birt isEqual: @" "] )
    {
      birt_scanner = [NSScanner scannerWithString: birt];
      [birt_scanner setCharactersToBeSkipped:
        [[NSCharacterSet decimalDigitCharacterSet] invertedSet]];
      while( ( birt_year < 1000 || birt_year > 9999 ) && ![birt_scanner isAtEnd] )
      {
        [birt_scanner scanUpToCharactersFromSet: [NSCharacterSet decimalDigitCharacterSet]
         intoString: nil];
        [birt_scanner scanInt: &birt_year];
      }
    }
  }
  if( deat = [[self subfieldWithType: @"DEAT"] valueOfSubfieldWithType: @"DATE"] )
  {
    if( ![deat isEqual: @""] && ![deat isEqual: @" "] )
    {
      deat_scanner = [NSScanner scannerWithString: deat];
      [deat_scanner setCharactersToBeSkipped:
        [[NSCharacterSet decimalDigitCharacterSet] invertedSet]];
      while( ( deat_year < 1000 || deat_year > 9999 ) && ![deat_scanner isAtEnd] )
      {
        [deat_scanner scanUpToCharactersFromSet: [NSCharacterSet decimalDigitCharacterSet]
         intoString: nil];
        [deat_scanner scanInt: &deat_year];
      }
    }
  }
  
  if( birt_year > 1000 && birt_year < 9999 )
    [result appendString:
             [[NSNumber numberWithInt: birt_year] stringValue]];
  [result appendString: @"-"];
  if( deat_year > 1000 && deat_year < 9999 )
    [result appendString:
             [[NSNumber numberWithInt: deat_year] stringValue]];
  [result appendString: @")"];
          
  
  return result;
}

// build the text summary for this persoon
// to be displayed in person view mode
- (NSString*) textSummary: (id) my_ged
{
  NSMutableString* result = [[NSMutableString alloc] init];
  NSString *birth_place, *death_place, *tmp_str;
  NSMutableArray* fams_array = [self spouseFamilies: my_ged];
  NSMutableArray* child_array;
  INDI* tmp;
  int i, j;
  
  [result setString: @"Born:\t\t"];
  if( tmp_str = [[self subfieldWithType: @"BIRT"] valueOfSubfieldWithType: @"DATE"] )
    [result appendString: tmp_str];
  if( birth_place = [[self subfieldWithType: @"BIRT"]
                    valueOfSubfieldWithType: @"PLAC"] )
  {
    [result appendString: @"\t("];
    [result appendString: birth_place];
    [result appendString: @")"];
  }
  [result appendString: @"\nDied:\t\t"];
  if( tmp_str = [[self subfieldWithType: @"DEAT"] valueOfSubfieldWithType: @"DATE"] )
    [result appendString: tmp_str];
  if( death_place = [[self subfieldWithType: @"DEAT"]
                    valueOfSubfieldWithType: @"PLAC"] )
  {
    [result appendString: @"\t("];
    [result appendString: death_place];
    [result appendString: @")"];
  }
  
  [result appendString: @"\n\nFather:\t"];
  if( tmp = [self father: my_ged] )
  {
    [result appendString: [tmp fullName]];
    [result appendString: @"\t"];
    [result appendString: [tmp lifespan]];
  }
  [result appendString: @"\nMother:\t"];
  if( tmp = [self mother: my_ged] )
  {
    [result appendString: [tmp fullName]];
    [result appendString: @"\t"];
    [result appendString: [tmp lifespan]];
  }
           
  for( i = 0; i < [fams_array count]; i++ )
  {
    [result appendString: @"\n\nSpouse:\t"];
    
    if( [[self sex] isEqual: @"M"] )
    {
      if( tmp = [[fams_array objectAtIndex: i] wife: my_ged] )
      {
        [result appendString: [tmp fullName]];
        [result appendString: @"\t"];
        [result appendString: [tmp lifespan]];
      }
    }
    else
    {
      if( tmp = [[fams_array objectAtIndex: i] husband: my_ged] )
      {
        [result appendString: [tmp fullName]];
        [result appendString: @"\t"];
        [result appendString: [tmp lifespan]];
      }
    }
    
    child_array = [[fams_array objectAtIndex: i] children: my_ged];
    for( j = 0; j < [child_array count]; j++ )
    {
      if( tmp = [child_array objectAtIndex: j] )
      {
        [result appendString: @"\n\tChild:\t"];
        [result appendString: [tmp fullName]];
        [result appendString: @"\t"];
        [result appendString: [tmp lifespan]];
      }
    }
  }
  
  return result;
}

- (NSString*) descendantsGEDCOM: (id) my_ged
{
  NSMutableString* result = [[NSMutableString alloc] initWithString: @""];
  NSArray* spice = [self spouseFamilies: my_ged];
  NSArray* children;
  INDI* tmp_indi;
  FAM* tmp_fam;
  int j, k;
  
  [result setString: [self dataForFile]];
  for( j = 0; j < [spice count]; j++ )
  {
    tmp_fam = [spice objectAtIndex: j];
    [result appendString: [tmp_fam dataForFile]];

    children = [tmp_fam children: my_ged];
    if( [[tmp_fam husband: my_ged] isEqual: self] )
      tmp_indi = [tmp_fam wife: my_ged];
    else
      tmp_indi = [tmp_fam husband: my_ged];
    
    if( tmp_indi )
    {
      [result appendString: [tmp_indi dataForFile]];
      [result appendString: @"\n"];
      for( k = 0; k < [children count]; k++ )
        [result appendString: [[children objectAtIndex: k] descendantsGEDCOM: my_ged]];
    }
  }
  
  return result;
}

- (NSString*) ancestorsGEDCOM: (id) my_ged
{
  NSMutableString* result = [[NSMutableString alloc] initWithString: @""];
  id tmp;
  
  [result setString: [self dataForFile]];
  if( tmp = [my_ged recordWithLabel: [self valueOfSubfieldWithType: @"FAMC"]] )
    [result appendString: [tmp dataForFile]];
  if( tmp = [self father: my_ged] )
    [result appendString: [tmp ancestorsGEDCOM: my_ged]];
  if( tmp = [self mother: my_ged] )
    [result appendString: [tmp ancestorsGEDCOM: my_ged]];

  return result;
}

- (NSString*) descendantReportText: (id) my_ged: (int) my_level
{
  NSMutableString* result = [[NSMutableString alloc] initWithString: @""];
  NSMutableString* prefix = [[NSMutableString alloc] initWithString: @""];
  NSArray* spice = [self spouseFamilies: my_ged];
  NSArray* children;
  NSString* tmp_str;
  INDI* tmp_indi;
  FAM* tmp_fam;
  GCField* tmp_field;
  int i, j, k;
  
  for( i = 0; i < my_level; i++ )
    [prefix appendString: @"      "];
    
  [result appendString: prefix];
  [result appendString: @"("];
  [result appendString: [[NSNumber numberWithInt: my_level] stringValue]];
  [result appendString: @") "];
  [result appendString: [self fullName]];
  [prefix appendString: @"    "];
  if( tmp_field = [self subfieldWithType: @"BIRT"] )
  {
    [result appendString: @"\n"];
    [result appendString: prefix];
    [result appendString: @"Born: "];
    if( tmp_str = [tmp_field valueOfSubfieldWithType: @"DATE"] )
      [result appendString: tmp_str];
    if( tmp_str = [tmp_field valueOfSubfieldWithType: @"PLAC"] )
    {
      [result appendString: @", "];
      [result appendString: tmp_str];
    }
  }
  if( tmp_field = [self subfieldWithType: @"DEAT"] )
  {
    [result appendString: @"\n"];
    [result appendString: prefix];
    [result appendString: @"Died: "];
    if( tmp_str = [tmp_field valueOfSubfieldWithType: @"DATE"] )
      [result appendString: tmp_str];
    if( tmp_str = [tmp_field valueOfSubfieldWithType: @"PLAC"] )
    {
      [result appendString: @", "];
      [result appendString: tmp_str];
    }
  }
  [result appendString: @"\n"];
  for( j = 0; j < [spice count]; j++ )
  {
    if( j > 0 )
    {
      [prefix deleteCharactersInRange: NSMakeRange( 0, 2 )];
      [result appendString: prefix];
      [result appendString: @"Spouse #"];
      [result appendString: [[NSNumber numberWithInt: (j + 1)] stringValue]];
      [result appendString: @" of "];
      [result appendString: [self fullName]];
      [result appendString: @"\n"];
    }
    tmp_fam = [spice objectAtIndex: j];
    children = [tmp_fam children: my_ged];
    if( [[tmp_fam husband: my_ged] isEqual: self] )
      tmp_indi = [tmp_fam wife: my_ged];
    else
      tmp_indi = [tmp_fam husband: my_ged];
    
    if( tmp_indi )
    {
      [result appendString: prefix];
      [result appendString: @"+ "];
      [result appendString: [tmp_indi fullName]];
      [prefix appendString: @"  "];
      if( tmp_field = [tmp_indi subfieldWithType: @"BIRT"] )
      {
        [result appendString: @"\n"];
        [result appendString: prefix];
        [result appendString: @"Born: "];
        if( tmp_str = [tmp_field valueOfSubfieldWithType: @"DATE"] )
          [result appendString: tmp_str];
        if( tmp_str = [tmp_field valueOfSubfieldWithType: @"PLAC"] )
        {
          [result appendString: @", "];
          [result appendString: tmp_str];
        }
      }
      if( tmp_field = [tmp_indi subfieldWithType: @"DEAT"] )
      {
        [result appendString: @"\n"];
        [result appendString: prefix];
        [result appendString: @"Died: "];
        if( tmp_str = [tmp_field valueOfSubfieldWithType: @"DATE"] )
          [result appendString: tmp_str];
        if( tmp_str = [tmp_field valueOfSubfieldWithType: @"PLAC"] )
        {
          [result appendString: @", "];
          [result appendString: tmp_str];
        }
      }
      if( tmp_field = [tmp_fam subfieldWithType: @"MARR"] )
      {
        [result appendString: @"\n"];
        [result appendString: prefix];
        [result appendString: @"Married: "];
        if( tmp_str = [tmp_field valueOfSubfieldWithType: @"DATE"] )
          [result appendString: tmp_str];
        if( tmp_str = [tmp_field valueOfSubfieldWithType: @"PLAC"] )
        {
          [result appendString: @", "];
          [result appendString: tmp_str];
        }
      }
      [result appendString: @"\n"];
      for( k = 0; k < [children count]; k++ )
        [result appendString:
          [[children objectAtIndex: k] descendantReportText: my_ged: (my_level + 1)]];
    }
  }
  
  return result;
}

- (NSString*) ancestorsReportText: (id) my_ged: (NSString*) my_prefix
{
  id tmp;
  NSMutableString* result = [[NSMutableString alloc] initWithString: @""];
//  NSMutableString* prefix = [[NSMutableString alloc] initWithString: @""];
  NSMutableString* prefix2 = [[NSMutableString alloc] initWithString: my_prefix];
  if( [prefix2 length] > 2 )
    [prefix2 deleteCharactersInRange: NSMakeRange( ([prefix2 length] - 1), 1 )];
  if( [prefix2 length] > 0 )
    [prefix2 appendString: @" "];
  [prefix2 appendString: @"    |"];
//  int i;

//  for( i = 0; i < my_level; i++ )
//    [prefix appendString: @"          "];
//  [prefix appendString: @"-"];
  
//  if( tmp = [my_ged recordWithLabel: [self valueOfSubfieldWithType: @"FAMC"]] )
//    [result appendString: [tmp dataForFile]];
  if( tmp = [self father: my_ged] )
  {
    if( [[self sex] isEqualToString: @"F"] )
    {
      [result appendString: [tmp ancestorsReportText: my_ged: [my_prefix stringByAppendingString: @"    |"]]];
      [result appendString: [my_prefix stringByAppendingString: @"    |\n"]];
    }
    else
    {
      [result appendString: [tmp ancestorsReportText: my_ged: prefix2]];
      [result appendString: prefix2];
      [result appendString: @"\n"];
    }
  }

//  [result appendString: prefix];
//  [result appendString: @"------"];
//  [result appendString: prefix];
//  [result appendString: @"|"];
//  [result appendString: prefix];
//  [result appendString: @"\n"];
  [result appendString: my_prefix];
  [result appendString: @"-"];
  [result appendString: [self fullName]];
  [result appendString: @" "];
  [result appendString: [self lifespan]];
  [result appendString: @"\n"];
//  [result appendString: prefix];
//  [result appendString: @"\n"];
//  [result appendString: prefix];
//  [result appendString: @"|\n"];
//  [result appendString: prefix];
//  [result appendString: @"------"];

  if( tmp = [self mother: my_ged] )
  {
    if( [[self sex] isEqualToString: @"M"] )
    {
      [result appendString: [my_prefix stringByAppendingString: @"    |\n"]];
      [result appendString: [tmp ancestorsReportText: my_ged: [my_prefix stringByAppendingString: @"    |"]]];
    }
    else
    {
      [result appendString: prefix2];
      [result appendString: @"\n"];
      [result appendString: [tmp ancestorsReportText: my_ged: prefix2]];
    }
  }
    
  return result;
}

- (NSString*) htmlSummary: (id) my_ged
{
  NSString* tmp;
  INDI* tmp_indi;
  NSArray* spice = [self spouseFamilies: my_ged];
  NSArray* children;
  NSArray* notes = [self valuesOfSubfieldsWithType: @"NOTE"];
  int i, j;
  
  NSMutableString* result = [[NSMutableString alloc] initWithString: @"<html>\n"];
  [result appendString: @"<head><title>GenerationX "];
  [result appendString: [[NSDate date] description]];
  [result appendString: @"</title></head>\n"];
  [result appendString: @"<body bgcolor=FFFFFF>\n"];
  [result appendString: @"<center><font size=+5>G</font><font size=+2>enerationX</font><br>\n<i>"];
  [result appendString: [[NSDate date] description]];
  [result appendString: @"</i>\n<p>"];
  [result appendString: @"<table border=0 width=600 cellpadding=10><tr><td bgcolor=CCCCCC>\n<b>"];
  [result appendString: [self fullName]];
  [result appendString: @"</b>\n<tr><td>\n"];
  [result appendString: @"<b>Born: </b>"];
  if( tmp = [[self subfieldWithType: @"BIRT"] valueOfSubfieldWithType: @"DATE"] )
    [result appendString: tmp];
  if( tmp = [[self subfieldWithType: @"BIRT"] valueOfSubfieldWithType: @"PLAC"] )
  {
    [result appendString: @" ("];
    [result appendString: tmp];
    [result appendString: @")"];
  }
  [result appendString: @"<br>\n<b>Died: </b>"];
  if( tmp = [[self subfieldWithType: @"DEAT"] valueOfSubfieldWithType: @"DATE"] )
    [result appendString: tmp];
  if( tmp = [[self subfieldWithType: @"DEAT"] valueOfSubfieldWithType: @"PLAC"] )
  {
    [result appendString: @" ("];
    [result appendString: tmp];
    [result appendString: @")"];
  }
  [result appendString: @"<p><b>Father:</b> "];
  if( tmp_indi = [self father: my_ged] )
  {
    [result appendString: @"<a href=\""];
    [result appendString: [[[tmp_indi fieldValue] componentsSeparatedByString: @"@"] objectAtIndex: 1]];
    [result appendString: @".html\">"];
    [result appendString: [tmp_indi fullName]];
    [result appendString: @"</a>"];
  }
  [result appendString: @"<br>\n<b>Mother:</b> "];
  if( tmp_indi = [self mother: my_ged] )
  {
    [result appendString: @"<a href=\""];
    [result appendString: [[[tmp_indi fieldValue] componentsSeparatedByString: @"@"] objectAtIndex: 1]];
    [result appendString: @".html\">"];
    [result appendString: [tmp_indi fullName]];
    [result appendString: @"</a>"];
  }
  for( i = 0; i < [spice count]; i++ )
  {
    children = [[spice objectAtIndex: i] children: my_ged];
    if( [[[spice objectAtIndex: i] husband: my_ged] isEqual: self] )
      tmp_indi = [[spice objectAtIndex: i] wife: my_ged];
    else
      tmp_indi = [[spice objectAtIndex: i] husband: my_ged];
    
    if( tmp_indi )
    {
      [result appendString: @"\n<p><b>Spouse:</b> "];
      [result appendString: @"<a href=\""];
      [result appendString: [[[tmp_indi fieldValue] componentsSeparatedByString: @"@"] objectAtIndex: 1]];
      [result appendString: @".html\">"];
      [result appendString: [tmp_indi fullName]];
      [result appendString: @"</a>"];
      
      [result appendString: @"<br>\n<ul>"];
      for( j = 0; j < [children count]; j++ )
      {
        [result appendString: @"\n<li>"];
        [result appendString: @"<a href=\""];
        [result appendString: [[[[children objectAtIndex: j] fieldValue] componentsSeparatedByString: @"@"] objectAtIndex: 1]];
        [result appendString: @".html\">"];
        [result appendString: [[children objectAtIndex: j] fullName]];
        [result appendString: @"</a>"];
      }
      [result appendString: @"\n</ul>\n"];
    }
  }
  for( i = 0; i < [notes count]; i++ )
  {
    [result appendString: @"<p><b>Note:</b><br>\n"];
    [result appendString: [notes objectAtIndex: i]];
    [result appendString: @"\n"];
  }
  [result appendString: @"\n"];
  [result appendString: @"\n"];
  [result appendString: @"\n"];
  [result appendString: @"\n"];
  [result appendString: @"\n"];
  [result appendString: @"\n"];
  [result appendString: @"</table>\n"];
  [result appendString: @"</body>\n"];
  [result appendString: @"</html>\n"];
  
  return result;
}

// compare 2 fields for sorting by surname
- (NSComparisonResult) compare: (id) my_field
{
  if( [[self lastName] isEqual: [my_field lastName]] )
    return [[self firstName] compare: [my_field firstName]];
  else
    return [[self lastName] compare: [my_field lastName]];
}

@end
