#import "GenerationXController.h"
#import "GenericEventController.h"
#import "GCFile.h"
#import "GCField.h"
#import "FAM.h";
#import "GenXUtil.h";

@implementation GenericEventController

+ (GenericEventController*) sharedEvent
{
  static GenericEventController* shared_event = nil;
  
  if( ! shared_event )
    shared_event = [[GenericEventController alloc] initNib];
    
  return shared_event;
}

// load the nib
- (GenericEventController*) initNib
{
  [NSBundle loadNibNamed: @"GenericEvent" owner:self];
  type = @"EVEN";
//  ged = [[GCFile alloc] init];
  [header_text setBackgroundColor: [NSColor whiteColor]];
  
  return self;
}

// preload the dialog with data from the record being passed in
- (void) setField: (id) my_field
{
  NSString* tmp;
  GCField* date;
  
  field = my_field;
  type = [field fieldType];

  if( [type isEqual: @"EVEN"] )
  {
    [header_text setEditable: true];
    [header_text setBezeled: true];
    [header_text setDrawsBackground: true];
    if( tmp = [field valueOfSubfieldWithType: @"TYPE"] )
      [header_text setStringValue: tmp];
    else    
      [header_text setStringValue: @""];
  }
  else if( [type isEqual: @"OCCU"] )
  {
    [header_text setEditable: true];
    [header_text setBezeled: true];
    [header_text setDrawsBackground: true];
    if( tmp = [field fieldValue] )
      [header_text setStringValue: tmp];
    else    
      [header_text setStringValue: @"Occupation"];
  }
  else
  {
    [header_text setEditable: false];
    [header_text setBezeled: false];
    [header_text setDrawsBackground: false];
    if( tmp = [[GenXUtil sharedUtil] eventStringFromGEDCOM: type] )
      [header_text setStringValue: tmp];
    else
      [header_text setStringValue: type];      
  }
  
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
}

// extract all the stuff from the dialog and adjust our data accordingly
- (void) process
{
  NSMutableString* tmp = [[NSMutableString alloc] initWithString: @""];
  GCField* gc_tmp;

  [field setNeedSave: true];
  
  if( [type isEqual: @"EVEN"]
   && ! [[header_text stringValue] isEqual: @""] )
    if( gc_tmp = [field subfieldWithType: @"TYPE"] )
      [gc_tmp setFieldValue: [header_text stringValue]];
    else
      [field addSubfield: @"TYPE": [header_text stringValue]];    
  
  if( [type isEqual: @"OCCU"]
   && ! [[header_text stringValue] isEqual: @""] )
    [field setFieldValue: [header_text stringValue]];    
  
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
}

- (void) handleOk: (id) sender
{
  [[GenericEventController sharedEvent] process];
  
  [generic_event_window orderOut: self];
  [[NSApplication sharedApplication] endSheet: [[GenericEventController sharedEvent] window]];
}

- (void) handleCancel: (id) sender
{
  [generic_event_window orderOut: self];
  [[NSApplication sharedApplication] endSheet: generic_event_window];
}

- (NSWindow*) window
{
  return generic_event_window;
}

@end
