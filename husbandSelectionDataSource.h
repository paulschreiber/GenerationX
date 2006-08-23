/* husbandSelectionDataSource */

#import <Cocoa/Cocoa.h>
#import "INDI.h"

@interface husbandSelectionDataSource : NSObject
{
  IBOutlet id husbandTable;
  IBOutlet id famController;
	
  NSMutableArray* data;
  INDI* selectedIndi;
}

- (void) refresh;
- (INDI*) selectedIndi;

@end
