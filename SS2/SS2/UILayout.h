//
//  UILayout.h
//  SS2
//
//  Created by takanoter on 14-2-18.
//  Copyright (c) 2014年 takanoter. All rights reserved.
//

#ifndef SS2_UILayout_h
#define SS2_UILayout_h
//全局控制
#define G_SCENE_RANGE 0.35 //单个屏幕显示小节数，对应速度
#define G_SCENE_MAX_SHORT_NOTE_COUNT 128  //缓存一屏幕的音符信息
#define G_SCENE_MAX_LONG_NOTE_COUNT 64  //缓存一屏幕的音符信息
#define G_MAX_NUM_PRESERVE 5

//布局
#define LAYOUT_OFFSCENE_X -5000
#define LAYOUT_OFFSCENE_Y -5000

#define LAYOUT_SKVIEW_Y 0

#define LAYOUT_CHANNEL_BASE_X 60
#define LAYOUT_CHANNEL_BASE_Y 0

#define LAYOUT_COOL_X 256
#define LAYOUT_COOL_Y 512
#define LAYOUT_COMBO_X (256 - 72)
#define LAYOUT_COMBO_Y 816
#define LAYOUT_NUM_X (256 - 56)
#define LAYOUT_NUM_DIS_X 128
#define LAYOUT_NUM_Y 712

#define LAYOUT_BG_X 0
#define LAYOUT_BG_Y 256

//for skview
#define LAYOUT_LONG_NOTE_FIX_Y -64
#define LAYOUT_SKVIEW_CHANNEL_BASE_Y -480 //for skview

//ui资源大小、间距
#define SIZE_SHORT_NOTE_X 64
#define SIZE_SHORT_NOTE_Y 64
#define SIZE_LONG_NOTE_X 64
#define SIZE_LONG_NOTE_Y 64
#define SIZE_LONG_NOTE_FIX_Y 128
#define SIZE_CHANNEL_X 32
#define SIZE_CHANNEL_Y 512
#define SIZE_COOL_X 318
#define SIZE_COOL_Y 318
#define SIZE_COMBO_X 164
#define SIZE_COMBO_Y 164
#define SIZE_NUM_X 256
#define SIZE_NUM_Y 256
#define SIZE_BLOOM_X 256
#define SIZE_BLOOM_Y 256

#define SIZE_ANOTHER_KEY_X 32
#define SIZE_ANOTHER_KEY_Y 8

#define SIZE_SKVIEW_CHANNEL_X 64  //for skview

//ui资源加载定位
#define UIS_STATIC 1
#define UIS_BACKGROUND_PATTERN_COUNT 1
#define UIS_BACKGROUND_PATTERN_PREFIX "background_a_"
#define UIS_BLOOM_PATTERN_COUNT 12
#define UIS_BLOOM_PATTERN_PREFIX "bloom_a_"
#define UIS_COMBO_PATTERN_COUNT 6
#define UIS_COMBO_PATTERN_PREFIX "combo_a_"
#define UIS_COOL_PATTERN_COUNT 1
#define UIS_COOL_PATTERN_PREFIX "cool_a_"
#define UIS_KEY_PATTERN_COUNT 1
#define UIS_KEY_PATTERN_PREFIX "key_b_"
#define UIS_KEY_P0_PATTERN_COUNT 1
#define UIS_KEY_P0_PATTERN_PREFIX "key_b_part0_"
#define UIS_KEY_P1_PATTERN_COUNT 1
#define UIS_KEY_P1_PATTERN_PREFIX "key_b_part1_"
#define UIS_NUM_PATTERN_COUNT 10
#define UIS_NUM_PATTERN_PREFIX "num_a_"

#define UIS_ANOTHER_KEY_PATTERN_COUNT 1
#define UIS_ANOTHER_KEY_PATTERN_PREFIX "key_a_"


#endif
