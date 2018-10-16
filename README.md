   # WJXImagePreview

   ## 介绍
    图片预览控件仿照微信朋友圈!

   ## 版本
    1.0.0

   ## 版本
    source 'https://github.com/wangjixiao1992/WJXImagePreview.git'
    platform :ios, '8.0'

    target 'TargetName' do
    pod 'WJXImagePreview', '~> 1.0.0'
    end

   ## 演示代码
    //网络图片
    NSString *str = @"";
    NSArray *array = @{};
    NSArray *imageViewArray = @{};
    WJXImagePreviewCtl *vc = [[WJXImagePreviewCtl alloc] initWithUrl:str
                                                            urlArray:array
                                                      imageViewArray:imageViewArray
                                                          controller:self];
    [self.navigationController presentViewController:vc
                                            animated:NO
                                          completion:^{

                                          }];
    //网络图片
    UIImageView *imageView = @"";
    NSArray *imageViewArray = @{};
    WJXImagePreviewCtl *vc = [[WJXImagePreviewCtl alloc] initWithimageView:imageView
                                                            imageViewArray:imageViewArray
                                                                controller:self];
    [self.navigationController presentViewController:vc
                                            animated:NO
                                          completion:^{
                                          
                                          }];
   ## 联系我们
   如有疑问请发送邮件.谢谢~
wjx_19920914_msg@126.com



