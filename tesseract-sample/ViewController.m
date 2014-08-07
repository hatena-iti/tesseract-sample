//
//  ViewController.m
//  tesseract-sample
//

#import "ViewController.h"

// TesseractOCR.framework: https://github.com/gali8/Tesseract-OCR-iOS

// kImageFileName の値を @"ocr-sample-japanese"（日本語文字サンプル）に指定した場合は、
// kLanguage の値を @"jpn" に指定します。
// kImageFileName == @"ocr-sample-english" の場合は、kLanguage = @"eng" とします。）

static NSString * const kImageFileName = @"ocr-sample-japanese"; // 日本語文字サンプル
//static NSString * const kImageFileName = @"ocr-sample-english"; // 英数字サンプル

static NSString * const kLanguage = @"jpn"; // 解析対象言語：日本語
//static NSString * const kLanguage = @"eng"; // 解析対象言語：英語

@interface ViewController ()

@end

@implementation ViewController {
    // 文字解析用に加工したイメージデータを保持するフィールド
    UIImage *adjustedImage_;
}

@synthesize imageView=imageView_;
@synthesize label=label_;

- (void)viewDidLoad {
    [super viewDidLoad];

    // 文字解析対象の画像を表示する
    self.imageView.image = [UIImage imageNamed:kImageFileName];

    // 文字解析を実行する
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [self analyze];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

// 文字解析を実行する
- (void)analyze {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{

        CIImage *ciImage = [[CIImage alloc] initWithImage:self.imageView.image];

        //文字を読みやすくするため、白黒にして、コントラストを強めに、また輪郭をくっきりさせるよう設定する
        CIFilter *ciFilter =
            [CIFilter filterWithName:@"CIColorMonochrome"
                       keysAndValues:kCIInputImageKey, ciImage,
                        @"inputColor", [CIColor colorWithRed:0.75 green:0.75 blue:0.75],
                        @"inputIntensity", [NSNumber numberWithFloat:1.0],
                        nil];
        ciFilter =
            [CIFilter filterWithName:@"CIColorControls"
                       keysAndValues:kCIInputImageKey, [ciFilter outputImage],
                        @"inputSaturation", [NSNumber numberWithFloat:0.0],
                        @"inputBrightness", [NSNumber numberWithFloat:-1.0],
                        @"inputContrast", [NSNumber numberWithFloat:4.0],
                        nil];

        ciFilter =
            [CIFilter filterWithName:@"CIUnsharpMask"
                       keysAndValues:kCIInputImageKey, [ciFilter outputImage],
                        @"inputRadius", [NSNumber numberWithFloat:2.5],
                        @"inputIntensity", [NSNumber numberWithFloat:0.5],
                        nil];

        CIContext *ciContext = [CIContext contextWithOptions:nil];
        CGImageRef cgImage =
            [ciContext createCGImage:[ciFilter outputImage] fromRect:[[ciFilter outputImage] extent]];

        // 文字解析対象の画像の色、コントラストを調整したものを変数に保存する
        UIImage *adjustedImage = [UIImage imageWithCGImage:cgImage];
        CGImageRelease(cgImage);

        Tesseract* tesseract = [[Tesseract alloc] initWithLanguage:kLanguage];
        tesseract.delegate = self;

//      [tesseract setVariableValue:@"0123456789" forKey:@"tessedit_char_whitelist"]; //limit search
        [tesseract setImage:adjustedImage]; //image to check
        [tesseract recognize];
        NSString *recognizedText = [tesseract recognizedText];
        tesseract = nil; //deallocate and free all memory

        dispatch_async(dispatch_get_main_queue(), ^{
            // 解析結果を画面に表示する
            self.label.text = recognizedText;
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        });
    });
}

#pragma mark - TesseractDelegate methods

- (BOOL)shouldCancelImageRecognitionForTesseract:(Tesseract*)tesseract {
    NSLog(@"progress: %d", tesseract.progress);
    return NO;  // return YES, if you need to interrupt tesseract before it finishes
}
@end
