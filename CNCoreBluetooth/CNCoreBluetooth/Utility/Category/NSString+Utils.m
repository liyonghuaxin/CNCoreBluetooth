//
//  NSString+Utils.m
//  doctor
//
//  Created by Fly on 14-5-9.
//  Copyright (c) 2014年 mardin partytime. All rights reserved.
//

#import "NSString+Utils.h"
#import <CommonCrypto/CommonDigest.h>
#define EMOJI_CODE_TO_SYMBOL(x) ((((0x808080F0 | (x & 0x3F000) >> 4) | (x & 0xFC0) << 10) | (x & 0x1C0000) << 18) | (x & 0x3F) << 24);

@implementation NSString (Utils)

- (int)getByteNum{
    int strlength = 0;
    char* p = (char*)[self cStringUsingEncoding:NSUTF8StringEncoding];
    for (int i=0 ; i<[self lengthOfBytesUsingEncoding:NSUTF8StringEncoding] ;i++) {
        if (*p) {
            p++;
            strlength++;
        }
        else {
            p++;
        }
    }
    return strlength;
}
- (NSString *)subStringByByteLength:(NSInteger)Len{
    
    NSString *tempStr = [[NSString alloc] init];
    if ([self getByteNum] <= Len) {
        tempStr = self;
    }else{
        NSInteger sum = 0;
        for(int i = 0; i<[self length]; i++){
            NSString *subStr = [self substringWithRange:NSMakeRange(i, 1)];
            int byteLen = [subStr getByteNum];
            sum += byteLen;
            if (sum > Len) {
                tempStr = [self substringWithRange:NSMakeRange(0, i)];
                break;
            }
        }
    }
    
    //右补空格
    NSMutableString *resultStr = [[NSMutableString alloc] init];
    [resultStr appendString:tempStr];
    for (int i = 0; i <Len-[tempStr getByteNum]; i++) {
        [resultStr appendString:@" "];
    }
    return resultStr;
}

- (NSString *)stringValue;
{
    if ([self isKindOfClass:[NSString class]]) {
        return self;
    }else
    {
        return [NSString stringWithFormat:@"%@",self];
    }
}
- (NSString*)trim{
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

- (NSString*)trimRedundantWhiteSpace{
    NSCharacterSet *whitespaces = [NSCharacterSet whitespaceCharacterSet];
    NSPredicate *noEmptyStrings = [NSPredicate predicateWithFormat:@"SELF != ''"];
    
    NSArray *parts = [self componentsSeparatedByCharactersInSet:whitespaces];
    NSArray *filteredArray = [parts filteredArrayUsingPredicate:noEmptyStrings];
    return  [filteredArray componentsJoinedByString:@" "];
}

- (NSString *)MD5 {
    // Create pointer to the string as UTF8
    const char* ptr = [self UTF8String];
    
    // Create byte array of unsigned chars
    unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
    
    // Create 16 byte MD5 hash value, store in buffer
    CC_MD5(ptr, (CC_LONG) strlen(ptr), md5Buffer);
    
    // Convert MD5 value in the buffer to NSString of hex values
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x",md5Buffer[i]];
    }
    
    return output;
}
+ (NSString *)emojiWithCode:(int)code {
    int sym = EMOJI_CODE_TO_SYMBOL(code);
    return [[NSString alloc] initWithBytes:&sym length:sizeof(sym) encoding:NSUTF8StringEncoding];
}
- (NSString *)unicodeEmojiToUTF;
{
    NSString *result = [self mutableCopy];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\[emoji\\][^\\[]*\\[/emoji\\]" options:kNilOptions error:NULL];
    NSArray *arrayOfAllMatches = [regex matchesInString:self options:kNilOptions range:NSMakeRange(0, self.length)];
    NSUInteger urlClipLength = 0;
    for (NSTextCheckingResult *match in arrayOfAllMatches)
    {
        if (match.range.location == NSNotFound && match.range.length <= 1) continue;
        NSRange range = match.range;
        NSString *urlstring = [self substringWithRange:NSMakeRange(range.location+7, range.length-15)];
        urlstring = [NSString stringWithFormat:@"0x%@",urlstring];
        const char *hexChar = [urlstring cStringUsingEncoding:NSUTF8StringEncoding];
        int hexNumber;
        
        sscanf(hexChar, "%x", &hexNumber);
        if (urlClipLength) {
            range.location-=urlClipLength;
        }
        NSString *emoji = [NSString emojiWithCode:hexNumber];
        if (emoji) {
            result = [result stringByReplacingCharactersInRange:range withString:emoji];
        }
        urlClipLength+=range.length-emoji.length;
        
    }
    return result;
}
- (NSString *)replaceUnicodeToChinese{
    
	NSString *tempStr1 = [self stringByReplacingOccurrencesOfString:@"\\u" withString:@"\\U"];
	NSString *tempStr2 = [tempStr1 stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
	NSString *tempStr3 = [[@"\"" stringByAppendingString:tempStr2] stringByAppendingString:@"\""];
	NSData *tempData = [tempStr3 dataUsingEncoding:NSUTF8StringEncoding];
	NSString* returnStr = [NSPropertyListSerialization propertyListFromData:tempData
                                                           mutabilityOption:NSPropertyListImmutable
                                                                     format:NULL
                                                           errorDescription:NULL];
	
	//NSLog(@"Output = %@", returnStr);
	
	return [returnStr stringByReplacingOccurrencesOfString:@"\\r\\n" withString:@"\n"];
}

- (CGRect)stringHeightWithConstraintWidth:(CGFloat)width fontsize:(CGFloat)size;
{
    CGRect textRect = [self boundingRectWithSize:CGSizeMake(width, MAXFLOAT) options:NSStringDrawingTruncatesLastVisibleLine |NSStringDrawingUsesLineFragmentOrigin |NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:size]} context:nil];
    return textRect;
}

- (CGRect)stringHeightWithConstraintWidth:(CGFloat)width fontsize:(UIFont *)font WithSpace:(float)space
{
    if (space == 10) {
        CGRect rect = [self stringHeightWithConstraintWidth:width fontsize:16];
        if (rect.size.height<20) {
            //一行
            space = 0;
        }
    }
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:space];//调整行间距
    CGRect textRect = [self boundingRectWithSize:CGSizeMake(width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font,NSParagraphStyleAttributeName:paragraphStyle} context:nil];
    return textRect;
}
@end
