//
//  NUSASessionDelegate.h
//  Dragon Medical SpeechKit
//
//  Copyright 2011 Nuance Communications, Inc. All rights reserved.
//
//  SDK version: 3.1.05417.105
//

#import <UIKit/UIKit.h>

//////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////
/** @brief NUSASession delegate messages.
 
	@xmlonly<nmFramework>NuanceSpeechAnywhere</nmFramework>@endxmlonly
	@since 1.0
 
	Delegate messages sent by the NUSASession class to its delegate receiver. All messages 
	provided by the protocol are optional and can be implemented by the receiver. 
*/
@protocol NUSASessionDelegate <NSObject>
@optional

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Recording sessions
//////////////////////////////////////////////////////////////////////////////////////////

/** @brief Sent after audio data recording has started￼.
	@since 1.0
	
	Sent to the delegate whenever a recording session is started.
 */
- (void) sessionDidStartRecording;

/** @brief Sent after audio data recording has stopped.
	@since 1.0
 
	Sent to the delegate whenever a recording session is finished. Reasons for stopping a recording 
	session can be your integration calling stopRecording:(), the user finished speaking when 
    startRecordingOneUtterance:() was used or an error situation.
 */
- (void) sessionDidStopRecording;

//////////////////////////////////////////////////////////////////////////////////////////
/// @name TTS
//////////////////////////////////////////////////////////////////////////////////////////

/** @brief Sent after speaking has started￼.
    @since 1.3
 
    Sent to the delegate whenever speaking is started.
    If a call to startSpeaking() cancels a previous call to startSpeaking(), this message is not sent again.
 */
- (void) sessionDidStartSpeaking;

/** @brief Sent after speaking has stopped.
    @since 1.3
 
    Sent to the delegate whenever speaking is finished. This message is sent when the session has finished speaking the provided text or stopSpeaking() is called. 
    If speaking is cancelled by another call to startSpeaking(), this message is only sent after the last text has been finished.
 */
- (void) sessionDidStopSpeaking;

@end
