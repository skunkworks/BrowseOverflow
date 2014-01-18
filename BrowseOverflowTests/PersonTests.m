//
//  PersonTests.m
//  BrowseOverflow
//
//  Created by Richard Shin on 1/11/14.
//  Copyright (c) 2014 Richard Shin. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Person.h"

@interface PersonTests : XCTestCase
{
    Person *person;
}

@end

@implementation PersonTests

- (void)testPersonExists
{
    person = [[Person alloc] init];
    
    XCTAssertNotNil(person);
}

- (void)testPersonHasAName
{
    person = [[Person alloc] initWithName:@"Richard Shin"
                                avatarURL:nil];
    
    XCTAssertEqual(person.name, @"Richard Shin");
}

- (void)testPersonHasAnAvatarURL
{
    NSURL *avatarURL = [NSURL URLWithString:@"http://www.richardshin.com/logo.png"];

    person = [[Person alloc] initWithName:@"Richard Shin"
                                avatarURL:avatarURL];
    
    XCTAssertEqual(person.avatarURL, avatarURL);
}

- (void)testIsEqualWhenNamesAreNotEqualReturnsFalse
{
    Person *onePerson = [[Person alloc] initWithName:@"Richard Shin" avatarURL:nil];
    Person *anotherPerson = [[Person alloc] initWithName:@"Some dude" avatarURL:nil];
    
    BOOL isEqual = [onePerson isEqual:anotherPerson];
    BOOL isEqualOtherWay = [anotherPerson isEqual:onePerson];
    
    XCTAssertFalse(isEqual);
    XCTAssertFalse(isEqualOtherWay);
}

- (void)testIsEqualWhenAvatarURLsAreNotEqualReturnsFalse
{
    NSURL *oneURL = [NSURL URLWithString:@"http://yahoo.com"];
    NSURL *anotherURL = [NSURL URLWithString:@"http://google.com"];
    Person *onePerson = [[Person alloc] initWithName:@"Richard Shin" avatarURL:oneURL];
    Person *anotherPerson = [[Person alloc] initWithName:@"Richard Shin" avatarURL:anotherURL];
    
    BOOL isEqual = [onePerson isEqual:anotherPerson];
    BOOL isEqualOtherWay = [anotherPerson isEqual:onePerson];
    
    XCTAssertFalse(isEqual);
    XCTAssertFalse(isEqualOtherWay);
}

- (void)testIsEqualWhenPropertiesAreEqualReturnsTrue
{
    NSURL *oneURL = [NSURL URLWithString:@"http://yahoo.com"];
    Person *onePerson = [[Person alloc] initWithName:@"Richard Shin" avatarURL:oneURL];
    Person *anotherPerson = [[Person alloc] initWithName:@"Richard Shin" avatarURL:oneURL];
    
    BOOL isEqual = [onePerson isEqual:anotherPerson];
    BOOL isEqualOtherWay = [anotherPerson isEqual:onePerson];
    
    XCTAssertTrue(isEqual);
    XCTAssertTrue(isEqualOtherWay);
}

@end
