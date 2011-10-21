//
//  BTOAuthLoginDelegate.h
//
//  Created by Brandon Tate on 8/31/11.
//  Copyright 2011 Brandon Tate. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OAToken.h"

@protocol BTOAuthLoginDelegate <NSObject>

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

@end
