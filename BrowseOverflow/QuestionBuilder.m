//
//  QuestionBuilder.m
//  BrowseOverflow
//
//  Created by Richard Shin on 1/13/14.
//  Copyright (c) 2014 Richard Shin. All rights reserved.
//

#import "QuestionBuilder.h"

@implementation QuestionBuilder

NSString *const QuestionBuilderError = @"QuestionBuilderError";

#pragma mark - Const strings used in StackOverflow API's JSON format
NSString *const QuestionsArrayKey = @"items";
NSString *const QuestionIDKey = @"question_id";
NSString *const QuestionDateKey = @"creation_date";
NSString *const QuestionScoreKey = @"score";
NSString *const QuestionAskerKey = @"owner";
NSString *const QuestionTitleKey = @"title";
NSString *const QuestionBodyKey = @"body";

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

- (NSArray *)questionsFromJSON:(NSString *)objectNotation error:(NSError **)error
{
    NSParameterAssert(objectNotation);
    
    NSData *jsonData = [objectNotation dataUsingEncoding:NSUTF8StringEncoding];
    NSError *jsonParsingError;
    id jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData
                                                    options:0
                                                      error:&jsonParsingError];
    
    if (!jsonObject) {
        // If jsonObject is nil, there was a JSON parsing error
        if (error) {
            *error = [NSError errorWithDomain:QuestionBuilderError
                                         code:QuestionBuilderInvalidJSONError
                                     userInfo:@{ NSUnderlyingErrorKey : jsonParsingError }];
        }
        return nil;
    }
    
    NSDictionary *jsonDictionary = (NSDictionary *)jsonObject;
    NSArray *jsonQuestions = [jsonDictionary objectForKey:QuestionsArrayKey];
    if (!jsonQuestions) {
        // Received "valid" JSON that parsed okay, but it doesn't have a format I understand!
        if (error) {
            *error = [NSError errorWithDomain:QuestionBuilderError
                                         code:QuestionBuilderMissingDataError
                                     userInfo:nil];
        }
        return nil;
    }
    
    NSMutableArray *questions = [NSMutableArray array];
    for (id jsonQuestion in jsonQuestions) {
        Question *question = [[Question alloc] init];
        question.questionID = [[jsonQuestion objectForKey:QuestionIDKey] integerValue];
        question.title = [jsonQuestion objectForKey:QuestionTitleKey];
        question.score = [[jsonQuestion objectForKey:QuestionScoreKey] integerValue];
        NSTimeInterval dateInterval = (NSTimeInterval)[[jsonQuestion objectForKey:QuestionDateKey] integerValue];
        question.date = [NSDate dateWithTimeIntervalSince1970:dateInterval];
        
        id jsonAsker = [jsonQuestion objectForKey:QuestionAskerKey];
        question.asker = [self.personBuilder personFromJSONObject:jsonAsker];
        [questions addObject:question];
    }
    return [questions copy];
}

- (BOOL)fillQuestion:(Question *)question
withQuestionBodyJSON:(NSString *)objectNotation
               error:(NSError **)error
{
    NSParameterAssert(question);
    
    NSData *jsonData = [objectNotation dataUsingEncoding:NSUTF8StringEncoding];
    NSError *jsonParsingError;
    id jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData
                                                    options:0
                                                      error:&jsonParsingError];
    // Failed to parse JSON - probably not JSON format!
    if (!jsonObject) {
        if (error) {
            *error = [NSError errorWithDomain:QuestionBuilderError
                                         code:QuestionBuilderInvalidJSONError
                                     userInfo:@{ NSUnderlyingErrorKey : jsonParsingError }];
        }
        return NO;
    }
    
    NSDictionary *jsonDictionary = (NSDictionary *)jsonObject;
    NSArray *jsonQuestions = [jsonDictionary objectForKey:QuestionsArrayKey];
    if (!jsonQuestions) {
        // Failed to get questions array from JSON. Valid JSON, but it's missing the data we need!
        if (error) {
            *error = [NSError errorWithDomain:QuestionBuilderError
                                         code:QuestionBuilderMissingDataError
                                     userInfo:nil];
        }
        return NO;
    }
    
    if ([jsonQuestions count] == 0 ||
        [jsonQuestions[0] objectForKey:QuestionBodyKey] == nil) {
        // We got a questions array, but it's either empty or is missing the body!
        if (error) {
            *error = [NSError errorWithDomain:QuestionBuilderError
                                         code:QuestionBuilderMissingDataError
                                     userInfo:nil];
        }
        return NO;
    }
    
    question.body = [jsonQuestions[0] objectForKey:QuestionBodyKey];
    return YES;
}

@end
