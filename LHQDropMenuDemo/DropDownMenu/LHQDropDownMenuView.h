//
//  WTDropDownMenuView.h
//  ApartmentLocksApp
//
//  Created by WaterWorld on 2019/4/10.
//  Copyright © 2019年 linhuaqin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WTIndexPatch.h"

typedef NS_ENUM(NSUInteger, DropDownMenuStyle) {
    DropDownMenuStyleTableView = 0, // 普通tableview 仅支持一级菜单
    DropDownMenuStyleCustom, // 自定义视图，需设置，仅支持一级菜单
};

@class LHQDropDownMenuView;
@protocol WTDropDownMenuViewDelegate <NSObject>
- (void)menuView:(LHQDropDownMenuView *)menu tfColumn:(NSInteger)column; // 菜单被点击
- (void)menuView:(LHQDropDownMenuView *)menu selectIndex:(WTIndexPatch *)index value:(NSString *)value; // 下拉菜单被点击
@end

@interface LHQDropDownMenuView : UIView

- (instancetype)initWithFrame:(CGRect)frame titles:(NSArray *)titles subTitles:(NSArray *)subTitles;

// 各个菜单风格数组, 默认都为DropDownMenuStyleTableView
@property (strong, nonatomic) NSMutableArray *menuStyleArray;
// 自定义下拉视图
@property (strong, nonatomic) NSMutableArray *customViews;

// 标题数组
@property (nonatomic, strong) NSArray *titles;
// 子标题数组
@property (nonatomic, strong) NSArray *subTitles;
// 背景色
@property (strong, nonatomic) UIColor *menuBackgroundColor;
// Item选中字体颜色, 默认橙红色
@property (strong, nonatomic) UIColor *itemTextSelectColor;
// Item未选中字体颜色, 默认黑色
@property (strong, nonatomic) UIColor *itemTextUnSelectColor;
// 角标选中颜色, 默认橙红色
@property (strong, nonatomic) UIColor *arrowSelectColor;
// 角标未选中颜色, 默认黑色
@property (strong, nonatomic) UIColor *arrowUnSelectColor;
// cell选中字体颜色, 默认橙红色
@property (strong, nonatomic) UIColor *cellTextSelectColor;
// cell未选中字体颜色, 默认黑色
@property (strong, nonatomic) UIColor *cellTextUnSelectColor;
// 分割线颜色, 默认灰色
@property (strong, nonatomic) UIColor *separatorColor;
// Item字体大小, 默认14
@property (assign, nonatomic) CGFloat itemFontSize;
// cell字体大小, 默认14
@property (assign, nonatomic) CGFloat cellTitleFontSize;
// 下拉表单高度, 默认300
@property (assign, nonatomic) CGFloat tableViewHeight;
// cell高度, 默认44
@property (assign, nonatomic) CGFloat cellHeight;
// 动画时间, 默认0.25
@property (assign, nonatomic) CGFloat kAnimationDuration;

@property (nonatomic, weak) id<WTDropDownMenuViewDelegate> delegate;

- (void)hidenMenuView;


@end

