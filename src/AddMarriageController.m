#import "GenerationXController.h"
#import "AddMarriageController.h"
#import "ChooseFieldController.h"
#import "GCFile.h"
#import "GCField.h"
#import "FAM.h";

@implementation AddMarriageController

+ (AddMarriageController*) sharedAddMarr
{
  static AddMarriageController* shared_panel = nil;
  
  if( ! shared_panel )
    shared_panel = [[AddMarriageController alloc] initNib];
    
  return shared_panel;
}

// load the nib
- (AddMarriageController*) initNib
{
  [NSBundle loadNibNamed: @"AddMarriage" owner:self];
  ged = [[GCFile alloc] init];
  
  return self;
}

// preload the dialog with data from the record being passed in
- (void) prepForDisplay: (id) my_ged: (id) my_event: (id) my_indi
{
  NSString* tmp;
  GCField* date;
  ged = my_ged;
  indi = my_indi;
  event = [ged famWithLabel: [my_event fieldValue]];
  
  if( !indi )
  {
    // NSLog( @"AddMarriageContorller::prepForDisplay got a nil record" );
    return;
  }
    
  [spouse_text setStringValue: @""];
  [marr_place setStringValue: @""];
  [note_text setStringValue: @""];
  [source_text setStringValue: @""];
  
  if( event )
  {
    if( [[event husband: ged] isEqual: indi] 
     && ( tmp = [[event wife: ged] fullName] ) )
      [spouse_text setStringValue: tmp];
    else if( tmp = [[event husband: ged] fullName] )
      [spouse_text setStringValue: tmp];
    
    if( tmp = [[event subfieldWithType: @"MARR"] valueOfSubfieldWithType: @"PLAC"] )
      [marr_place setStringValue: tmp];
      
    if( tmp = [[event subfieldWithType: @"MARR"] valueOfSubfieldWithType: @"NOTE"] )
      [note_text setStringValue: tmp];
      
    if( tmp = [[event subfieldWithType: @"MARR"] valueOfSubfieldWithType: @"SOUR"] )
      [source_text setStringValue: tmp];
  }

  if( date = [[event subfieldWithType: @"MARR"] subfieldWithType: @"DATE"] )
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
        
      [marr_day selectItemWithTitle: day_str];
      [marr_month selectItemAtIndex: [cal_date monthOfYear]];
      [marr_year setStringValue:
        [[NSNumber numberWithInt: [cal_date yearOfCommonEra]] stringValue]];
    }
    else
    {
      cal_date = [NSCalendarDate dateWithString: [date fieldValue]
        calendarFormat: @"%b %Y"];

      if( cal_date )
      {
        [marr_day selectItemWithTitle: @"--"];
        [marr_month selectItemAtIndex: [cal_date monthOfYear]];
        [marr_year setStringValue:
          [[NSNumber numberWithInt: [cal_date yearOfCommonEra]] stringValue]];
      }
      else
      {
        cal_date = [NSCalendarDate dateWithString: [date fieldValue]
          calendarFormat: @"%Y"];
          
        if( cal_date )
        {
          [marr_day selectItemWithTitle: @"--"];
          [marr_month selectItemWithTitle: @"---"];
          [marr_year setStringValue:
            [[NSNumber numberWithInt: [cal_date yearOfCommonEra]] stringValue]];
        }
      }
    }
  }
  else
  {
    [marr_day selectItemWithTitle: @"--"];
    [marr_month selectItemWithTitle: @"---"];
    [marr_year setStringValue: @""];
  }
  
  tmp = @"New Marriage for ";
  tmp = [tmp stringByAppendingString: [indi fullName]];
  [header_text setStringValue: tmp];
}

// extract all the stuff from the dialog and adjust our data accordingly
- (void) process
{
  NSMutableString* fams_label = [[NSMutableString alloc] init];
  NSMutableString* tmp = [[NSMutableString alloc] init];
  GCField* gc_tmp;
  NSMutableArray* tmp_array;
  GCField* fams;
  INDI* spouse = nil;

  // just in case we have to create any new records. we can ensure giving them
  // unique identifiers by using epoch time
  // (the number of seconds since midnight on 01 JAN 1970)
  [fams_label setString: @"@FAM_"];
  [fams_label appendString:
               [[NSNumber numberWithDouble: floor( [[NSDate date] timeIntervalSince1970] )]
               stringValue]];
  [fams_label appendString: @"@"];
  
  //
  // do it
  //
  
  // SPOUSE
  [tmp setString: [spouse_text stringValue]];
  tmp_array = [ged indisWithNameContaining: tmp];

  if( [tmp_array count] == 0 )
  {
    // NSLog( @"Coundn't find specified spouse." );
    [add_marr_window orderOut: self];
    NSRunAlertPanel( @"Error",
                     @"I couldn't find a spouse matching your specification.\nYour marriage was not created",
                     @"Ok", nil, nil );
  }
  else if ( [tmp_array count] > 1 )
  {
// NSLog( @"Found multiple matching parents." );
    [[ChooseFieldController sharedChooser] setHeaderString: @"Found these possible spouses:"];
    [[ChooseFieldController sharedChooser] setFields: tmp_array: ged];
    [NSApp runModalForWindow: [[ChooseFieldController sharedChooser] window]];
    spouse = (INDI*)[[ChooseFieldController sharedChooser] result];
  }
  else
  {
    spouse = [tmp_array objectAtIndex: 0];
  }
  
  if( spouse )
  {
    // add FAMS links to the INDIs
    //
    // if event is nil, this is a new marriage
    if( !event )
    {
      gc_tmp = [indi addSubfield: @"FAMS": fams_label];
      [indi setNeedSave: true];
      gc_tmp = [spouse addSubfield: @"FAMS": fams_label];
      [spouse setNeedSave: true];
    }
    // if the spouse has changed
    // remove the link from the old spouse
    // and add it to the new one
    else if( [[spouse sex] isEqualToString: @"M"]
          && ! [[event husband: ged] isEqual: spouse] )
    {
      [[event husband: ged] removeSubfieldWithType: @"FAMS" Value: [event fieldValue]];
      gc_tmp = [spouse addSubfield: @"FAMS": [event fieldValue]];
      [spouse setNeedSave: true];
    }
    else if( [[spouse sex] isEqualToString: @"F"]
          && ! [[event wife: ged] isEqual: spouse] )
    {
      [[event wife: ged] removeSubfieldWithType: @"FAMS" Value: [event fieldValue]];
      gc_tmp = [spouse addSubfield: @"FAMS": [event fieldValue]];
      [spouse setNeedSave: true];
    }

    if( event )
      fams = event;
    else
      fams = [ged addRecord: @"FAM": fams_label];
    [fams setNeedSave: true];
    
    // add the HUSB and WIFE links
    if( [[indi sex] isEqual: @"M"] )
    {
      if( gc_tmp = [fams subfieldWithType: @"HUSB"] )
        [gc_tmp setFieldValue: [indi fieldValue]];
      else
        gc_tmp = [fams addSubfield: @"HUSB": [indi fieldValue]];
        
      if( gc_tmp = [fams subfieldWithType: @"WIFE"] )
        [gc_tmp setFieldValue: [spouse fieldValue]];
      else
        gc_tmp = [fams addSubfield: @"WIFE": [spouse fieldValue]];
    }
    else
    {
      if( gc_tmp = [fams subfieldWithType: @"WIFE"] )
        [gc_tmp setFieldValue: [indi fieldValue]];
      else
        gc_tmp = [fams addSubfield: @"WIFE": [indi fieldValue]];

      if( gc_tmp = [fams subfieldWithType: @"HUSB"] )
        [gc_tmp setFieldValue: [spouse fieldValue]];
      else
        gc_tmp = [fams addSubfield: @"HUSB": [spouse fieldValue]];
    }
    
    // this is important.
    // to speed filtering, FAM records can "remember" their
    // spouses without following the link to the INDI records
    // that "rememberance" needs to be reset when we change
    // the spouses
    [(FAM*)fams forget];
    
    // DATE
    [tmp setString: @""];
    if( ! [[marr_day titleOfSelectedItem] isEqual: @"--"] )
    {
      [tmp setString: [marr_day titleOfSelectedItem]];
    }
    if( ! [[marr_month titleOfSelectedItem] isEqual: @"---"] )
    {
      [tmp appendString: @" "];
      [tmp appendString: [marr_month titleOfSelectedItem]];
    }
    if( ![[marr_year stringValue] isEqual: @""] )
    {
      [tmp appendString: @" "];
      [tmp appendString: [marr_year stringValue]];
    }
        
    // add the date to the FAM
    if( ! ( gc_tmp = [fams subfieldWithType: @"MARR"] ) )
      gc_tmp = [fams addSubfield: @"MARR": @""];
      
    if( gc_tmp = [gc_tmp subfieldWithType: @"DATE"] )
      [gc_tmp setFieldValue: tmp];
    else if( ! [tmp isEqualToString: @""] )
      [[fams subfieldWithType: @"MARR"] addSubfield: @"DATE": tmp];
  
    // PLACE
    if( ! [[marr_place stringValue] isEqual: @""] )
    {
      if( ! ( gc_tmp = [fams subfieldWithType: @"MARR"] ) )
        gc_tmp = [fams addSubfield: @"MARR": @""];
        
      if( gc_tmp = [gc_tmp subfieldWithType: @"PLAC"] )
        [gc_tmp setFieldValue: [marr_place stringValue]];
      else
        [[fams subfieldWithType: @"MARR"] addSubfield: @"PLAC": [marr_place stringValue]];
    }

    // NOTE
    if( ! [[note_text stringValue] isEqual: @""] )
    {
      if( ! ( gc_tmp = [fams subfieldWithType: @"MARR"] ) )
        gc_tmp = [fams addSubfield: @"MARR": @""];
        
      if( gc_tmp = [gc_tmp subfieldWithType: @"NOTE"] )
        [gc_tmp setFieldValue: [note_text stringValue]];
      else
        [[fams subfieldWithType: @"MARR"] addSubfield: @"NOTE": [note_text stringValue]];
    }
      
    // SOUR
    if( ! [[source_text stringValue] isEqual: @""] )
    {
      if( ! ( gc_tmp = [fams subfieldWithType: @"MARR"] ) )
        gc_tmp = [fams addSubfield: @"MARR": @""];
        
      if( gc_tmp = [gc_tmp subfieldWithType: @"SOUR"] )
        [gc_tmp setFieldValue: [source_text stringValue]];
      else
        [[fams subfieldWithType: @"MARR"] addSubfield: @"SOUR": [source_text stringValue]];
    }
  }
}

- (void) handleOk: (id) sender
{
  [[AddMarriageController sharedAddMarr] process];
  
  [add_marr_window orderOut: self];
  [[NSApplication sharedApplication] endSheet: [[AddMarriageController sharedAddMarr] window]];
}

- (void) handleCancel: (id) sender
{
  [add_marr_window orderOut: self];
  [[NSApplication sharedApplication] endSheet: add_marr_window];
}

- (NSWindow*) window
{
  return add_marr_window;
}

@end
