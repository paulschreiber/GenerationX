/* NewIndiController */

#import <Cocoa/Cocoa.h>
#import "GCFile.h"

@interface NoteController : NSObject
{
    IBOutlet NSWindow* note_window;

    IBOutlet NSTextField*   header_text;
    IBOutlet NSTextView*    note_text;

    NSModalSession modal_session;
    NSString* type;
//    GCFile* ged;
    id field;
}

+ (NoteController*) sharedNote;
- (NoteController*) initNib;
- (void) setField: (id) my_field;
- (void) process;
- (void) handleOk: (id) sender;
- (void) handleCancel: (id) sender;
- (NSWindow*) window;

@end
