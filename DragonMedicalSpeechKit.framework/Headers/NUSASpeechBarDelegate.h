//
//  NUSASpeechBarDelegate.h
//  Dragon Medical SpeechKit
//
//  Copyright (c) 2012 Nuance Communications, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NUSATypes.h"

/** @brief Audio quality. 
 *
 */
typedef enum {
    /** @brief The audio quality is ok. */
	NUSAAudioQualityIsOK		= 0,
    /** @brief The audio quality is too loud. */
	NUSAAudioQualityIsTooLoud	= 1, 
    /** @brief The audio quality is too noisy. */
	NUSAAudioQualityIsTooNoisy	= 2,
    /** @brief The audio quality is too soft. */
	NUSAAudioQualityIsTooSoft	= 3,
} NUSAAudioQuality; 


//////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////
/** @brief NUSA speech bar delegate messages.
 
 @xmlonly<nmFramework>DragonMedicalSpeechKit</nmFramework>@endxmlonly
 @since 1.3
 
 Delegate messages sent by the NUSACustomVuiController class to its delegate receiver. 
 All messages provided by the protocol are mandatory and must be implemented by the receiver. 
 Messages will be sent on the thread that sent the initWithView() message to the VUI controller. 

 */

@protocol NUSASpeechBarDelegate <NSObject>

- (void) updateSignalLevel: (Float32) signalLevel quality: (NUSAAudioQuality) quality;

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Recording 
//////////////////////////////////////////////////////////////////////////////////////////

/** @brief Sent after audio data recording has started.
 @since 1.3
 
 Sent to the delegate whenever a recording session is started.
 */
- (void) didStartRecording;

/** @brief Sent after audio data recording has stopped.
 @since 1.3
 
 Sent to the delegate whenever a recording session is finished. Reasons for stopping a recording 
 session can be your integration calling stopRecording:(), the user finished speaking when 
 startRecordingOneUtterance:() was used or an error situation.
 */
- (void) didStopRecording;

//////////////////////////////////////////////////////////////////////////////////////////
/// @name TTS
//////////////////////////////////////////////////////////////////////////////////////////

/** @brief Sent after speaking has started.
 @since 1.3
 
 Sent to the delegate whenever speaking is started.
 If a call to startSpeaking() cancels a previous call to startSpeaking(), this message is not sent again.
 */
- (void) didStartSpeaking;

/** @brief Sent after speaking has stopped.
 @since 1.3
 
 Sent to the delegate whenever speaking is finished. This message is sent when the session has finished 
 speaking the provided text or stopSpeaking() is called. 
 If speaking is cancelled by another call to startSpeaking(), this message is only sent after the last text has been finished.
 */
- (void) didStopSpeaking;

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Processing state handling 
//////////////////////////////////////////////////////////////////////////////////////////

/** @brief Sent after the end user has started to speak.
 @since 1.3
 
 Sent to the receiver whenever the user starts speaking in a speech-enabled GUI view. 
 Each didStartProcessing() message will be paired with a corresponding 
 didFinishProcessing() message.
 */
- (void) didStartProcessing; 

/** @brief Sent after Dragon Medical SpeechKit has finished processing all audio data
 @since 1.3
 
 Sent to the receiver whenever the user stops speaking and Dragon Medical SpeechKit has finished
 processing all audio data and added all recognized text to the views' text controls. Note that 
 there might be a delay between when the user stops speaking and this message. The same is true if 
 you send the NUSASession::stopRecording() message. 
 */
- (void) didFinishProcessing; 

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Error handling 
//////////////////////////////////////////////////////////////////////////////////////////

/** @brief Sent when an asynchronous error has occurred.
 @since 1.3
 
 Sent to the receiver whenever an asynchronous error happens.
 By default Dragon Medical SpeechKit displays an alert view if an error occurs.
 To suppress this alert view the didReceiveError delegate must return @c YES. 
 In this case the error should be handled by the integration e.g. by displaying a custom alert view.
 
 @param id A string containing the error id.
 @param message A string containing the localized error message.
 @return @c YES if the error was handled by the integration and the default alert view should be suppressed, @c NO if the default alert view should be displayed.
 */
- (BOOL) didReceiveError: (NSString *)id message: (NSString *)message; 

@end


