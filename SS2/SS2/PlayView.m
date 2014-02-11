//
//  PlayView.m
//  SS2
//
//  Created by takanoter on 14-2-10.
//  Copyright (c) 2014年 takanoter. All rights reserved.
//

#import "PlayView.h"
#import <UIKit/UIGestureRecognizerSubclass.h>

@implementation PlayView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        //self.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"yourBackground.png"]];
        self.backgroundColor=[UIColor blackColor];
        NSLog(@"[Debug] self view");
    }
    return self;
}

- (void)logTouchInfo:(UITouch *)touch {
    CGPoint locInSelf = [touch locationInView:self];
    CGPoint locInWin = [touch locationInView:nil];
    NSLog(@"    touch.locationInView = {%2.3f, %2.3f}", locInSelf.x, locInSelf.y);
    NSLog(@"    touch.locationInWin = {%2.3f, %2.3f}", locInWin.x, locInWin.y);
    NSLog(@"    touch.phase = %d", touch.phase);
    NSLog(@"    touch.tapCount = %d", touch.tapCount);
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"touchesBegan - touch count = %d", [touches count]);
    for(UITouch *touch in event.allTouches) {
        [self logTouchInfo:touch];
    }
}

-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"touchesBegan - touch count = %d", [touches count]);
    for(UITouch *touch in event.allTouches) {
        [self logTouchInfo:touch];
    }
}

-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"touchesBegan - touch count = %d", [touches count]);
    for(UITouch *touch in event.allTouches) {
        [self logTouchInfo:touch];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
