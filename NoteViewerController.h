/* ImageViewerController */

#import <Cocoa/Cocoa.h>

#import "GenXUtil.h"
#import "GCField.h"
#import "INDI.h"

@interface NoteViewerController : NSObject
{
    IBOutlet id panel;
    IBOutlet NSTextField* header_text;
    IBOutlet NSOutlineView* note_outline;
    IBOutlet id noteText;
    IBOutlet id sourceText;
    IBOutlet id buttonPlus;
    IBOutlet id buttonMinus;
    
    GCField* field;
    GCField* currentNote;
    NSMutableArray* events;
}

+ (NoteViewerController*) sharedViewer;

- (NoteViewerController*) initViewer;
- (void) setField: (id) my_field;
- (void) toggle;
- (BOOL) isVisible;

- (void) handleSelectSource: (id) sender;
- (void) handleChangeSource: (id) sender;
- (void) handleAddNote: (id) sender;
- (void) handleDeleteNote: (id) sender;

@end
