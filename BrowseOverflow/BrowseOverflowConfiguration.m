//
//  BrowseOverflowConfiguration
//  BrowseOverflow
//
//  Created by Richard Shin on 1/19/14.
//  Copyright (c) 2014 Richard Shin. All rights reserved.
//

#import "BrowseOverflowConfiguration.h"

@implementation BrowseOverflowConfiguration

- (StackOverflowManager *)createManager
{
    StackOverflowManager *manager = [[StackOverflowManager alloc] init];
    PersonBuilder *personBuilder = [[PersonBuilder alloc] init];
    manager.questionBuilder = [[QuestionBuilder alloc] initWithPersonBuilder:personBuilder];
    manager.answerBuilder = [[AnswerBuilder alloc] initWithPersonBuilder:personBuilder];
    manager.communicator = [[StackOverflowCommunicator alloc] init];
    manager.communicator.delegate = manager;
    
    return manager;
}

- (AvatarStore *)avatarStore
{
    static AvatarStore *avatarStore;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        avatarStore = [[AvatarStore alloc] init];
    });
    return avatarStore;
}

@end
