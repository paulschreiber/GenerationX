#import "GenerationXController.h"
#import "NoteController.h"
//#import "GCFile.h"
#import "GCField.h"
#import "FAM.h";

@implementation NoteController

+ (NoteController*) sharedNote
{
  static NoteController* shared_note = nil;
  
  if( ! shared_note )
    shared_note = [[NoteController alloc] initNib];
    
  return shared_note;
}

// load the nib
- (NoteController*) initNib
{
  [NSBundle loadNibNamed: @"Note" owner:self];
  [note_text setContinuousSpellCheckingEnabled: true];
  
  return self;
}

- (void) setField: (id) my_field
{
  NSMutableString* tmp = [[NSMutableString alloc] init];
  field = my_field;
  
  [tmp setString: @"Note for "];
  if( [[field fieldType] isEqual: @"INDI"] )
    [tmp appendString: [field fullName]];
  else
    [tmp appendString: [field fieldValue]];

  [header_text setStringValue: tmp];
  [note_text setString: @""];
}

// extract all the stuff from the dialog and adjust our data accordingly
- (void) process
{
  GCField* added;
  NSArray* bits = [[note_text string] componentsSeparatedByString: @"\n"];
  int i;
  
  added = [field addSubfield: @"NOTE": [NSString stringWithString: [bits objectAtIndex: 0]]];
  for( i = 1; i < [bits count]; i++ )
    [added addSubfield: @"CONT": [NSString stringWithString: [bits objectAtIndex: i]]];
    
  [added setNeedSave: true];
}

- (void) handleOk: (id) sender
{
  NSNotificationCenter*		appNotificationCenter;

  [[NoteController sharedNote] process];
  
  [note_window orderOut: self];
  [[NSApplication sharedApplication] endSheet: [[NoteController sharedNote] window]];
  
  // Send a notification to the notification center
  appNotificationCenter = [NSNotificationCenter defaultCenter];
  [appNotificationCenter 	postNotificationName: @"GenXNoteAdded"
                            object: self];
}

- (void) handleCancel: (id) sender
{
  [note_window orderOut: self];
  [[NSApplication sharedApplication] endSheet: note_window];
}

- (NSWindow*) window
{
  return note_window;
}

@end
