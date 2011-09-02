This is a universal oauth login controller designed to be used with OAuthConsumer.<br /> 
It takes a couple of settings for your specific OAuth setup and displays the login in a webview.  


<pre>
BTOAuthLoginViewController *loginController = [[[BTOAuthLoginViewController alloc] init] autorelease];
loginController.delegate = self;
loginController.consumerKey = @"Your Consumer Key";
loginController.consumerSecret = @"Your Consumer Secret";;
    
loginController.requestTokenEndpoint = @"https://api.twitter.com/oauth/request_token";
loginController.accessTokenEndpoint = @"https://api.twitter.com/oauth/access_token";
loginController.authorizationEndpoint = @"https://api.twitter.com/oauth/authorize";
loginController.consumerRealm = @"https://api.twitter.com";

// This can be anything.  It will not be called
loginController.authorizationCallbackUrl = @"http://sbtwitter.com";

[self presentModalViewController: loginController];
</pre>
