/* descOutlineController */

#import <Cocoa/Cocoa.h>

#import "INDI.h";
#import "FAM.h";

@interface descOutlineController : NSObject
{
    IBOutlet id descOutline;
		
		INDI* currentIndi;
}

- (void) updateWithIndi: (INDI*) i;
- (void) handleUpButton: (id) sender;

@end
