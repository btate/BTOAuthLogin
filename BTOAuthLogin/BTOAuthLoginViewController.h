//
//  BTOAuthLoginViewController.h
//
//  Created by Brandon Tate on 8/31/11.
//  Copyright 2011 Brandon Tate. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OAConsumer.h"
#import "OAToken.h"
#import "BTOAuthLoginDelegate.h"


@interface BTOAuthLoginViewController : UIViewController <UIWebViewDelegate>{
   
    /** The ouath request token. */
    OAToken     *_requestToken;
    
    /** The oauth access token. */
    OAToken     *_accessToken;
    
    /** The authentication response string. */
    NSString    *_responseString;
    
    /** The oauth consumer. */
    OAConsumer  *_consumer;
    
    /** The delegate. **/
    id<BTOAuthLoginDelegate>    _delegate;
    
}

/** Property for the delegate. */
@property(retain)   id  delegate;

// Flags

/** Flag to determine whether or not to hide the cancel bar. */
@property(nonatomic)            BOOL    hideCancelBar;

/** Flag for which http method to use for logging in.  Defaults to YES, which is POST. */
@property(nonatomic)            BOOL    usePostMethodForLogin;


// IBOutlets

/** The webview. */
@property (nonatomic, retain)       IBOutlet    UIWebView               *webview;

/** The navigation bar. */
@property (nonatomic, retain)       IBOutlet    UINavigationBar         *navBar;

/** An activity indicator. */
@property (nonatomic, retain)       IBOutlet    UIActivityIndicatorView *activityIndicator;

// OAuth Data

/** Read only property oauth request token. */
@property(nonatomic, readonly)  OAToken *requestToken;

/** Read only property oauth access token. */
@property(nonatomic, readonly)  OAToken *accessToken;

/** Read only property for the authentication response string. */
@property(nonatomic, readonly)  NSString *responseString;


// API Key

/** The consumer realm for the request. */
@property(nonatomic, retain)    NSString *consumerRealm;

/** The api key for the app. */
@property(nonatomic, retain)    NSString *consumerKey;

/** The secret key for the app. */
@property(nonatomic, retain)    NSString *consumerSecret;

/** The request token endpoint. */
@property(nonatomic, retain)    NSString *requestTokenEndpoint;

/** The access token endpoint. */
@property(nonatomic, retain)    NSString *accessTokenEndpoint;

/** The authorization endpoint. */
@property(nonatomic, retain)    NSString *authorizationEndpoint;

/** The callback url. */
@property(nonatomic, retain)    NSString *authorizationCallbackUrl;


// IBActions

- (IBAction) close:(id)sender;



@end
