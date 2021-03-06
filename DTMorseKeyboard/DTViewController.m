//
//  DTViewController.m
//  DTMorseKeyboard
//
//  Created by Oliver Drobnik on 01.04.12.
//  Copyright (c) 2012 Drobnik KG. All rights reserved.
//

#import "DTViewController.h"
#import "DTMorseKeyboard.h"

@interface DTViewController ()

@end

@implementation DTViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	
	DTMorseKeyboard *kb = [[DTMorseKeyboard alloc] initWithDelegate:textField];
	textField.inputView = kb;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
	    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
	} else {
	    return YES;
	}
}

#pragma mark Properties

@synthesize textField;

@end
