//
//  DTMorseKeyboard.h
//  DTMorseKeyboard
//
//  Created by Oliver Drobnik on 01.04.12.
//  Copyright (c) 2012 Drobnik KG. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DTMorseKeyboard : UIView

@property (nonatomic, weak) id <UIKeyInput> inputDelegate;

- (id)initWithDelegate:(id<UIKeyInput>)delegate;

@end
