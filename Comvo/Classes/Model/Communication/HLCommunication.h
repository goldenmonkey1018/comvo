//
//  FUCommunication.h
//  FitnessUnion
//
//  Created by Wendell on 7/11/14.
//  Copyright (c) 2014 Wendell. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface HLCommunication : NSObject
// Functions ;
+ (HLCommunication *) sharedManager;

- ( void ) sendToService : (NSString *) _url
                 params  : ( NSDictionary* ) _params
                 success : ( void (^)( id _responseObject ) ) _success
                 failure : ( void (^)( NSError* _error ) ) _failure;

- ( void ) sendToServiceWithImage : (NSString *) _url
                          params  : ( NSDictionary* ) _params
                            image : ( NSData* ) _imageData
                          success : ( void (^)( id _responseObject ) ) _success
                          failure : ( void (^)( NSError* _error ) ) _failure;

- ( void ) sendToServiceWithMedia : (NSString *) _url
                           params : (NSDictionary *) _params
                            media : (NSData *) _mediaData
                         fileName : (NSString *) fileName
                         mimeType : (NSString *) mimeType
                          success : (void (^)(id _responseObject)) _success
                          failure : (void (^)(NSError* _error)) _failure;

- ( void ) sendToServiceWithMedia : (NSString *) _url
                           params : (NSDictionary *) _params
                            media : (NSData *) _mediaData
                         fileName : (NSString *) fileName
                         mimeType : (NSString *) mimeType
                            image : ( NSData* ) _imageData
                          success : (void (^)(id _responseObject)) _success
                          failure : (void (^)(NSError* _error)) _failure;

- ( void ) sendToServiceWithMedia : (NSString *) _url
                           params : (NSDictionary *) _params
                            media : (NSData *) _mediaData
                         fileName : (NSString *) fileName
                         thumbnail: (NSData *) _imageThumbnailData
                         mimeType : (NSString *) mimeType
                          success : (void (^)(id _responseObject)) _success
                          failure : (void (^)(NSError* _error)) _failure;

- ( void ) sendToServiceWithMultiImages : (NSString *) _url
                                params  : ( NSDictionary* ) _params
                              arrImages : ( NSArray* ) arrImages
                                success : ( void (^)( id _responseObject ) ) _success
                                failure : ( void (^)( NSError* _error ) ) _failure;

- ( void ) sendToServiceWithProfileImage : (NSString *) _url
                                 params  : ( NSDictionary* ) _params
                                   image : ( NSData* ) _imageData
                                 success : ( void (^)( id _responseObject ) ) _success
                                 failure : ( void (^)( NSError* _error ) ) _failure;

- ( void ) sendToServiceWithProfileImage : (NSString *) _url
                                 params  : ( NSDictionary* ) _params
                           greetingAudio : ( NSData *)_greetingAudio
                                 success : ( void (^)( id _responseObject ) ) _success
                                 failure : ( void (^)( NSError* _error ) ) _failure;

- ( void ) sendToServiceWithProfileImage : (NSString *) _url
                                 params  : ( NSDictionary* ) _params
                                   image : ( NSData* ) _imageData
                           greetingAudio : ( NSData *)_greetingAudio
                                 success : ( void (^)( id _responseObject ) ) _success
                                 failure : ( void (^)( NSError* _error ) ) _failure;

- ( void ) sendToServiceSendToAdmin : (NSString *) _url
                            params  : ( NSDictionary* ) _params
                              image : ( NSData* ) _imageData
                            success : ( void (^)( id _responseObject ) ) _success
                            failure : ( void (^)( NSError* _error ) ) _failure;

- (void)downloadImage: (NSURL *)url
             success : ( void (^)( id _responseObject ) ) _success
             failure : ( void (^)( NSError* _error ) ) _failure;

@end

