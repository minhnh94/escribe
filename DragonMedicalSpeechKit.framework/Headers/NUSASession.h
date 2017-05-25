//
//  NUSASession.h
//  Dragon Medical SpeechKit
//
//  Copyright 2011 Nuance Communications, Inc. All rights reserved.
//
//  SDK version: 3.1.06256.112
//

#import <Foundation/Foundation.h>
#import "NUSATypes.h"
#import "NUSASessionDelegate.h"

@class NUSAVuiController; 

/** @brief NHID Organization Token
 *
 *  This is to be used in place of the organization token, in the openForApplication method,
 *  to enable the NHID authentication.
 */
extern NSString* const kNUSAEnableNHIDOrganizationToken;

//////////////////////////////////////////////////////////////////////////////////////////
/// @name TTS voices 
/// @relates NUSASession
///
/// @brief Constants for the speakingVoice property NUSASession. 
///
/// @{
/// 
//////////////////////////////////////////////////////////////////////////////////////////

/** @brief Female voice 
 *
 *	This is the default voice used for TTS if no speaking voice is specified by your integration.
 */
extern NSString* const kNUSASpeakingVoiceFemale; 
/** @brief Male voice */
extern NSString* const kNUSASpeakingVoiceMale;
/// @}

//////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////
/** @brief Representation of a mobile speech session.
 
	@xmlonly<nmFramework>DragonMedicalSpeechKit</nmFramework>@endxmlonly
	@since 1.0
 
	This interface manages the authentication and licensing with the web service provider 
	via the information passed in the openForApplication:partnerGuid:licenseGuid:userId:() 
	message and audio sessions via startRecording:() and stopRecording(). Once a session 
	is opened, it will stay open (usable) until explicitly closed via close(); this frees 
	the web service resources and releases the license, if applicable. The session instance 
	communicates asynchronous messages to its delegate, if set. The delegate methods are 
	not mandatory. 
 
	There is exactly one session instance available to an application; it is retrievable 
	via the sharedSession() class method. Usually the application will open the session as 
	soon as user credentials are available and keep it open for the lifetime of the 
	application. 
*/
@interface NUSASession : NSObject {
	@protected	
	id<NUSASessionDelegate>	delegate; 
}

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Properties
//////////////////////////////////////////////////////////////////////////////////////////

/** @brief NUSASession delegate.
	@since 1.0

	This delegate receives messages from the session instance. Delegates must 
	conform to the NUSASessionDelegate protocol. The delegate will not be 
	retained. 
 */
@property (nonatomic, assign) id<NUSASessionDelegate> delegate; 

/**	@brief Dragon Medical Server URL
	@since 1.1
	
	The Dragon Medical Server URL that the SpeechKit will contact and use for
	speech recognition functionality. 
 */
@property (nonatomic, copy) NSString* serverURL; 

/** @brief Deprecated, setting this property will have no effect.
    @deprecated As of release 3.2
 */
@property (nonatomic, copy) NSString* language __attribute__((deprecated));

/** @brief The voice to use for speech
    @since 1.3
 
    Applications can set the speaking voice for TTS. Setting the voice is optional, if no speaker is selected, a predefined default value is used (kNUSASpeakingVoiceFemale).
 */
@property (nonatomic, copy) NSString* speakingVoice; 

/**	@brief Dragon Medical SpeechKit application help URL
 @since 1.3
 
URL where the application help is hosted. If this value is set prior to calling openForApplication, the "What You Can Say" page will contain the application's online help. 
 */
@property (nonatomic, copy) NSString* onlineHelpURL; 

/** @brief Returns the shared client session instance.
	@since 1.0

	Returns the shared Dragon Medical SpeechKit client session instance. The shared session instance
	is guaranteed to be valid throughout the life time of your application. 
 
	@return The shared Dragon Medical SpeechKit client session instance.
*/
+ (NUSASession*) sharedSession;

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Authenticating with the service
//////////////////////////////////////////////////////////////////////////////////////////


/** @brief Authenticates a user with the Dragon Medical Server.
	@since 1.0

	This message creates a connection to the Dragon Medical Server and authenticates
	the application, user and account information as passed. Sessions are usually opened as 
	soon as user credentials are available in your application. Licensing errors will 
	be displayed to the end user of your application.
 
	Note that the Dragon Medical Server will automatically free user licenses if there are
	longer periods of inactivity. In these cases you do not need to explicitly reopen or close the 
	session; the license will be reaquired automatically with the next user activity, e.g. starting 
	a recording session.
  
	If the licenseGuid or partnerGuid parameter were not specified (e.g. a @c nil object was passed), 
	Dragon Medical SpeechKit will not try to verify the license with the web service and will not offer 
	speech recognition related functionality to the end user or your application - it has the same effect 
	as not calling the method at all. E.g. calling startRecording:() will not have any effect. 

	@param userId			Mandatory user ID of the author. The user ID must be a non-empty string. 
	@param licenseGuid		Organization token (due to a terminology change the organization token should be passed to the licenseGuid parameter). Invalid organization tokens will be rejected during runtime and 
							cause an alert message to appear to the end user.  
    @param partnerGuid		Partner GUID. Invalid partner guids will be rejected during runtime and 
							cause an alert message to appear to the end user. 
	@param applicationName	Mandatory application name. The application name identifies your application on the 
							web service and can be chosen by your integration. The application name is not 
							part of the licensing information; it can be any string up to 50 characters in length. 
 */
- (void) openForApplication: (NSString*) applicationName partnerGuid: (NSString*) partnerGuid licenseGuid: (NSString*) licenseGuid userId: (NSString*) userId;  

/** @brief Frees web service resources and licenses on the Dragon Medical Server.
	@since 1.0

	This message disconnects and frees any speech recognition resources and user licenses on the 
	Dragon Medical Server. Usually the session should be closed when the application is
	shut down, or becomes inactive. 
 
	Note that the Dragon Medical Server will automatically free user licenses transparently
	to your application in case of longer periods of inactivity. In these cases you do not need to 
	explicitly reopen or close the session; the license will be reaquired automatically by the 
	next user activity, e.g. starting a recording session. 
 */
- (void) close;

/** @brief Enables NHID authentication for using speech recognition.
    @since 3.0
 
    In the “Physician Portal” users can log in with their NHID. This is where they can browse 
    the list of NHID Standard applications and access the corresponding zero-config links.
    After a link reaches the application, it is passed to the Dragon Medical Server using this method.
 
    After enabling the NHID authentication, the openForApplication method should be called 
    with the "EnableNHIDOrganizationToken" parameter instead of the organization token.
 
    @param url  The zero-config link accessed from the “Physician Portal”.
    @return     Returns empty string if everything was OK, otherwise some debug info on what went wrong.
 */
- (NSString*) enableNHIDWithUrl: (NSString*) url;

/** @brief Check if NHID authentication is enabled on the current device.
    @since 3.0

    @return @c YES if NHID authentication is enabled, otherwise @c NO.
 */
- (BOOL) isNHIDEnabled;

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Using speech recognition
//////////////////////////////////////////////////////////////////////////////////////////

/** @brief Starts recording audio data and audio processing on the Dragon Medical Server.
	@since 1.0

	This message starts recording audio data via the active audio route and starts 
	recognizing recorded and streamed audio data on the Dragon Medical Server.
	Once started, recording will continue until stopRecording() is called explicitly. Note that 
	recording will also be stopped implicitly after a period of inactivity. The session will send the 
	sessionDidStartRecording() message to its delegate. 
 
	While audio data recording is active, audio data will be sent to the web service to be 
	recognized. Recognized text is then added to the currently active GUI control.
 
	If audio data is already recorded, this method does not do anything. If the session has not 
	been previously opened, the method does not do anything. 
 
	@param	error	If recording could not be started, error information is passed via this
					parameter, otherwise @c nil.
	@return			Returns @c NO if recording could not be started. More information about the 
					failure is passed in the error parameter. 
 */
- (BOOL) startRecording: (NSError**) error;

/** @brief Starts recording audio data and audio processing on the Dragon Medical Server.
	@since 1.3
 
	This message starts recording audio data via the active audio route and starts 
	recognizing recorded and streamed audio data on the Dragon Medical Server.
	Once started, recording will continue until the system detects that the user stopped 
	speaking or stopRecording() is called explicitly. The session will send the 
	sessionDidStartRecording() message to its delegate. 
 
	While audio data recording is active, audio data will be sent to the web service to be 
	recognized. Recognized text is then added to the currently active GUI control.
 
	If audio data is already recorded, this method does not do anything. If the session has not 
	been previously opened, the method does not do anything. 
 
	@param	error	If recording could not be started, error information is passed via this
	parameter, otherwise @c nil.
	@return			Returns @c NO if recording could not be started. More information about the 
	failure is passed in the error parameter. 
 */
- (BOOL) startRecordingOneUtterance: (NSError**) error;

/** @brief Stops recording audio data.
	@since 1.0

	This message stops recording audio data and requests any pending recognition results from the Dragon
	Medical Server. If recording is not running, this method does not do anything. If the
	session has not been previously opened, the method does not do anything. The session will send the 
	sessionDidStopRecording message to its delegate. 
 */
- (void) stopRecording;

/** @brief Aborts recording audio data.
	@since 1.3
 
	The message aborts recording audio data and discards any pending recognition results from the Dragon
	Medical Server. If recording is not running, this method does not do anything. If the
	session has not been previously opened, the method does not do anything. The session will send the 
	sessionDidStopRecording message to its delegate. 
 */
- (void) abortRecording;

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Using TTS
//////////////////////////////////////////////////////////////////////////////////////////

/** @brief Starts speaking. 
    @since 1.3
 
    This message starts speaking the provided text. 
    Once started, speaking will continue until the text has been read in full or stopSpeaking is called.
	The session will send the sessionDidStartSpeaking message to its delegate.
 
	If speaking is already active, new request are queued.
    If the session has not been previously opened, the method does not do anything. If the provided text is nil or empty,
	the method does not do anything.
 
	@param	text	The string to be spoken.
 */
- (void) startSpeaking: (NSString*) text;

/** @brief Stops speaking
    @since 1.3
 
    Stops speaking. All pending spaking request are cancelled. 
    If speaking is not running, this method does not do anything. If the
	session has not been previously opened, the method does not do anything. The session will send the 
	sessionDidStopSpeaking message to its delegate. 
 */
- (void) stopSpeaking;


//////////////////////////////////////////////////////////////////////////////////////////
/// @name Personalization and help screen
//////////////////////////////////////////////////////////////////////////////////////////

/** @brief Displays the specified content in a separate window
    @since 3.0
 
    The window is only displayed if an open VuiController exists. If there is no open VuiController or the session was not opened previously,
    the method does not do anything
 
    @param contentType    Type of the content to be displayed.
 */
- (void) showFormWithContent: (NUSAContentType) contentType;


@end
