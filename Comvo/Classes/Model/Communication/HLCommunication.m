//
//  FUCommunication.m
//  FitnessUnion
//
//  Created by DeMing Yu on 7/11/14.
//  Copyright (c) 2014 DeMing Yu. All rights reserved.
//
// Web Services ;

#import "HLCommunication.h"
#import "AFHTTPRequestOperationManager.h"
#import "AFHTTPRequestOperation.h"

#import "Constants_Comvo.h"

#import <AFHTTPSessionManager.h>

@interface HLCommunication ()

@end

@implementation HLCommunication

#pragma mark - Shared Functions
+ ( HLCommunication* ) sharedManager
{
    __strong static HLCommunication* sharedObject = nil ;
	static dispatch_once_t onceToken ;
    
    dispatch_once( &onceToken, ^{
        sharedObject = [ [ HLCommunication alloc ] init ] ;
	} ) ;
    
    return sharedObject ;
}

#pragma mark - HLCommunication
- ( id ) init
{
    self = [ super init ] ;
    
    if( self )
    {
        
    }
    
    return self ;
}

#pragma mark - Web Service

- ( void ) sendToService : (NSString *) _url
                 params  : ( NSDictionary* ) _params
                 success : ( void (^)( id _responseObject ) ) _success
                 failure : ( void (^)( NSError* _error ) ) _failure
{
#if 0
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.securityPolicy.allowInvalidCertificates = YES;
    
    [manager POST: [NSString stringWithFormat: @"%@%@", API_HOME, _url] parameters:_params success:^(AFHTTPRequestOperation *operation, id _responseObject){
		
        if( _success )
        {
            _success( _responseObject ) ;
        }
		
    } failure:^(AFHTTPRequestOperation *operation, NSError *_error) {
        if( _failure )
        {
            NSLog(@"%@",_error.description);
            _failure( _error ) ;
            
        }
    }];
#else
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString: API_HOME]];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager POST: _url parameters: _params success: ^(NSURLSessionDataTask *task, id responseObject) {
        NSData *data = (NSData*)responseObject;
        NSLog(@"response=%@",[NSString stringWithUTF8String:data.bytes]);
        NSDictionary *dict=[NSJSONSerialization JSONObjectWithData:(NSData *)responseObject options:NSJSONReadingAllowFragments error:nil];
        NSLog(@"response=%@", dict);
        
        if( _success )
        {
            _success( dict ) ;
        }
        
    } failure: ^(NSURLSessionDataTask *task, NSError *error) {
        if( _failure )
        {
            NSLog(@"%@",error.description);
            _failure( error ) ;
            
        }
    }];
    
#endif
}

- ( void ) sendToServiceWithImage : (NSString *) _url
                          params  : ( NSDictionary* ) _params
                            image : ( NSData* ) _imageData
                          success : ( void (^)( id _responseObject ) ) _success
                          failure : ( void (^)( NSError* _error ) ) _failure
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.securityPolicy.allowInvalidCertificates = YES;
    
    [manager POST: [NSString stringWithFormat: @"%@%@", API_HOME, _url] parameters: _params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData: _imageData name: @"file" fileName: @"attachment.jpg" mimeType: @"image/jpg"];
    } success:^(AFHTTPRequestOperation *operation, id _responseObject) {
        
        if( _success )
        {
            _success( _responseObject ) ;
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *_error) {
        
        if( _failure )
        {
            NSLog(@"%@",_error.description);
            _failure( _error ) ;
            
        }
        
    }];
}

- ( void ) sendToServiceWithMedia : (NSString *) _url
                           params : (NSDictionary *) _params
                            media : (NSData *) _mediaData
                         fileName : (NSString *) fileName
                         mimeType : (NSString *) mimeType
                            image : ( NSData* ) _imageData
                          success : (void (^)(id _responseObject)) _success
                          failure : (void (^)(NSError* _error)) _failure
{
    
}

- ( void ) sendToServiceWithMedia : (NSString *) _url
                           params : (NSDictionary *) _params
                            media : (NSData *) _mediaData
                         fileName : (NSString *) fileName
                         mimeType : (NSString *) mimeType
                          success : (void (^)(id _responseObject)) _success
                          failure : (void (^)(NSError* _error)) _failure
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.securityPolicy.allowInvalidCertificates = YES;
    
    [manager POST: [NSString stringWithFormat: @"%@%@", API_HOME, _url] parameters: _params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData: _mediaData name: @"media" fileName: fileName mimeType: mimeType];
    } success:^(AFHTTPRequestOperation *operation, id _responseObject) {
        
        if( _success )
        {
            _success( _responseObject ) ;
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *_error) {
        NSLog(@"%@", operation.responseString);
        if( _failure )
        {
            NSLog(@"%@",_error.description);
            _failure( _error ) ;
            
        }
        
    }];
}

- ( void ) sendToServiceWithMedia : (NSString *) _url
                           params : (NSDictionary *) _params
                            media : (NSData *) _mediaData
                         fileName : (NSString *) fileName
                         thumbnail: (NSData *) _imageThumbnailData
                         mimeType : (NSString *) mimeType
                          success : (void (^)(id _responseObject)) _success
                          failure : (void (^)(NSError* _error)) _failure
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    //    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.securityPolicy.allowInvalidCertificates = YES;
    
    [manager POST: [NSString stringWithFormat: @"%@%@", API_HOME, _url] parameters: _params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData: _mediaData name: @"media" fileName: fileName mimeType: mimeType];
        [formData appendPartWithFileData: _imageThumbnailData name: @"thumbnail" fileName: @"thumbnail.jpg" mimeType: @"image/jpg"];
    } success:^(AFHTTPRequestOperation *operation, id _responseObject) {
        
        if( _success )
        {
            _success( _responseObject ) ;
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *_error) {
        NSLog(@"%@", operation.responseString);
        if( _failure )
        {
            NSLog(@"%@",_error.description);
            _failure( _error ) ;
            
        }
        
    }];
}



- ( void ) sendToServiceWithMultiImages : (NSString *) _url
                          params  : ( NSDictionary* ) _params
                        arrImages : ( NSArray* ) arrImages
                          success : ( void (^)( id _responseObject ) ) _success
                          failure : ( void (^)( NSError* _error ) ) _failure
{
    
#if 0
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.securityPolicy.allowInvalidCertificates = YES;
    
    [manager POST: [NSString stringWithFormat: @"%@%@", API_HOME, _url] parameters: _params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        for (int i = 0; i < [arrImages count]; i++) {
            NSData *_imageData = [arrImages objectAtIndex: i];
            [formData appendPartWithFileData: _imageData name: @"photos[]" fileName: @"attachment.jpg" mimeType: @"image/jpg"];
        }
        
    } success:^(AFHTTPRequestOperation *operation, id _responseObject) {
        
        if( _success )
        {
            _success( _responseObject ) ;
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *_error) {
        
        if( _failure )
        {
            NSLog(@"%@",_error.description);
            _failure( _error ) ;
            
        }
    }];
#endif
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString: API_HOME]];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager POST: _url parameters: _params constructingBodyWithBlock: ^(id<AFMultipartFormData> formData) {
        for (int i = 0; i < [arrImages count]; i++) {
            NSData *_imageData = [arrImages objectAtIndex: i];
            [formData appendPartWithFileData: _imageData name: @"photos[]" fileName: @"attachment.jpg" mimeType: @"image/jpg"];
        }
    } success: ^(NSURLSessionDataTask *task, id responseObject) {
        NSData *data = (NSData*)responseObject;
        NSLog(@"respnose=%@",[NSString stringWithUTF8String:data.bytes]);
        NSDictionary *dict=[NSJSONSerialization JSONObjectWithData:(NSData *)responseObject options:NSJSONReadingAllowFragments error:nil];
        NSLog(@"response=%@", dict);
        
        if( _success )
        {
            _success( dict ) ;
        }
        
    } failure: ^(NSURLSessionDataTask *task, NSError *error) {
        if( _failure )
        {
            NSLog(@"%@",error.description);
            _failure( error );
        }
    }];
}

- ( void ) sendToServiceWithProfileImage : (NSString *) _url
                                  params  : ( NSDictionary* ) _params
                                    image : ( NSData* ) _imageData
                                  success : ( void (^)( id _responseObject ) ) _success
                                  failure : ( void (^)( NSError* _error ) ) _failure
{
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString: API_HOME]];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager POST: _url parameters: _params constructingBodyWithBlock: ^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData: _imageData name: @"profile_photo" fileName: @"attachment.jpg" mimeType: @"image/jpg"];
    } success: ^(NSURLSessionDataTask *task, id responseObject) {
        NSData *data = (NSData*)responseObject;
        NSLog(@"respnose=%@",[NSString stringWithUTF8String:data.bytes]);
        NSDictionary *dict=[NSJSONSerialization JSONObjectWithData:(NSData *)responseObject options:NSJSONReadingAllowFragments error:nil];
        NSLog(@"response=%@", dict);
        
        if( _success )
        {
            _success( dict ) ;
        }
        
    } failure: ^(NSURLSessionDataTask *task, NSError *error) {
        if( _failure )
        {
            NSLog(@"%@",error.description);
            _failure( error ) ;
            
        }
    }];
}

- ( void ) sendToServiceWithProfileImage : (NSString *) _url
                                 params  : ( NSDictionary* ) _params
                           greetingAudio : ( NSData *)_greetingAudio
                                 success : ( void (^)( id _responseObject ) ) _success
                                 failure : ( void (^)( NSError* _error ) ) _failure
{
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString: API_HOME]];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager POST: _url parameters: _params constructingBodyWithBlock: ^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData: _greetingAudio name: @"greeting_audio" fileName: @"recording.aac" mimeType: @"audio/aac"];
    } success: ^(NSURLSessionDataTask *task, id responseObject) {
        NSData *data = (NSData*)responseObject;
        NSLog(@"response=%@",[NSString stringWithUTF8String:data.bytes]);
        NSDictionary *dict=[NSJSONSerialization JSONObjectWithData:(NSData *)responseObject options:NSJSONReadingAllowFragments error:nil];
        NSLog(@"response=%@", dict);
        
        if( _success )
        {
            _success( dict ) ;
        }
        
    } failure: ^(NSURLSessionDataTask *task, NSError *error) {
        if( _failure )
        {
            NSLog(@"%@",error.description);
            _failure( error ) ;
            
        }
    }];
}


- ( void ) sendToServiceWithProfileImage : (NSString *) _url
                                 params  : ( NSDictionary* ) _params
                                   image : ( NSData* ) _imageData
                           greetingAudio : ( NSData *)_greetingAudio
                                 success : ( void (^)( id _responseObject ) ) _success
                                 failure : ( void (^)( NSError* _error ) ) _failure
{
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString: API_HOME]];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager POST: _url parameters: _params constructingBodyWithBlock: ^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData: _imageData name: @"profile_photo" fileName: @"attachment.jpg" mimeType: @"image/jpg"];
        [formData appendPartWithFileData: _greetingAudio name: @"greeting_audio" fileName: @"recording.aac" mimeType: @"audio/aac"];
    } success: ^(NSURLSessionDataTask *task, id responseObject) {
        NSData *data = (NSData*)responseObject;
        NSLog(@"response=%@",[NSString stringWithUTF8String:data.bytes]);
        NSDictionary *dict=[NSJSONSerialization JSONObjectWithData:(NSData *)responseObject options:NSJSONReadingAllowFragments error:nil];
        NSLog(@"response=%@", dict);
        
        if( _success )
        {
            _success( dict ) ;
        }
        
    } failure: ^(NSURLSessionDataTask *task, NSError *error) {
        if( _failure )
        {
            NSLog(@"%@",error.description);
            _failure( error ) ;
            
        }
    }];
}

- ( void ) sendToServiceSendToAdmin : (NSString *) _url
                                 params  : ( NSDictionary* ) _params
                                   image : ( NSData* ) _imageData
                                 success : ( void (^)( id _responseObject ) ) _success
                                 failure : ( void (^)( NSError* _error ) ) _failure
{
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString: API_HOME]];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager POST: _url parameters: _params constructingBodyWithBlock: ^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData: _imageData name: @"photo" fileName: @"Image.jpg" mimeType: @"image/jpg"];
    } success: ^(NSURLSessionDataTask *task, id responseObject) {
        NSData *data = (NSData*)responseObject;
        NSLog(@"respnose=%@",[NSString stringWithUTF8String:data.bytes]);
        NSDictionary *dict=[NSJSONSerialization JSONObjectWithData:(NSData *)responseObject options:NSJSONReadingAllowFragments error:nil];
        NSLog(@"response=%@", dict);
        
        if( _success )
        {
            _success( dict ) ;
        }
        
    } failure: ^(NSURLSessionDataTask *task, NSError *error) {
        if( _failure )
        {
            NSLog(@"%@",error.description);
            _failure( error ) ;
            
        }
    }];
}

- (void)downloadImage: (NSURL *)url
             success : ( void (^)( id _responseObject ) ) _success
             failure : ( void (^)( NSError* _error ) ) _failure
{
    NSURLRequest *request = [NSURLRequest requestWithURL: url];
    
    AFHTTPRequestOperation *requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest: request];
    requestOperation.responseSerializer = [AFImageResponseSerializer serializer];
    requestOperation.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if( _success )
        {
            _success( responseObject ) ;
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        if( _failure )
        {
            NSLog(@"%@",error.description);
            _failure( error ) ;
            
        }

    }];
    
    [requestOperation start];
//    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
//    
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"filename"];
//    operation.outputStream = [NSOutputStream outputStreamToFileAtPath:path append:NO];
//    
//    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog(@"Successfully downloaded file to %@", path);
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSLog(@"Error: %@", error);
//    }];

}


@end
