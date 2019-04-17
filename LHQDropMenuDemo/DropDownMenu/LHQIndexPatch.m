//
//  WTIndexPatch.m
//  ApartmentLocksApp
//
//  Created by WaterWorld on 2019/4/10.
//  Copyright © 2019年 linhuaqin. All rights reserved.
//

#import "LHQIndexPatch.h"

@implementation LHQIndexPatch

- (instancetype)initWithColumn:(NSInteger)column section:(NSInteger)section{
    self = [super init];
    if (self) {
        _column = column;
        _section = section;
    }
    return self;
}

@end
