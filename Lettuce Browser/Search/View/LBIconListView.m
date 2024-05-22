//
//  LBIconListView.m
//  Lettuce Browser
//
//  Created by shen on 2024/4/3.
//

#import "LBIconListView.h"
#import "Lettuce_Browser-Swift.h"

@interface LBIconListView ()

@property (nonatomic, copy) NSArray * urlArrays;
@property (nonatomic, copy) NSArray * tabLogArrays;

@end

@implementation LBIconListView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self initializeAppearance];
    }
    return self;
}

- (void)initializeAppearance {
    NSArray * iconArrays = @[@"home_search_douyin",@"home_search_whatsApp",@"home_search_youtube",@"home_search_twitter",@"home_search_amazon",@"home_search_camera",@"home_search_facebook",@"home_search_google"];
    NSArray * iconNameArrays = @[@"TikTok",@"WhatsApp",@"YouTube",@"Twitter",@"Amazon",@"Instagram",@"Facebook",@"Google"];
    self.urlArrays = @[@"https://www.tiktok.com",@"https://www.whatsapp.com",@"https://www.youtube.com",@"https://www.twitter.com",@"https://www.amazon.com",@"https://www.instagram.com",@"https://www.facebook.com",@"https://www.google.com"];
    self.tabLogArrays = @[@"tiktok",@"whatsapp",@"youtube",@"twitter",@"amazon",@"instagram",@"facebook",@"google"];
    
    CGFloat realWidth = LBAdapterWidth(62);
    CGFloat realHeight = LBAdapterHeight(70);
    CGFloat padding = (kLBDeviceWidth - (LBAdapterHeight(32) * 2) - (realWidth * 4)) / 3;
    CGFloat topMargin = 0;
    CGFloat topMargin2Line = LBAdapterHeight(28) + realHeight;
    CGFloat leftMargin = 0;
    
    for (int i = 0; i < iconArrays.count; i ++) {
        leftMargin = i;
        if (i > 3) {
            leftMargin -= 4;
            topMargin = topMargin2Line;
        }
        NSString * icon = iconArrays[i];
        NSString * iconName = iconNameArrays[i];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(leftMargin * padding + realWidth * leftMargin, topMargin, realWidth, realHeight);
        UIImage *image = [UIImage imageNamed:icon];
        button.tag = i;
        [button setImage:image forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:LBAdapterHeight(13)];
        [button setTitle:iconName forState:UIControlStateNormal];
        
        /// 图片在上，文字在下
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        button.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        button.imageEdgeInsets = UIEdgeInsetsMake(-(button.titleLabel.intrinsicContentSize.height + LBAdapterHeight(8)), 0, 0, -button.titleLabel.intrinsicContentSize.width);
        button.titleEdgeInsets = UIEdgeInsetsMake(0, -button.imageView.frame.size.width, -(button.imageView.frame.size.height + LBAdapterHeight(8)), 0);
        [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
    }
}

- (void)buttonClicked:(UIButton *)sender {
    NSString * url = self.urlArrays[sender.tag];
    NSString * tbaName = self.tabLogArrays[sender.tag];
    [LBTBALogManager objcLogEventWithName:@"pro_nav" params:@{@"bro":tbaName}];
    if (self.iconClickBlock) {
        self.iconClickBlock(url);
    }
}

@end
