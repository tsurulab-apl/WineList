//
//  AbstractRegistrationViewController.swift
//  WineList
//
//  Created by 鶴澤幸治 on 2017/07/17.
//  Copyright © 2017年 Koji Tsurusawa. All rights reserved.
//

import UIKit


/// 登録画面の抽象クラス
/// - キーボード表示時にテキストフィールドやテキストビューが隠れないようにスクロールする。
/// - 改行キーでキーボードを閉じる。
/// - スクロールビューのズーム。
/// - 保存、リセット時の確認メッセージ/完了メッセージを表示する。
class AbstractRegistrationViewController: UIViewController,UINavigationControllerDelegate,UITextFieldDelegate,UITextViewDelegate,UIScrollViewDelegate {

    // MARK: - 定数

    /// キーボード表示時にテキストフィールドやテキストビューが隠れないようにスクロールする対応用
    /// スクロール位置調整用のマージンサイズ
    private static let SCROLL_MARGIN:Float = 8.0

    // メッセージを表示する秒数
    private static let MESSAGE_SECOND:Double = 0.5

    // MARK: - 変数
    
    /// キーボード表示時にテキストフィールドやテキストビューが隠れないようにスクロールする対応用
    /// 選択中のテキストフィールドやテキストビューを格納する。
    var activeText:UIView?

    // MARK: - メソッド

    /// viewDidLoad
    ///
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let scrollView = self.getScrollView()
        scrollView.delegate = self
        
        let uiTextFields = self.getUITextFields()
        for uiTextField in uiTextFields {
            uiTextField.delegate = self
            
        }
        let uiTextViews = self.getUITextViews()
        for uiTextView in uiTextViews {
            uiTextView.delegate = self
        }
    }

    /// スクロールビューを戻す。
    /// 継承先でoverrideする。
    ///
    /// - Returns: スクロールビュー
    func getScrollView() -> UIScrollView {
        fatalError("override this method")
    }

    /// スクロールビューでズームするビューを戻す。
    /// 継承先でoverrideする。
    ///
    /// - Returns: ズームするビュー
    func getZoomView() -> UIView? {
        return nil
    }
    
    /// delegate設定するUITextFiledの配列を戻す。
    /// 継承先でoverrideする。
    ///
    /// - Returns: UITextFieldの配列
    func getUITextFields() -> [UITextField] {
            return []
    }
    
    /// delegate設定するUITextViewの配列を戻す。
    /// 継承先でoverrideする。
    ///
    /// - Returns: UITextViewの配列
    func getUITextViews() -> [UITextView] {
        return []
    }

    /// didReceiveMemoryWarning
    ///
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /// viewWillAppear
    ///
    /// - Parameter animated: <#animated description#>
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // キーボード表示時のスクロール対応
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(AbstractRegistrationViewController.keyboardWillShowNotification(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        notificationCenter.addObserver(self, selector: #selector(AbstractRegistrationViewController.keyboardWillHideNotification(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    /// スクロールビューのZoom対象を戻す。
    ///
    /// - Parameter scrollView: <#scrollView description#>
    /// - Returns: <#return value description#>
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        // return a view that will be scaled. if delegate returns nil, nothing happens
        let zoomView = self.getZoomView()
        return zoomView
    }
    
    /// キーボードを表示する際にテキストフィールドやテキストビューと重複しないようスクロールを調整する。
    ///
    /// - Parameter notification: <#notification description#>
    func keyboardWillShowNotification(_ notification: Notification) {
        if let activeText = self.activeText {
            if let userInfo = notification.userInfo {
                // キーボードの上端を取得
                let keyboardEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
                let boundSize = UIScreen.main.bounds.size
                let keyboardTop = boundSize.height - keyboardEndFrame.size.height
                //print("キーボードの上端：(\(keyboardTop))")
                
                // テキストフィールド、テキストビューの下端を取得
                let textRect = activeText.superview?.convert(activeText.frame, to: nil)
                let textBottom = (textRect?.origin.y)! + (textRect?.height)! + CGFloat(AbstractRegistrationViewController.SCROLL_MARGIN)
                //print("テキストフィールドの下端：(\(textBottom))")
                
                // テキストフィールド、テキストビューがキーボードに隠れている場合は、スクロールを調整。
                if textBottom >= keyboardTop {
                    let scroll = textBottom - keyboardTop
                    let scrollView = self.getScrollView()
                    scrollView.contentOffset.y = scroll
                }
            }
            // activeTextを初期化
            self.activeText = nil
        }
    }
    
    /// キーボードの表示を終了する際にスクロールを元に戻す。
    ///
    /// - Parameter notification: <#notification description#>
    func keyboardWillHideNotification(_ notification: Notification) {
        let scrollView = self.getScrollView()
        scrollView.contentOffset.y = 0
    }
    
    /// 改行(Enter)時にキーボードを閉じる
    /// 名前、価格
    ///
    /// - Parameter textField: <#textField description#>
    /// - Returns: <#return value description#>
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    /// UITextFieldの編集を開始した際
    /// activeTextに自身を保存し、キーボードのスクロールを制御する。
    ///
    /// - Parameter textField: <#textField description#>
    /// - Returns: <#return value description#>
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        self.activeText = textField
        return true
    }
    
    /// UITextViewの編集を開始した際
    /// activeTextに自身を保存し、キーボードのスクロールを制御する。
    ///
    /// - Parameter textView: <#textView description#>
    /// - Returns: <#return value description#>
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        self.activeText = textView
        return true
    }
    
    /// PickerViewやキーボードを閉じる
    ///
    /// - Parameters:
    ///   - touches: <#touches description#>
    ///   - event: <#event description#>
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let uiTextFields = self.getUITextFields()
        for uiTextField in uiTextFields {
            if uiTextField.isEditing {
                uiTextField.endEditing(true)
            }
        }
        let uiTextViews = self.getUITextViews()
        for uiTextView in uiTextViews {
            uiTextView.endEditing(true)
        }
    }

    /// 保存処理
    ///
    /// - Parameter handler: OKボタン押下時のハンドラーを指定する。
    func saveAction(handler: ((UIAlertAction) -> Swift.Void)? = nil) {

        let alert: UIAlertController = UIAlertController(title: "保存", message: "保存します。よろしいですか？", preferredStyle:  UIAlertControllerStyle.alert)
        
        // OKボタン
        let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: handler)

        // キャンセルボタン
        let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertActionStyle.cancel, handler:{
            (action: UIAlertAction!) -> Void in
            // 何もしない
            //print("Cancel")
        })

        // キャンセル、OKの順に設定
        alert.addAction(cancelAction)
        alert.addAction(defaultAction)

        // アラート表示
        present(alert, animated: true, completion: nil)
    }

    /// リセット処理
    ///
    /// - Parameter handler: OKボタン押下時のハンドラーを指定する。
    func resetAction(handler: ((UIAlertAction) -> Swift.Void)? = nil) {
        
        let alert: UIAlertController = UIAlertController(title: "リセット", message: "リセットします。よろしいですか？", preferredStyle:  UIAlertControllerStyle.alert)
        
        // OKボタン
        let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: handler)
        
        // キャンセルボタン
        let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertActionStyle.cancel, handler:{
            (action: UIAlertAction!) -> Void in
            // 何もしない
            //print("Cancel")
        })
        
        // キャンセル、OKの順に設定
        alert.addAction(cancelAction)
        alert.addAction(defaultAction)
        
        // アラート表示
        present(alert, animated: true, completion: nil)
    }

    /// 保存メッセージの表示
    ///
    func showSaveMessage() {
            self.showMessage(title: "保存しました。", message: "")
    }

    /// リセットメッセージの表示
    ///
    func showResetMessage() {
        self.showMessage(title: "リセットしました。", message: "")
    }

    /// Invalidメッセージの表示
    ///
    /// - Parameter message: メッセージ
    func showInvalidMessage(message:String) {
        self.showMessage(title: "確認", message: message)
    }

    /// メッセージ表示
    ///
    /// - Parameters:
    ///   - title: タイトル文字列
    ///   - message: メッセージ文字列
    func showMessage(title:String, message:String) {
        
        // アラート作成
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        // アラート表示
        self.present(alert, animated: true, completion: {
            // アラートを自動で閉じる
            DispatchQueue.main.asyncAfter(deadline: .now() + AbstractRegistrationViewController.MESSAGE_SECOND, execute: {
                alert.dismiss(animated: true, completion: nil)
            })
        })
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
