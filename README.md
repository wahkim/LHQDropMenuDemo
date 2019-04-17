# LHQDropMenuDemo
iOS 自定义筛选列表项

```
_menuView = [[LHQDropDownMenuView alloc]initWithFrame:CGRectMake(0, [UIApplication sharedApplication].statusBarFrame.size.height + 44, [UIScreen mainScreen].bounds.size.width, 45) titles:@[@"地址",@"日期"] subTitles:@[@[@"1",@"2",@"3"],@[@"12",@"123",@"1234",@"12345"]]];
        _menuView.delegate = self;
        _menuView.arrowSelectColor = [UIColor orangeColor];
        _menuView.arrowUnSelectColor = [UIColor grayColor];
        _menuView.itemTextSelectColor = [UIColor orangeColor];
        _menuView.itemTextUnSelectColor = [UIColor grayColor];
        _menuView.separatorColor = [UIColor grayColor];
        _menuView.itemFontSize = 13;
        _menuView.cellTitleFontSize = 13;
        _menuView.cellTextSelectColor = [UIColor orangeColor];
        _menuView.cellTextUnSelectColor = [UIColor grayColor];
        _menuView.menuStyleArray = @[[NSNumber numberWithInteger:DropDownMenuStyleTableView],
                                     [NSNumber numberWithInteger:DropDownMenuStyleCustom]].mutableCopy;
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 300)];
        label.text = @"自定义视图";
        label.textAlignment = NSTextAlignmentCenter;
        _menuView.customViews = @[[NSNull null],label].mutableCopy;
```
