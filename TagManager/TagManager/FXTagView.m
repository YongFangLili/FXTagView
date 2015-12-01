//
//  FXTagsView.m
//  TagManager
//
//  Created by ftxbird on 15/11/27.
//  Copyright © 2015年 ftxbird. All rights reserved.
//

#import "FXTagView.h"


@protocol keyInputTextFieldDelegate <NSObject>

@optional
/**
 *  键盘删除键 回调
 */
- (void)deleteBackward;

@end

@interface  FXTagTextField : UITextField

@property (nonatomic,assign) id<keyInputTextFieldDelegate> keyInputDelegate;

@end


@implementation FXTagTextField

- (CGRect)textRectForBounds:(CGRect)bounds {
    return CGRectInset( bounds , 9 , 0 );
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
    return CGRectInset( bounds , 9 , 0 );
}

- (void)deleteBackward {

    [super deleteBackward];
    
    if (_keyInputDelegate &&[_keyInputDelegate respondsToSelector:@selector(deleteBackward)]) {
        [_keyInputDelegate deleteBackward];
    }
}


@end


/**根据项目需要,此处做调整*/
CGFloat   const columnSpace       = 8;  //列间距
CGFloat   const rowSpace          = 8;  //行间距
CGFloat   const rowHeight         = 30; //行高
CGFloat   const inputViewWidth    = 100;//输入框宽度
CGFloat   const tagMinWidth       = 60; //标签最小宽度
NSInteger const limitTagCount     = 15; //标签数量限制
NSInteger const limitTagWordCount = 15; //单标签文本字数限制


@interface FXTagView()<UITextFieldDelegate,keyInputTextFieldDelegate>

/**缓存TagsButton*/
@property (nonatomic,strong) NSArray *tagButtonPool;

/**单击删除按钮*/
@property (nonatomic,strong) UIButton *tagDeleteButton;

/**用户回退删除是否打开*/
@property (nonatomic,strong) UIButton *backDeleteButton ;
@end


@implementation FXTagView

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

+ (instancetype)tagViewFrame:(CGRect)frame showType:(ShowViewType)showType {

    FXTagView *tagView = [[self alloc] initWithFrame:frame];
    tagView.showType = showType;
    
    switch (showType) {
        case ShowViewTypeNormal: {
            
            break;
        }
        case ShowViewTypeEdit: {
            //添加输入框
            [tagView addSubview:tagView.inputTextField];
            break;
        }
        case ShowViewTypeSelected: {
            
            break;
        }
        default: {
            break;
        }
    }
    
    return tagView;
}


+ (instancetype)tagViewFrame:(CGRect)frame showType:(ShowViewType)showType showTagArray:(NSArray *)tags {
    FXTagView *tagView = [self tagViewFrame:frame showType:showType];
    [tagView addTags:tags];
    
    return tagView;
}


- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIMenuControllerWillShowMenuNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIMenuControllerDidHideMenuNotification object:nil];
}


- (void)commonInit {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(WillShowMenu:) name:UIMenuControllerWillShowMenuNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(HideMenu:) name:UIMenuControllerDidHideMenuNotification object:nil];
    
    _showType = ShowViewTypeNormal;
    
    _tagFont = [UIFont systemFontOfSize:14.0f];
    _tagFontColor = UIColorFromRGB(0x3F3F3F);
    _tagBackGroundColor = [UIColor whiteColor];
    _tagBorderColor = UIColorFromRGB(0xCACACA);
    _tagsArray = [NSMutableArray array];
    _tagSeletedColor = UIColorFromRGB(0x0FA2F9);
    
    self.backgroundColor = _tagBackGroundColor;
    
    //初始化缓存池
    [self initReusableButtonPool];
}


/**
 *  初始化缓存池
 */
- (void)initReusableButtonPool {
    NSMutableArray *tempArray = [NSMutableArray array];
    
    for (NSInteger i =0; i< limitTagCount; i++) {
        UIButton *tagBtn = [UIButton new];
        [tagBtn.titleLabel setFont:_tagFont];
        [tagBtn setBackgroundColor:_tagBackGroundColor];
        [tagBtn setTitleColor:_tagFontColor forState:UIControlStateNormal];
        tagBtn.layer.cornerRadius = ceil(rowHeight/2);
        tagBtn.layer.masksToBounds = YES;
        tagBtn.layer.borderColor = _tagBorderColor.CGColor;
        tagBtn.layer.borderWidth = 1/[UIScreen mainScreen].scale;
        [tempArray addObject:tagBtn];
    }
    self.tagButtonPool = [tempArray copy];
}

/**
 *  获取缓存中的TagButton
 *
 *  @return Button
 */
- (UIButton *)dequeueReusableTagButton:(NSInteger)tag {
    
    if (self.tagButtonPool.count<=0) return nil;
    
    UIButton *button = [self.tagButtonPool objectAtIndex:tag];
    
    return button;
    
}

/**
 *  点击标签,弹出删除菜单
 *
 *  @param sender 所点击的标签
 */
- (void)tagButtonSelected:(UIButton *)sender {
    
    if(self.showType ==ShowViewTypeNormal) return;
    
    if (self.showType == ShowViewTypeEdit) {
        [self becomeFirstResponder];
        UIMenuController *menu = [UIMenuController sharedMenuController];
        if (sender.selected) {
            [sender setTitleColor:_tagBackGroundColor forState:UIControlStateNormal];
            [sender setBackgroundColor:_tagSeletedColor];
            sender.selected=NO;
            [menu setMenuVisible:NO animated:YES];
        }else{
            [menu setMenuVisible:NO];
            [_tagDeleteButton setTitleColor:_tagFontColor forState:UIControlStateNormal];
            [_tagDeleteButton setBackgroundColor:_tagBackGroundColor];
            _tagDeleteButton.selected=NO;
            _tagDeleteButton=sender;
            [menu setTargetRect:sender.frame inView:self];
            [menu setMenuVisible:YES animated:YES];
        }
    }else if(self.showType == ShowViewTypeSelected) {
    
        [self changeButtonSelectedState:sender];
    }
}


- (void)changeButtonSelectedState:(UIButton *)sender {
    
    sender.selected = !sender.selected;
    if (sender.selected) {
        sender.layer.borderColor = self.tagSeletedColor.CGColor;
        [sender setTitleColor:self.tagSeletedColor forState:UIControlStateNormal];
        sender.backgroundColor = self.backgroundColor;
        
        if([self.tagDelegate respondsToSelector:@selector(tagDidSelectText:tagView:)]){
            [self.tagDelegate tagDidSelectText:sender.currentTitle tagView:self];
        }
        
        
    }else {
        sender.backgroundColor = self.backgroundColor;
        sender.layer.borderColor = self.tagBorderColor.CGColor;
        [sender setTitleColor:self.tagFontColor forState:UIControlStateNormal];
        
        
        if([self.tagDelegate respondsToSelector:@selector(tagUnSelectText:tagView:)]){
            [self.tagDelegate tagUnSelectText:sender.currentTitle tagView:self];
        }
    }
    
}


/**
 *  添加一个Tag   ***此处可优化为不用整个遍历创建
 *
 *  @param tagString 待添加Tag文本
 */
- (void)addTag:(NSString *)tagString {

    tagString = [tagString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if (tagString.length==0) {
        NSLog(@"不能输入空白标签!");
        return;
    }
    
    if (tagString.length>limitTagWordCount) {
        NSLog(@"最多10个字!");
        return;
    }
    
    for (NSString *title in self.tagsArray)
    {
        if ([tagString isEqualToString:title])
        {
            NSLog(@"已存在相同标签!");
            return;
        }
    }
    
    if (self.tagsArray.count == limitTagCount) {
        NSLog(@"超过标签数量限制,当前限制15个");
        return;
    }

    [self.tagsArray addObject:tagString];

    [self layoutSubviews];
    
    if ([self.tagDelegate respondsToSelector:@selector(heightDidChangedTagView:height:)]) {
        [self.tagDelegate heightDidChangedTagView:self height:self.frame.size.height];
    }

}

/**
 *  添加一个数组字符串
 *
 *  @param tags 待添加字符串数组
 */
- (void)addTags:(NSArray *)tags {
    
    if(!tags || !tags.count) return;
    
    for (NSString *tag in tags)
    {
        NSArray *result = [_tagsArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF == %@", tag]];
        if (result.count == 0)
        {
            [_tagsArray addObject:tag];
        }
    }
    
    [self layoutSubviews];
   
}

/**
 *  改变指定字符串 的控件选择状态
 *
 *  @param tagString 待改变状态控件的文本
 */
- (void)changeTagStateSpecialTag:(NSString *)tagString  {

   NSInteger foundedIndex =  [self findTagIndexByTagStr:tagString];
    
   if (foundedIndex == -1) return;
    
    UIButton *sender = [self.tagButtonPool objectAtIndex:foundedIndex];
    
    sender.selected = !sender.selected;
    if (sender.selected) {
        sender.layer.borderColor = self.tagSeletedColor.CGColor;
        [sender setTitleColor:self.tagSeletedColor forState:UIControlStateNormal];
        sender.backgroundColor = self.backgroundColor;
    }else {
        sender.backgroundColor = self.backgroundColor;
        sender.layer.borderColor = self.tagBorderColor.CGColor;
        [sender setTitleColor:self.tagFontColor forState:UIControlStateNormal];
    }
}

/**
 *  搜索指定文本所在 索引
 *
 *  @param tagString 搜索字符串
 *
 *  @return -1: 未找到 0-N: 寻找到
 */
- (NSInteger)findTagIndexByTagStr:(NSString *)tagString {

    NSInteger foundedIndex = -1;
    for (NSString *tempTagString in self.tagsArray)
    {
        if ([tagString isEqualToString:tempTagString])
        {
            foundedIndex = (NSInteger)[self.tagsArray indexOfObject:tempTagString];
            break;
        }
    }
    return foundedIndex;
}


/**
 *  移除一个Tag
 *
 *  @param tagString 待移除Tag文本
 */
- (void)removeTag:(NSString *)tagString {
    
    NSInteger foundIndex = [self findTagIndexByTagStr:tagString];
    
    if ([self findTagIndexByTagStr:tagString] == -1)
    {
        return;
    }
    [self.tagsArray removeObjectAtIndex:foundIndex];
    
    [self layoutSubviews];
    
    if ([self.tagDelegate respondsToSelector:@selector(heightDidChangedTagView:height:)]) {
        [self.tagDelegate heightDidChangedTagView:self height:self.frame.size.height];
    }

}

/**
 *  判断是否需要换行
 *
 *  @param currentX 当前移动X点
 *  @param btnWidth 当前要添加的宽度
 *
 *  @return Bool 是否需要换行
 */
- (BOOL)ifNeedAddRowCurrentX:(CGFloat)currentX  width:(CGFloat)btnWidth {
    
    //当前剩余宽度
    CGFloat restSpace = self.frame.size.width - currentX - columnSpace;
    
    //判断待加入按钮是否大于剩余宽度
    if (btnWidth > restSpace) {
        return YES;
    }else {
        return NO;
    }
}


- (void)layoutSubviews {

    if(_showType == ShowViewTypeEdit &&!_inputTextField) {
        [self inputTextField];
    }
    
    //子控件从视图移除
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:[UIButton class]]) {

            [view removeFromSuperview];
        }
    }
    //设置tagsArray,创建添加tag控件,并设置Frame
    //设置起点XY
    CGFloat moveX  = columnSpace;
    CGFloat moveY  = rowSpace;
    
    for (NSInteger i=0 ; i<self.tagsArray.count; i++) {
        
        NSString *tagText = (NSString *)[self.tagsArray objectAtIndex:i];
        UIButton *tagBtn = [self tagButtonWithTag:tagText index:i];
        CGFloat btnWidth = [tagBtn.titleLabel.text sizeWithAttributes:@{NSFontAttributeName:_tagFont}].width  + 20.0f;
        if(btnWidth < tagMinWidth) {
            btnWidth = tagMinWidth;
        }
        if([self ifNeedAddRowCurrentX:moveX width:btnWidth]){
            moveX = columnSpace;
            moveY += (rowHeight+rowSpace);
        }
        tagBtn.frame = CGRectMake(moveX, moveY, btnWidth, rowHeight);
        moveX += btnWidth + columnSpace;
        [self addSubview:tagBtn];
    }
    
    //更新 输入框 Frame
    if(self.showType == ShowViewTypeEdit) {
        BOOL addRowForTextField = [self ifNeedAddRowCurrentX:moveX width:self.inputTextField.frame.size.width];
        if (addRowForTextField) {
            moveX = columnSpace;
            moveY += (rowHeight +rowSpace);
        }
        self.inputTextField.frame = CGRectMake(moveX, moveY, inputViewWidth, rowHeight);
    }
    
    //更新容器Frame
    CGRect tempFrame = self.frame;
    tempFrame.size.height = moveY + rowHeight + columnSpace;
    self.frame = tempFrame;
}



- (UIButton *)tagButtonWithTag:(NSString *)tagTitle index:(NSInteger)index
{
    //从缓存取
    UIButton *tagBtn = [self dequeueReusableTagButton:index];
    [tagBtn setTitle:tagTitle forState:UIControlStateNormal];
    //选择模式添加 点击事件
    if (self.showType == ShowViewTypeEdit||self.showType == ShowViewTypeSelected) {
        [tagBtn addTarget:self action:@selector(tagButtonSelected:) forControlEvents:UIControlEventTouchUpInside];
    }
    return tagBtn;
}


- (FXTagTextField *)inputTextField {

    if (_inputTextField == nil) {
        FXTagTextField* inputField = [[FXTagTextField alloc] init];
        inputField.backgroundColor = [UIColor whiteColor];
        inputField.font = _tagFont;
        inputField.textColor = _tagFontColor;
        inputField.autocorrectionType = UITextAutocorrectionTypeNo;
        [inputField addTarget:self action:@selector(textFieldDidChange:)forControlEvents:UIControlEventEditingChanged];
        inputField.delegate = self;
        inputField.keyInputDelegate = self;
        inputField.placeholder=@"输入标签";
        inputField.returnKeyType = UIReturnKeyDone;
        _inputTextField = inputField;
        [self addSubview:_inputTextField];
        
    }
    return _inputTextField;
}

#pragma dataCheck






#pragma textField delegate 

- (void)deleteBackward {

    if (self.inputTextField.text.length > 0) return;
    if (self.tagsArray.count <=0) return;
    
     UIButton *lastButton = [self.tagButtonPool objectAtIndex:(self.tagsArray.count-1)];
    if (lastButton.selected) {
        lastButton.selected=NO;
        [lastButton setTitleColor:_tagFontColor forState:UIControlStateNormal];
        [lastButton setBackgroundColor:_tagBackGroundColor];
        [self removeTag:lastButton.currentTitle];
        self.backDeleteButton = nil;
        
        if ([self.tagDelegate respondsToSelector:@selector(tagDeletedText:tagView:)]){
            if(self.showType == ShowViewTypeEdit) {
                [self.tagDelegate tagDeletedText:lastButton.currentTitle tagView:self];
            }
        }
    }
    else{
        [lastButton setTitleColor:_tagBackGroundColor forState:UIControlStateNormal];
        [lastButton setBackgroundColor:_tagSeletedColor];
        lastButton.selected=YES;
        self.backDeleteButton = lastButton;
    }
    
    
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{

    return YES;
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
   
    if(self.limitChar) {
        NSString * regex = @"^[\u4E00-\u9FA5A-Za-z0-9_]+$";
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
        BOOL isMatch = [pred evaluateWithObject:textField.text];
        if (!isMatch) {
            return NO;
        }
    }
    
    [self addTag:textField.text];
    _inputTextField.text= nil;
    
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {

    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    NSLog(@"textFieldDidBeginEditing");
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField {

    NSLog(@"textFieldDidEndEditing");
}

- (void)textFieldDidChange:(FXTagTextField *)textField {
    NSLog(@"textFieldDidChange");
    if (!self.backDeleteButton || !self.tagsArray.count) return;
    

    self.backDeleteButton.backgroundColor = self.backgroundColor;
    self.backDeleteButton.layer.borderColor = self.tagBorderColor.CGColor;
    [self.backDeleteButton setTitleColor:self.tagFontColor forState:UIControlStateNormal];
    self.backDeleteButton.selected = NO;
    self.backDeleteButton = nil;
}

#pragma mark - Custom Menu

- (void)HideMenu:(NSNotification *)notification{
    [_tagDeleteButton setTitleColor:_tagFontColor forState:UIControlStateNormal];
    [_tagDeleteButton setBackgroundColor:_tagBackGroundColor];
    _tagDeleteButton.selected=NO;
    _tagDeleteButton=nil;
    
}
- (void)WillShowMenu:(NSNotification *)notification{
    [_tagDeleteButton setTitleColor:_tagBackGroundColor forState:UIControlStateNormal];
    [_tagDeleteButton setBackgroundColor:_tagSeletedColor];
    _tagDeleteButton.selected=YES;
}

- (BOOL)canBecomeFirstResponder{
    return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    if (_tagDeleteButton) {
        return action == @selector(delete:);
    }
    return NO;
}

- (void)delete:(id)sender{
    
    NSString *tempStr = _tagDeleteButton.currentTitle;
    
    [self removeTag:tempStr];
    
    
    if ([self.tagDelegate respondsToSelector:@selector(tagDeletedText:tagView:)]){

        [self.tagDelegate tagDeletedText:tempStr tagView:self];
    }
}




@end
