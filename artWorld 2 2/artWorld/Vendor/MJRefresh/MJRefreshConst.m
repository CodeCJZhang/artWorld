//
//  MJRefreshConst.m
//  MJRefresh
//
//  Created by mj on 14-1-3.
//  Copyright (c) 2014年 itcast. All rights reserved.
//

#import <UIKit/UIKit.h>

const CGFloat MJRefreshViewHeight = 64.0;
const CGFloat MJRefreshFastAnimationDuration = 0.25;
const CGFloat MJRefreshSlowAnimationDuration = 0.4;

NSString *const MJRefreshBundleName = @"MJRefresh.bundle";

NSString *const MJRefreshFooterPullToRefresh = @"上拉可以加载更多数据";
NSString *const MJRefreshFooterReleaseToRefresh = @"松开立即加载更多数据";
NSString *const MJRefreshFooterRefreshing = @"正在加载数据，请稍后...";

NSString *const MJRefreshHeaderPullToRefresh = @"下拉可以刷新";
NSString *const MJRefreshHeaderReleaseToRefresh = @"松开立即刷新";
NSString *const MJRefreshHeaderRefreshing = @"正在获取最新数据，请稍后...";
NSString *const MJRefreshHeaderTimeKey = @"MJRefreshHeaderView";

NSString *const MJRefreshContentOffset = @"contentOffset";
NSString *const MJRefreshContentSize = @"contentSize";