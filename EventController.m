//  EventController.m
//  GenerationX
//
//  Created by Benjamin Chartier on September 1 2002.

#import "EventController.h"
#import "GenericEventController.h"
#import "EventWithFAMCController.h"
#import "AddMarriageController.h"
#import "NoteController.h"

@implementation EventController

// Update the user interface
- (void) refreshGUI
{
  [appController refreshGUI];
}

// Add an event to the current record
- (void) addEvent:(NSString*) type
{
  GCField* tmp = [[appController currentRecord] addSubfield: type: @""];
  [[GenericEventController sharedEvent] setField: tmp];
  [NSApp beginSheet: [[GenericEventController sharedEvent] window]
    modalForWindow: [appController mainWindow]
    modalDelegate: self
    didEndSelector: @selector(refreshGUI)
    contextInfo: nil];
}

- (void) handleDeleteEvent:(id) sender
{
/*
  if( current_event )
  {
    //
    // Generic Events
    //
    if( [[current_event fieldType] isEqualToString: @"BURI"]
    || [[current_event fieldType] isEqualToString: @"CREM"]
    || [[current_event fieldType] isEqualToString: @"BIRT"]
    || [[current_event fieldType] isEqualToString: @"DEAT"]
    || [[current_event fieldType] isEqualToString: @"BAPM"]
    || [[current_event fieldType] isEqualToString: @"BARM"]
    || [[current_event fieldType] isEqualToString: @"BASM"]
    || [[current_event fieldType] isEqualToString: @"BLES"]
    || [[current_event fieldType] isEqualToString: @"CHRA"]
    || [[current_event fieldType] isEqualToString: @"CONF"]
    || [[current_event fieldType] isEqualToString: @"FCOM"]
    || [[current_event fieldType] isEqualToString: @"ORDN"]
    || [[current_event fieldType] isEqualToString: @"NATU"]
    || [[current_event fieldType] isEqualToString: @"EMIG"]
    || [[current_event fieldType] isEqualToString: @"IMMI"]
    || [[current_event fieldType] isEqualToString: @"CENS"]
    || [[current_event fieldType] isEqualToString: @"PROB"]
    || [[current_event fieldType] isEqualToString: @"WILL"]
    || [[current_event fieldType] isEqualToString: @"GRAD"]
    || [[current_event fieldType] isEqualToString: @"RETI"]
    || [[current_event fieldType] isEqualToString: @"MARR"]
   || [[current_event fieldType] isEqualToString: @"ANUL"]
   || [[current_event fieldType] isEqualToString: @"DIV"]
   || [[current_event fieldType] isEqualToString: @"DIVF"]
   || [[current_event fieldType] isEqualToString: @"ENGA"]
   || [[current_event fieldType] isEqualToString: @"MARB"]
   || [[current_event fieldType] isEqualToString: @"MARC"]
   || [[current_event fieldType] isEqualToString: @"MARL"]
   || [[current_event fieldType] isEqualToString: @"MARS"]
    || [[current_event fieldType] isEqualToString: @"EVEN"] )
    {
      [current_record removeSubfield: current_event];
      [self refreshGUI];
    }
    //
    // FAMC Events
    //
    else if( [[current_event fieldType] isEqual: @"ADOP"]
    || [[current_event fieldType] isEqual: @"CHR"] )
    {
      NSString* tmp;
      GCField* gc_tmp;
      // if the event has a FAMC, remove the FAMC's linke to this INDI
      if( tmp = [current_event valueOfSubfieldWithType: @"FAMC"] )
      {
        if( gc_tmp = [ged famWithLabel: tmp] )
          [gc_tmp removeSubfieldWithType: @"CHIL" Value: [current_record fieldValue]];
      }
      // delete the event
      [current_record removeSubfield: current_event];
      [self refreshGUI];
    }
    //
    // MARR Event
    //
    else if( [[current_event fieldType] isEqual: @"FAMS"] )
    {
      NSBeginAlertSheet( @"Are you sure?", @"I'm sure", @"Cancel", nil,
        main_window, self, @selector( deleteMarriagePanelDidEnd:returnCode:contextInfo: ), nil, nil,
        @"You are about to delete all information about this marriage. Are you sure you want to do this?" );
    }
  }
*/
}

- (void)deleteMarriagePanelDidEnd:(NSOpenPanel *)sheet
  returnCode:(int)returnCode
  contextInfo:(void  *)contextInfo
{
// BCH
/*  if( returnCode == NSAlertDefaultReturn )
  {
    [ged removeRecord: [ged famWithLabel: [current_event fieldValue]]];
    [self refreshGUI];
  }
*/
}

//
// INDI Events
//
- (void) handleAddChristening:(id) sender
{
  GCField* tmp = [[appController currentRecord] addSubfield: @"CHR": @""];
  [[EventWithFAMCController sharedEvent] setField: tmp: [appController currentRecord]: [appController gedFile]];
  [NSApp beginSheet: [[EventWithFAMCController sharedEvent] window]
    modalForWindow: [appController mainWindow]
    modalDelegate: self
    didEndSelector: @selector(refreshGUI)
    contextInfo: nil];
}

- (void) handleAddBaptism:(id) sender
{
  [self addEvent: @"BAPM"];
}

- (void) handleAddBlessing:(id) sender
{
  [self addEvent: @"BLESS"];
}

- (void) handleAddConfirmation:(id) sender
{
  [self addEvent: @"CONF"];
}

- (void) handleAddBarmitzvah:(id) sender
{
  [self addEvent: @"BARM"];
}

- (void) handleAddBasmitzvah:(id) sender
{
  [self addEvent: @"BASM"];
}

- (void) handleAddFirstCommunion:(id) sender
{
  [self addEvent: @"FCOM"];
}

- (void) handleAddAdultChristening:(id) sender
{
  [self addEvent: @"CHRA"];
}

- (void) handleAddOrdination:(id) sender
{
  [self addEvent: @"ORDN"];
}

- (void) handleAddAdoption:(id) sender
{
  GCField* tmp = [[appController currentRecord] addSubfield: @"ADOP": @""];
  [[EventWithFAMCController sharedEvent] setField: tmp: [appController currentRecord]: [appController gedFile]];
  [NSApp beginSheet: [[EventWithFAMCController sharedEvent] window]
    modalForWindow: [appController mainWindow]
    modalDelegate: self
    didEndSelector: @selector(refreshGUI) contextInfo: nil];
}

- (void) handleAddEmigration:(id) sender
{
  [self addEvent: @"EMIG"];
}

- (void) handleAddImmigration:(id) sender
{
  [self addEvent: @"IMMI"];
}

- (void) handleAddNaturalization:(id) sender
{
  [self addEvent: @"NATU"];
}

- (void) handleAddGraduation:(id) sender
{
  [self addEvent: @"GRAD"];
}

- (void) handleAddRetirement:(id) sender
{
  [self addEvent: @"RETI"];
}

- (void) handleAddProbate:(id) sender
{
  [self addEvent: @"PROB"];
}

- (void) handleAddWill:(id) sender
{
  [self addEvent: @"WILL"];
}

- (void) handleAddCremation:(id) sender
{
  [self addEvent: @"CREM"];
}

- (void) handleAddBurial:(id) sender
{
  [self addEvent: @"BURI"];
}

- (void) handleAddOtherEvent:(id) sender
{
  [self addEvent: @"EVEN"];
}

//
// FAM Events
//
- (void) handleAddEngagement:(id) sender
{
  [self addEvent: @"ENGA"];
}

- (void) handleAddDivorce:(id) sender
{
  [self addEvent: @"DIV"];
}

- (void) handleAddAnnulment:(id) sender
{
  [self addEvent: @"ANUL"];
}

- (void) handleAddMarriageBann:(id) sender
{
  [self addEvent: @"MARB"];
}

- (void) handleAddMarriageSettlement:(id) sender
{
  [self addEvent: @"MARS"];
}

- (void) handleAddMarriageContract:(id) sender
{
  [self addEvent: @"MARC"];
}

- (void) handleAddMarriageLicense:(id) sender
{
  [self addEvent: @"MARL"];
}

- (void) handleAddDivorceFiling:(id) sender
{
  [self addEvent: @"DIVF"];
}

//
// FAM & INDI events
- (void) handleAddMarriage:(id) sender
{
  if( [[[appController currentRecord] fieldType] isEqual: @"INDI"] )
  {
    [[AddMarriageController sharedAddMarr] prepForDisplay: [appController gedFile]: nil: [appController currentRecord]];
    [NSApp beginSheet: [[AddMarriageController sharedAddMarr] window]
      modalForWindow: [appController mainWindow]
      modalDelegate: self
      didEndSelector: @selector(refreshGUI)
      contextInfo: nil];
  }
  else if( [[[appController currentRecord] fieldType] isEqual: @"FAM"] )
    [self addEvent: @"MARR"];
}


- (void) handleAddNote:(id) sender
{
  [[NoteController sharedNote] setField: [appController currentRecord]];
  [NSApp beginSheet: [[NoteController sharedNote] window]
    modalForWindow: [appController mainWindow]
    modalDelegate: self
    didEndSelector: nil
    contextInfo: nil];
}

- (void)doAddImage:(NSOpenPanel *)sheet
  returnCode:(int)returnCode
  contextInfo:(void  *)contextInfo
{
  GCField* gc_tmp;
  NSString* file = [sheet filename];
  
  if (returnCode == NSOKButton)
  {
    [[appController currentRecord] setNeedSave: true];
    gc_tmp = [[appController currentRecord] addSubfield: @"OBJE": @""];
    if( [file hasSuffix: @".jpg"] || [file hasSuffix: @"JPG"] )
      [gc_tmp addSubfield: @"FORM": @"jpeg"];
    else if( [file hasSuffix: @".gif"] || [file hasSuffix: @"GIF"] )
      [gc_tmp addSubfield: @"FORM": @"gif"];
    else if( [file hasSuffix: @".bmp"] || [file hasSuffix: @"BMP"] )
      [gc_tmp addSubfield: @"FORM": @"bmp"];
    else if( [file hasSuffix: @".tiff"] || [file hasSuffix: @"TIFF"] )
      [gc_tmp addSubfield: @"FORM": @"tiff"];
    [gc_tmp addSubfield: @"FILE": file];
  }
  
  [appController handleIndiSelectionChanged: nil];

}

- (void) handleAddImage:(id) sender
{
  NSOpenPanel* open;
  NSArray *fileTypes = [NSArray arrayWithObjects:
    @"jpg", @"JPG", @"gif", @"GIF", @"bmp", @"BMP", @"tiff", @"TIFF", nil];
  
  // Display a standard open dialog
  open = [NSOpenPanel openPanel];
  [open setAllowsMultipleSelection:false];
  [open beginSheetForDirectory:NSHomeDirectory()
    file:nil
    types:fileTypes
    modalForWindow: [appController mainWindow]
    modalDelegate: self
    didEndSelector: @selector(doAddImage:returnCode:contextInfo:)
    contextInfo: nil];
}

@end
