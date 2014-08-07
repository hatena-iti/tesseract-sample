tesseract-sample
================

Tesseract ライブラリを用いた、OCR（画像からの文字解析）機能の iOS アプリサンプルです。

# （参考）Tesseract ライブラリの導入手順

## 準備

### Cocoapods（http://cocoapods.org/） のインストール

コンソールから以下のコマンドを実行して、Cocoapods をインストールします。（未インストールの場合のみ。）

```
$ sudo gem install cocoapods
```

### traineddata ファイルの取得

https://code.google.com/p/tesseract-ocr/downloads/list から、
各言語用のデータファイルを取得します。
日本語用のデータファイルは「tesseract-ocr-3.02.jpn.tar.gz」です。

## ビルド

### Podfile の作成

プロジェクトのルートに「Podfile」という名前のファイルを作成し、以下内容を記入します。

```
pod 'TesseractOCRiOS', '~> 2.3'
```

### 必要なライブラリのインストールと設定

TesseractOCR.framework など、必要なライブラリをインストールするために、コンソールでプロジェクトのルートに移動して、以下のコマンドを実行します。

```
$ pod install
```

### プロジェクトを開く

コンソールから以下コマンドを実行して、Xcode でプロジェクトを開きます。

```
$ open tesseract-sample.xcworkspace
```

「{プロジェクト名}.xcworkspace」を指定して、「open」コマンドを実行します。
以降、プロジェクトを開くときは、「{プロジェクト名}.xcworkspace」を指定するようにします。

### traineddata ファイルの配置

「tessdata」フォルダをプロジェクト内に作成して、各言語用のデータファイル（*.traineddata）をその中に格納します。
XCode を開いて、このフォルダをプロジェクトのソースツリーにドラッグして追加します。このとき、「<code>Create folder references for any added folders</code>」オプションを指定して追加するようにします。

### CoreImage.framework へのリンク

対象 XCode プロジェクトの「General」=>「Linked Frameworks and Libraries」=>「+」を
選択して、「<code>CoreImage.framework</code>」を追加します。
　

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
