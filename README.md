This is a universal oauth login controller designed to be used with OAuthConsumer.<br /> 
It takes a couple of settings for your specific OAuth setup and displays the login in a webview.  


<pre>

// Setup the login controller
BTOAuthLoginViewController *loginController = [[[BTOAuthLoginViewController alloc] init] autorelease];
loginController.delegate = self;
loginController.consumerKey = @"Your Consumer Key";
loginController.consumerSecret = @"Your Consumer Secret";;
    
// Twitter example
loginController.requestTokenEndpoint = @"https://api.twitter.com/oauth/request_token";
loginController.accessTokenEndpoint = @"https://api.twitter.com/oauth/access_token";
loginController.authorizationEndpoint = @"https://api.twitter.com/oauth/authorize";
loginController.consumerRealm = @"https://api.twitter.com";

// This can be anything.  It will not be called
loginController.authorizationCallbackUrl = @"http://sbtwitter.com";

// This flag is used to hide the cancel bar at the top of the view.  This defaults to NO.
loginController.hideCancelBar = NO;

[self presentModalViewController: loginController];
</pre>

<br /><br />

The login controller will send you the oauth token or alert you of an error 
using the following delegate methods.

<pre>

/**
 *  Called when the OAuth login is successful.
 *
 *  @param  token   The OAuth token.
 *  @param  responseString  The response string from the oauth request. 
 */
- (void) BTOAuthLoginDidSucceedWithAccessToken: (OAToken *) token andResponseString: (NSString *) responseString;

/**
 *  Called when the OAuth login fails.
 *
 *  @param  error   The reason it failed.
 */
- (void) BTOAuthLoginDidFailWithError: (NSError *) error;

/**
 *  Called when the user cancels authentication.
 */
- (void) BTOAuthLoginCanceled;

</pre>


<p>
This library uses the popular <a href="http://code.google.com/p/oauthconsumer/">OAConsumer Library</a> and the <br />
<a href="http://allseeing-i.com/ASIHTTPRequest/">ASIHTTPRequest Library</a> to process the login.  Thanks to those guys.
</p>

<p> This is free to use however. </p>

