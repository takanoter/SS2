//
//  SKPlayView.h
//  SS2
//
//  Created by takanoter on 14-2-13.
//  Copyright (c) 2014年 takanoter. All rights reserved.
//
#import "BMSEngine.h"
#import <SpriteKit/SpriteKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "utils.h"

@interface SKPlayView : SKView {
}
- (id)initWithFrame:(CGRect)frame  byBms:(BMSEngine*)bms;
@end
