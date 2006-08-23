/* indiDetailPanelController */

#import <Cocoa/Cocoa.h>

#import "INDI.h"

@interface indiDetailPanelController : NSObject
{
    IBOutlet id panel;
    IBOutlet id nameText;
    IBOutlet id birthDateText;
    IBOutlet id deathDateText;
    IBOutlet id fatherText;
    IBOutlet id motherText;
    IBOutlet id spouseTable;
    IBOutlet id sourceText;
		
		INDI* currentIndi;
}

+ (indiDetailPanelController*) sharedIndiDetailPanel;
- (indiDetailPanelController*) init;

- (void) setVisible: (BOOL) b;
- (void) toggle;
- (void) updateWithIndi: (INDI*) i;
- (BOOL) isVisible;

- (void) handleSelectFather: (id) sender;
- (void) handleSelectMother: (id) sender;
- (void) handleSelectSpouse: (id) sender;
- (void) handleSelectSource: (id) sender;
- (void) handleChangeSource: (id) sender;

@end
