#import "ChooseFieldController.h"

#import "INDI.h"

@implementation ChooseFieldController

+ (ChooseFieldController*) sharedChooser
{
  static ChooseFieldController* my_data = nil;
  
  if( ! my_data )
    my_data = [[ChooseFieldController alloc] initChooser];
    
  return my_data;
}

// load the nib
- (ChooseFieldController*) initChooser
{
  [NSBundle loadNibNamed: @"ChooseField" owner:self];
  [table setDataSource: self];
  result = nil;
  
  return self;
}

- (void) setFields: (NSArray*) my_fields: (GCFile*) my_ged
{
  ged = my_ged;
  [fields release];
  fields = [my_fields retain];
//  [table setDataSource: self];
  [table reloadData];
}

- (void) setHeaderString: (NSString*) my_header
{
  [header setStringValue: my_header];
//  [header display];
}

- (GCField*) result
{
  return result;
}

- (IBAction)handleOk:(id)sender
{
  [[ChooseFieldController sharedChooser] doOk];
}

- (void) doOk
{
  result = [fields objectAtIndex: [table selectedRow]];

  [window orderOut: self];
  [NSApp stopModal];
}

- (IBAction)handleNone:(id)sender
{
  [[ChooseFieldController sharedChooser] doNone];
}

- (void) doNone
{
  result = nil;
  [window orderOut: self];
  [NSApp stopModal];
}

- (NSWindow*) window
{
  return window;
}

//
// NSTableView methods
//
- (int)numberOfRowsInTableView:(NSTableView *)aTableView
{
  return [fields count];
}

- (id)tableView:(NSTableView *)aTableView
  objectValueForTableColumn:(NSTableColumn *)aTableColumn
  row:(int)rowIndex
{
  NSMutableString* tmp = [[NSMutableString alloc] init];
  
  if( [[[fields objectAtIndex: rowIndex] fieldType] isEqual: @"INDI"] )
  {
    [tmp setString: [[fields objectAtIndex: rowIndex] fullName]];
    [tmp appendString: [[fields objectAtIndex: rowIndex] lifespan]];
  }
  else
  {
    [tmp setString: [[[fields objectAtIndex: rowIndex] husband: ged] fullName]];
    [tmp appendString: @"/"];
    [tmp appendString: [[[fields objectAtIndex: rowIndex] wife: ged] fullName]];
  }
  
  return tmp;
}

@end
