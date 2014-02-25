//
//  SKPlayView.m
//  SS2
//
//  Created by takanoter on 14-2-13.
//  Copyright (c) 2014年 takanoter. All rights reserved.
//

#import "SKPlayView.h"
#import "SKPlayScene.h"
@interface SKPlayView() {
    SKPlayScene* now;
}
@end

@implementation SKPlayView

- (id)initWithFrame:(CGRect)frame byBms:(BMSEngine *)bms
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.showsDrawCount=YES;
        self.showsFPS=YES;
        now = [[SKPlayScene alloc] initWithSize:CGSizeMake(768,1024)];
        //now->audioPlayer = audioPlayer;
        now->bms = bms;
        [self presentScene:now];
    }
    return self;
}



// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    NSLog(@"What's this?");
    // Drawing code
}


@end
