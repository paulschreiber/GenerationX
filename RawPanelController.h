/* RawPanelController */

#import <Cocoa/Cocoa.h>
#import "GCField.h"

@interface RawPanelController : NSObject
{
    IBOutlet NSOutlineView* raw_outline;
    IBOutlet NSPanel*       raw_panel;
    
    GCField* field;
}

+ (RawPanelController*) sharedRawPanel;
- (RawPanelController*) initNib;
- (void) display;
- (void) handleNewFieldButton: (id) sender;
- (void) handleDeleteFieldButton: (id) sender;
- (GCField*) dataField;
- (void) setDataField: (GCField*) my_field;

@end
