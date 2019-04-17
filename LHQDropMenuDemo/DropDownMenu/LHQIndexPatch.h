//
//  WTIndexPatch.h
//  ApartmentLocksApp
//
//  Created by WaterWorld on 2019/4/10.
//  Copyright © 2019年 linhuaqin. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LHQIndexPatch : NSObject

@property (nonatomic, assign) NSInteger column; // 菜单index
@property (nonatomic, assign) NSInteger section; //每项菜单行index

- (instancetype)initWithColumn:(NSInteger)column section:(NSInteger)section;

@end

NS_ASSUME_NONNULL_END
