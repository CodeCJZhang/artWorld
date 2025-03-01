//
//  PlaceholderTextView.h
//  SaleHelper
//
//  Created by gitBurning on 14/12/8.
//  Copyright (c) 2014年 Burning_git. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BRPlaceholderTextView : UITextView

@property(copy,nonatomic)   NSString *placeholder;

@property(strong,nonatomic) NSIndexPath * indexPath;

//最大长度设置
@property(assign,nonatomic) NSInteger maxTextLength;

//更新高度的时候
@property(assign,nonatomic) float updateHeight;

/**
 *  增加text 长度限制
 *
 *  @param maxLength
 *  @param limit
 */
-(void)addMaxTextLengthWithMaxLength:(NSInteger)maxLength andEvent:(void(^)(BRPlaceholderTextView*text))limit;
/**
 *  开始编辑 的 回调
 *
 *  @param begin
 */
-(void)addTextViewBeginEvent:(void(^)(BRPlaceholderTextView*text))begin;

/**
 *  结束编辑 的 回调
 *
 *  @param begin
 */
-(void)addTextViewEndEvent:(void(^)(BRPlaceholderTextView*text))End;

/**
 *  设置Placeholder 颜色
 *
 *  @param color
 */
-(void)setPlaceholderColor:(UIColor*)color;

/**
 *  设置Placeholder 字体
 *
 *  @param font
 */
-(void)setPlaceholderFont:(UIFont*)font;

/**
 *  设置透明度
 *
 *  @param opacity
 */
-(void)setPlaceholderOpacity:(float)opacity;

@end
