//
//  FQQWebViewController.m
//  FQQWebViewController
//
//  Created by 冯清泉 on 2017/3/13.
//  Copyright © 2017年 冯清泉. All rights reserved.
//

#import "FQQWebViewController.h"
#import <WebKit/WebKit.h>

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

typedef NS_ENUM(NSInteger, Statu){
    Add,
    Switch
};

@interface FQQWebViewController () <WKNavigationDelegate>

@property (nonatomic) WKWebView *webView;
@property (nonatomic) Statu statu;
@property (nonatomic) NSString *link;
@property (nonatomic) NSMutableArray<NSURL *> *URLs;
@property (nonatomic) NSUInteger index;
@property (nonatomic) NSString *htmlString;

@end

@implementation FQQWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _link = @"http://elderscrollsonline.wiki.fextralife.com";
    _URLs = [NSMutableArray arrayWithObject:[NSURL URLWithString:_link]];
    _index = 0;
    
    _webView = [[WKWebView alloc]initWithFrame:self.view.bounds];
    _webView.navigationDelegate = self;
    [self.view addSubview:_webView];
    
    [self makeButtomNav];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        _htmlString = [NSString stringWithContentsOfURL:_URLs[_index] encoding:NSUTF8StringEncoding error:nil];
        if(_htmlString == nil || _htmlString.length == 0){
            NSLog(@"load failed!");
        }else{
            _htmlString = [self filterHtmlString:_htmlString];
            [_webView loadHTMLString:_htmlString baseURL:_URLs[_index]];
        }
    });
}

- (NSString *)filterHtmlString:(NSString *)htmlString{
    NSScanner *theScanner;
    NSString *text = nil;
    theScanner = [NSScanner scannerWithString:htmlString];
    
    [theScanner scanUpToString:@"<div id=\"fex-account\">" intoString:NULL];
    [theScanner scanUpToString:@"</form>" intoString:&text];
    htmlString = [htmlString stringByReplacingOccurrencesOfString:text withString:@""];
    
    [theScanner scanUpToString:@"<div class=\"discussion-wrapper\" id=\"discussions-section\">" intoString:NULL];
    [theScanner scanUpToString:@"<script data-cfasync=\"false\" type=\"text/javascript\" src=\"/wiki/js/comment-posting.js\">" intoString:&text];
    htmlString = [htmlString stringByReplacingOccurrencesOfString:text withString:@""];
    
    return htmlString;
}

- (void)makeButtomNav{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, SCREEN_HEIGHT - 50, SCREEN_WIDTH, 50)];
    view.backgroundColor = [UIColor blackColor];
    [self.view addSubview:view];
    NSArray *buttonDefaultImages = @[@"tab_btn_back", @"tab_btn_refresh", @"tab_btn_next"];
    NSArray *buttonPressedImages = @[@"tab_btn_back_down", @"tab_btn_refresh_down", @"tab_btn_next_down"];
    for(int i = 0; i < 3; i++){
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        if(i == 0){
            button.frame = CGRectMake(75, SCREEN_HEIGHT - 50, 50, 50);
        }else if(i == 1){
            button.frame = CGRectMake(250, SCREEN_HEIGHT - 50, 50, 50);
        }else{
            button.frame = CGRectMake(125, SCREEN_HEIGHT - 50, 50, 50);
        }
        [button setImage:[UIImage imageNamed:buttonDefaultImages[i]] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:buttonPressedImages[i]] forState:UIControlStateHighlighted];
        button.tag = i;
        [button addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
    }
}

-(void)click:(UIButton *)Btn{
    switch (Btn.tag) {
        case 1:{
            //刷新
            [_webView loadHTMLString:_htmlString baseURL:_URLs[_index]];
        }
            break;
        case 0:{
            //后退
            if(_index > 0){
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    _htmlString = [NSString stringWithContentsOfURL:_URLs[_index - 1] encoding:NSUTF8StringEncoding error:nil];
                    if(_htmlString == nil || _htmlString.length == 0){
                        NSLog(@"load failed!");
                    }else{
                        _index--;
                        _htmlString = [self filterHtmlString:_htmlString];
                        [_webView loadHTMLString:_htmlString baseURL:_URLs[_index]];
                    }
                });
            }else{
                [self.navigationController popViewControllerAnimated:YES];
            }
        }
            break;
        case 2:{
            //前进
            if(_index < _URLs.count - 1){
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    _htmlString = [NSString stringWithContentsOfURL:_URLs[_index + 1] encoding:NSUTF8StringEncoding error:nil];
                    if(_htmlString == nil || _htmlString.length == 0){
                        NSLog(@"load failed!");
                    }else{
                        _index++;
                        _htmlString = [self filterHtmlString:_htmlString];
                        [_webView loadHTMLString:_htmlString baseURL:_URLs[_index]];
                    }
                });
            }
        }
            break;
        default:
            break;
    }
}

#pragma mark - WKNavigationDelegate
// 接收到服务器跳转请求之后再执行
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation{
}

// 在发送请求之前，决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{
    NSString *URLString = navigationAction.request.URL.absoluteString;
    NSLog(@"监测到的WKWebView上的请求 %@",URLString);
    
    WKNavigationActionPolicy actionPolicy;
    if([URLString hasPrefix:_link]){
        actionPolicy = WKNavigationActionPolicyAllow;
        if(_index == _URLs.count - 1){
            _statu = Add;//新增
        }else{
            _statu = Switch;//替换
        }
    }else{
        actionPolicy = WKNavigationActionPolicyCancel;
    }
    
    // 这句是必须加上的，不然会异常
    decisionHandler(actionPolicy);
}

// 在收到响应后，决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler{
    NSURL *URL = navigationResponse.response.URL;
    NSLog(@"响应头url->%@", URL.absoluteString);
    
    WKNavigationResponsePolicy responsePolicy = WKNavigationResponsePolicyCancel;
    // 这句是必须加上的，不然会异常
    decisionHandler(responsePolicy);
    
    if([URL.absoluteString hasPrefix:_link]){
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            _htmlString = [NSString stringWithContentsOfURL:URL encoding:NSUTF8StringEncoding error:nil];
            if(_htmlString == nil || _htmlString.length == 0){
                NSLog(@"load failed!");
            }else{
                _index++;
                if(_statu == Switch){
                    NSMutableIndexSet *set = [[NSMutableIndexSet alloc]init];
                    for(NSUInteger i = _index; i < _URLs.count; i++){
                        [set addIndex:i];
                    }
                    [_URLs removeObjectsAtIndexes:set];
                }
                [_URLs addObject:URL];
                _htmlString = [self filterHtmlString:_htmlString];
                [_webView loadHTMLString:_htmlString baseURL:_URLs[_index]];
            }
        });
    }
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation{
    NSLog(@"start");
}

- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation{
    NSLog(@"loading...");
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    NSLog(@"finish");
    /*
     ⚠️：这个方法是当网页的内容全部显示（网页内的所有图片必须都正常显示）的时候调用（不是出现的时候就调用），否则不显示，或则部分显示时这个方法就不调用。
     */
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error{
    NSLog(@"failProvisional");
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error{
    NSLog(@"fail");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
