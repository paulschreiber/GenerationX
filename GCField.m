//
//  GCField.m
//  GenerationX
//
//  Created by Nowhere Man on Tue Feb 19 2002.
//  Copyright (c) 2001 Nowhere Man. All rights reserved.
//

#import "GCField.h"
#import "GenXUtil.h"

@implementation GCField

// class models a single record or subfield of a record

// setup a new field given its level. type, and label
- (id)init: (int) my_level : (NSString*) my_type : (NSString*) my_value
{
  type = [my_type retain];
  value = [my_value retain];
  level = my_level;
  num_subfields = 0;
  subfields = [[NSMutableArray alloc] init];
  need_save = false;
  
  return self;
}

- (void) setFieldType: (NSString*) my_type
{
  [type release];
  type = [my_type retain];
  need_save = true;
}

- (void) setFieldValue: (NSString*) my_value
{
  [value release];
  value = [my_value retain];
  need_save = true;
}

- (void) setNeedSave: (BOOL) b
{
  int i;
  
  need_save = b;
  
  for( i = 0; i < num_subfields; i++ )
    [[subfields objectAtIndex: i ] setNeedSave: b];
}

- (NSString*) fieldType
{
  if( type )
    return type;
  else
    return @"";
}

- (NSString*) fieldValue
{
  if( value )
    return value;
  else
    return @"";
}

- (NSString*) textValue
{
  NSMutableString* result = [[NSMutableString alloc] initWithString: [self fieldValue]];
  int i = 0;
  
  for( i = 0; i < num_subfields; i++ )
    if( [[[subfields objectAtIndex: i] fieldType] isEqualToString: @"CONT"] )
    {
      [result appendString: @"\n"];
      [result appendString: [[subfields objectAtIndex: i] fieldValue]];
    }
    else if( [[[subfields objectAtIndex: i] fieldType] isEqualToString: @"CONC"] )
    {
      [result appendString: @" "];
      [result appendString: [[subfields objectAtIndex: i] fieldValue]];
    }
    
  return result;
}

- (int) fieldLevel
{
  return level;
}

- (BOOL) needSave
{
  int i;
  
  if( need_save )
    return true;
  
  for( i = 0; i < num_subfields; i++ )
    if( [[subfields objectAtIndex: i ] needSave] )
      return true;
      
  return false;
}

- (int) numSubfields
{
  return num_subfields;
}

- (GCField*) eventAtIndex: (int) index
{
  int i;
  
  for( i = 0; i < num_subfields; i++ )
  {
    if( [[subfields objectAtIndex: i] isEvent] )
      index--;
    if( index == -1 )
      return [subfields objectAtIndex: i];
  }
  
  return nil;
}

- (GCField*) subfieldAtIndex: (int) index
{
  return [subfields objectAtIndex: index];
}

// find a subfield of this field given its type
// if this field has more than one subfield of the
// requested type, returns the first one found
- (GCField*) subfieldWithType: (NSString*) my_type;
{
  GCField* result;
  int i;
  for( i = 0; i < num_subfields; i++ )
  {
    result = [subfields objectAtIndex: i];
    if( [[result fieldType] isEqual: my_type] )
      return result;
  }
  
  return nil;
}

- (NSMutableArray*) subfieldsWithType: (NSString*) my_type
{
  NSMutableArray* result = [[NSMutableArray alloc] init];
  int i = 0;
  
  for( i = 0; i < num_subfields; i++ )
  {
    if( [[[subfields objectAtIndex: i] fieldType] isEqual: my_type] )
      [result addObject: [subfields objectAtIndex: i]];
  }
  
  return result;
}

// return the values of all subfield of this field
// given their type
- (NSMutableArray*) valuesOfSubfieldsWithType: (NSString*) my_type
{
  NSMutableArray* result = [[NSMutableArray alloc] init];
  int i = 0;
  
  for( i = 0; i < num_subfields; i++ )
  {
    if( [[[subfields objectAtIndex: i] fieldType] isEqual: my_type] )
      [result addObject: [[subfields objectAtIndex: i] fieldValue]];
  }
  
  return result;
}

// return the value of a subfield of this field
// given its type
// if this field has more than one subfield of the
// requested type, returns the first one found
- (NSString*) valueOfSubfieldWithType: (NSString*) my_type
{
  NSString* tmp;
  int i;
  for( i = 0; i < num_subfields; i++ )
  {
    tmp = [[subfields objectAtIndex: i] fieldType];
    if( [tmp isEqual: my_type] )
      return [[subfields objectAtIndex: i] fieldValue];
  }
  
  return nil;
}

// return the last subfield added
- (GCField*) lastField
{
  return [subfields lastObject];
}

// add a subfield to this field
- (GCField*) addSubfield: (NSString*) my_type : (NSString*) my_value
{
  GCField* field = [GCField alloc];
  [field init: (level + 1) : my_type : my_value];
  
  [subfields addObject: field];
  num_subfields++;

  return field;
}

- (void) removeSubfield: (GCField*) my_field
{
  [subfields removeObject: my_field];
  num_subfields--;
  need_save = true;
}

// remove a subfield of this field given its type
// and value
- (void) removeSubfieldWithType: (NSString*) my_type Value: (NSString*) my_value
{
  int i;
  
  if( !my_type )
    my_type = @"";
  if( !my_value )
    my_value = @"";

  for( i = 0; i < num_subfields; i++ )
  {
    GCField* tmp = [subfields objectAtIndex: i];
    if( [[tmp fieldType] isEqual: my_type]
     && [[tmp fieldValue] isEqual: my_value] )
    {
      [subfields removeObject: tmp];
      num_subfields--;
      need_save = true;
    }
  }  
}

// return the GEDCOM code for this field suitable for writing to file
- (NSString*) dataForFile
{
  NSMutableString* result = [[NSMutableString alloc] initWithString: @""];
  int i;
  
  if( level == 0 )
  {
    if( [type isEqual: @"HEAD"] )
    {
      [result appendString:
               [[NSNumber numberWithInt: level] stringValue]];
      [result appendString: @" "];
      [result appendString: value];
      [result appendString: @"\n"];
    }
    else
    {
      [result appendString:
               [[NSNumber numberWithInt: level] stringValue]];
      [result appendString: @" "];
      [result appendString: value];
      [result appendString: @" "];
      [result appendString: type];
      [result appendString: @"\n"];
    }
  }
  else
  {
    [result appendString:
               [[NSNumber numberWithInt: level] stringValue]];
    [result appendString: @" "];
    [result appendString: type];
    if( value )
    {
      [result appendString: @" "];
      [result appendString: value];
    }
    [result appendString: @"\n"];
  } 
  
  for( i = 0; i < num_subfields; i++ )
    [result appendString:
             [[subfields objectAtIndex: i] dataForFile]];
    
  return result;
}

// determine if this field is identical to the given one
- (BOOL) isIdentical: (GCField*)my_field
{
  if( [[self dataForFile] isEqual: [my_field dataForFile]] )
    return true;
    
  return false;
}

- (BOOL) isEvent
{
  NSString* my_type = [self fieldType];
  
  if( [my_type isEqualToString: @"BIRT"]
   || [my_type isEqualToString: @"DEAT"]
   || [my_type isEqualToString: @"BURI"]
   || [my_type isEqualToString: @"CREM"]
   || [my_type isEqualToString: @"BAPM"]
   || [my_type isEqualToString: @"BARM"]
   || [my_type isEqualToString: @"BASM"]
   || [my_type isEqualToString: @"BLES"]
   || [my_type isEqualToString: @"CHRA"]
   || [my_type isEqualToString: @"CONF"]
   || [my_type isEqualToString: @"FCOM"]
   || [my_type isEqualToString: @"ORDN"]
   || [my_type isEqualToString: @"NATU"]
   || [my_type isEqualToString: @"EMIG"]
   || [my_type isEqualToString: @"IMMI"]
   || [my_type isEqualToString: @"CENS"]
   || [my_type isEqualToString: @"PROB"]
   || [my_type isEqualToString: @"WILL"]
   || [my_type isEqualToString: @"GRAD"]
   || [my_type isEqualToString: @"RETI"]
   || [my_type isEqualToString: @"EVEN"]
   || [my_type isEqualToString: @"CHR"]
   || [my_type isEqualToString: @"ADOP"]
   || [my_type isEqualToString: @"MARR"]
   || [my_type isEqualToString: @"FAMS"]
   || [my_type isEqualToString: @"ENGA"]
   || [my_type isEqualToString: @"DIV"]
   || [my_type isEqualToString: @"ANUL"]
   || [my_type isEqualToString: @"MARB"]
   || [my_type isEqualToString: @"MARS"]
   || [my_type isEqualToString: @"MARC"]
   || [my_type isEqualToString: @"MARL"]
   || [my_type isEqualToString: @"DIVF"] )
    return true;
    
  return false;
}

- (void) sortEvents
{
  [subfields sortUsingSelector: @selector( eventCompare: )];
}

- (NSComparisonResult) eventCompare: (GCField*) my_field
{
  NSDate* date1, *date2;
  NSString* date1_str, *date2_str;
  
  // if they both have a DATE, do a compare
  if( ( date1_str = [self valueOfSubfieldWithType: @"DATE"] )
   && ( date2_str = [my_field valueOfSubfieldWithType: @"DATE"] ) )
  {
    date1 = [NSDate dateWithNaturalLanguageString: date1_str];
    date2 = [NSDate dateWithNaturalLanguageString: date2_str];
    return [date1 compare: date2];
  }
  // if only one has a date, that one goes first
  else if( date1_str = [self valueOfSubfieldWithType: @"DATE"] )
    return NSOrderedAscending;
  else if( date2_str = [my_field valueOfSubfieldWithType: @"DATE"] )
    return NSOrderedDescending;
  // otherwise we'll just go alpha for now
  // alpha by GEDCOM, *not* alpha by natural language
  else
  {
    return [[self fieldType] compare: [my_field fieldType]]; 
  }
}

- (int)numberOfRowsInTableView:(NSTableView *)aTableView
{
  int i, result = 0;
  
  for( i = 0; i < num_subfields; i++ )
    if( [[subfields objectAtIndex: i] isEvent] )
      result++;
      
  return result;
}

- (id)tableView:(NSTableView *)aTableView
  objectValueForTableColumn:(NSTableColumn *)aTableColumn
  row:(int)rowIndex
{
  GCField* tmp = [self eventAtIndex: rowIndex];
  NSString* tmp_str;
  NSMutableString* result = 
    [[NSMutableString alloc] initWithString: 
    [[GenXUtil sharedUtil] eventStringFromGEDCOM:
    [[self eventAtIndex: rowIndex] fieldType]]];
    
  if( [[tmp fieldType] isEqualToString: @"EVEN"] )
    [result setString: [tmp valueOfSubfieldWithType: @"TYPE"]];
    
  if( ! result )
    [result setString: [tmp fieldType]];
    
  if( ! result )
    [result setString: @""];
    
  if( tmp_str = [tmp valueOfSubfieldWithType: @"DATE"] )
  {
    [result appendString: @" ("];
    [result appendString: tmp_str];
    [result appendString: @")"];
  }
    
  return result;
}

@end
