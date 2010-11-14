/* childSelectionDataSource */

#import <Cocoa/Cocoa.h>
#import "INDI.h"

@interface childSelectionDataSource : NSObject
{
  IBOutlet id childTable;
  IBOutlet id famController;
	
  NSMutableArray* data;
  INDI* selectedIndi;
}

- (void) refresh;
- (INDI*) selectedIndi;

@end
