//
//  ViewController.m
//  TagManager
//
//  Created by johnny on 15/11/27.
//  Copyright © 2015年 ftxbird. All rights reserved.
//

#import "ViewController.h"
#import "FXTagView.h"

#define ScreenWidth [UIScreen mainScreen].bounds.size.width

@interface ViewController ()<FXTagViewDelegate>

@property (nonatomic,strong) FXTagView *tagEditView;
@property (nonatomic,strong) FXTagView *tagselectView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    FXTagView *tagEditView =[FXTagView tagViewFrame:CGRectMake(20, 20, 300, 100) showType:ShowViewTypeEdit];
    [self.view addSubview:tagEditView];
    self.tagEditView = tagEditView;

    FXTagView *tagSelectedView = [FXTagView tagViewFrame:CGRectMake(20, 200, 300, 100) showType:ShowViewTypeSelected showTagArray:@[@"你好",@"英语魔方秀",@"四级英语",@"大宝天天见"]];
    tagSelectedView.tagDelegate = self;
    [self.view addSubview:tagSelectedView];
    self.tagselectView = tagSelectedView;
    
    // Do any additional setup after loading the view, typically from a nib.
}



- (void)tagDidSelectText:(NSString *)selectText tagView:(FXTagView *)tagView{
    NSLog(@"%@",selectText);
    [self.tagEditView addTag:selectText];
}


- (void)tagUnSelectText:(NSString *)unSelectText tagView:(FXTagView *)tagView{

    NSLog(@"%@",unSelectText);
    [self.tagEditView removeTag:unSelectText];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
