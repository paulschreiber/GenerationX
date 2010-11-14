/* FileStatsController */

#import <Cocoa/Cocoa.h>

#import "GCFile.h"

@interface FileStatsController : NSObject
{
    IBOutlet id stats_header;
    IBOutlet id stats_text;
    IBOutlet id stats_window;
}

+ (FileStatsController*) sharedStats;
- (FileStatsController*) initNib;

- (void) displayStats: (GCFile*) ged;

@end
