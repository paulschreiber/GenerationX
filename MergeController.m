#import "MergeController.h"
#import "GenerationXController.h"
#import "GCFile.h"

@implementation MergeController

+ (MergeController*) sharedMerge
{
  static MergeController* my_data = nil;
  
  if( ! my_data )
    my_data = [[MergeController alloc] initNib];
    
  return my_data;
}

// load the nib
- (MergeController*) initNib
{
  [NSBundle loadNibNamed: @"Merge" owner:self];
  
  return self;
}

// set up some inital stuff and attempt to merge 2 GEDCOM files
- (void)doMerge: (GCFile*) my_original: (GCFile*) my_merge: (id) my_sender
{
  sender = my_sender;
  
  original = my_original;
  merge = my_merge;
  
  merge_record = [merge indiAtIndex: 0];
  
  merge_index = -1;
  
  [self resumeMerge];
}

- (void)resumeMerge
{
  merge_index++;
  
  // run through all the records
  for( ; merge_index < [merge numRecords]; merge_index++ )
  {
    // if there's no labeling conflict
    // just add the record being merged to the database
    if( ! [original recordWithLabel:
          [[merge recordAtIndex: merge_index] fieldValue]] )
      [original addRecord: [merge recordAtIndex: merge_index]];
    // ...but if we find a record with a label that already exists
    // in our database, cry for help
    else if( ! [[original recordWithLabel:
               [[merge recordAtIndex: merge_index] fieldValue]]
               isIdentical: [merge recordAtIndex: merge_index]] )
    {
      original_record = [original recordWithLabel: [[merge recordAtIndex: merge_index] fieldValue]];
      merge_record = [merge recordAtIndex: merge_index];
      [merge_label setStringValue: [[merge recordAtIndex: merge_index] fieldValue]];
      [original_field setString: [original_record dataForFile]];
      [merge_field setString: [merge_record dataForFile]];
      [NSApp runModalForWindow: merge_window];
      return;
    }
  }
  
  [merge_window orderOut: self];
  [sender refreshGUI];
}

// it would be nice to let the user choose to keep both records
// from a merge dialog. there's a lot of tracking down and
// changing of links involved. maybe in the future.
//
// NOT IMPLEMENTED
- (IBAction)handleKeepBoth:(id)sender
{
  [[MergeController sharedMerge] keepBoth];
  [NSApp stopModal];
  [[MergeController sharedMerge] resumeMerge];
}

- (void)keepBoth
{
  // if we want to keep both
  // rename the record being merged
  // and update all pointers to it
  // in its FAMS and FAMC records
  //
  // NOT IMPLEMENTED YET
}

- (IBAction)handleKeepOriginal:(id)sender
{
  // if we want to keep the original record
  // do nothing and continue
  [NSApp stopModal];
  [[MergeController sharedMerge] resumeMerge];
}

- (IBAction)handleReplaceOriginal:(id)sender
{
  [[MergeController sharedMerge] replaceOriginal];
  [NSApp stopModal];
  [[MergeController sharedMerge] resumeMerge];
}

- (void)replaceOriginal
{
  // if we want to relpace the original
  // with the record being merged
  // remove the original ecord and add
  // the new one
  [original replaceRecord: original_record withRecord: [merge recordAtIndex: merge_index]];
}

@end
