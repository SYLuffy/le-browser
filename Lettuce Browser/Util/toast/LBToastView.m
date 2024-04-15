//
//  JJAToastView.m
//  JJCToast
//
//  Created by shenyi on 2021/12/15.
//  Copyright © 2021 jojo. All rights reserved.
//

#import "LBToastView.h"
#import "LBToastConfig.h"

@interface LBToastView()
@property (nonatomic, strong) UIImageView *tipImageView;
@property (nonatomic, strong) UILabel *messageLabel;
@property (nonatomic, strong) UIImage *displayImage;
@property (nonatomic, assign) CGFloat leftPadding;
@property (nonatomic, assign) CGFloat topPadding;
@end

@implementation LBToastView

+ (instancetype _Nullable)toastWithMessage:(NSString * _Nullable)message
                                      type:(JJCToastType)type
                                   originY:(CGFloat)originY
                                  tipImage:(UIImage * _Nullable)image {
    LBToastView *toastView = [[LBToastView alloc] init];
    toastView.displayImage = image;
    toastView.leftPadding = message ? kToastConfig.leftPadding : 0;
    toastView.topPadding = message ? kToastConfig.topPadding : 0;
    [toastView setCommonWithMessage:message
                               type:type];
    
    [toastView setFrameWithMessage:message
                              type:type
                           originY:originY];
    return toastView;
}

- (void)setCommonWithMessage:(NSString * _Nullable)message
                        type:(JJCToastType)type {
    self.backgroundColor = kToastConfig.backColor;
    if (self.displayImage && type == JJCToastTypeImage) {
        self.tipImageView.image = kToastConfig.imageCornerRadius > 0 ? [self JJCToast_cornerRadius:kToastConfig.imageCornerRadius size:kToastConfig.tipImageSize withImage:self.displayImage] : self.displayImage;
    }
    self.layer.cornerRadius = kToastConfig.cornerRadius;
    self.layer.masksToBounds = YES;
    self.messageLabel.attributedText = [self attributed:message];
}

- (NSAttributedString *)attributed:(NSString * _Nullable)message {
    if (!message) { return nil; }
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
    if (kToastConfig.lineSpacing > 0) {
        paragraphStyle.lineSpacing = kToastConfig.lineSpacing - (self.messageLabel.font.lineHeight - self.messageLabel.font.pointSize);
    }
    if (kToastConfig.lineHeight > 0) {
        paragraphStyle.maximumLineHeight = kToastConfig.lineHeight;
        paragraphStyle.minimumLineHeight = kToastConfig.lineHeight;
    }
    CGFloat baselineOffset = (kToastConfig.lineHeight - self.messageLabel.font.lineHeight) / 4;
    NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
    [attributes setValue:paragraphStyle forKey:NSParagraphStyleAttributeName];
    [attributes setValue:@(baselineOffset) forKey:NSBaselineOffsetAttributeName];
    [attributes setValue:kToastConfig.font forKey:NSFontAttributeName];
    [attributes setValue:kToastConfig.textColor forKey:NSForegroundColorAttributeName];
    NSAttributedString *attStr = [[NSAttributedString alloc] initWithString:message
                                                                 attributes:attributes];
    if(kToastConfig.attStrColor && NSMaxRange(kToastConfig.attStrRange) <= attStr.length){
        NSMutableAttributedString *mulAtstr = [[NSMutableAttributedString alloc] initWithAttributedString:attStr];
        [mulAtstr addAttribute:NSForegroundColorAttributeName value:kToastConfig.attStrColor range:kToastConfig.attStrRange];
        return mulAtstr.copy;
    }
    NSAssert(NSMaxRange(kToastConfig.attStrRange) <= attStr.length, @"attStrRange 已经超出文本长度");
    return attStr;
}

- (void)setFrameWithMessage:(NSString * _Nullable)message
                       type:(JJCToastType)type
                    originY:(CGFloat)originY {
    CGSize toastSize = [self getToastSizeWithMessage:message type:type];
    
    CGFloat y = originY > 0 ? originY : ((KLBScreenHeight - toastSize.height) / 2);
    CGFloat topSpace = kToastConfig.minTopMargin;
    y = y < topSpace ? topSpace : y;
    if (2 * topSpace + toastSize.height > KLBScreenHeight) {
        toastSize.height = KLBScreenHeight - (2 * topSpace);
    }
    CGFloat toastWidth = kToastConfig.minWidth > toastSize.width ? kToastConfig.minWidth : toastSize.width;
    self.frame = CGRectMake((kLBScreenWidth - toastWidth) / 2, y, toastWidth, toastSize.height);
    [self addConstraintWithType:type message:message];
}

- (CGSize)getToastSizeWithMessage:(NSString * _Nullable)message
                             type:(JJCToastType)type {
    if (type == JJCToastTypeImage && !message) {
        return CGSizeMake(kToastConfig.tipImageSize.width + (2 * self.leftPadding), kToastConfig.tipImageSize.height + (2 * self.topPadding));
    }
    CGFloat maxWidth = kLBScreenWidth - (kToastConfig.minLeftMargin * 2);
    CGFloat maxHeight = KLBScreenHeight - (kToastConfig.minTopMargin * 2);
    CGSize textSize = [_messageLabel sizeThatFits:CGSizeMake(maxWidth - kToastConfig.leftPadding, maxHeight - kToastConfig.topPadding)];
    CGFloat labelWidth = textSize.width;
    CGFloat labelHeight = textSize.height;
    CGSize imageSize = (type == JJCToastTypeWords) ? CGSizeMake(0, 0) : kToastConfig.tipImageSize;
    CGFloat toastHeight = 2 * self.topPadding + imageSize.height + labelHeight;
    CGFloat toastWidth = ((labelWidth > imageSize.width) || (type == JJCToastTypeWords)) ? labelWidth + (2 * self.leftPadding) : imageSize.width + (2 * self.leftPadding);
    if (type == JJCToastTypeImage && message) { toastHeight += kToastConfig.tipImageBottomMargin; }
    return CGSizeMake(toastWidth, toastHeight);
}

- (void)addConstraintWithType:(JJCToastType)type
                      message:(NSString * _Nullable)message {
    
    if (type == JJCToastTypeImage && !message) {
        [self addSubview:self.tipImageView];
        [self.tipImageView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.tipImageView
                                                         attribute:NSLayoutAttributeTop
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeTop
                                                        multiplier:1.0
                                                          constant:self.topPadding]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.tipImageView
                                                         attribute:NSLayoutAttributeLeft
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeLeft
                                                        multiplier:1.0
                                                          constant:self.leftPadding]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.tipImageView
                                                         attribute:NSLayoutAttributeBottom
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeBottom
                                                        multiplier:1.0
                                                          constant:-self.topPadding]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.tipImageView
                                                         attribute:NSLayoutAttributeRight
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeRight
                                                        multiplier:1.0
                                                          constant:-self.leftPadding]];
        return;
    }
    
    [self addSubview:self.messageLabel];
    [self.messageLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    if (type == JJCToastTypeWords) {
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.messageLabel
                                                         attribute:NSLayoutAttributeTop
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeTop
                                                        multiplier:1.0
                                                          constant:self.topPadding]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.messageLabel
                                                         attribute:NSLayoutAttributeLeft
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeLeft
                                                        multiplier:1.0
                                                          constant:self.leftPadding]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.messageLabel
                                                         attribute:NSLayoutAttributeBottom
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeBottom
                                                        multiplier:1.0
                                                          constant:-self.topPadding]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.messageLabel
                                                         attribute:NSLayoutAttributeRight
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeRight
                                                        multiplier:1.0
                                                          constant:-self.leftPadding]];
    } else {
        [self addSubview:self.tipImageView];
        [self.tipImageView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.tipImageView
                                                         attribute:NSLayoutAttributeTop
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeTop
                                                        multiplier:1.0
                                                          constant:self.topPadding]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.tipImageView
                                                         attribute:NSLayoutAttributeCenterX
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeCenterX
                                                        multiplier:1.0
                                                          constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.tipImageView
                                                         attribute:NSLayoutAttributeWidth
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:nil
                                                         attribute:NSLayoutAttributeNotAnAttribute
                                                        multiplier:1.0
                                                          constant:kToastConfig.tipImageSize.width]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.tipImageView
                                                         attribute:NSLayoutAttributeHeight
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:nil
                                                         attribute:NSLayoutAttributeNotAnAttribute
                                                        multiplier:1.0
                                                          constant:kToastConfig.tipImageSize.height]];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.messageLabel
                                                         attribute:NSLayoutAttributeTop
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self.tipImageView
                                                         attribute:NSLayoutAttributeBottom
                                                        multiplier:1.0
                                                          constant:kToastConfig.tipImageBottomMargin]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.messageLabel
                                                         attribute:NSLayoutAttributeLeft
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeLeft
                                                        multiplier:1.0
                                                          constant:self.leftPadding]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.messageLabel
                                                         attribute:NSLayoutAttributeBottom
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeBottom
                                                        multiplier:1.0
                                                          constant:-self.topPadding]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.messageLabel
                                                         attribute:NSLayoutAttributeRight
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeRight
                                                        multiplier:1.0
                                                          constant:-self.leftPadding]];
    }
}

- (UIImage *)JJCToast_cornerRadius:(CGFloat)radius size:(CGSize)size withImage:(UIImage *)image {
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    UIBezierPath * path = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(radius, radius)];
    CGContextAddPath(ctx,path.CGPath);
    CGContextClip(ctx);
    [image drawInRect:rect];
    CGContextDrawPath(ctx, kCGPathFillStroke);
    UIImage * newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

#pragma mark - property

- (UIImageView *)tipImageView {
    if (!_tipImageView) {
        _tipImageView = [[UIImageView alloc] init];
    }
    return _tipImageView;
}

- (UILabel *)messageLabel {
    if (!_messageLabel) {
        _messageLabel = [[UILabel alloc] init];
        _messageLabel.numberOfLines = 0;
        _messageLabel.textAlignment = NSTextAlignmentCenter;
        UIFont *font = [UIFont systemFontOfSize:14];
        _messageLabel.font = font;
    }
    return _messageLabel;
}

@end
