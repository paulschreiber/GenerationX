/* ImageViewerController */

#import <Cocoa/Cocoa.h>

//#import "GenerationXController.h"
#import "GenXUtil.h"
#import "GCField.h"
#import "INDI.h"

@interface ImageViewerController : NSObject
{
    // InterfaceBuilder outlets
    IBOutlet NSWindow* 		window;
    IBOutlet NSTextField* 	headerText;
    IBOutlet NSTextField* 	sourceText;
    IBOutlet NSOutlineView*	imageOutline;
    IBOutlet NSImageView* 	imagePreview;

    IBOutlet NSButton* 		buttonUp;
    IBOutlet NSButton* 		buttonDown;
    IBOutlet NSButton* 		buttonPlus;
    IBOutlet NSButton* 		buttonMinus;
    
    // Other instance variables
    GCField* 			record;
    NSMutableArray* 		events;
}


+ (ImageViewerController*) sharedViewer;

- (ImageViewerController*) initViewer;

// Accessors
- (void) setRecord: (id) aRecord;
- (id) record;
- (NSWindow*) window;
- (void) toggle;
- (BOOL) isVisible;

// Others
- (void) updateViewContent;

// InterfaceBuilder actions
- (void) handleSelectSource: (id) sender;
- (void) handleChangeSource: (id) sender;
- (void) imageHasBeenClicked: (id) sender;
- (void) buttonUpHasBeenClicked: (id) sender;
- (void) buttonDownHasBeenClicked: (id) sender;
- (void) buttonPlusHasBeenClicked: (id) sender;
- (void) buttonMinusHasBeenClicked: (id) sender;

@end
