//
//  DTAppDelegate.h
//  DTMorseKeyboard
//
//  Created by Oliver Drobnik on 01.04.12.
//  Copyright (c) 2012 Drobnik KG. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DTViewController;

@interface DTAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) DTViewController *viewController;

@end
