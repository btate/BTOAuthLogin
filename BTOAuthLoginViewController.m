//
//  BTOAuthLoginViewController.m
//
//  Created by Brandon Tate on 8/31/11.
//  Copyright 2011 Brandon Tate. All rights reserved.
//

#import "BTOAuthLoginViewController.h"
#import "OAMutableURLRequest.h"
#import "OADataFetcher.h"


@interface BTOAuthLoginViewController()

/** Private property for consumer. */
@property (nonatomic, retain)   OAConsumer  *consumer;


// OAuth Methods

- (void) startOAuth;
- (void) requestTokenFromProvider;
- (void) requestTokenRequest:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data;
- (void) requestTokenRequest:(OAServiceTicket *)ticket didFailWithError:(NSError *)error;
- (void) loadLoginPage;
- (void) accessTokenFromProvider;
- (void) accessTokenRequest:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data;
- (void) accessTokenRequest:(OAServiceTicket *)ticket didFailWithError:(NSError *)error;
- (NSString *) extractVerifierFromOAuthUrl:(NSString *)url;

@end

@implementation BTOAuthLoginViewController

@synthesize delegate=_delegate;
@synthesize hideCancelBar, usePostMethodForLogin;
@synthesize consumer = _consumer;
@synthesize requestToken=_requestToken, accessToken=_accessToken, responseString=_responseString;
@synthesize consumerRealm=_consumerRealm, consumerKey=_consumerKey, consumerSecret=_consumerSecret, requestTokenEndpoint=_requestTokenEndpoint;
@synthesize accessTokenEndpoint=_accessTokenEndpoint, authorizationEndpoint=_authorizationEndpoint, authorizationCallbackUrl=_authorizationCallbackUrl;
@synthesize webview=_webview, navBar=_navBar, activityIndicator=_activityIndicator;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.hideCancelBar = NO;
        self.usePostMethodForLogin = YES;
    }
    return self;
}

- (id) init{
    self = [super initWithNibName:@"BTOAuthLoginViewController" bundle:nil];
    if (self) {
        // Setup custom stuff
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


- (void) dealloc{
    
    [_consumerRealm release]; _consumerRealm = nil;
    [_requestToken release]; _requestToken = nil;
    [_accessToken release]; _accessToken = nil;
    [_responseString release]; _responseString = nil;
    [_consumerKey release]; _consumerKey = nil;
    [_consumerSecret release]; _consumerSecret = nil;
    [_requestTokenEndpoint release]; _requestTokenEndpoint = nil;
    [_accessTokenEndpoint release]; _accessTokenEndpoint = nil;
    [_authorizationEndpoint release]; _authorizationEndpoint = nil;
    [_authorizationCallbackUrl release]; _authorizationEndpoint = nil;
    [_webview release]; _webview = nil;
    [_navBar release]; _navBar = nil;
    [_activityIndicator release]; _activityIndicator = nil;
    [_consumer release]; _consumer = nil;
    _delegate = nil;
    
    [super dealloc];
    
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void) viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    // Adjust to let the webview take the whole view
    if (self.hideCancelBar) {
        CGRect navBarFrame = self.navBar.frame;
        CGRect webViewFrame = self.webview.frame;
        
        webViewFrame.size.height = webViewFrame.size.height + navBarFrame.size.height;
        webViewFrame.origin.y = navBarFrame.origin.y;
        
        self.navBar.hidden = YES;
        self.webview.frame = webViewFrame;
        
    }
    
}

- (void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self startOAuth];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}



#pragma mark - OAuth Methods

/**
 *  Starts the oauth process.
 */
- (void) startOAuth{
    
    self.consumer = [[[OAConsumer alloc] initWithKey:self.consumerKey secret:self.consumerSecret] autorelease];
    [self.activityIndicator startAnimating];
    [self requestTokenFromProvider];
}

/**
 *  Gets a request token from the oauth provider.
 */
- (void) requestTokenFromProvider{
    
    OAMutableURLRequest *request = 
    [[[OAMutableURLRequest alloc] initWithURL:[NSURL URLWithString: self.requestTokenEndpoint]
                                     consumer:self.consumer
                                        token:nil   
                                     realm:self.consumerRealm
                            signatureProvider:nil] autorelease];
    
    OARequestParameter *callbackParameter = [[[OARequestParameter alloc] 
                                              initWithName:@"oauth_callback" 
                                              value:self.authorizationCallbackUrl
                                              ] autorelease];
    
    
    [request setHTTPMethod:@"POST"];
    [request setParameters:[NSArray arrayWithObject:callbackParameter]];
       
    OADataFetcher *fetcher = [[[OADataFetcher alloc] init] autorelease];
    [fetcher fetchDataWithRequest:request
                         delegate:self
                didFinishSelector:@selector(requestTokenRequest:didFinishWithData:)
                  didFailSelector:@selector(requestTokenRequest:didFailWithError:)];
   
}

/**
 *  Creates a request token from the data.  Uses it to log the user in.
 *
 *  @param  ticket  The previous request ticket.
 *  @param  data    The response data.
 */
- (void) requestTokenRequest:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data{
    
    if (ticket.didSucceed == NO) {
        if ([self.delegate respondsToSelector:@selector(BTOAuthLoginDidFailWithError:)]) {
            NSError *error = [NSError errorWithDomain:@"com.brandontate.btoauthlogin" code:42 userInfo:[NSDictionary dictionaryWithObject:ticket.body forKey:NSLocalizedDescriptionKey]];
            
            
            [self.delegate BTOAuthLoginDidFailWithError:error];
        }
        return;
    }
    
    NSString *responseBody = [[NSString alloc] initWithData:data
                                                   encoding:NSUTF8StringEncoding];
    [_requestToken autorelease];
    _requestToken = [[[OAToken alloc] initWithHTTPResponseBody:responseBody] retain];
    [responseBody release];
    
    [self loadLoginPage];
    
}

/**
 *  Called when oauth request token request fails.
 *
 *  @param  ticket  The previous request ticket.
 *  @param  error   The error.
 */
- (void) requestTokenRequest:(OAServiceTicket *)ticket didFailWithError:(NSError *)error{
    
    if ([self.delegate respondsToSelector:@selector(BTOAuthLoginDidFailWithError:)]) {
        [self.delegate BTOAuthLoginDidFailWithError:error];
    }
    
}

/**
 *  Loads the login page into the webview.
 *
 */
- (void) loadLoginPage{
    
    // Need to adjust this to allow post or get
    // Or just do post for now and look at linked in later
    NSMutableURLRequest *request;
    
    if (self.usePostMethodForLogin) {
        NSString *postString = [NSString stringWithFormat:@"oauth_token=%@&auth_token_secret=%@", self.requestToken.key, self.requestToken.secret];
        NSData *postData = [NSData dataWithBytes:[postString UTF8String] length:[postString length]];
        request = [[[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:self.authorizationEndpoint]] autorelease];
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody:postData];
    }
    else{
        NSString *authorizationURLWithToken = [NSString stringWithFormat:@"%@?oauth_token=%@&auth_token_secret=%@", 
                                           self.authorizationEndpoint, self.requestToken.key, self.requestToken.secret];
        
        NSURL *authorizationURL = [NSURL URLWithString:authorizationURLWithToken];
        request = [NSMutableURLRequest requestWithURL: authorizationURL];
    }
    
    
    
    [self.webview loadRequest:request];
    
}


/**
 *  Requests an access token from the provider
 */
- (void) accessTokenFromProvider{
    
    OAMutableURLRequest *request = 
    [[[OAMutableURLRequest alloc] initWithURL:[NSURL URLWithString:self.accessTokenEndpoint]
                                     consumer:self.consumer
                                        token:self.requestToken   
                                     realm:self.consumerRealm
                            signatureProvider:nil] autorelease];
    
    
    
    
    [request setHTTPMethod:@"POST"];
    OADataFetcher *fetcher = [[[OADataFetcher alloc] init] autorelease];
    [fetcher fetchDataWithRequest:request
                         delegate:self
                didFinishSelector:@selector(accessTokenRequest:didFinishWithData:)
                  didFailSelector:@selector(accessTokenRequest:didFailWithError:)];
    
}


/**
 *  Creates a request token from the data.  Uses it to log the user in.
 *
 *  @param  ticket  The previous request ticket.
 *  @param  data    The response data.
 */
- (void) accessTokenRequest:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data {
    
    NSString *responseBody = [[NSString alloc] initWithData:data
                                                   encoding:NSUTF8StringEncoding];
    
    BOOL problem = ([responseBody rangeOfString:@"oauth_problem"].location != NSNotFound);
    if ( problem )
    {
        if ([self.delegate respondsToSelector:@selector(BTOAuthLoginDidFailWithError:)]) {
            NSError *error = [NSError errorWithDomain:@"com.brandontate.btoauthlogin" code:42 userInfo:[NSDictionary dictionaryWithObject:ticket.body forKey:NSLocalizedDescriptionKey]];
            [self.delegate BTOAuthLoginDidFailWithError:error];
        }
        
    }
    else
    {
        [_accessToken autorelease];
        _accessToken = [[[OAToken alloc] initWithHTTPResponseBody:responseBody] retain];
        if ([self.delegate respondsToSelector:@selector(BTOAuthLoginDidSucceedWithAccessToken:andResponseString:)]) {
            [self.delegate BTOAuthLoginDidSucceedWithAccessToken:self.accessToken andResponseString:responseBody];
        }
    }
    [responseBody release];
    
}

/**
 *  Called when oauth access token request fails.
 *
 *  @param  ticket  The previous request ticket.
 *  @param  error   The error.
 */
- (void) accessTokenRequest:(OAServiceTicket *)ticket didFailWithError:(NSError *)error{
    
    if ([self.delegate respondsToSelector:@selector(BTOAuthLoginDidFailWithError:)]) {
        
        [self.delegate BTOAuthLoginDidFailWithError:error];
    }
    
}

#pragma mark - Helper Methods

/**
 *  Gets the verifier from the oauth url.
 *
 *  @param  url    The url string.
 *
 *  @return NSString    The Verifier.
 */
- (NSString *) extractVerifierFromOAuthUrl:(NSString *)url{
    if (!url) return nil;
	
	NSArray					*tuples = [url componentsSeparatedByString: @"&"];
	if (tuples.count < 1) return nil;
	
	for (NSString *tuple in tuples) {
		NSArray *keyValueArray = [tuple componentsSeparatedByString: @"="];
		
		if (keyValueArray.count == 2) {
			NSString				*key = [keyValueArray objectAtIndex: 0];
			NSString				*value = [keyValueArray objectAtIndex: 1];
			
			if ([key isEqualToString:@"oauth_verifier"]) return value;
		}
	}
	
	return nil;
}

#pragma mark - UIWebViewDelegate Methods

/**
 *  Checks the request against the callback url. 
 *  If the request is the callback url, request verifier is parsed out and a request is sent
 *  for the access token.
 */
- (BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType 
{
    
	NSURL *url = request.URL;
	NSString *urlString = url.absoluteString;
    
    [self.activityIndicator startAnimating];
    
    // Check for callback url
    BOOL requestForCallbackURL = ([urlString rangeOfString:self.authorizationCallbackUrl].location != NSNotFound);
    if ( requestForCallbackURL )
    {
        // Check for acceptance
        BOOL userAllowedAccess = ([urlString rangeOfString:@"oauth_token="].location != NSNotFound);
        if ( userAllowedAccess )
        {   
            // Get the access token
            [_requestToken setVerifier:[self extractVerifierFromOAuthUrl:urlString]];
            [self accessTokenFromProvider];
        }
        else
        {
            // User refused to allow our app access
            // Notify parent and close this view
            if ([self.delegate respondsToSelector:@selector(BTOAuthLoginCanceled)]) {
                [self.delegate BTOAuthLoginCanceled];
            }
            
            [self dismissModalViewControllerAnimated:YES];
        }
        
        return NO;
    }
    
	return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self.activityIndicator stopAnimating];
}

#pragma mark - IBActions

/**
 *  Closes the window.
 *
 *  @param  sender  The sending view.
 *
 *  @return IBAction
 */
- (IBAction) close:(id)sender{
    
    [self.parentViewController dismissModalViewControllerAnimated:YES];
}


@end
