//
//  WTDropDownMenuView.m
//  ApartmentLocksApp
//
//  Created by WaterWorld on 2019/4/10.
//  Copyright © 2019年 linhuaqin. All rights reserved.
//

#import "LHQDropDownMenuView.h"
#import "LHQSubTitleModel.h"

#define kSCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define kSCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)
#define SCREEN_SCALE [UIScreen mainScreen].scale

@interface LHQDropDownMenuView () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) UIView *backgroundView; // 整体背景
@property (strong, nonatomic) UIView *bottomLineView; // 菜单底部横线
@property (strong, nonatomic) UITableView *tableView; // 列表
@property (strong, nonatomic) UIScrollView *customScrollView; // 列表

@property (nonatomic, assign) NSInteger numberOfColumn; //列数
@property (nonatomic, assign) NSInteger currentSelectColumn; // 记录最近选中列
@property (nonatomic, assign) NSInteger lastSelectSection; // 记录上一次的section选择，用于回显
@property (nonatomic, assign) NSMutableArray *currentSelectSections; // 记录最近选中的sections
@property (nonatomic, assign) BOOL isShow; // 是否弹出
@property (nonatomic, strong) NSMutableArray *currentFirstShow; // 该列表是否初次弹出无选择项

@property (nonatomic, strong) NSMutableArray *currentBgLayers;  //菜单背景layers
@property (nonatomic, strong) NSMutableArray *currentTitleLayers; //菜单titlelayers
@property (nonatomic, strong) NSMutableArray *currentSeparatorLayers; //菜单分隔竖线separatorlayers
@property (nonatomic, strong) NSMutableArray *currentIndicatorLayers; //菜单箭头layers

@property (nonatomic, strong) NSMutableArray *subTitleModels;

@end

@implementation LHQDropDownMenuView

- (instancetype)initWithFrame:(CGRect)frame titles:(NSArray *)titles subTitles:(NSArray *)subTitles{
    if (self = [super initWithFrame:frame]) {
        [self initAttributes];
        self.titles = titles;
        [self setupWithSubTitles:subTitles];
        self.numberOfColumn = titles.count;
        [self setupUI];
        [self addAction];
    }
    return self;
}

// 默认配置
- (void)initAttributes {
    self.menuBackgroundColor = [UIColor whiteColor];
    self.itemTextSelectColor = [UIColor colorWithRed:246.0/255.0 green:79.0/255.0 blue:0.0/255.0 alpha:1.0];
    self.itemTextUnSelectColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
    self.arrowSelectColor = [UIColor colorWithRed:246.0/255.0 green:79.0/255.0 blue:0.0/255.0 alpha:1.0];
    self.arrowUnSelectColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
    self.cellTextSelectColor = [UIColor colorWithRed:246.0/255.0 green:79.0/255.0 blue:0.0/255.0 alpha:1.0];
    self.cellTextUnSelectColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
    self.separatorColor = [UIColor colorWithRed:219.0/255.0 green:219.0/255.0 blue:219.0/255.0 alpha:1.0];
    self.itemFontSize = 14.0;
    self.cellTitleFontSize = 14.0;
    self.tableViewHeight = 300.0;
    self.cellHeight = 44;
    self.kAnimationDuration = 0.25;
    
    self.customViews = [NSMutableArray array];
    self.currentSelectSections = [NSMutableArray array];
    self.currentBgLayers = [NSMutableArray array];
    self.currentTitleLayers = [NSMutableArray array];
    self.currentSeparatorLayers = [NSMutableArray array];
    self.currentIndicatorLayers = [NSMutableArray array];

    self.subTitleModels = [NSMutableArray array];
}

- (void)setupWithSubTitles:(NSArray *)subTitles{
    [subTitles enumerateObjectsUsingBlock:^(NSArray *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSMutableArray *array = [NSMutableArray array];
        [obj enumerateObjectsUsingBlock:^(NSString *objc, NSUInteger idx, BOOL * _Nonnull stop) {
            LHQSubTitleModel *model = [[LHQSubTitleModel alloc]init];
            model.isSelect = NO;
            model.subTitle = objc;
            [array addObject:model];
        }];
        [self.subTitleModels addObject:array];
    }];
}

#pragma mark - setupUI
- (void)setupUI{
    CGFloat backgroundLayerWidth = self.frame.size.width / _numberOfColumn;
    [self.currentBgLayers removeAllObjects];
    [self.currentTitleLayers removeAllObjects];
    [self.currentSeparatorLayers removeAllObjects];
    [self.currentIndicatorLayers removeAllObjects];
    
    for (NSInteger i = 0; i < self.numberOfColumn; i++) {
        // backgroundLayer
        CGPoint backgroundLayerPosition = CGPointMake((i + 0.5) * backgroundLayerWidth, self.bounds.size.height * 0.5);
        CALayer *backgroundLayer = [self creatBackgroundLayer:backgroundLayerPosition backgroundColor:self.menuBackgroundColor];
        
        [self.layer addSublayer:backgroundLayer];
        [self.currentBgLayers addObject:backgroundLayer];
        
        // titleLayer
        NSString *titleStr = self.titles[i];
        
        CGPoint titleLayerPosition = CGPointMake((i + 0.5) * backgroundLayerWidth, self.bounds.size.height * 0.5);
        CATextLayer *titleLayer = [self creatTitleLayer:titleStr position:titleLayerPosition textColor:self.itemTextUnSelectColor];
        [self.layer addSublayer:titleLayer];
        [self.currentTitleLayers addObject:titleLayer];
        
        // indicatorLayer
        CGSize textSize = [self calculateStringSize:titleStr];// calculateStringSize(titleStr)
        CGPoint indicatorLayerPosition = CGPointMake(titleLayerPosition.x + (textSize.width / 2) + 10, self.bounds.size.height * 0.5 + 2);
        
        CAShapeLayer *indicatorLayer = [self creatIndicatorLayer:indicatorLayerPosition color:self.arrowUnSelectColor];
        [self.layer addSublayer:indicatorLayer];
        [self.currentIndicatorLayers addObject:indicatorLayer];
        
        // separatorLayer
        if (i != self.numberOfColumn - 1) {
            CGPoint separatorLayerPosition = CGPointMake(ceil((i + 1) * backgroundLayerWidth) - 1, self.bounds.size.height * 0.5);
            
            CAShapeLayer *separatorLayer = [self creatSeparatorLayer:separatorLayerPosition color:_separatorColor];
            [self.layer addSublayer:separatorLayer];
            [self.currentSeparatorLayers addObject:separatorLayer];
        }
    }
    [self addSubview:self.bottomLineView];
}

#pragma mark - 菜单点击
- (void)addAction {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(menuTapped:)];
    [self addGestureRecognizer:tap];
}

- (void)menuTapped:(UITapGestureRecognizer *)ges{
    if (_delegate) {
        CGPoint tapPoint = [ges locationInView:self];
        NSInteger tapIndex = tapPoint.x / (self.frame.size.width / _numberOfColumn);
        for (NSInteger i = 0; i < self.numberOfColumn; i++) {
            if (i != tapIndex) {
                [self animateForIndicator:_currentIndicatorLayers[i] show:NO complete:^{
                    [self animateForTitleLayer:self.currentTitleLayers[i] indicator:nil show:NO complete:^{
                    }];
                }];
            }
        }
        
        // 收回
        if (_currentSelectColumn == tapIndex && _isShow) {
            [self animateForIndicator:_currentIndicatorLayers[tapIndex] titlelayer:_currentTitleLayers[tapIndex] show:NO complete:^{
                self.currentSelectColumn = tapIndex;
                self.isShow = false;
            }];
            _currentSelectSections[_currentSelectColumn] = [NSNumber numberWithInteger:_lastSelectSection];
        }
        // 弹出
        else{
            if ([self.delegate respondsToSelector:@selector(menuView:tfColumn:)]) {
                [self.delegate menuView:self tfColumn:tapIndex];
            }
            _currentSelectColumn = tapIndex;
            _lastSelectSection = [NSString stringWithFormat:@"%@", _currentSelectSections[_currentSelectColumn]].integerValue;
            [self.tableView reloadData];
            [self animateForIndicator:_currentIndicatorLayers[tapIndex] titlelayer:_currentTitleLayers[tapIndex] show:YES complete:^{
                self.isShow = YES;
            }];
        }
    }
    
}

#pragma mark - 背景点击
// 背景点击
- (void)backTapped:(UITapGestureRecognizer *)sender {
    [self animateForIndicator:_currentIndicatorLayers[_currentSelectColumn] titlelayer:_currentTitleLayers[_currentSelectColumn] show:NO complete:^{
        self.isShow = NO;
    }];
}

#pragma mark - Pubic Method
- (void)hidenMenuView{
    [self animateForIndicator:_currentIndicatorLayers[_currentSelectColumn] titlelayer:_currentTitleLayers[_currentSelectColumn] show:NO complete:^{
        self.isShow = NO;
    }];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger rows = [_subTitleModels[_currentSelectColumn] count];
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class])];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass([UITableViewCell class])];
        cell.textLabel.textColor = _cellTextUnSelectColor;
        cell.textLabel.highlightedTextColor = _cellTextSelectColor;
        cell.textLabel.font = [UIFont systemFontOfSize:_cellTitleFontSize];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    LHQSubTitleModel *model = _subTitleModels[_currentSelectColumn][indexPath.row];
    cell.textLabel.text = model.subTitle;
    // 上次选中行
    if (model.isSelect == NO) {
        cell.textLabel.textColor = _cellTextUnSelectColor;
    }else{
        cell.textLabel.textColor = _cellTextSelectColor;
    }
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_delegate) {
        CATextLayer *titleLayer = _currentTitleLayers[_currentSelectColumn];
        _currentSelectSections[_currentSelectColumn] = [NSNumber numberWithInteger:indexPath.row];
        
        NSArray *currentArray = _subTitleModels[_currentSelectColumn];
        [currentArray enumerateObjectsUsingBlock:^(LHQSubTitleModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj.isSelect = NO;
        }];
        LHQSubTitleModel *model = _subTitleModels[_currentSelectColumn][indexPath.row];
        model.isSelect = YES;
        
        [self animateForTitleLayer:titleLayer indicator:_currentIndicatorLayers[_currentSelectColumn] show:YES complete:^{
        }];
        // 收回列表
        _lastSelectSection = [NSString stringWithFormat:@"%@", _currentSelectSections[_currentSelectColumn]].integerValue;
        [self animateForIndicator:_currentIndicatorLayers[_currentSelectColumn] titlelayer:titleLayer show:NO complete:^{
            self.isShow = NO;
        }];
        if ([self.delegate respondsToSelector:@selector(menuView:selectIndex:value:)]) {
            LHQIndexPatch *index = [[LHQIndexPatch alloc] initWithColumn:_currentSelectColumn section:indexPath.row];
            [self.delegate menuView:self selectIndex:index value:model.subTitle];
        }
    }
}

#pragma mark - setter
- (void)setMenuBackgroundColor:(UIColor *)menuBackgroundColor {
    _menuBackgroundColor = menuBackgroundColor;
    for (CALayer *backLayer in self.currentBgLayers) {
        backLayer.backgroundColor = [_menuBackgroundColor CGColor];
        self.backgroundColor = _menuBackgroundColor;
    }
}

- (void)setItemTextUnSelectColor:(UIColor *)itemTextUnSelectColor {
    _itemTextUnSelectColor = itemTextUnSelectColor;
    for (CATextLayer *titleLayer in self.currentTitleLayers) {
        titleLayer.foregroundColor = [_itemTextUnSelectColor CGColor];
    }
    
}

- (void)setItemTextSelectColor:(UIColor *)itemTextSelectColor{
    _itemTextSelectColor = itemTextSelectColor;
    for (CATextLayer *titleLayer in self.currentTitleLayers) {
        titleLayer.foregroundColor = [_itemTextSelectColor CGColor];
    }
}

- (void)setArrowSelectColor:(UIColor *)arrowSelectColor{
    _arrowSelectColor = arrowSelectColor;
    for (CAShapeLayer *indicatorLayer in self.currentIndicatorLayers) {
        indicatorLayer.strokeColor = [_arrowSelectColor CGColor];
        indicatorLayer.fillColor = [_arrowSelectColor CGColor];//
    }
}

- (void)setArrowUnSelectColor:(UIColor *)arrowUnSelectColor{
    _arrowUnSelectColor = arrowUnSelectColor;
    for (CAShapeLayer *indicatorLayer in self.currentIndicatorLayers) {
        indicatorLayer.strokeColor = [_arrowUnSelectColor CGColor];
        indicatorLayer.fillColor = [_arrowUnSelectColor CGColor];//
    }
}


- (void)setSeparatorColor:(UIColor *)separatorColor {
    _separatorColor = separatorColor;
    for (CAShapeLayer *separatorLayer in self.currentSeparatorLayers) {
        separatorLayer.strokeColor = [_separatorColor CGColor];
    }
}

- (void)setItemFontSize:(CGFloat)itemFontSize {
    _itemFontSize = itemFontSize;
    for (CATextLayer *titleLayer in self.currentTitleLayers) {
        titleLayer.fontSize = _itemFontSize;
    }
}

#pragma mark - Animation
// 组合动画
- (void)animateForIndicator:(CAShapeLayer *)indicator titlelayer:(CATextLayer *)titlelayer show:(BOOL)show complete:(void(^)(void))complete {
    [self animateForIndicator:indicator show:show complete:^{
        [self animateForTitleLayer:titlelayer indicator:indicator show:show complete:^{
            [self animateForBackgroundView:show complete:^{
                [self animateTableViewWithShow:show complete:^{
                }];
            }];
        }];
    }];
    if (complete) {
        complete();
    }
}

// 背景动画
- (void)animateForBackgroundView:(BOOL)show complete:(void(^)(void))complete {
    
    if (show) {
        [self.superview addSubview:self.backgroundView];
        [self.superview addSubview:self];
        [UIView animateWithDuration:_kAnimationDuration animations:^{
            self.backgroundView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
        }];
    } else {
        _currentSelectSections[_currentSelectColumn] = [NSNumber numberWithInteger:_lastSelectSection];
        [UIView animateWithDuration:_kAnimationDuration animations:^{
            self.backgroundView.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
        } completion:^(BOOL finished) {
            [self.backgroundView removeFromSuperview];
        }];
    }
    if (complete) {
        complete();
    }
}

// tableView 动画
- (void)animateTableViewWithShow:(BOOL)show complete:(void(^)(void))complete {
    BOOL haveItems = NO;
    if (show) {
        [self showListViewWithHaveItems:haveItems];
    } else {
        [self hiddenListViewWithHaveItems:haveItems];
    }
    if (complete) {
        complete();
    }
}

- (void)showListViewWithHaveItems:(BOOL)haveItems{
    DropDownMenuStyle style = DropDownMenuStyleTableView;
    if (_currentSelectColumn < _menuStyleArray.count) {
        style = [NSString stringWithFormat:@"%@", _menuStyleArray[_currentSelectColumn]].integerValue;
    }
    NSInteger numberOfSection = [self.subTitleModels[_currentSelectColumn] count];
    CGFloat tempHeight = numberOfSection * _cellHeight;
    CGFloat heightForTableView = (tempHeight > _tableViewHeight) ? _tableViewHeight : tempHeight;
    switch (style) {
        case DropDownMenuStyleTableView:
        {
            [self.tableView removeFromSuperview];
            [self.customScrollView removeFromSuperview];
            self.tableView.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y + self.bounds.size.height, self.bounds.size.width, 0);
            [self.superview insertSubview:self.tableView belowSubview:self];
            [UIView animateWithDuration:_kAnimationDuration animations:^{
                self.tableView.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y + self.bounds.size.height, self.bounds.size.width, heightForTableView);
            }];
        }
            break;
        case DropDownMenuStyleCustom:
        {
            [self.tableView removeFromSuperview];
            [self.customScrollView removeFromSuperview];
            if (_currentSelectColumn < _customViews.count) {
                UIView *view = _customViews[_currentSelectColumn];
                if (view != nil) {
//                    CGFloat viewHeight = view.frame.size.height > 0 ? view.frame.size.height : _cellHeight;
                    CGFloat viewHeight = view.frame.size.height;
//                    viewHeight = viewHeight > _tableViewHeight ? _tableViewHeight : viewHeight;
                    view.frame = CGRectMake(0, 0, self.bounds.size.width, viewHeight);
                    self.customScrollView.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y + self.bounds.size.height, self.bounds.size.width, 0);
                    [self.customScrollView addSubview:view];
                    [self.superview addSubview:self.customScrollView];
                    [UIView animateWithDuration:_kAnimationDuration animations:^{
                        self.customScrollView.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y + self.bounds.size.height, self.bounds.size.width, viewHeight);
                    }];
                }else{
                    self.tableView.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y + self.bounds.size.height, self.bounds.size.width, 0);
                    [self.superview addSubview:self.tableView];
                    [UIView animateWithDuration:_kAnimationDuration animations:^{
                        self.tableView.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y + self.bounds.size.height, self.bounds.size.width, heightForTableView);
                    }];
                }
            }else{
                self.tableView.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y + self.bounds.size.height, self.bounds.size.width, 0);
                [self.superview addSubview:self.tableView];
                [UIView animateWithDuration:_kAnimationDuration animations:^{
                    self.tableView.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y + self.bounds.size.height, self.bounds.size.width, heightForTableView);
                }];
            }
        }
            break;
            
        default:
            break;
    }
}

- (void)hiddenListViewWithHaveItems:(BOOL)haveItems{
    DropDownMenuStyle style = DropDownMenuStyleTableView;
    if (_currentSelectColumn < _menuStyleArray.count) {
        style = [NSString stringWithFormat:@"%@", _menuStyleArray[_currentSelectColumn]].integerValue;
    }
    switch (style) {
        case DropDownMenuStyleTableView:
        {
            [UIView animateWithDuration:_kAnimationDuration animations:^{
                self.tableView.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y + self.bounds.size.height, self.bounds.size.width, 0);
            } completion:^(BOOL finished) {
                [self.tableView removeFromSuperview];
            }];
        }
            break;
        case DropDownMenuStyleCustom:
        {
            if (_currentSelectColumn < _customViews.count) {
                UIView *view = _customViews[_currentSelectColumn];
                if (view != nil) {
                    [UIView animateWithDuration:_kAnimationDuration animations:^{
                        self.customScrollView.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y + self.bounds.size.height, self.bounds.size.width, 0);
                    } completion:^(BOOL finished) {
                        [self.customScrollView removeFromSuperview];
                        for (UIView *subView in [self.customScrollView subviews]) {
                            [subView removeFromSuperview];
                        }
                    }];
                } else {
                    [UIView animateWithDuration:_kAnimationDuration animations:^{
                        self.tableView.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y + self.bounds.size.height, self.bounds.size.width, 0);
                    } completion:^(BOOL finished) {
                        [self.tableView removeFromSuperview];
                    }];
                }
            } else {
                [UIView animateWithDuration:_kAnimationDuration animations:^{
                    self.tableView.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y + self.bounds.size.height, self.bounds.size.width, 0);
                } completion:^(BOOL finished) {
                    [self.tableView removeFromSuperview];
                }];
            }
        }
            break;
            
        default:
            break;
    }
}

// 箭头指示符动画
- (void)animateForIndicator:(CAShapeLayer *)indicator show:(BOOL)show complete:(void(^)(void))complete {
    if (show) {
        indicator.transform = CATransform3DMakeRotation(M_PI, 0, 0, 1);
        indicator.strokeColor = [_arrowSelectColor CGColor];
        indicator.fillColor = [_arrowSelectColor CGColor];//
    }else {
        indicator.transform = CATransform3DIdentity;
        indicator.strokeColor = [_arrowUnSelectColor CGColor];
        indicator.fillColor = [_arrowUnSelectColor CGColor]; //
    }
    if (complete) {
        complete();
    }
}

// titleLayer动画
- (void)animateForTitleLayer:(CATextLayer *)textLayer indicator:(CAShapeLayer *)indicator show:(BOOL)show complete:(void(^)(void))complete {
    
    CGSize textSize = [self calculateStringSize:[NSString stringWithFormat:@"%@", textLayer.string]];
    
    CGFloat maxWidth = self.bounds.size.width / _numberOfColumn - 25;
    CGFloat textLayerWidth = (textSize.width < maxWidth) ? textSize.width : maxWidth;
    CGFloat textLayerHeight = textSize.height;
    textLayer.bounds = CGRectMake(0, 0, textLayerWidth, textLayerHeight);
    if (indicator) {
        indicator.position = CGPointMake(textLayer.position.x + textLayerWidth / 2 + 10, indicator.position.y) ;
    }
    if (show) {
        textLayer.foregroundColor = [_itemTextSelectColor CGColor];
    }else {
        textLayer.foregroundColor = [_itemTextUnSelectColor CGColor];
    }
    if (complete) {
        complete();
    }
}

#pragma mark - Layer
// 背景layer
- (CALayer *)creatBackgroundLayer:(CGPoint)position backgroundColor:(UIColor *)backgroundColor {
    CALayer *layer = [[CALayer alloc] init];
    layer.position = position;
    layer.backgroundColor = [_menuBackgroundColor CGColor];
    layer.bounds = CGRectMake(0, 0, self.bounds.size.width/_numberOfColumn, self.bounds.size.height - 1);
    return layer;
}

// 标题Layer
- (CATextLayer *)creatTitleLayer:(NSString *)text position:(CGPoint)position textColor:(UIColor *)textColor {
    // size
    CGSize textSize = [self calculateStringSize:text];
    CGFloat maxWidth = self.bounds.size.width / _numberOfColumn - 25;
    CGFloat textLayerWidth = textSize.width < maxWidth ? textSize.width : maxWidth;
    
    //textLayer
    CATextLayer *textLayer = [[CATextLayer alloc] init];
    textLayer.bounds = CGRectMake(0, 0, textLayerWidth, textSize.height);
    textLayer.fontSize = _itemFontSize;
    textLayer.string = text;
    textLayer.alignmentMode = kCAAlignmentCenter;
    textLayer.truncationMode = kCATruncationEnd;
    textLayer.foregroundColor = [textColor CGColor];
    textLayer.contentsScale = SCREEN_SCALE;
    textLayer.position = position;
    return textLayer;
}
// 箭头指示符indicatorLayer
- (CAShapeLayer *)creatIndicatorLayer:(CGPoint)position color:(UIColor *)color {
    // path
    UIBezierPath *bezierPath = [[UIBezierPath alloc] init];
    [bezierPath moveToPoint:CGPointMake(0, 0)];
    [bezierPath addLineToPoint:CGPointMake(3.5, 3.5)];
    //    [bezierPath moveToPoint:CGPointMake(5, 5)];
    [bezierPath addLineToPoint:CGPointMake(7, 0)];
    [bezierPath closePath];
    // 填充色
    //    [color setFill];
    //    [bezierPath fill];
    
    // shapeLayer
    CAShapeLayer *shapeLayer = [[CAShapeLayer alloc] init];
    shapeLayer.path = bezierPath.CGPath;
    shapeLayer.lineWidth = 0.8;
    shapeLayer.strokeColor = [color CGColor];
    shapeLayer.fillColor = color.CGColor;
    
    //    shapeLayer.
    shapeLayer.bounds = CGPathGetBoundingBox(shapeLayer.path);
    shapeLayer.position = position;
    return shapeLayer;
}
// 竖分隔线separatorLayer
- (CAShapeLayer *)creatSeparatorLayer:(CGPoint)position color:(UIColor *)color {
    // path
    UIBezierPath *bezierPath = [[UIBezierPath alloc] init];
    [bezierPath moveToPoint:CGPointMake(0, 0)];
    [bezierPath addLineToPoint:CGPointMake(0, self.bounds.size.height - 16)];
    [bezierPath closePath];
    
    // separatorLayer
    CAShapeLayer *separatorLayer = [[CAShapeLayer alloc] init];
    separatorLayer.path = bezierPath.CGPath;
    separatorLayer.lineWidth = 1;
    separatorLayer.strokeColor = [color CGColor];
    separatorLayer.bounds = CGPathGetBoundingBox(separatorLayer.path);
    separatorLayer.position = position;
    return separatorLayer;
}

- (CGSize)calculateStringSize: (NSString *)string {
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:_itemFontSize]};
    NSStringDrawingOptions option = NSStringDrawingUsesLineFragmentOrigin;
    CGSize size = [string boundingRectWithSize:CGSizeMake(280, 0) options:option attributes:attributes context:nil].size;
    return CGSizeMake(ceil(size.width)+2, size.height);
}

#pragma mark - lazy
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y + self.bounds.size.height, self.bounds.size.width, 0)];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.rowHeight = _cellHeight;
        _tableView.backgroundColor = [UIColor colorWithWhite:0.99 alpha:1];
        _tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
        _tableView.separatorColor = [UIColor clearColor];
    }
    return _tableView;
}

- (UIView *)backgroundView {
    if (!_backgroundView) {
        _backgroundView = [[UIView alloc] initWithFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y+1, kSCREEN_WIDTH, kSCREEN_HEIGHT)];
        _backgroundView.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
        [_backgroundView setOpaque:NO];
        [_backgroundView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backTapped:)]];
    }
    return _backgroundView;
}

- (UIView *)bottomLineView {
    if (!_bottomLineView) {
        _bottomLineView = [[UIView alloc] initWithFrame:CGRectMake(0, self.bounds.size.height-(1.0/SCREEN_SCALE), self.frame.size.width, (1.0/SCREEN_SCALE))];
        _bottomLineView.backgroundColor = [UIColor grayColor];
//        _bottomLineView.layer.shadowColor = WTBgColor_BlackA.CGColor;
//        _bottomLineView.layer.shadowOpacity = 0.3;
//        _bottomLineView.layer.shadowOffset = CGSizeMake(0, 2);
//        _bottomLineView.layer.shadowRadius = 3;
    }
    return _bottomLineView;
}

- (UIScrollView *)customScrollView {
    if (!_customScrollView) {
        _customScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y + self.bounds.size.height, self.bounds.size.width, 0)];
        _customScrollView.backgroundColor = [UIColor whiteColor];
    }
    return _customScrollView;
}

@end
