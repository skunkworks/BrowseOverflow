//
//  StackOverflowCommunicator.m
//  BrowseOverflow
//
//  Created by Richard Shin on 1/11/14.
//  Copyright (c) 2014 Richard Shin. All rights reserved.
//

#import "StackOverflowCommunicator.h"

@interface StackOverflowCommunicator ()
// FIXME: stashing the completion and error handler blocks is not a good idea because back-to-back async
// requests will cause one to overwrite the other, and only one of the events receives a response!
@property (nonatomic, copy) void (^completionHandler)(NSString *jsonResponse);
@property (nonatomic, copy) void (^errorHandler)(NSError *error);
@end

@implementation StackOverflowCommunicator

NSString *const StackOverflowCommunicatorErrorDomain = @"StackOverflowCommunicatorErrorDomain";

- (void)setDelegate:(id<StackOverflowCommunicatorDelegate>)delegate
{
    if (delegate &&
        ![delegate conformsToProtocol:@protocol(StackOverflowCommunicatorDelegate)]) {
        [NSException raise:NSInvalidArgumentException
                    format:@"Delegate does not conform to required protocol"];
    }
    _delegate = delegate;
}

- (void)fetchContentAtURL:(NSURL *)url
{
    fetchingURL = url;
}

// Design issue: when the NSURLConnection gives us a response (via NSURLConnectionDataDelegate
// protocol methods), the communicator has different behavior depending on what API request
// it is fulfilling. For example, the connection:didReceiveResponse: method is the same for all
// requests, but connection:didFinishLoading: will be handled much differently, as the communicator
// will have to be responsible for returning that data to its delegate (i.e. the StackOverflowManager
// facade).
//
// The book recommends using blocks, which makes perfect sense because the block can carry around the
// code it should execute on success/failure. This should be set up when the connection
// is initiated. Makes sense to have blocks stored as properties -- completionHandler and
// errorHandler. Be careful about strong reference cycles (use weakSelf!)

- (void)initiateConnectionToURL:(NSURL *)url
              completionHandler:(void (^)(NSString *dataString))onCompletion
                   errorHandler:(void (^)(NSError *error))onError
{
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    [self cancelAndDiscardCurrentURLConnection];
    self.completionHandler = onCompletion;
    self.errorHandler = onError;
    receivedData = [NSMutableData data];
    fetchingConnection = [[NSURLConnection alloc] initWithRequest:request
                                                         delegate:self];
}

- (void)fetchQuestionsWithTag:(NSString *)tag
{
    NSParameterAssert(tag);
    
    NSString *urlString = [NSString stringWithFormat:@"http://api.stackexchange.com/2.1/search?pagesize=20&order=desc&sort=activity&site=stackoverflow&tagged=%@", tag];
    NSURL *url = [NSURL URLWithString:urlString];
    [self fetchContentAtURL:url];
    
    // To prevent having to refer to self and create a reference cycle
    id<StackOverflowCommunicatorDelegate> delegate = self.delegate;
    [self initiateConnectionToURL:url
                completionHandler:^(NSString *jsonResponse) {
                    [delegate fetchQuestionsDidReturnJSON:jsonResponse];
                }
                     errorHandler:^(NSError *error) {
                         [delegate fetchQuestionsFailedWithError:error];
                     }];
}

- (void)fetchBodyForQuestionWithID:(NSInteger)questionID
{
    NSString *urlString = [NSString stringWithFormat:@"http://api.stackexchange.com/2.1/questions/%ld?site=stackoverflow&filter=!9f*CwKRWa", (long)questionID];
    NSURL *url = [NSURL URLWithString:urlString];
    [self fetchContentAtURL:url];
    
    id<StackOverflowCommunicatorDelegate> delegate = self.delegate;
    [self initiateConnectionToURL:url
                completionHandler:^(NSString *jsonResponse) {
                    [delegate fetchBodyForQuestionWithID:questionID
                                           didReturnJSON:jsonResponse];
                }
                     errorHandler:^(NSError *error) {
                         [delegate fetchBodyForQuestionWithIDFailedWithError:error];
                     }];
}

- (void)fetchAnswersToQuestionWithID:(NSInteger)questionID
{
    NSString *urlString = [NSString stringWithFormat:@"http://api.stackexchange.com/2.1/questions/%ld/answers?order=desc&sort=activity&site=stackoverflow&filter=!-.AG)tkYKcl.", (long)questionID];
    NSURL *url = [NSURL URLWithString:urlString];
    [self fetchContentAtURL:url];
    
    id<StackOverflowCommunicatorDelegate> delegate = self.delegate;
    [self initiateConnectionToURL:url
                completionHandler:^(NSString *jsonResponse) {
                    [delegate fetchAnswersForQuestionWithID:questionID
                                              didReturnJSON:jsonResponse];
                }
                     errorHandler:^(NSError *error) {
                         [delegate fetchAnswersForQuestionWithIDFailedWithError:error];
                     }];
}

- (void)cancelAndDiscardCurrentURLConnection {
    [fetchingConnection cancel];
    fetchingConnection = nil;
}

#pragma mark - NSURLConnectionDelegate methods

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    self.errorHandler(error);
}

#pragma mark - NSURLConnectionDataDelegate methods

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [receivedData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSString *dataString = [[NSString alloc] initWithData:receivedData
                                                 encoding:NSUTF8StringEncoding];
    self.completionHandler(dataString);
    [self cancelAndDiscardCurrentURLConnection];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
    if (statusCode != 200) {
        // Redirects, other statuses handled here
        NSError *error = [NSError errorWithDomain:StackOverflowCommunicatorErrorDomain
                                             code:statusCode
                                         userInfo:nil];
        self.errorHandler(error);
    }
}

- (void)dealloc
{
    [fetchingConnection cancel];
}

@end
