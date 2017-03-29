//
//  NUSACustomVuiControllerDelegate.h
//  Dragon Medical SpeechKit
//
//  Copyright (c) 2012 Nuance Communications, Inc. All rights reserved.
//
//  SDK version: 3.1.05417.105
//

#import <Foundation/Foundation.h>

@protocol NUSACustomVuiControllerDelegate <NSObject>
@optional

/** @brief Sent when the speech bar is shown for a control.
    @since 1.3

	Sent to the receiver whenever the speech bar is displayed for a control. Provides information about the speech bar's position on the screen.
	
    @param frame Designates the total screen area covered by the speech bar and possibly other input views currently displayed (i.e. the soft keyboard and accessory views, if applicable).
*/
- (void) speechBarDidShow: (CGRect) frame;

/** @brief Sent when the speech bar is hidden.
    @since 1.3

	Sent to the receiver whenever the speech bar is hidden.
*/
- (void) speechBarDidHide;
@end
