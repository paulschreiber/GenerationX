/* ChooseFieldController */

#import <Cocoa/Cocoa.h>

#import "GCFile.h"
#import "GCField.h"

@interface ChooseFieldController : NSObject
{
    IBOutlet NSTextField* header;
    IBOutlet NSTableView* table;
    IBOutlet NSWindow* window;
    
    NSArray* fields;
    GCField* result;
    GCFile* ged;
}
+ (ChooseFieldController*) sharedChooser;
- (ChooseFieldController*) initChooser;
- (void) setFields: (NSArray*) my_fields: (GCFile*) my_ged;
- (void) setHeaderString: (NSString*) my_header;
- (GCField*) result;
- (IBAction)handleOk:(id)sender;
- (void) doOk;
- (IBAction)handleNone:(id)sender;
- (void) doNone;
- (NSWindow*) window;
@end
