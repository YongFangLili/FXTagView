//
//  FXTagsView.h
//  TagManager
//
//  Created by ftxbird on 15/11/27.
//  Copyright © 2015年 ftxbird. All rights reserved.
//


#import <UIKit/UIKit.h>

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@class FXTagTextField;
@class FXTagView;


@protocol FXTagViewDelegate<NSObject>

@optional
/**
 *  高度改变回调
 *
 *  @param tagView FXTagView 实例
 */
-(void)heightDidChangedTagView:(FXTagView*)tagView height:(CGFloat)height;

/**
 *  选择显示模式下,单击点击选择的Tag文本
 *
 *  @param text 选择的文本
 */
- (void)tagDidSelectText:(NSString *)text tagView:(FXTagView *)tagView;

/**
 *  选择显示模式下,取消选择的Tag文本
 *
 *  @param text 选择的文本
 */
- (void)tagUnSelectText:(NSString *)text tagView:(FXTagView *)tagView;

@end

/**
 *  控件展示类型
 */
typedef NS_ENUM(NSInteger, ShowViewType) {
    /**
     *  纯展示,无交互功能
     */
    ShowViewTypeNormal = 0,
    /**
     *  展示 + 编辑
     */
    ShowViewTypeEdit,
    /**
     *  展示 + 选择
     */
    ShowViewTypeSelected
};



@interface FXTagView : UIView

/**展示类型*/
@property (nonatomic,assign) ShowViewType showType;

/**标签数组*/
@property (nonatomic,strong) NSMutableArray *tagsArray;

/**文本输入控件*/
@property (nonatomic,strong) FXTagTextField *inputTextField;

/**代理*/
@property (nonatomic,weak)   id<FXTagViewDelegate>tagDelegate;

/**
 *  标签View 初始化方法
 *
 *  @param frame    tagView初始Frame
 *  @param showType 展示类型
 *
 *  @return 返回TagView实例
 */
+ (instancetype)tagViewFrame:(CGRect)frame showType:(ShowViewType)showType;

/**
 *  标签View 初始化方法
 *
 *  @param frame    tagView初始Frame
 *  @param showType 展示类型
 *  @param tags     默认文本数组
 *
 *  @return 返回TagView实例
 */
+ (instancetype)tagViewFrame:(CGRect)frame showType:(ShowViewType)showType showTagArray:(NSArray *)tags;


/**
 *  添加一个Tag   (已优化为从重用池取, 还可以继续优化不用整个遍历!!!)
 *
 *  @param tagString 待添加Tag文本
 */
- (void)addTag:(NSString *)tagString;

/**
 *  添加一个数组字符串
 *
 *  @param tags 待添加字符串数组
 */
- (void)addTags:(NSArray *)tags;
/**
 *  移除一个Tag
 *
 *  @param tagString 待移除Tag文本
 */
- (void)removeTag:(NSString *)tagString;
@end
