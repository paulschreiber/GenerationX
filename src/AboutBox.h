//  AboutBox.h
//  GenerationX
//
//  Created by Benjamin Chartier on August 26 2002.

#import <Cocoa/Cocoa.h>

@interface AboutBox : NSObject
{
    IBOutlet id 	appNameField;
    IBOutlet id 	copyrightField;
    IBOutlet id 	creditsField;
    IBOutlet id 	versionField;
    
    NSTimer*		scrollTimer;
    float			scrollPos;
    float			scrollHeight;
    BOOL			scrollRestartAtTop;
}

+ (AboutBox*)sharedInstance;
- (void)showPanel;

@end
