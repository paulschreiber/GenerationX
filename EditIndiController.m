#import "GenerationXController.h"
#import "EditIndiController.h"
#import "ChooseFieldController.h"
#import "GCFile.h"
#import "FAM.h";

#define UTIL [UtilController sharedUtil]

@implementation EditIndiController

+ (EditIndiController*) sharedNewIndi
{
  static EditIndiController* shared_panel = nil;
  
  if( ! shared_panel )
    shared_panel = [[EditIndiController alloc] initNib];
    
  return shared_panel;
}

// load the nib
- (EditIndiController*) initNib
{
  [NSBundle loadNibNamed: @"EditIndi" owner:self];
  ged = [[GCFile alloc] init];
  
  return self;
}

// preload the dialog with data from the record being passed in
- (void) prepForDisplay: (id) my_ged: (id) my_field
{
  ged = my_ged;
  field = my_field;
    
  [first_name setStringValue: @""];
  [last_name setStringValue: @""];
  [name_suffix setStringValue: @""];
  [sex_matrix deselectAllCells];
  [birth_day selectItemWithTitle: @"--"];
  [birth_month selectItemWithTitle: @"---"];
  [birth_year setStringValue: @""];
  [birth_place setStringValue: @""];
  [death_day selectItemWithTitle: @"--"];
  [death_month selectItemWithTitle: @"---"];
  [death_year setStringValue: @""];
  [death_place setStringValue: @""];
  [father_text setStringValue: @""];
  [mother_text setStringValue: @""];

  // if we're editing an existing person, load up
  // the dialog with their info
  if( field )
  {
    if( ![[field firstName] isEqual: @"?"] )
      [first_name setStringValue: [field firstName]];
    if( ![[field lastName] isEqual: @"?"] )
      [last_name setStringValue: [field lastName]];
    if( ![[field nameSuffix] isEqual: @""] )
      [name_suffix setStringValue: [field nameSuffix]];
    
    if( ![[field sex] isEqual: @"F"] )
      [sex_matrix selectCellWithTag: 0];
    else
      [sex_matrix selectCellWithTag: 1];
      
    if( [[field subfieldWithType: @"BIRT"] subfieldWithType: @"DATE"] )
    {
      GCField* birth = [[field subfieldWithType: @"BIRT"] subfieldWithType: @"DATE"];
      NSCalendarDate* birth_date =
        [NSCalendarDate dateWithString: [birth fieldValue]
        calendarFormat: @"%d %b %Y"];
      
      if( birth_date )
      {
        NSMutableString* day_str = [[NSMutableString alloc] init];
        NSNumber* day = [NSNumber numberWithInt: [birth_date dayOfMonth]];
        if( [day intValue] < 10 )
        {
          [day_str setString: @"0"];
          [day_str appendString: [day stringValue]];
        }
        else
          [day_str setString: [day stringValue]];
          
        [birth_day selectItemWithTitle: day_str];
        [birth_month selectItemAtIndex: [birth_date monthOfYear]];
        [birth_year setStringValue:
          [[NSNumber numberWithInt: [birth_date yearOfCommonEra]] stringValue]];
      }
      else
      {
        birth_date = [NSCalendarDate dateWithString: [birth fieldValue]
          calendarFormat: @"%b %Y"];

        if( birth_date )
        {
          [birth_day selectItemWithTitle: @"--"];
          [birth_month selectItemAtIndex: [birth_date monthOfYear]];
          [birth_year setStringValue:
            [[NSNumber numberWithInt: [birth_date yearOfCommonEra]] stringValue]];
        }
        else
        {
          birth_date = [NSCalendarDate dateWithString: [birth fieldValue]
            calendarFormat: @"%Y"];
            
          if( birth_date )
          {
            [birth_day selectItemWithTitle: @"--"];
            [birth_month selectItemWithTitle: @"---"];
            [birth_year setStringValue:
              [[NSNumber numberWithInt: [birth_date yearOfCommonEra]] stringValue]];
          }
        }
      }
    }
    else
    {
      [birth_day selectItemWithTitle: @"--"];
      [birth_month selectItemWithTitle: @"---"];
      [birth_year setStringValue: @""];
    }

    if( [[field subfieldWithType: @"BIRT"] subfieldWithType: @"PLAC"] )
      [birth_place setStringValue: [[field subfieldWithType: @"BIRT"] valueOfSubfieldWithType: @"PLAC"]];
    
    if( [[field subfieldWithType: @"DEAT"] subfieldWithType: @"DATE"] )
    {
      GCField* death = [[field subfieldWithType: @"DEAT"] subfieldWithType: @"DATE"];
      NSCalendarDate* death_date =
        [NSCalendarDate dateWithString: [death fieldValue]
        calendarFormat: @"%d %b %Y"];
      
      if( death_date )
      {
        NSMutableString* day_str = [[NSMutableString alloc] init];
        NSNumber* day = [NSNumber numberWithInt: [death_date dayOfMonth]];
        if( [day intValue] < 10 )
        {
          [day_str setString: @"0"];
          [day_str appendString: [day stringValue]];
        }
        else
          [day_str setString: [day stringValue]];
          
        [death_day selectItemWithTitle: day_str];
        [death_month selectItemAtIndex: [death_date monthOfYear]];
        [death_year setStringValue:
          [[NSNumber numberWithInt: [death_date yearOfCommonEra]] stringValue]];
      }
      else
      {
        death_date = [NSCalendarDate dateWithString: [death fieldValue]
          calendarFormat: @"%b %Y"];

        if( death_date )
        {
          [death_day selectItemWithTitle: @"--"];
          [death_month selectItemAtIndex: [death_date monthOfYear]];
          [death_year setStringValue:
            [[NSNumber numberWithInt: [death_date yearOfCommonEra]] stringValue]];
        }
        else
        {
          death_date = [NSCalendarDate dateWithString: [death fieldValue]
            calendarFormat: @"%Y"];
            
          if( death_date )
          {
            [death_day selectItemWithTitle: @"--"];
            [death_month selectItemWithTitle: @"---"];
            [death_year setStringValue:
              [[NSNumber numberWithInt: [death_date yearOfCommonEra]] stringValue]];
          }
        }
      }
    }
    else
    {
      [death_day selectItemWithTitle: @"--"];
      [death_month selectItemWithTitle: @"---"];
      [death_year setStringValue: @""];
    }

    if( [[field subfieldWithType: @"DEAT"] subfieldWithType: @"PLAC"] )
      [death_place setStringValue: [[field subfieldWithType: @"DEAT"] valueOfSubfieldWithType: @"PLAC"]];
        
    if( [field subfieldWithType: @"FAMC"] )
    {
      if( [[field father: my_ged] fullName] )
        [father_text setStringValue: [[field father: my_ged] fullName]];
      if( [[field mother: my_ged] fullName] )
        [mother_text setStringValue: [[field mother: my_ged] fullName]];
    }
  }
}

// extract all the stuff from the dialog and adjust our data accordingly
- (BOOL) process
{
  NSMutableString* indi_label = [[NSMutableString alloc] init];
  NSMutableString* famc_label = [[NSMutableString alloc] init];
  NSMutableString* birth_str  = [[NSMutableString alloc] init];
  NSMutableString* death_str  = [[NSMutableString alloc] init];
  NSMutableString* tmp = [[NSMutableString alloc] init];
  INDI* added;
  GCField* gc_tmp;
  GCField* famc = nil;
  INDI* father = nil; 
  INDI* mother = nil;
  NSMutableArray* famc_array;
  NSArray* children_array;
  NSDate* birth_date = nil;
  NSDate* death_date = nil;
  NSDate* father_birth_date = nil;
  NSDate* mother_birth_date = nil;
  NSDate* father_death_date = nil;
  NSDate* mother_death_date = nil;
  NSDate* child_birth_date = nil;
  NSDate* child_death_date = nil;
  int i = 0;
  
  // just in case we have to create any new records. we can ensure giving them
  // unique identifiers by using epoch time
  // (the number of seconds since midnight on 01 JAN 1970)
  [indi_label setString: @"@INDI_"];
  [indi_label appendString:
               [[NSNumber numberWithDouble: floor( [[NSDate date] timeIntervalSince1970] )]
               stringValue]];
  [indi_label appendString: @"@"];
  [famc_label setString: @"@FAM_"];
  [famc_label appendString:
               [[NSNumber numberWithDouble: floor( [[NSDate date] timeIntervalSince1970] )]
               stringValue]];
  [famc_label appendString: @"@"];
  
  // if we're editing an existing record, get it
  // otherwise make a new INDI record
  if( field )
    added = field;
  else
    added = [[INDI alloc] init: 0 : @"INDI" : indi_label];
//    added = [ged addRecord: @"INDI": indi_label];
    
  [added setNeedSave: true];


//
// BEGIN SANITY CHECKING
//

  // force the selection of a sex
  if( ! [sex_matrix selectedCell] )
  {
    NSRunAlertPanel( @"Error", 
      @"Please indicate a gender for this person.",
      @"Ok", nil, nil );
    return false;
  }

  // make sure the death date is later than the birth date
  [birth_str setString: @""];
  if( ! [[birth_day titleOfSelectedItem] isEqual: @"--"] )
  {
    [birth_str setString: [birth_day titleOfSelectedItem]];
  }
  if( ! [[birth_month titleOfSelectedItem] isEqual: @"---"] )
  {
    [birth_str appendString: @" "];
    [birth_str appendString: [birth_month titleOfSelectedItem]];
  }
  if( ![[birth_year stringValue] isEqual: @""] )
  {
    [birth_str appendString: @" "];
    [birth_str appendString: [birth_year stringValue]];
  }

  [death_str setString: @""];
  if( ! [[death_day titleOfSelectedItem] isEqual: @"--"] )
  {
    [death_str setString: [death_day titleOfSelectedItem]];
  }
  if( ! [[death_month titleOfSelectedItem] isEqual: @"---"] )
  {
    [death_str appendString: @" "];
    [death_str appendString: [death_month titleOfSelectedItem]];
  }
  if( ![[death_year stringValue] isEqual: @""] )
  {
    [death_str appendString: @" "];
    [death_str appendString: [death_year stringValue]];
  }

  birth_date = [[GenXUtil sharedUtil] dateFromGEDCOM: birth_str];
  death_date = [[GenXUtil sharedUtil] dateFromGEDCOM: death_str];
//  NSLog( [birth_date description] );
//  NSLog( [death_date description] );
  
  if( [birth_date compare: death_date] == NSOrderedDescending )
  {
    NSRunAlertPanel( @"Error", 
      @"Please check the dates you enetered.\nA person cannot die before they were born.",
      @"Ok", nil, nil );
    return false;
  }

  // if neither of the parent fields has been altered
  // check against their dates
  if( ( ![[father_text stringValue] isEqual: @""]
        && ![[mother_text stringValue] isEqual: @""] )
    && ( [[father_text stringValue] isEqual: [[field father: ged] fullName]]
        && [[mother_text stringValue] isEqual: [[field mother: ged] fullName]] ) )
  {
    gc_tmp = [ged recordWithLabel: [added valueOfSubfieldWithType: @"FAMC"]];
    father_birth_date = [[(FAM*)gc_tmp husband: ged] birthDate];
    mother_birth_date = [[(FAM*)gc_tmp wife: ged] birthDate];
    father_death_date = [[(FAM*)gc_tmp husband: ged] deathDate];
    // add a year to the father's death date since technically a person
    // can be born up to 9 months after their father dies. a year gives 3 months buffer
    father_death_date = [father_death_date addTimeInterval: 31536000];
    mother_death_date = [[(FAM*)gc_tmp wife: ged] deathDate];
    if( [birth_date compare: father_birth_date] == NSOrderedAscending
      || [birth_date compare: mother_birth_date] == NSOrderedAscending )
    {
      NSRunAlertPanel( @"Error",
        @"Please check the birth date for this person.\nIt is earlier than one of the parents' birth dates.",
        @"Ok", nil, nil );
      return false;
    }
    else if( [birth_date compare: father_death_date] == NSOrderedDescending
      || [birth_date compare: mother_death_date] == NSOrderedDescending )
    {
      NSRunAlertPanel( @"Error",
        @"Please check the birth date for this person.\nIt is later than one of the parents' death dates.",
        @"Ok", nil, nil );
      return false;
    }
    else if( [death_date compare: father_birth_date] == NSOrderedAscending
      || [death_date compare: mother_birth_date] == NSOrderedAscending )
    {
      NSRunAlertPanel( @"Error",
        @"Please check the death date for this person.\nIt is earlier than one of the parents' birth dates.",
        @"Ok", nil, nil );
      return false;
    }
  }
  // single father case
  else if( ( ![[father_text stringValue] isEqual: @""]
        && [[mother_text stringValue] isEqual: @""] )
    && [[father_text stringValue] isEqual: [[field father: ged] fullName]] )
  {
    gc_tmp = [ged recordWithLabel: [added valueOfSubfieldWithType: @"FAMC"]];
    father_birth_date = [[(FAM*)gc_tmp husband: ged] birthDate];
    father_death_date = [[(FAM*)gc_tmp husband: ged] deathDate];
    // add a year to the father's death date since technically a person
    // can be born up to 9 months after their father dies. a year gives 3 months buffer
    father_death_date = [father_death_date addTimeInterval: 31536000];
    if( [birth_date compare: father_birth_date] == NSOrderedAscending )
    {
      NSRunAlertPanel( @"Error",
        @"Please check the birth date for this person.\nIt is earlier than the father's birth date.",
        @"Ok", nil, nil );
      return false;
    }
    else if( [birth_date compare: father_death_date] == NSOrderedDescending )
    {
      NSRunAlertPanel( @"Error",
        @"Please check the birth date for this person.\nIt is later than the father's death date.",
        @"Ok", nil, nil );
      return false;
    }
    else if( [death_date compare: father_birth_date] == NSOrderedAscending )
    {
      NSRunAlertPanel( @"Error",
        @"Please check the death date for this person.\nIt is earlier than the father's birth date.",
        @"Ok", nil, nil );
      return false;
    }
  }
  // single mother case
  else if( ( [[father_text stringValue] isEqual: @""]
        && ![[mother_text stringValue] isEqual: @""] )
    && [[mother_text stringValue] isEqual: [[field mother: ged] fullName]] )
  {
    gc_tmp = [ged recordWithLabel: [added valueOfSubfieldWithType: @"FAMC"]];
    mother_birth_date = [[(FAM*)gc_tmp wife: ged] birthDate];
    mother_death_date = [[(FAM*)gc_tmp wife: ged] deathDate];
    if( [birth_date compare: mother_birth_date] == NSOrderedAscending )
    {
      NSRunAlertPanel( @"Error",
        @"Please check the birth date for this person.\nIt is earlier than the mother's birth date.",
        @"Ok", nil, nil );
      return false;
    }
    else if( [birth_date compare: mother_death_date] == NSOrderedDescending )
    {
      NSRunAlertPanel( @"Error",
        @"Please check the birth date for this person.\nIt is later than the mother's death date.",
        @"Ok", nil, nil );
      return false;
    }
    else if( [death_date compare: mother_birth_date] == NSOrderedAscending )
    {
      NSRunAlertPanel( @"Error",
        @"Please check the death date for this person.\nIt is earlier than the mother's birth date.",
        @"Ok", nil, nil );
      return false;
    }
  }
  
  //
  // check against dates of any children this person has
  //
  children_array = [added INDIChildren: ged];
  for( i = 0; i < [children_array count]; i++ )
  {
    child_birth_date = [[children_array objectAtIndex: i] birthDate];
    child_death_date = [[children_array objectAtIndex: i] deathDate];

    if( [birth_date compare: child_birth_date] == NSOrderedDescending )
    {
      NSRunAlertPanel( @"Error",
        @"Please check the birth date for this person.\nIt is later than one of its children's birth dates.",
        @"Ok", nil, nil );
      return false;
    }
    else if( [birth_date compare: child_death_date] == NSOrderedDescending )
    {
      NSRunAlertPanel( @"Error",
        @"Please check the birth date for this person.\nIt is later than one of its children's death dates.",
        @"Ok", nil, nil );
      return false;
    }
    else if( [death_date compare: child_birth_date] == NSOrderedAscending )
    {
      NSRunAlertPanel( @"Error",
        @"Please check the death date for this person.\nIt is earlier than one of its children's birth dates.",
        @"Ok", nil, nil );
      return false;
    }
  }

//
// END SANITY CHECKING
//

  //
  // FAMC
  //

  // if either of the fields has been altered
  // see if we can find a matching FAM record
  if( ( ![[father_text stringValue] isEqual: @""]
        || ![[mother_text stringValue] isEqual: @""] )
    && ! ( [[father_text stringValue] isEqual: [[field father: ged] fullName]]
        && [[mother_text stringValue] isEqual: [[field mother: ged] fullName]] ) )
    famc_array = [ged famsWithFather: [father_text stringValue] Mother: [mother_text stringValue]];

  // if the fields are both filled in and are not the parents
  // already asigned to this person
  if( ( ![[father_text stringValue] isEqual: @""]
        && ![[mother_text stringValue] isEqual: @""] )
      && ! ( [[father_text stringValue] isEqual: [[field father: ged] fullName]]
        && [[mother_text stringValue] isEqual: [[field mother: ged] fullName]] ) )
  {
    // if we didn't find a matching FAM record, maybe we can
    // find the INDI records and make a new FAM record for them
    if( [famc_array count] == 0 )
    {
      NSMutableArray* tmp_array = [ged indisWithNameContaining: [father_text stringValue]];
      NSMutableArray* father_array = [[NSMutableArray alloc] init];
      NSMutableArray* mother_array = [[NSMutableArray alloc] init];

//DEBUG
// NSLog( @"EditIndiController::process Coundn't find a matching FAM record." ); 
      
      for( i = 0; i < [tmp_array count]; i++ )
        if( ![[tmp_array objectAtIndex: i] valueOfSubfieldWithType: @"SEX"]
         || [[[tmp_array objectAtIndex: i] valueOfSubfieldWithType: @"SEX"] isEqual: @"M"] )
          [father_array addObject: [tmp_array objectAtIndex: i]];
          
      tmp_array = [ged indisWithNameContaining: [mother_text stringValue]];
      for( i = 0; i < [tmp_array count]; i++ )
        if( ![[tmp_array objectAtIndex: i] valueOfSubfieldWithType: @"SEX"]
         || [[[tmp_array objectAtIndex: i] valueOfSubfieldWithType: @"SEX"] isEqual: @"F"] )
          [mother_array addObject: [tmp_array objectAtIndex: i]];


      // if we found a mother
      if( [mother_array count] == 1 )
        mother = [mother_array objectAtIndex: 0];
      // if we found more than one possible mother, ask for help
      if( [mother_array count] > 1 )
      {
        [[ChooseFieldController sharedChooser] setHeaderString: @"Found these possible mothers:"];
        [[ChooseFieldController sharedChooser] setFields: mother_array: ged];
        [NSApp runModalForWindow: [[ChooseFieldController sharedChooser] window]];
        mother = [[ChooseFieldController sharedChooser] result];
      }
      
      // if we found a father
      if( [father_array count] == 1 )
        father = [father_array objectAtIndex: 0];
      // if we found more than one possible father, ask for help
      if( [father_array count] > 1 )
      {
        [[ChooseFieldController sharedChooser] setHeaderString: @"Found these possible fathers:"];
        [[ChooseFieldController sharedChooser] setFields: father_array: ged];
        [NSApp runModalForWindow: [[ChooseFieldController sharedChooser] window]];
        father = [[ChooseFieldController sharedChooser] result];
      }
      
      // if we found matching INDI records
      if( father && mother )
      {
        father_birth_date = [father birthDate];
        mother_birth_date = [mother birthDate];
        father_death_date = [father deathDate];
        // add a year to the father's death date since technically a person
        // can be born up to 9 months after their father dies. a year gives 3 months buffer
        father_death_date = [father_death_date addTimeInterval: 31536000];
       mother_death_date = [mother deathDate];
        if( [birth_date compare: father_birth_date] == NSOrderedAscending
         || [birth_date compare: mother_birth_date] == NSOrderedAscending )
        {
          //[new_indi_window orderOut: self];
          NSRunAlertPanel( @"Error",
          @"Please check the parents you enetered. According to you one of them was born after their child was born.",
            @"Ok", nil, nil );
          return false;
        }
        else if( [birth_date compare: father_death_date] == NSOrderedDescending
         || [birth_date compare: mother_death_date] == NSOrderedDescending )
        {
          //[new_indi_window orderOut: self];
          NSRunAlertPanel( @"Error",
          @"Please check the parents you entered. According to you one of them died before their child was born.",
            @"Ok", nil, nil );
          return false;
        }
        else if( [death_date compare: father_birth_date] == NSOrderedAscending
         || [death_date compare: mother_birth_date] == NSOrderedAscending )
        {
          //[new_indi_window orderOut: self];
          NSRunAlertPanel( @"Error",
          @"Please check the parents you enetered. According to you one of them was born after their child died.",
            @"Ok", nil, nil );
          return false;
        }
        else
        {
//DEBUG
// NSLog( @"EditIndiController::process Found INDIs...building new FAM." ); 
          famc = [ged addRecord: @"FAM": famc_label];
          [famc setNeedSave: true];
          [famc addSubfield: @"HUSB": [father fieldValue]];
          [famc addSubfield: @"WIFE": [mother fieldValue]];
          
          [father addSubfield: @"FAMS": [famc fieldValue]];
          [mother addSubfield: @"FAMS": [famc fieldValue]];
        }
      }
      else
      {
        //[new_indi_window orderOut: self];
        NSRunAlertPanel( @"Error",
          @"Please check the parents you entered.\nI couldn't find their records.",
          @"Ok", nil, nil );
        return false;
      }
    }
    else if ( [famc_array count] > 1 )
    {
//DEBUG
// NSLog( @"EditIndiController::process Found multiple matching FAM records." );

      [[ChooseFieldController sharedChooser] setHeaderString: @"Found these possible parents:"];
      [[ChooseFieldController sharedChooser] setFields: famc_array: ged];
      [NSApp runModalForWindow: [[ChooseFieldController sharedChooser] window]];
      gc_tmp = [[ChooseFieldController sharedChooser] result];

      father_birth_date = [[(FAM*)gc_tmp husband: ged] birthDate];
      mother_birth_date = [[(FAM*)gc_tmp wife: ged] birthDate];
      father_death_date = [[(FAM*)gc_tmp husband: ged] deathDate];
      // add a year to the father's death date since technically a person
      // can be born up to 9 months after their father dies. a year gives 3 months buffer
      father_death_date = [father_death_date addTimeInterval: 31536000];
      mother_death_date = [[(FAM*)gc_tmp wife: ged] deathDate];
      if( [birth_date compare: father_birth_date] == NSOrderedAscending
        || [birth_date compare: mother_birth_date] == NSOrderedAscending )
      {
        //[new_indi_window orderOut: self];
        NSRunAlertPanel( @"Error",
          @"Please check the parents you enetered. According to you one of them was born after their child was born.",
          @"Ok", nil, nil );
        return false;
      }
      else if( [birth_date compare: father_death_date] == NSOrderedDescending
        || [birth_date compare: mother_death_date] == NSOrderedDescending )
      {
        //[new_indi_window orderOut: self];
        NSRunAlertPanel( @"Error",
          @"Please check the parents you entered. According to you one of them died before their child was born.",
          @"Ok", nil, nil );
        return false;
      }
      else if( [death_date compare: father_birth_date] == NSOrderedAscending
        || [death_date compare: mother_birth_date] == NSOrderedAscending )
      {
        //[new_indi_window orderOut: self];
        NSRunAlertPanel( @"Error",
          @"Please check the parents you enetered. According to you one of them was born after their child died.",
          @"Ok", nil, nil );
        return false;
      }
      else
        famc = gc_tmp;
    }
    else
    {
//DEBUG
// NSLog( @"EditIndiController::process Found one set of matching parents. Proceeding." );
      gc_tmp = [famc_array objectAtIndex: 0];

      father_birth_date = [[(FAM*)gc_tmp husband: ged] birthDate];
      mother_birth_date = [[(FAM*)gc_tmp wife: ged] birthDate];
      father_death_date = [[(FAM*)gc_tmp husband: ged] deathDate];
      // add a year to the father's death date since technically a person
      // can be born up to 9 months after their father dies. a year gives 3 months buffer
      father_death_date = [father_death_date addTimeInterval: 31536000];
      mother_death_date = [[(FAM*)gc_tmp wife: ged] deathDate];
      if( [birth_date compare: father_birth_date] == NSOrderedAscending
        || [birth_date compare: mother_birth_date] == NSOrderedAscending )
      {
        //[new_indi_window orderOut: self];
        NSRunAlertPanel( @"Error",
          @"Please check the parents you enetered. According to you one of them was born after their child was born.",
          @"Ok", nil, nil );
        return false;
      }
      else if( [birth_date compare: father_death_date] == NSOrderedDescending
        || [birth_date compare: mother_death_date] == NSOrderedDescending )
      {
        //[new_indi_window orderOut: self];
        NSRunAlertPanel( @"Error",
          @"Please check the parents you entered. According to you one of them died before their child was born.",
          @"Ok", nil, nil );
        return false;
      }
      else if( [death_date compare: father_birth_date] == NSOrderedAscending
        || [death_date compare: mother_birth_date] == NSOrderedAscending )
      {
        //[new_indi_window orderOut: self];
        NSRunAlertPanel( @"Error",
          @"Please check the parents you enetered. According to you one of them was born after their child died.",
          @"Ok", nil, nil );
        return false;
      }
      else
        famc = gc_tmp;
    }
  }
  // if only the father field was filled in
  else if( ![[father_text stringValue] isEqual: @""] && [[mother_text stringValue] isEqual: @""] )
  {
    NSMutableArray* tmp_array = [ged indisWithNameContaining: [father_text stringValue]];
    NSMutableArray* father_array = [[NSMutableArray alloc] init];
    
    for( i = 0; i < [tmp_array count]; i++ )
      if( ![[tmp_array objectAtIndex: i] valueOfSubfieldWithType: @"SEX"]
       || [[[tmp_array objectAtIndex: i] valueOfSubfieldWithType: @"SEX"] isEqual: @"M"] )
        [father_array addObject: [tmp_array objectAtIndex: i]];
    
    // if we found a FAM with this father, but no WIFE
    if( [famc_array count] == 1 )
    {
//DEBUG
// NSLog( @"EditIndiController::process Found a FAMC for person with only a father" );
      gc_tmp = [famc_array objectAtIndex: 0];

      father_birth_date = [[(FAM*)gc_tmp husband: ged] birthDate];
      father_death_date = [[(FAM*)gc_tmp husband: ged] deathDate];
      // add a year to the father's death date since technically a person
      // can be born up to 9 months after their father dies. a year gives 3 months buffer
      father_death_date = [father_death_date addTimeInterval: 31536000];
      if( [birth_date compare: father_birth_date] == NSOrderedAscending )
      {
        //[new_indi_window orderOut: self];
        NSRunAlertPanel( @"Error",
          @"Please check the father you enetered. According to you he was born after his child was born.",
          @"Ok", nil, nil );
        return false;
      }
      else if( [birth_date compare: father_death_date] == NSOrderedDescending )
      {
        //[new_indi_window orderOut: self];
        NSRunAlertPanel( @"Error",
          @"Please check the father you entered. According to you he died more than a year before his child was born.",
          @"Ok", nil, nil );
        return false;
      }
      else if( [death_date compare: father_birth_date] == NSOrderedAscending )
      {
        //[new_indi_window orderOut: self];
        NSRunAlertPanel( @"Error",
          @"Please check the father you enetered. According to you he was born after his child died.",
          @"Ok", nil, nil );
        return false;
      }
      else
        famc = gc_tmp;
/*
      [famc setNeedSave: true];
      [added addSubfield: @"FAMC": [famc fieldValue]];

      // add this person as a CHIL to his FAMC
      gc_tmp = [famc addSubfield: @"CHIL": [added fieldValue]];
*/
    }
    else if ( [famc_array count] > 1 )
    {
//DEBUG
// NSLog( @"EditIndiController::process Found multiple matching single fathers." );

      [[ChooseFieldController sharedChooser] setHeaderString: @"Found these possible parents:"];
      [[ChooseFieldController sharedChooser] setFields: famc_array: ged];
      [NSApp runModalForWindow: [[ChooseFieldController sharedChooser] window]];
      gc_tmp = [[ChooseFieldController sharedChooser] result];
      
      father_birth_date = [[(FAM*)gc_tmp husband: ged] birthDate];
      father_death_date = [[(FAM*)gc_tmp husband: ged] deathDate];
      // add a year to the father's death date since technically a person
      // can be born up to 9 months after their father dies. a year gives 3 months buffer
      father_death_date = [father_death_date addTimeInterval: 31536000];
      if( [birth_date compare: father_birth_date] == NSOrderedAscending )
      {
        //[new_indi_window orderOut: self];
        NSRunAlertPanel( @"Error",
          @"Please check the father you enetered. According to you he was born after his child was born.",
          @"Ok", nil, nil );
        return false;
      }
      else if( [birth_date compare: father_death_date] == NSOrderedDescending )
      {
        //[new_indi_window orderOut: self];
        NSRunAlertPanel( @"Error",
          @"Please check the father you entered. According to you he died more than a year before his child was born.",
          @"Ok", nil, nil );
        return false;
      }
      else if( [death_date compare: father_birth_date] == NSOrderedAscending )
      {
        //[new_indi_window orderOut: self];
        NSRunAlertPanel( @"Error",
          @"Please check the father you enetered. According to you he was born after his child died.",
          @"Ok", nil, nil );
        return false;
      }
      else
        famc = gc_tmp;
    }
    // otherwise, if we can find the father's record, set up a new FAM record
    // with him as HUSB, but no WIFE
    else if( [father_array count] == 1 ) //&& [[[father_array objectAtIndex: 0] sex] isEqual: @"M"] )
    {
      father = [father_array objectAtIndex: 0];
      father_birth_date = [father birthDate];
      father_death_date = [father deathDate];
      // add a year to the father's death date since technically a person
      // can be born up to 9 months after their father dies. a year gives 3 months buffer
      father_death_date = [father_death_date addTimeInterval: 31536000];
      if( [birth_date compare: father_birth_date] == NSOrderedAscending )
      {
        //[new_indi_window orderOut: self];
        NSRunAlertPanel( @"Error",
          @"Please check the father you enetered. According to you he was born after his child was born.",
          @"Ok", nil, nil );
        return false;
      }
      else if( [birth_date compare: father_death_date] == NSOrderedDescending )
      {
        //[new_indi_window orderOut: self];
        NSRunAlertPanel( @"Error",
          @"Please check the father you entered. According to you he died more than a year before his child was born.",
          @"Ok", nil, nil );
        return false;
      }
      else if( [death_date compare: father_birth_date] == NSOrderedAscending )
      {
        //[new_indi_window orderOut: self];
        NSRunAlertPanel( @"Error",
          @"Please check the father you enetered. According to you he was born after his child died.",
          @"Ok", nil, nil );
        return false;
      }
      else
      {
//DEBUG
// NSLog( @"EditIndiController::process Adding FAMC for person with only a father" );
        famc = [ged addRecord: @"FAM": famc_label];
        [famc setNeedSave: true];
        [famc addSubfield: @"HUSB": [[father_array objectAtIndex: 0] fieldValue]];
        gc_tmp = [[father_array objectAtIndex: 0] addSubfield: @"FAMS": famc_label];
        [gc_tmp setNeedSave: true];
      }
    }
    else if( [father_array count] > 1 ) //&& [[[father_array objectAtIndex: 0] sex] isEqual: @"M"] )
    {
      [[ChooseFieldController sharedChooser] setHeaderString: @"Found these possible fathers:"];
      [[ChooseFieldController sharedChooser] setFields: father_array: ged];
      [NSApp runModalForWindow: [[ChooseFieldController sharedChooser] window]];
      father = [[ChooseFieldController sharedChooser] result];

      father_birth_date = [father birthDate];
      father_death_date = [father deathDate];
      // add a year to the father's death date since technically a person
      // can be born up to 9 months after their father dies. a year gives 3 months buffer
      father_death_date = [father_death_date addTimeInterval: 31536000];
      if( [birth_date compare: father_birth_date] == NSOrderedAscending )
      {
        //[new_indi_window orderOut: self];
        NSRunAlertPanel( @"Error",
          @"Please check the father you enetered. According to you he was born after his child was born.",
          @"Ok", nil, nil );
        return false;
      }
      else if( [birth_date compare: father_death_date] == NSOrderedDescending )
      {
        //[new_indi_window orderOut: self];
        NSRunAlertPanel( @"Error",
          @"Please check the father you entered. According to you he died more than a year before his child was born.",
          @"Ok", nil, nil );
        return false;
      }
      else if( [death_date compare: father_birth_date] == NSOrderedAscending )
      {
        //[new_indi_window orderOut: self];
        NSRunAlertPanel( @"Error",
          @"Please check the father you enetered. According to you he was born after his child died.",
          @"Ok", nil, nil );
        return false;
      }
      else
      {
//DEBUG
// NSLog( @"EditIndiController::process Adding FAMC for person with only a father" );
        famc = [ged addRecord: @"FAM": famc_label];
        [famc setNeedSave: true];
        [famc addSubfield: @"HUSB": [father fieldValue]];
        gc_tmp = [father addSubfield: @"FAMS": famc_label];
        [gc_tmp setNeedSave: true];
      }
    }
    else
    {
//DEBUG
// NSLog( @"EditIndiController::process Only father specified, but errors encountered finding him." );
      //[new_indi_window orderOut: self];
      NSRunAlertPanel( @"Error", 
        @"Please check the father you entered.\nI couldn't find his record.",
        @"Ok", nil, nil );
        return false;
    }
  }
  // if only the mother field was filled in
  else if( ![[mother_text stringValue] isEqual: @""] && [[father_text stringValue] isEqual: @""] )
  {
    NSMutableArray* tmp_array = [ged indisWithNameContaining: [mother_text stringValue]];
    NSMutableArray* mother_array = [[NSMutableArray alloc] init];
    
    for( i = 0; i < [tmp_array count]; i++ )
      if( ![[tmp_array objectAtIndex: i] valueOfSubfieldWithType: @"SEX"]
       || [[[tmp_array objectAtIndex: i] valueOfSubfieldWithType: @"SEX"] isEqual: @"F"] )
        [mother_array addObject: [tmp_array objectAtIndex: i]];

    // if there's already a FAM record with the mother but no HUSB
    if( [famc_array count] == 1 )
    {
//DEBUG
// NSLog( @"EditIndiController::process Found a FAMC for person with only a mother" );
      gc_tmp = [famc_array objectAtIndex: 0];
      mother_birth_date = [[(FAM*)gc_tmp wife: ged] birthDate];
      mother_death_date = [[(FAM*)gc_tmp wife: ged] deathDate];
      if( [birth_date compare: mother_birth_date] == NSOrderedAscending )
      {
        //[new_indi_window orderOut: self];
        NSRunAlertPanel( @"Error",
          @"Please check the mother you enetered. According to you she was born after her child was born.",
          @"Ok", nil, nil );
        return false;
      }
      else if( [birth_date compare: mother_death_date] == NSOrderedDescending )
      {
        //[new_indi_window orderOut: self];
        NSRunAlertPanel( @"Error",
          @"Please check the mother you entered. According to you she died before her child was born.",
          @"Ok", nil, nil );
        return false;
      }
      else if( [death_date compare: mother_birth_date] == NSOrderedAscending )
      {
        //[new_indi_window orderOut: self];
        NSRunAlertPanel( @"Error",
          @"Please check the mother you enetered. According to you she was born after her child died.",
          @"Ok", nil, nil );
        return false;
      }
      else
        famc = gc_tmp;
    }
    else if ( [famc_array count] > 1 )
    {
//DEBUG
// NSLog( @"EditIndiController::process Found multiple matching single fathers." );

      [[ChooseFieldController sharedChooser] setHeaderString: @"Found these possible parents:"];
      [[ChooseFieldController sharedChooser] setFields: famc_array: ged];
      [NSApp runModalForWindow: [[ChooseFieldController sharedChooser] window]];
      gc_tmp = [[ChooseFieldController sharedChooser] result];

      mother_birth_date = [[(FAM*)gc_tmp wife: ged] birthDate];
      mother_death_date = [[(FAM*)gc_tmp wife: ged] deathDate];
      if( [birth_date compare: mother_birth_date] == NSOrderedAscending )
      {
        //[new_indi_window orderOut: self];
        NSRunAlertPanel( @"Error",
          @"Please check the mother you enetered. According to you she was born after her child was born.",
          @"Ok", nil, nil );
        return false;
      }
      else if( [birth_date compare: mother_death_date] == NSOrderedDescending )
      {
        //[new_indi_window orderOut: self];
        NSRunAlertPanel( @"Error",
          @"Please check the mother you entered. According to you she died before her child was born.",
          @"Ok", nil, nil );
        return false;
      }
      else if( [death_date compare: mother_birth_date] == NSOrderedAscending )
      {
        //[new_indi_window orderOut: self];
        NSRunAlertPanel( @"Error",
          @"Please check the mother you enetered. According to you she was born after her child died.",
          @"Ok", nil, nil );
        return false;
      }
      else
        famc = gc_tmp;
    }
    // otherwise, if we can find the mother's record, set up a new FAM record
    // with her as WIFE, but no HUSB
    else if( [mother_array count] == 1 ) // && [[[mother_array objectAtIndex: 0] sex] isEqual: @"F"] )
    {
      mother = [mother_array objectAtIndex: 0];
      mother_birth_date = [mother birthDate];
      mother_death_date = [mother deathDate];
      if( [birth_date compare: mother_birth_date] == NSOrderedAscending )
      {
        //[new_indi_window orderOut: self];
        NSRunAlertPanel( @"Error",
          @"Please check the mother you enetered. According to you she was born after her child was born.",
          @"Ok", nil, nil );
        return false;
      }
      else if( [birth_date compare: mother_death_date] == NSOrderedDescending )
      {
        //[new_indi_window orderOut: self];
        NSRunAlertPanel( @"Error",
          @"Please check the mother you entered. According to you she died before her child was born.",
          @"Ok", nil, nil );
        return false;
      }
      else if( [death_date compare: mother_birth_date] == NSOrderedAscending )
      {
        //[new_indi_window orderOut: self];
        NSRunAlertPanel( @"Error",
          @"Please check the mother you enetered. According to you she was born after her child died.",
          @"Ok", nil, nil );
        return false;
      }
      else
      {
//DEBUG
// NSLog( @"EditIndiController::process Adding FAMC for person with only a mother" );
        famc = [ged addRecord: @"FAM": famc_label];
        // tag the record for saving later
        [famc setFieldValue: famc_label];
        [famc setNeedSave: true];
        gc_tmp = [[mother_array objectAtIndex: 0] addSubfield: @"FAMS": famc_label];
        // tag the record for saving later
        [gc_tmp setFieldValue: famc_label];
        [famc addSubfield: @"WIFE": [[mother_array objectAtIndex: 0] fieldValue]];
      }
    }
    else if( [mother_array count] > 1 ) //&& [[[father_array objectAtIndex: 0] sex] isEqual: @"M"] )
    {
      [[ChooseFieldController sharedChooser] setHeaderString: @"Found these possible fathers:"];
      [[ChooseFieldController sharedChooser] setFields: mother_array: ged];
      [NSApp runModalForWindow: [[ChooseFieldController sharedChooser] window]];
      mother = [[ChooseFieldController sharedChooser] result];

      mother_birth_date = [mother birthDate];
      mother_death_date = [mother deathDate];
      if( [birth_date compare: mother_birth_date] == NSOrderedAscending )
      {
        //[new_indi_window orderOut: self];
        NSRunAlertPanel( @"Error",
          @"Please check the mother you enetered. According to you she was born after her child was born.",
          @"Ok", nil, nil );
        return false;
      }
      else if( [birth_date compare: mother_death_date] == NSOrderedDescending )
      {
        //[new_indi_window orderOut: self];
        NSRunAlertPanel( @"Error",
          @"Please check the mother you entered. According to you she died before her child was born.",
          @"Ok", nil, nil );
        return false;
      }
      else if( [death_date compare: mother_birth_date] == NSOrderedAscending )
      {
        //[new_indi_window orderOut: self];
        NSRunAlertPanel( @"Error",
          @"Please check the mother you enetered. According to you she was born after her child died.",
          @"Ok", nil, nil );
        return false;
      }
      else
      {
//DEBUG
// NSLog( @"EditIndiController::process Adding FAMC for person with only a mother" );
        famc = [ged addRecord: @"FAM": famc_label];
        [famc setNeedSave: true];
        [famc addSubfield: @"WIFE": [mother fieldValue]];
        gc_tmp = [mother addSubfield: @"FAMS": famc_label];
        [gc_tmp setNeedSave: true];
      }
    }
    else
    {
//DEBUG
// NSLog( @"EditIndiController::process Only mother specified, but errors encountered finding her." );
      //[new_indi_window orderOut: self];
      NSRunAlertPanel( @"Error", 
        @"Please check the mother you enetered.\nI couldn't find her record.",
        @"Ok", nil, nil );
      return false;
    }
  }

//
// there's no going back from this point on
// we're about to start changing data
//
  
  if( famc )
  {
    GCField* old_famc;
    [famc setNeedSave: true];

    // if this person already has a FAMC tag
    // change it to the new value
    // and remove this person from the old FAMC as a CHIL
    if( gc_tmp = [added subfieldWithType: @"FAMC"] )
    {
      old_famc = [ged recordWithLabel: [gc_tmp fieldValue]];
      [[ged famWithLabel: [gc_tmp fieldValue]]
        removeSubfieldWithType: @"CHIL" Value: [added fieldValue]];
      [gc_tmp setFieldValue: [famc fieldValue]];
      
    }
    // otherwise, give this person a FAMC tag
    else
      [added addSubfield: @"FAMC": [famc fieldValue]];

    // add this person as a CHIL to his FAMC
    [famc addSubfield: @"CHIL": [added fieldValue]];

    // at this point,
    // it's pointless to keep the old FAM record around if it has
    // fewer than 2 links left in it.
    if( old_famc && [old_famc numSubfields] < 2 )
      [ged removeRecord: old_famc];
  }

  // NAME
  [tmp setString: [first_name stringValue]];
  [tmp appendString: @" /"];
  [tmp appendString: [last_name stringValue]];
  [tmp appendString: @"/"];
  if( ! ( gc_tmp = [added subfieldWithType: @"NAME"] ) )
    gc_tmp = [added addSubfield: @"NAME": [NSString stringWithString: tmp]];
  else
    [gc_tmp setFieldValue: [NSString stringWithString: tmp]]; 
  
  // if the user changed the field
  if( ![[first_name stringValue] isEqual: [field firstName]] )
  {
    // if the field doesn't exist, create it
    if( ! [gc_tmp subfieldWithType: @"GIVN"] )
      [gc_tmp addSubfield: @"GIVN": [first_name stringValue]];
    // if it exists and was changed to be blank, delete it
    else if( [[first_name stringValue] isEqual: @""] )
      [gc_tmp removeSubfieldWithType: @"GIVN" Value: [added firstName]];
    // otherwise just update the value
    else
      [[gc_tmp subfieldWithType: @"GIVN"] setFieldValue: [first_name stringValue]];
  }
    
  // if the user changed the field
  if( ![[last_name stringValue] isEqual: [field lastName]] )
  {
    // if the field doesn't exist, create it
    if( ! [gc_tmp subfieldWithType: @"SURN"] )
      [gc_tmp addSubfield: @"SURN": [last_name stringValue]];
    // if it exists and was changed to be blank, delete it
    else if( [[last_name stringValue] isEqual: @""] )
      [gc_tmp removeSubfieldWithType: @"SURN" Value: [added lastName]];
    // otherwise just update the value
    else
      [[gc_tmp subfieldWithType: @"SURN"] setFieldValue: [last_name stringValue]];
  }
    
  // if the user changed the field
  if( ![[name_suffix stringValue] isEqual: [field nameSuffix]] )
  {
    // if the field doesn't exist, create it
    if( ! [gc_tmp subfieldWithType: @"NSFX"] )
      [gc_tmp addSubfield: @"NSFX": [name_suffix stringValue]];
    // if it exists and was changed to be blank, delete it
    else if( [[name_suffix stringValue] isEqual: @""] )
      [gc_tmp removeSubfieldWithType: @"NSFX" Value: [added nameSuffix]];
    // otherwise just update the value
    else
      [[gc_tmp subfieldWithType: @"NSFX"] setFieldValue: [name_suffix stringValue]];
  }
  
  // SEX
  if( gc_tmp = [added subfieldWithType: @"SEX"] )
    [gc_tmp setFieldValue: [[sex_matrix selectedCell] title]];
  else
    [added addSubfield: @"SEX": [[sex_matrix selectedCell] title]];
  
  // BIRT
  if( gc_tmp = [[added subfieldWithType: @"BIRT"] subfieldWithType: @"DATE"] )
    [gc_tmp setFieldValue: [NSString stringWithString: birth_str]];
  else if( ![tmp isEqual: @""] && ( gc_tmp = [added subfieldWithType: @"BIRT"] ) )
    [gc_tmp addSubfield: @"DATE": [NSString stringWithString: birth_str]];
  else if( ![tmp isEqual: @""] )
  {
    gc_tmp = [added addSubfield: @"BIRT": @""];
    [gc_tmp addSubfield: @"DATE": [NSString stringWithString: birth_str]];
  }
  
  if( ! [[birth_place stringValue] isEqual: @""] )
  {
    if( ! [added subfieldWithType: @"BIRT"] )
      gc_tmp = [added addSubfield: @"BIRT": @""];
    else
      gc_tmp = [added subfieldWithType: @"BIRT"];
      
    if( gc_tmp = [gc_tmp subfieldWithType: @"PLAC"] )
      [gc_tmp setFieldValue: [birth_place stringValue]];
    else
      [[added subfieldWithType: @"BIRT"] addSubfield: @"PLAC": [birth_place stringValue]];
  }
      
  // DEAT
  if( gc_tmp = [[added subfieldWithType: @"DEAT"] subfieldWithType: @"DATE"] )
    [gc_tmp setFieldValue: [NSString stringWithString: death_str]];
  else if( ![tmp isEqual: @""] && ( gc_tmp = [added subfieldWithType: @"DEAT"] ) )
    [gc_tmp addSubfield: @"DATE": [NSString stringWithString: death_str]];
  else if( ![tmp isEqual: @""] )
  {
    gc_tmp = [added addSubfield: @"DEAT": @""];
    [gc_tmp addSubfield: @"DATE": [NSString stringWithString: death_str]];
  }
  
  if( ! [[death_place stringValue] isEqual: @""] )
  {
    if( ! [added subfieldWithType: @"DEAT"] )
      gc_tmp = [added addSubfield: @"DEAT": @""];
    else
      gc_tmp = [added subfieldWithType: @"DEAT"];
      
    if( gc_tmp = [gc_tmp subfieldWithType: @"PLAC"] )
      [gc_tmp setFieldValue: [death_place stringValue]];
    else
      [[added subfieldWithType: @"DEAT"] addSubfield: @"PLAC": [death_place stringValue]];
  }
  
  if( !field )
    [ged addRecord: added];
    
  return true;
}

- (void) handleOk: (id) sender
{
  if( [[EditIndiController sharedNewIndi] process] )
  {  
    [new_indi_window orderOut: self];
    [[NSApplication sharedApplication] endSheet: [[EditIndiController sharedNewIndi] window]];
  }
}

- (void) handleCancel: (id) sender
{
  [new_indi_window orderOut: self];
  [[NSApplication sharedApplication] endSheet: new_indi_window];
}

- (NSWindow*) window
{
  return new_indi_window;
}

@end
