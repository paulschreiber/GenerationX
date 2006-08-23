/* sourceTableDataSource */

#import <Cocoa/Cocoa.h>
#import "GCFile.h"
#import "GCField.h"

@interface sourceTableDataSource : NSObject
{
  IBOutlet id sourceTable;
  IBOutlet id sourceText;
	IBOutlet id sourceSearchField;
	IBOutlet id sourceMessageText;
	
	id sortedColumn;
	BOOL sortDescending;
	
	GCField* currentSource;
	NSMutableArray* displayedSources;
}

- (void) refresh;
- (void) refreshWithGED: (GCFile*) g;
- (void) selectSource: (GCField*) s;
- (GCField*) selectedSource;

- (void) handleFilterSources: (id) sender;

@end
