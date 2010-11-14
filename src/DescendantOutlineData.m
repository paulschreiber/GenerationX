//
//  DescendantOutlineData.m
//  GenerationX
//
//  Created by Nowhere Man on Thu Feb 28 2002.
//  Copyright (c) 2001 Nowhere Man. All rights reserved.
//

#import "DescendantOutlineData.h"


@implementation DescendantOutlineData

+ (DescendantOutlineData*) sharedDescendant
{
  static DescendantOutlineData* my_data = nil;
  
  if( ! my_data )
    my_data = [[DescendantOutlineData alloc] init];
    
  return my_data;
}

- (void) setData: (INDI*) my_indi: (GCFile*) my_ged
{
  [indi release];
  indi = [my_indi retain];
  ged = my_ged;
}

//
// NSOutlineView methods
//
- (id)outlineView:(NSOutlineView *)outlineView
  child:(int)index
  ofItem:(id)item
{
  if( ! item )
    return [[indi spouseFamilies: ged] objectAtIndex: index];
  else if( [[item fieldType] isEqual: @"INDI"] )
    return [[item spouseFamilies: ged] objectAtIndex: index];
  else
    return [[item children: ged] objectAtIndex: index];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView
  isItemExpandable:(id)item
{
  if( !item && [[indi spouseFamilies: ged] count] )
    return true;
  else if( [[item fieldType] isEqual: @"INDI"] && [[item spouseFamilies: ged] count] )
    return true;
  else if( [[item fieldType] isEqual: @"FAM"] && [[item children: ged] count] )
    return true;
    
  return false;
}

- (int)outlineView:(NSOutlineView *)outlineView
  numberOfChildrenOfItem:(id)item
{
  if( item == nil )
    return [[indi spouseFamilies: ged] count];
  else if( [[item fieldType] isEqual: @"INDI"] )
    return [[item spouseFamilies: ged] count];
  else
    return [[item children: ged] count];
}

- (id)outlineView:(NSOutlineView *)outlineView
  objectValueForTableColumn:(NSTableColumn *)tableColumn
  byItem:(id)item
{
  NSMutableString* result = [[NSMutableString alloc] init];
  
  if( [[tableColumn identifier] isEqual: @"NAME"] )
  {
    if( [[item fieldType] isEqual: @"INDI"] )
    {
        [result setString: [item fullName]];
        [result appendString: @" "];
        [result appendString: [item lifespan]];
        return result;
    }
    else
    {
        int selected_level = [outlineView levelForItem: item];
        int i = [outlineView rowForItem: item];
        INDI* spouse;
        
        if( selected_level == 0 )
        {
        if( [[indi sex] isEqual: @"M"] )
            spouse = [item wife: ged];
        else
            spouse = [item husband: ged];
        }
        else
        {
        while( [outlineView levelForRow: i] >= selected_level )
            i--;
            
        if( [[[outlineView itemAtRow: i] sex] isEqual: @"M"] )
            spouse = [item wife: ged];
        else
            spouse = [item husband: ged];
        }
        
        [result setString: @"+ "];
        if( spouse )
        {
        [result appendString: [spouse fullName]];
        [result appendString: @" "];
        [result appendString: [spouse lifespan]];
        }
        else
        [result appendString: @"?"];
        
        return result;
    }
  }
  
  return result;
}

@end
