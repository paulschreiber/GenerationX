#import "GenerationXController.h"
#import "EventWithFAMCController.h"
#import "ChooseFieldController.h"
#import "GCFile.h"
#import "GCField.h"
#import "FAM.h";
#import "GenXUtil.h";

@implementation EventWithFAMCController

+ (EventWithFAMCController*) sharedEvent
{
  static EventWithFAMCController* shared_event = nil;
  
  if( ! shared_event )
    shared_event = [[EventWithFAMCController alloc] initNib];
    
  return shared_event;
}

// load the nib
- (EventWithFAMCController*) initNib
{
  [NSBundle loadNibNamed: @"EventWithFAMC" owner:self];
  type = @"ADOP";
//  ged = [[GCFile alloc] init];
//  [header_text setBackgroundColor: [NSColor whiteColor]];
  
  return self;
}

// preload the dialog with data from the record being passed in
- (void) setField: (id) my_field: (id) my_indi: (id) my_ged
{
  NSString* tmp;
  GCField *date;
  FAM* famc;
  INDI* tmp_indi;
  
  field = my_field;
  ged = my_ged;
  type = [field fieldType];
  indi = my_indi;

  if( tmp = [[GenXUtil sharedUtil] eventStringFromGEDCOM: type] )
    [header_text setStringValue: tmp];
  else
    [header_text setStringValue: type];

  if( date = [field subfieldWithType: @"DATE"] )
  {
    NSCalendarDate* cal_date =
      [NSCalendarDate dateWithString: [date fieldValue]
      calendarFormat: @"%d %b %Y"];
    
    if( cal_date )
    {
      NSMutableString* day_str = [[NSMutableString alloc] init];
      NSNumber* day = [NSNumber numberWithInt: [cal_date dayOfMonth]];
      if( [day intValue] < 10 )
      {
        [day_str setString: @"0"];
        [day_str appendString: [day stringValue]];
      }
      else
        [day_str setString: [day stringValue]];
        
      [event_day selectItemWithTitle: day_str];
      [event_month selectItemAtIndex: [cal_date monthOfYear]];
      [event_year setStringValue:
        [[NSNumber numberWithInt: [cal_date yearOfCommonEra]] stringValue]];
    }
    else
    {
      cal_date = [NSCalendarDate dateWithString: [date fieldValue]
        calendarFormat: @"%b %Y"];

      if( cal_date )
      {
        [event_day selectItemWithTitle: @"--"];
        [event_month selectItemAtIndex: [cal_date monthOfYear]];
        [event_year setStringValue:
          [[NSNumber numberWithInt: [cal_date yearOfCommonEra]] stringValue]];
      }
      else
      {
        cal_date = [NSCalendarDate dateWithString: [date fieldValue]
          calendarFormat: @"%Y"];
          
        if( cal_date )
        {
          [event_day selectItemWithTitle: @"--"];
          [event_month selectItemWithTitle: @"---"];
          [event_year setStringValue:
            [[NSNumber numberWithInt: [cal_date yearOfCommonEra]] stringValue]];
        }
      }
    }
  }
  else
  {
    [event_day selectItemWithTitle: @"--"];
    [event_month selectItemWithTitle: @"---"];
    [event_year setStringValue: @""];
  }
  
  if( tmp = [field valueOfSubfieldWithType: @"PLAC"] )
    [event_place setStringValue: tmp];
  else
    [event_place setStringValue: @""];

  if( tmp = [field valueOfSubfieldWithType: @"NOTE"] )
    [note_text setStringValue: tmp];
  else
    [note_text setStringValue: @""];

  if( tmp = [field valueOfSubfieldWithType: @"SOUR"] )
    [source_text setStringValue: tmp];
  else
    [source_text setStringValue: @""];

  if( famc = [ged famWithLabel: [field valueOfSubfieldWithType: @"FAMC"]] )
  {
    if( tmp_indi = [famc husband: ged] )
      [father_text setStringValue: [tmp_indi fullName]];
    else
      [father_text setStringValue: @""];
      
    if( tmp_indi = [famc wife: ged] )
      [mother_text setStringValue: [tmp_indi fullName]];
    else
      [mother_text setStringValue: @""];
  }
  else
  {
    [father_text setStringValue: @""];
    [mother_text setStringValue: @""];
  }
}

// extract all the stuff from the dialog and adjust our data accordingly
- (void) process
{
  NSMutableString* tmp = [[NSMutableString alloc] initWithString: @""];
  NSMutableString* famc_label = [[NSMutableString alloc] init];
  GCField *gc_tmp, *famc = nil;
  NSMutableArray* famc_array;
  int i;
  GCField* mother, *father;
  
  [field setNeedSave: true];
  
  // DATE
  if( ! [[event_day titleOfSelectedItem] isEqual: @"--"] )
  {
    [tmp setString: [event_day titleOfSelectedItem]];
  }
  if( ! [[event_month titleOfSelectedItem] isEqual: @"---"] )
  {
    [tmp appendString: @" "];
    [tmp appendString: [event_month titleOfSelectedItem]];
  }
  if( ![[event_year stringValue] isEqual: @""] )
  {
    [tmp appendString: @" "];
    [tmp appendString: [event_year stringValue]];
  }
  
  if( ![tmp isEqual: @""] )
  {
    // add the date to the event
    if( !( gc_tmp = [field subfieldWithType: @"DATE"] ) )
      gc_tmp = [field addSubfield: @"DATE": @""];
      
    [gc_tmp setFieldValue: tmp];
  }

  // PLACE
  if( ! [[event_place stringValue] isEqual: @""] )
  {
    if( !( gc_tmp = [field subfieldWithType: @"PLAC"] ) )
      gc_tmp = [field addSubfield: @"PLAC": @""];

    [gc_tmp setFieldValue: [event_place stringValue]];
  }
      
  // NOTE
  if( ! [[note_text stringValue] isEqual: @""] )
  {
    if( !( gc_tmp = [field subfieldWithType: @"NOTE"] ) )
      gc_tmp = [field addSubfield: @"NOTE": @""];

    [gc_tmp setFieldValue: [note_text stringValue]];
  }
    
  // SOUR
  if( ! [[source_text stringValue] isEqual: @""] )
  {
    if( !( gc_tmp = [field subfieldWithType: @"SOUR"] ) )
      gc_tmp = [field addSubfield: @"SOUR": @""];

    [gc_tmp setFieldValue: [source_text stringValue]];
  }

  //
  // FAMC
  //

  // just in case we have to create any new records. we can ensure giving them
  // unique identifiers by using epoch time
  // (the number of seconds since midnight on 01 JAN 1970)
  [famc_label setString: @"@FAM_"];
  [famc_label appendString:
               [[NSNumber numberWithDouble: floor( [[NSDate date] timeIntervalSince1970] )]
               stringValue]];
  [famc_label appendString: @"@"];

  // if either of the fields has been altered
  // see if we can find a matching FAM record
  if( ( ![[father_text stringValue] isEqual: @""]
        || ![[mother_text stringValue] isEqual: @""] )
    && ! ( [[father_text stringValue] isEqual: [[indi father: ged] fullName]]
        && [[mother_text stringValue] isEqual: [[indi mother: ged] fullName]] ) )
    famc_array = [ged famsWithFather: [father_text stringValue] Mother: [mother_text stringValue]];

  // if the fields are both filled in and are not the parents
  // already asigned to this person
  if( ( ![[father_text stringValue] isEqual: @""]
        && ![[mother_text stringValue] isEqual: @""] )
      && ! ( [[father_text stringValue] isEqual: [[indi father: ged] fullName]]
        && [[mother_text stringValue] isEqual: [[indi mother: ged] fullName]] ) )
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
//DEBUG
// NSLog( @"EditIndiController::process Found INDIs...building new FAM." ); 
        famc = [ged addRecord: @"FAM": famc_label];
        [famc setNeedSave: true];
        [famc addSubfield: @"HUSB": [father fieldValue]];
        [famc addSubfield: @"WIFE": [mother fieldValue]];
        
        [father addSubfield: @"FAMS": [famc fieldValue]];
        [mother addSubfield: @"FAMS": [famc fieldValue]];
      }
      else
      {
        [event_window orderOut: self];
        NSRunAlertPanel( @"Error",
          @"Error encountered trying to find parent records. All other changes were successful.",
          @"Ok", nil, nil );
      }
    }
    else if ( [famc_array count] > 1 )
    {
//DEBUG
// NSLog( @"EditIndiController::process Found multiple matching FAM records." );

      [[ChooseFieldController sharedChooser] setHeaderString: @"Found these possible parents:"];
      [[ChooseFieldController sharedChooser] setFields: famc_array: ged];
      [NSApp runModalForWindow: [[ChooseFieldController sharedChooser] window]];
      famc = [[ChooseFieldController sharedChooser] result];
    }
    else
    {
//DEBUG
// NSLog( @"EditIndiController::process Found one set of matching parents. Proceeding." );
      famc = [famc_array objectAtIndex: 0];
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
      famc = [famc_array objectAtIndex: 0];
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
      famc = [[ChooseFieldController sharedChooser] result];
    }
    // otherwise, if we can find the father's record, set up a new FAM record
    // with him as HUSB, but no WIFE
    else if( [father_array count] == 1 ) //&& [[[father_array objectAtIndex: 0] sex] isEqual: @"M"] )
    {
//DEBUG
// NSLog( @"EditIndiController::process Adding FAMC for person with only a father" );
      famc = [ged addRecord: @"FAM": famc_label];
      [famc setNeedSave: true];
      [famc addSubfield: @"HUSB": [[father_array objectAtIndex: 0] fieldValue]];
      gc_tmp = [[father_array objectAtIndex: 0] addSubfield: @"FAMS": famc_label];
      [gc_tmp setNeedSave: true];
    }
    else if( [father_array count] > 1 ) //&& [[[father_array objectAtIndex: 0] sex] isEqual: @"M"] )
    {
      [[ChooseFieldController sharedChooser] setHeaderString: @"Found these possible fathers:"];
      [[ChooseFieldController sharedChooser] setFields: father_array: ged];
      [NSApp runModalForWindow: [[ChooseFieldController sharedChooser] window]];
      father = [[ChooseFieldController sharedChooser] result];
//DEBUG
// NSLog( @"EditIndiController::process Adding FAMC for person with only a father" );
      famc = [ged addRecord: @"FAM": famc_label];
      [famc setNeedSave: true];
      [famc addSubfield: @"HUSB": [father fieldValue]];
      gc_tmp = [father addSubfield: @"FAMS": famc_label];
      [gc_tmp setNeedSave: true];
    }
    else
    {
//DEBUG
// NSLog( @"EditIndiController::process Only father specified, but errors encountered finding him." );
      [event_window orderOut: self];
      NSRunAlertPanel( @"Error", 
        @"Errors encountered finding father record. All other changes were successful.",
        @"Ok", nil, nil );
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
      famc = [famc_array objectAtIndex: 0];
    }
    else if ( [famc_array count] > 1 )
    {
//DEBUG
// NSLog( @"EditIndiController::process Found multiple matching single fathers." );

      [[ChooseFieldController sharedChooser] setHeaderString: @"Found these possible parents:"];
      [[ChooseFieldController sharedChooser] setFields: famc_array: ged];
      [NSApp runModalForWindow: [[ChooseFieldController sharedChooser] window]];
      famc = [[ChooseFieldController sharedChooser] result];
    }
    // otherwise, if we can find the mother's record, set up a new FAM record
    // with her as WIFE, but no HUSB
    else if( [mother_array count] == 1 ) // && [[[mother_array objectAtIndex: 0] sex] isEqual: @"F"] )
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
    else if( [mother_array count] > 1 ) //&& [[[father_array objectAtIndex: 0] sex] isEqual: @"M"] )
    {
      [[ChooseFieldController sharedChooser] setHeaderString: @"Found these possible fathers:"];
      [[ChooseFieldController sharedChooser] setFields: mother_array: ged];
      [NSApp runModalForWindow: [[ChooseFieldController sharedChooser] window]];
      mother = [[ChooseFieldController sharedChooser] result];
//DEBUG
// NSLog( @"EditIndiController::process Adding FAMC for person with only a mother" );
      famc = [ged addRecord: @"FAM": famc_label];
      [famc setNeedSave: true];
      [famc addSubfield: @"WIFE": [mother fieldValue]];
      gc_tmp = [mother addSubfield: @"FAMS": famc_label];
      [gc_tmp setNeedSave: true];
    }
    else
    {
//DEBUG
// NSLog( @"EditIndiController::process Only mother specified, but errors encountered finding her." );
      [event_window orderOut: self];
      NSRunAlertPanel( @"Error", 
        @"Errors encountered finding mother record. All other changes were successful.",
        @"Ok", nil, nil );
    }
  }

  if( famc )
  {
    [famc setNeedSave: true];

    // if this person already has a FAMC tag
    // change it to the new value
    // and remove this person from the old FAMC as a CHIL
    if( gc_tmp = [field subfieldWithType: @"FAMC"] )
    {
      GCField* old_famc = [ged recordWithLabel: [gc_tmp fieldValue]];
      [[ged famWithLabel: [gc_tmp fieldValue]]
        removeSubfieldWithType: @"CHIL" Value: [indi fieldValue]];
      [gc_tmp setFieldValue: [famc fieldValue]];
      
      // now that we've removed the CHIL from the FAM record,
      // it's pointless to keep the FAM record around if it has
      // fewer than 2 links left in it.
      if( old_famc && [old_famc numSubfields] < 2 )
        [ged removeRecord: old_famc];
    }
    // otherwise, give this event a FAMC tag
    else
      [field addSubfield: @"FAMC": [famc fieldValue]];

    // add this person as a CHIL to his FAMC
    [famc addSubfield: @"CHIL": [indi fieldValue]];
  }
}

- (void) handleOk: (id) sender
{
  [[EventWithFAMCController sharedEvent] process];
  
  [event_window orderOut: self];
  [[NSApplication sharedApplication] endSheet: [[EventWithFAMCController sharedEvent] window]];
}

- (void) handleCancel: (id) sender
{
  [event_window orderOut: self];
  [[NSApplication sharedApplication] endSheet: event_window];
}

- (NSWindow*) window
{
  return event_window;
}

@end
