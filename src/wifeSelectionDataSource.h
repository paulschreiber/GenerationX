/* wifeSelectionDataSource */

#import <Cocoa/Cocoa.h>
#import "INDI.h"

@interface wifeSelectionDataSource : NSObject
{
  IBOutlet id wifeTable;
  IBOutlet id famController;
	
  NSMutableArray* data;
  INDI* selectedIndi;
}

- (void) refresh;
- (INDI*) selectedIndi;

@end
