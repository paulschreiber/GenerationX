//  EventController.h
//  GenerationX
//
//  Created by Benjamin Chartier on September 1 2002.

#import <Cocoa/Cocoa.h>
#import "GenerationXController.h"

@interface EventController : NSObject
{
  IBOutlet GenerationXController*		appController;
}

// Add an event to the current record
- (void) addEvent:(NSString*) type;

// Delete an event
- (void) handleDeleteEvent:(id) sender;
- (void)deleteMarriagePanelDidEnd:(NSOpenPanel *)sheet
  returnCode:(int)returnCode
  contextInfo:(void  *)contextInfo;

// INDI events
- (void) handleAddChristening:(id) sender;
- (void) handleAddBaptism:(id) sender;
- (void) handleAddBlessing:(id) sender;
- (void) handleAddConfirmation:(id) sender;
- (void) handleAddBarmitzvah:(id) sender;
- (void) handleAddBasmitzvah:(id) sender;
- (void) handleAddFirstCommunion:(id) sender;
- (void) handleAddAdultChristening:(id) sender;
- (void) handleAddOrdination:(id) sender;
- (void) handleAddAdoption:(id) sender;
- (void) handleAddEmigration:(id) sender;
- (void) handleAddImmigration:(id) sender;
- (void) handleAddNaturalization:(id) sender;
- (void) handleAddGraduation:(id) sender;
- (void) handleAddRetirement:(id) sender;
- (void) handleAddProbate:(id) sender;
- (void) handleAddWill:(id) sender;
- (void) handleAddCremation:(id) sender;
- (void) handleAddBurial:(id) sender;
- (void) handleAddOtherEvent:(id) sender;

// FAM events
- (void) handleAddEngagement:(id) sender;
- (void) handleAddDivorce:(id) sender;
- (void) handleAddAnnulment:(id) sender;
- (void) handleAddMarriageBann:(id) sender;
- (void) handleAddMarriageSettlement:(id) sender;
- (void) handleAddMarriageContract:(id) sender;
- (void) handleAddMarriageLicense:(id) sender;
- (void) handleAddDivorceFiling:(id) sender;

// FAM & INDI events
- (void) handleAddMarriage:(id) sender;
- (void) handleAddNote:(id) sender;
- (void) handleAddImage:(id) sender;

@end
