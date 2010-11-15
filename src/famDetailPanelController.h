/* famDetailPanelController */

#import <Cocoa/Cocoa.h>

#import "FAM.h"
#import "husbandSelectionDataSource.h"
#import "wifeSelectionDataSource.h"

@interface famDetailPanelController : NSObject
{
    IBOutlet id panel;
    IBOutlet id husbandText;
    IBOutlet id wifeText;
    IBOutlet id marriageDateText;
    IBOutlet id childrenTable;
	IBOutlet id progIndicator;
	IBOutlet id sourceText;
	
    IBOutlet id husbandSheet;
    husbandSelectionDataSource * husbandDataSource;
	
    IBOutlet id wifeSheet;
    wifeSelectionDataSource * wifeDataSource;
	
    IBOutlet id childSheet;
    IBOutlet id childDataSource;
	
	FAM* currentFam;
}

+ (famDetailPanelController*) sharedFamDetailPanel;
- (famDetailPanelController*) init;

- (void) setVisible: (BOOL) b;
- (void) toggle;
- (void) updateWithFam: (FAM*) i;
- (void) refreshDataSources: (id)sender;
- (BOOL) isVisible;

- (void) handleSelectChild: (id) sender;
- (void) handleSelectHusband: (id) sender;
- (void) handleSelectWife: (id) sender;

- (void) handleChangeHusband: (id) sender;
- (void) handleHusbOK: (id) sender;
- (void) handleHusbCancel: (id) sender;

- (void) handleChangeWife: (id) sender;
- (void) handleWifeOK: (id) sender;
- (void) handleWifeCancel: (id) sender;

- (void) handleAddChild: (id) sender;
- (void) handleChildOK: (id) sender;
- (void) handleChildCancel: (id) sender;
- (void) handleDeleteChild: (id) sender;

- (void) handleSelectSource: (id) sender;
- (void) handleChangeSource: (id) sender;

@end
