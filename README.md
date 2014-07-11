tesseract-sample
================

Tesseract ライブラリを用いた、OCR（画像からの文字解析）機能の iOS アプリサンプルです。

# （参考）Tesseract ライブラリの導入手順

## 準備

### TesseractOCR.framework の取得

https://github.com/gali8/Tesseract-OCR-iOS から、
TesseractOCR.framework のソースを取得します。

### traineddata ファイルの取得

https://code.google.com/p/tesseract-ocr/downloads/list から、
各言語用のデータファイルを取得します。
日本語用のデータファイルは「tesseract-ocr-3.02.jpn.tar.gz」です。

## ビルド

### TesseractOCR.framework の配置

取得した TesseractOCR.framework のソースの「Products」フォルダの中から、
「TesseractOCR.framework」ファイルを取得し、対象の XCode Project 内にコピーします。

### traineddata ファイルの配置

取得した TesseractOCR.framework のソースの「Template Framework Project」フォルダ内の
「tessdata」フォルダを、対象のXCode プロジェクトのルートにドラッグしてコピーします。
このとき、「<code>Create folder references for any added folders</code>」オプションを
選択しておきます。

追加の言語用のデータファイル（日本語用データファイルなど）がある場合は、
この「tessdata」フォルダに配置します。

### libstdc++.6.0.9.dylib ライブラリへのリンク（iOS7以降）

対象 XCode プロジェクトの「General」=>「Linked Frameworks and Libraries」=>「+」を
選択して、「<code>libstdc++.6.0.9</code>」を追加します。

### Other Linker Flags の設定

対象 XCode プロジェクトの「Build Settings」=>「Other Linker Flags」を
選択して、「<code>-lstdc++</code>」を値として指定します。

### C++ Standard Library の設定

対象 XCode プロジェクトの「Build Settings」=>「C++ Standard Library」を
選択して、その値を「<code>Compiler Default</code>」に設定します。

## TesseractOCR.framework の機能の利用

基本的には、以下のような形になります。

**MyViewController.h**

```objective-c
#import <TesseractOCR/TesseractOCR.h>
@interface MyViewController : UIViewController <TesseractDelegate>
@end
```

**MyViewController.m**

```objective-c
- (void)viewDidLoad
{
    [super viewDidLoad];

    // language are used for recognition. Ex: eng. Tesseract will search for a eng.traineddata file in the dataPath directory; eng+ita will search for a eng.traineddata and ita.traineddata.

    //Like in the Template Framework Project:
    // Assumed that .traineddata files are in your "tessdata" folder and the folder is in the root of the project.
    // Assumed, that you added a folder references "tessdata" into your xCode project tree, with the ‘Create folder references for any added folders’ options set up in the «Add files to project» dialog.
    // Assumed that any .traineddata files is in the tessdata folder, like in the Template Framework Project

    //Create your tesseract using the initWithLanguage method:
    // Tesseract* tesseract = [[Tesseract alloc] initWithLanguage:@"<strong>eng+ita</strong>"];

    // set up the delegate to recieve tesseract's callback
    // self should respond to TesseractDelegate and implement shouldCancelImageRecognitionForTesseract: method
    // to have an ability to recieve callback and interrupt Tesseract before it finishes

    Tesseract* tesseract = [[Tesseract alloc] initWithLanguage:@"eng+ita"];
    tesseract.delegate = self;

    [tesseract setVariableValue:@"0123456789" forKey:@"tessedit_char_whitelist"]; //limit search
    [tesseract setImage:[UIImage imageNamed:@"image_sample.jpg"]]; //image to check
    [tesseract recognize];

    NSLog(@"%@", [tesseract recognizedText]);

    tesseract = nil; //deallocate and free all memory
}

#pragma mark - TesseractDelegate methods

- (BOOL)shouldCancelImageRecognitionForTesseract:(Tesseract*)tesseract
{
    NSLog(@"progress: %d", tesseract.progress);
    return NO;  // return YES, if you need to interrupt tesseract before it finishes
}
```
