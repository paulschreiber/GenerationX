#import "FileStatsController.h"

@implementation FileStatsController

+ (FileStatsController*) sharedStats
{
  static FileStatsController* my_stats = nil;
  
  if( ! my_stats )
    my_stats = [[FileStatsController alloc] initNib];
    
  return my_stats;
}

// load the nib
- (FileStatsController*) initNib
{
  [NSBundle loadNibNamed: @"FileStatistics" owner:self];
  
  return self;
}

- (void) displayStats: (GCFile*) ged
{
  NSMutableString* stats = [[NSMutableString alloc] init];
  
  NSLog( [ged path] );
  [stats setString: [[NSNumber numberWithInt: [ged numRecords]] stringValue]];
  [stats appendString: @" records in file\n\t"];
  [stats appendString: [[NSNumber numberWithInt: [ged numIndividuals]] stringValue]];
  [stats appendString: @" individual records\n\t"];
  [stats appendString: [[NSNumber numberWithInt: [ged numFamilies]] stringValue]];
  [stats appendString: @" family records\n\t"];
  [stats appendString: [[NSNumber numberWithInt: [ged numOthers]] stringValue]];
  [stats appendString: @" other records\n\n"];
  [stats appendString: [[NSNumber numberWithInt: [[ged surnames] count]] stringValue]];
  [stats appendString: @" surnames in file"];
  
  [stats_header setStringValue: [[ged path] lastPathComponent]];
  [stats_text setStringValue: stats];
  [stats_window makeKeyAndOrderFront: self];
}

@end
