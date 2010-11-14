//
//  MyDocument.h
//  GenXDoc
//
//  Created by Nowhere Man on Fri Feb 06 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//


#import <Cocoa/Cocoa.h>
#import "GCFile.h"
#import "indiTableDataSource.h"
#import "famTableDataSource.h"

@interface MyDocument : NSDocument
{
  IBOutlet id mainWindow;
  IBOutlet id mainTabView;

  IBOutlet id indiTable;
  IBOutlet id indiSearchField;
  IBOutlet id indiMessageText;
  
	IBOutlet id famTable;
  IBOutlet id famSearchField;
  IBOutlet id famMessageText;

  IBOutlet id sourceMessageText;
  IBOutlet id sourceSearchField;
  IBOutlet id sourceDataSource;
	
  IBOutlet id descController;

  GCFile* ged;
	INDI* currentIndi;
	FAM* currentFam;
	indiTableDataSource* indiDataSource;
	famTableDataSource* famDataSource;
}

- (GCFile*) ged;
- (INDI*) currentIndi;
- (void) selectIndi: (INDI*) i;
- (void) selectFam: (FAM*) f;
- (void) handleContentChange;

- (void) handleAddIndi: (id) sender;
- (void) handleDeleteIndi: (id) sender;
- (void) handleSelectIndi: (id) sender;
- (void) handleFilterIndividuals: (id) sender;
- (void) handleAddFam: (id) sender;
- (void) handleDeleteFam: (id) sender;
- (void) handleSelectFam: (id) sender;
- (void) handleFilterFamilies: (id) sender;
- (void) handleAddSource: (id) sender;
- (void) handleDeleteSource: (id) sender;
- (void) handleFilterSources: (id) sender;
- (void) handleMergeFile:(id) sender;

- (void) handleDescendantsGEDCOM:(id) sender;
- (void) handleAncestorsGEDCOM:(id) sender;
- (void) handleDescendantReport:(id) sender;
- (void) handleAncestorsReport:(id) sender;
- (void) handleAllHTML:(id) sender;

@end
