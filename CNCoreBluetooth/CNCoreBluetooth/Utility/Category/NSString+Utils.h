//
//  NSString+Utils.h
//  doctor
//
//  Created by Fly on 14-5-9.
//  Copyright (c) 2014年 mardin partytime. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Utils)

//计算字符串的字节数(汉字占两个)
- (int)getByteNum;

//从字符串中截取指定字节数
- (NSString *)subStringByByteLength:(NSInteger)Len withPara:(NSString *)para;

/**
 *  去除字符串两边的空格
 *
 *  @return 删除空格后的字符串
 */
- (NSString*)trim;
/**
 *  去除多余的空格，包括字符串中间的空格
 *
 *  @return 删除空格后的字符串
 */
- (NSString*)trimRedundantWhiteSpace;

- (NSString *)MD5;

- (NSString *)replaceUnicodeToChinese;

- (NSString *)stringValue;

//[emoji]UNICODE字符[/emoji]
- (NSString *)unicodeEmojiToUTF;

- (CGRect)stringHeightWithConstraintWidth:(CGFloat)width fontsize:(CGFloat)size;

//计算有行间距时候的高度
- (CGRect)stringHeightWithConstraintWidth:(CGFloat)width fontsize:(UIFont *)font WithSpace:(float)space;
@end
