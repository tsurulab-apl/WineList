//
//  AbstractRegistrationViewController.swift
//  WineList
//
//  Created by 鶴澤幸治 on 2017/07/17.
//  Copyright © 2017年 Koji Tsurusawa. All rights reserved.
//

import UIKit

class AbstractRegistrationViewController: UIViewController,UINavigationControllerDelegate,UITextFieldDelegate,UITextViewDelegate,UIScrollViewDelegate {

    // キーボード表示時にテキストフィールドやテキストビューが隠れないようにスクロールする対応用
    var activeText:UIView?
    let scrollMargin:Float = 8.0

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
    ///
    /// スクロールビューを戻す。
    /// 継承先でoverrideする。
    ///
    func getScrollView() -> UIScrollView {
        fatalError("override this method")
    }
    ///
    /// delegate設定するUITextFiledの配列を戻す。
    /// 継承先でoverrideする。
    ///
    func getUITextFields() -> [UITextField] {
            return []
    }
    ///
    /// delegate設定するUITextViewの配列を戻す。
    /// 継承先でoverrideする。
    ///
    func getUITextViews() -> [UITextView] {
        return []
    }

    ///
    /// didReceiveMemoryWarning
    ///
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    ///
    /// viewWillAppear
    ///
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // キーボード表示時のスクロール対応
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(AbstractRegistrationViewController.keyboardWillShowNotification(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        notificationCenter.addObserver(self, selector: #selector(AbstractRegistrationViewController.keyboardWillHideNotification(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    ///
    /// キーボードを表示する際にテキストフィールドやテキストビューと重複しないようスクロールを調整する。
    ///
    func keyboardWillShowNotification(_ notification: Notification) {
        if let activeText = self.activeText {
            if let userInfo = notification.userInfo {
                // キーボードの上端を取得
                let keyboardEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
                let boundSize = UIScreen.main.bounds.size
                let keyboardTop = boundSize.height - keyboardEndFrame.size.height
                print("キーボードの上端：(\(keyboardTop))")
                
                // テキストフィールド、テキストビューの下端を取得
                let textRect = activeText.superview?.convert(activeText.frame, to: nil)
                let textBottom = (textRect?.origin.y)! + (textRect?.height)! + CGFloat(self.scrollMargin)
                print("テキストフィールドの下端：(\(textBottom))")
                
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
    ///
    /// キーボードの表示を終了する際にスクロールを元に戻す。
    ///
    func keyboardWillHideNotification(_ notification: Notification) {
        let scrollView = self.getScrollView()
        scrollView.contentOffset.y = 0
    }
    ///
    /// 改行(Enter)時にキーボードを閉じる
    /// 名前、価格
    ///
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    ///
    /// UITextFieldの編集を開始した際
    /// activeTextに自身を保存し、キーボードのスクロールを制御する。
    ///
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        self.activeText = textField
        return true
    }
    ///
    /// UITextViewの編集を開始した際
    /// activeTextに自身を保存し、キーボードのスクロールを制御する。
    ///
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        self.activeText = textView
        return true
    }
    ///
    /// PickerViewやキーボードを閉じる
    ///
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
