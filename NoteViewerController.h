/* ImageViewerController */

#import <Cocoa/Cocoa.h>

#import "GenXUtil.h"
#import "GCField.h"
#import "INDI.h"

@interface NoteViewerController : NSObject
{
    IBOutlet NSWindow* window;
    IBOutlet NSTextField* header_text;
    IBOutlet NSOutlineView* note_outline;
    
    GCField* field;
    NSMutableArray* events;
}

+ (NoteViewerController*) sharedViewer;

- (NoteViewerController*) initViewer;
- (void) setField: (id) my_field;
- (NSWindow*) window;

@end
