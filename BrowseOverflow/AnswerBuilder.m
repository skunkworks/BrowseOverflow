//
//  AnswerBuilder.m
//  BrowseOverflow
//
//  Created by Richard Shin on 1/19/14.
//  Copyright (c) 2014 Richard Shin. All rights reserved.
//

#import "AnswerBuilder.h"

@implementation AnswerBuilder

NSString *const AnswerBuilderError = @"AnswerBuilderError";

#pragma mark - String consts used to parse JSON
NSString *const AnswerArrayKey = @"items";
NSString *const AnswerIDKey = @"answer_id";
NSString *const AnswerScoreKey = @"score";
NSString *const AnswerBodyKey = @"body";
NSString *const AnswerAcceptedKey = @"is_accepted";
NSString *const AnswerAnswererKey = @"owner";
#pragma mark - Initializers

- (id)init {
    [NSException raise:@"Unsupported initializer" format:@"Use initWithPersonBuilder: instead"];
    return nil;
}

- (id)initWithPersonBuilder:(PersonBuilder *)personBuilder {
    NSParameterAssert(personBuilder);
    
    if (self = [super init]) {
        _personBuilder = personBuilder;
    }
    return self;
}

#pragma mark - Public methods

- (NSArray *)answersFromJSON:(NSString *)objectNotation
                       error:(NSError **)error
{
    NSParameterAssert(objectNotation);
    
    NSError *jsonParsingError;
    NSData *jsonData = [objectNotation dataUsingEncoding:NSUTF8StringEncoding];
    id jsonDictionary = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:0
                                                          error:&jsonParsingError];
    
    if (!jsonDictionary) {
        if (error) {
            *error = [NSError errorWithDomain:AnswerBuilderError
                                         code:AnswerBuilderInvalidJSONError
                                     userInfo:@{ NSUnderlyingErrorKey : jsonParsingError }];
        }
        return nil;
    }
    
    id jsonAnswersArray = [jsonDictionary objectForKey:AnswerArrayKey];
    if (!jsonAnswersArray) {
        if (error) {
            *error = [NSError errorWithDomain:AnswerBuilderError
                                         code:AnswerBuilderMissingDataError
                                     userInfo:nil];
        }
        return nil;
    }
    
    NSMutableArray *answers = [NSMutableArray array];
    for (id jsonAnswer in jsonAnswersArray) {
        Answer *answer = [[Answer alloc] init];

        answer.score = [[jsonAnswer objectForKey:AnswerScoreKey] intValue];
        answer.text = (NSString *)[jsonAnswer objectForKey:AnswerBodyKey];
        answer.accepted = [[jsonAnswer objectForKey:AnswerAcceptedKey] boolValue];

        id jsonAnswerer = [jsonAnswer objectForKey:AnswerAnswererKey];
        answer.answerer = [self.personBuilder personFromJSONObject:jsonAnswerer];
        [answers addObject:answer];
    }
    
    return [answers copy];
}

@end
