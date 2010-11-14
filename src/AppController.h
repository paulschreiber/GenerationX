/* AppController */

#import <Cocoa/Cocoa.h>

@interface AppController : NSObject
{
}
- (IBAction)handleShowPrefs:(id)sender;
- (IBAction)handleShowGEDCOM:(id)sender;
- (IBAction)handleShowIndiDetail:(id)sender;
- (IBAction)handleShowFamDetail:(id)sender;
- (IBAction)handleShowImageViewer:(id)sender;
- (IBAction)handleShowEventViewer:(id)sender;
- (IBAction)handleShowNoteViewer:(id)sender;

- (void) handleDescendantsGEDCOM:(id) sender;
- (void) handleAncestorsGEDCOM:(id) sender;
- (void) handleDescendantReport:(id) sender;
- (void) handleAncestorsReport:(id) sender;
- (void) handleAllHTML:(id) sender;

- (void) handleMergeFile:(id) sender;

@end
