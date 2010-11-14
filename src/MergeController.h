/* MergeController */

#import <Cocoa/Cocoa.h>
#import "GCFile.h"

@interface MergeController : NSObject
{
    NSModalSession session;
    id sender;
    IBOutlet NSWindow* merge_window;
    IBOutlet NSTextField* merge_label;
    IBOutlet NSTextView* merge_field;
    IBOutlet NSTextView* original_field;
    
    GCFile* original;
    GCFile* merge;
    GCField* original_record;
    GCField* merge_record;
    
    int merge_index;
}
+ (MergeController*) sharedMerge;
- (MergeController*) initNib;
- (void)doMerge: (GCFile*) my_original: (GCFile*) my_merge: (id) my_sender;
- (void) resumeMerge;
- (IBAction)handleKeepBoth:(id)sender;
- (void)keepBoth;
- (IBAction)handleKeepOriginal:(id)sender;
- (IBAction)handleReplaceOriginal:(id)sender;
- (void)replaceOriginal;
@end
