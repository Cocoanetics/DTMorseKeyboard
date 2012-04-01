//
//  DTMorseKeyboard.m
//  DTMorseKeyboard
//
//  Created by Oliver Drobnik on 01.04.12.
//  Copyright (c) 2012 Drobnik KG. All rights reserved.
//

#import "DTMorseKeyboard.h"

#define MAX_LONG_LENGTH 2.0f
#define MIN_DIT_LENGTH 0.15f
#define MAX_DIT_LENGTH 0.20f

static NSDictionary *morseLookup = nil;
static NSUInteger _longestMorseSequence = 0;


@implementation DTMorseKeyboard
{
	UIButton *_button;
	UILabel *_sequenceLabel;
	
	NSTimeInterval _lastTapTimestamp;
	NSTimeInterval _lastDitLength;
	BOOL _ignoreFollowingEvent;
	NSMutableString *_sequence;
	
}

+ (void)initialize
{
	morseLookup = [NSDictionary dictionaryWithObjectsAndKeys:@"a", @"··−·",
						@"b",@"−···",
						@"c",@"−·−·",
						@"d",@"−··",
						@"e",@"·",
						@"f",@"··−·",
						@"g",@"−−·",
						@"i",@"··",
						@"j",@"·−−−",
						@"k",@"−·−",
						@"l",@"·−··",
						@"m",@"−−",
						@"n",@"−·",
						@"o",@"−−−",
						@"p",@"·−−·",
						@"q",@"−−·−",
						@"r",@"·−·",
						@"s",@"···",
						@"t",@"−",
						@"u",@"··−",
						@"v",@"···−",
						@"w",@"·−−",
						@"x",@"−··−",
						@"y",@"−·−−",
						@"z",@"−−··",
						@"0",@"−−−−−",
						@"1",@"·−−−−",
						@"2",@"··−−−",
						@"3",@"···−−",
						@"4",@"····−",
						@"5",@"·····",
						@"6",@"−····",
						@"7",@"−−···",
						@"8",@"−−−··",
						@"9",@"−−−−·",
						nil];
	
	for (NSString *oneSequence in [morseLookup allKeys])
	{
		_longestMorseSequence = MAX(_longestMorseSequence, [oneSequence length]);
	}
}

- (id)initWithDelegate:(id<UIKeyInput>)delegate
{
	self = [super initWithFrame:CGRectMake(0, 0, 320, 150)];
	if (self) 
	{
		self.inputDelegate = delegate;
		self.backgroundColor = [UIColor grayColor];
		
		// TO DO: make this a custom button with Morse look
		_button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		[_button setTitle:@".-" forState:UIControlStateNormal];
		[self addSubview:_button]; // DOH
		
		[_button addTarget:self action:@selector(tapUp:) forControlEvents:UIControlEventTouchUpInside];
		[_button addTarget:self action:@selector(tapDown:) forControlEvents:UIControlEventTouchDown];
		
		// storage for . and - until we have a sequence
		_sequence = [[NSMutableString alloc] init];
		
		// initialize with something
		_lastDitLength = 0.25;
		
		// label to show what we recognized
		_sequenceLabel = [[UILabel alloc] init];
		_sequenceLabel.backgroundColor = [UIColor colorWithWhite:1 alpha:0.1];
		[self addSubview:_sequenceLabel];
	}
	
	return self;
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	
	_button.bounds = CGRectMake(0,0,60,60);
	_button.center = self.center;
	
	CGRect frame = self.bounds;
	frame.size.height = 30.0f;
	frame.origin.y = CGRectGetMaxY(self.bounds)-frame.size.height;
	_sequenceLabel.frame = frame;
	_sequenceLabel.textAlignment = UITextAlignmentCenter;
	
}

- (BOOL)canBecomeFirstResponder
{
	return YES;
}


// check if the sequence so far is a valid character
- (void)_sendRecognizedCharacter
{
	NSString *foundChar = [morseLookup objectForKey:_sequence];

	if (foundChar)
	{
		// send it
		[inputDelegate insertText:foundChar];
		
		// remove from sequence
		[_sequence replaceCharactersInRange:NSMakeRange(0, [_sequence length]) withString:@""];
	}
	else
	{
		// reset if it's too long and invalid
		if ([_sequence length]>_longestMorseSequence)
		{
			[_sequence deleteCharactersInRange:NSMakeRange(0, [_sequence length])];
		}
	}
	
	_sequenceLabel.text = _sequence;
}

- (void)_shortMorse
{
	[_sequence appendString:@"·"];
	
	_sequenceLabel.text = _sequence;

}

- (void)_longMorse
{
	[_sequence appendString:@"−"];
	
	_sequenceLabel.text = _sequence;

}

- (void)_letterPause
{
	[NSObject cancelPreviousPerformRequestsWithTarget:self];

	[self _sendRecognizedCharacter];
	
	// after 4 more dit pause there is a word break
	[self performSelector:@selector(_wordPause) withObject:nil afterDelay:_lastDitLength * 4.0f];
}

- (void)_wordPause
{
	// send a space
	[self.inputDelegate insertText:@" "];
	
	// empty sequence
	[_sequence deleteCharactersInRange:NSMakeRange(0, [_sequence length])];
}

#pragma mark Actions



- (void)tapDown:(UIButton *)button
{
	[NSObject cancelPreviousPerformRequestsWithTarget:self];

	_lastTapTimestamp = [NSDate timeIntervalSinceReferenceDate];
	_ignoreFollowingEvent = NO;
	
	// fire the tap up if it gets held longer than threshold
	[self performSelector:@selector(tapUp:) withObject:nil afterDelay:MAX_LONG_LENGTH];
}

- (void)tapUp:(UIButton *)button
{
	if (_ignoreFollowingEvent)
	{
		// already fired for this down-up
		return;
	}
	
	_ignoreFollowingEvent = YES;
	
	// prevent double firing
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
	
	NSTimeInterval elapsedTime = [NSDate timeIntervalSinceReferenceDate] - _lastTapTimestamp;
	
	if (elapsedTime >= 3.0f * _lastDitLength)
	{
		[self _longMorse];
	}
	else
	{
		[self _shortMorse];
		
		_lastDitLength = MIN(MAX_DIT_LENGTH, MAX(elapsedTime, MIN_DIT_LENGTH));;
	}
	
	// between characters  there are 3 dit pause
	[self performSelector:@selector(_letterPause) withObject:nil afterDelay:_lastDitLength * 3.0f];
}


#pragma mark Properties

@synthesize inputDelegate;

@end
