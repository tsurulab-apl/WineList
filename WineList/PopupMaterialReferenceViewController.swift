//
//  PopupMaterialReferenceViewController.swift
//  WineList
//
//  Created by 鶴澤幸治 on 2017/08/02.
//  Copyright © 2017年 Koji Tsurusawa. All rights reserved.
//

import UIKit

/// 資料参照画面
///
class PopupMaterialReferenceViewController: UIViewController,UIScrollViewDelegate {

    /// テキストビューの高さ
    private static let TEXT_VIEW_HEIGHT: CGFloat = 100.0
    
    /// 処理中のワイン
    var wine: Wine? = nil

    // コントロール
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var mainScrollView: UIScrollView!
    @IBOutlet weak var mainStackView: UIStackView!
    @IBOutlet weak var pageControl: UIPageControl!

    /// viewDidLoad
    ///
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // ポップアップの周りを半透明化
        view.backgroundColor = UIColor(colorLiteralRed: 0.0, green: 0.0, blue: 0.0, alpha: 0.5)

        // スクロールビューのdelegate設定
        self.mainScrollView.delegate = self

        // ページコントロールの設定
        self.pageControl.hidesForSinglePage = true
        self.pageControl.currentPageIndicatorTintColor = UIColor.blue2

    }
    
    /// didReceiveMemoryWarning
    ///
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /// viewDidLayoutSubviews
    ///
    override func viewDidLayoutSubviews() {
        
        // サブビューの全削除
        self.removeSubviews()
        
        // イメージビューの幅、高さを設定する。
        // mainScrollView配下のサイズはこの時点では定まっていない。(storyboardのサイズとなっている。)
        // そのため、popupViewのサイズからページコントローラーの高さを引いた値を利用する。
        let width = self.popupView.frame.width
        let height = self.popupView.frame.height - self.pageControl.frame.height
        
        var count:Int = 0
        var x:CGFloat = 0.0
        if let wine = self.wine {
            if let materials = wine.materials {
                for materialObj in materials {
                    let material = materialObj as! Material

                    // ズーム用スクロールビューの作成
                    let zoomScrollView = self.createZoomScrollView(width: width, height: height, x: x)
                    let stackView = zoomScrollView.subviews[0] as! UIStackView
                    
                    var useHeight = height
                    let isExistImage = !(material.data == nil)
                    let isExistNote = self.isExistNote(material: material)
                    
                    // イメージビューの作成
                    if let data = material.data {
                        let image = UIImage(data: data)
                        let imageView = UIImageView(image: image)
                        imageView.contentMode = UIViewContentMode.scaleAspectFit

                        if isExistNote {
                            useHeight -= PopupMaterialReferenceViewController.TEXT_VIEW_HEIGHT
                        }
                        imageView.heightAnchor.constraint(greaterThanOrEqualToConstant: 300.0).isActive = true
                        imageView.setContentHuggingPriority(100, for: .vertical)

                        stackView.addArrangedSubview(imageView)

                        useHeight = height - useHeight
                    }
                    
                    // テキストビューの作成
                    if isExistNote {
                        let textView = UITextView()
                        textView.font = UIFont.systemFont(ofSize: 14.0)
                        textView.isEditable = false
                        textView.isSelectable = false
                        textView.isScrollEnabled = false
                        textView.text = material.note

                        let size = textView.sizeThatFits(CGSize(width: width, height: CGFloat.greatestFiniteMagnitude))

                        // textViewのみの場合は、textViewを垂直方向にセンタリングする。
                        let textViewHeightConstraintActive = self.textViewVerticalCenter(stackView: stackView, isExistImage: isExistImage, height: height, textViewSize: size)

                        // textViewの高さを制約で付与する。
                        // ただし、textViewのみで垂直方向にセンタリングする場合は、制約を付与しない。
                        if textViewHeightConstraintActive {
                            textView.heightAnchor.constraint(equalToConstant: size.height).isActive = true
                        }
                        // imageViewより大きい値を設定し、imageViewが拡大されるようにする。
                        textView.setContentHuggingPriority(300, for: .vertical)

                        stackView.addArrangedSubview(textView)

                        // 高さが収まりきらない場合は、
                        // スタックビューの高さを調整しスクロール可能とする。
                        self.adjust(zoomScrollView: zoomScrollView, textViewSize: size)
                    }

                    // スライダー用スクロールビューにズーム用スクロールビューを追加
                    self.mainScrollView.addSubview(zoomScrollView)

                    count += 1
                    x += width
                }
            }
        }
        
        // スクロールビューのサイズを調整
        let scrollViewWidth:CGFloat = width * CGFloat(count)
        self.mainScrollView.contentSize = CGSize(width: scrollViewWidth, height: height)
        
        // ページコントロールを設定
        self.pageControl.numberOfPages = count
        
        // 回転時にページに合わせてスクロール位置を調整
        // offset.xは正しい値になっているが、何故かずれてしまう現象に対応
        // この処理を非同期で実行することでずれを正す。
        DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
            self.mainScrollView.contentOffset.x = self.mainScrollView.frame.maxX * CGFloat(self.pageControl.currentPage)
        })
    }

    /// テキストビューの垂直方向センタリング
    /// テキストビューのみの場合でテキストビューがポップアップビューの高さ内に収まる場合、
    /// テキストビューを垂直方向にセンタリングする。
    /// テキストビューの上部にスペース分の空ビューを追加することでセンタリングを実現する。
    /// また、空ビューを上部に追加した場合は、テキストビューに高さ制約を付与せずに自動拡大させる。
    /// そのため、戻り値で高さ制約を付与するか否かを表すフラグ値を戻す。
    ///
    /// - Parameters:
    ///   - stackView: スタックビュー
    ///   - isExistImage: イメージビューの存在 true:存在 false:不在
    ///   - height: ポップアップビューの高さ
    ///   - textViewSize: テキストビューのサイズ
    /// - Returns: テキストビューの高さ制約を付与するか否か true:付与する。false:付与しない。
    private func textViewVerticalCenter(stackView: UIStackView, isExistImage: Bool, height: CGFloat, textViewSize: CGSize) -> Bool {
        var textViewHeightConstraintActive = true
        if !isExistImage {
            if textViewSize.height < height {
                let spaceView = UIView()
                let spaceViewHeight = (height / 2) - (textViewSize.height / 2)
                spaceView.heightAnchor.constraint(equalToConstant: spaceViewHeight).isActive = true
                // textViewより大きい値を設定し、textViewが拡大されるようにする。
                spaceView.setContentHuggingPriority(600, for: .vertical)
                //spaceView.layer.borderWidth = 2.0
                //spaceView.layer.borderColor = UIColor.orange.cgColor
                stackView.addArrangedSubview(spaceView)
                textViewHeightConstraintActive = false
            }
        }
        return textViewHeightConstraintActive
    }
    
    /// 高さが収まりきらない場合にスタックビューの高さを調整しスクロール可能とする。
    ///
    /// - Parameters:
    ///   - zoomScrollView: ズームスクロールビュー
    ///   - textViewSize: テキストビューのサイズ
    private func adjust(zoomScrollView: UIScrollView, textViewSize: CGSize) {
        let stackView = zoomScrollView.subviews[0] as! UIStackView

        var subView0Height:CGFloat = 0.0
        let subView0 = stackView.arrangedSubviews[0]
        if !(subView0 is UITextView) {
            subView0Height = subView0.frame.size.height
        }
        let contentHeight = subView0Height + textViewSize.height
        if stackView.frame.size.height < contentHeight {
            stackView.frame.size.height = contentHeight
            zoomScrollView.isScrollEnabled = true
            zoomScrollView.showsVerticalScrollIndicator = true
            zoomScrollView.contentSize = stackView.frame.size
        }
    }
    
    /// ノートの存在チェック
    ///
    /// - Parameter material: 資料
    /// - Returns: ノートの存在 true:存在 false:不在
    private func isExistNote(material: Material) -> Bool {
        if let text = material.note {
            let note = text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            if note != "" {
                return true
            }
        }
        return false
    }
    
    /// ズーム用スクロールビューの作成
    ///
    /// - Parameters:
    ///   - width: 幅
    ///   - height: 高さ
    ///   - x: x位置
    /// - Returns: ズーム用スクロールビュー
    private func createZoomScrollView(width:CGFloat, height:CGFloat, x:CGFloat) -> UIScrollView {
        let scrollViewFrame = CGRect(x: x, y: 0, width: width, height: height)
        let zoomScrollView = UIScrollView(frame: scrollViewFrame)
        zoomScrollView.minimumZoomScale = 1
        zoomScrollView.maximumZoomScale = 4
        zoomScrollView.zoomScale = 1.0
        zoomScrollView.delegate = self
        zoomScrollView.isScrollEnabled = false
        zoomScrollView.showsHorizontalScrollIndicator = false
        zoomScrollView.showsVerticalScrollIndicator = false

        let stackViewFrame = CGRect(x: 0, y: 0, width: width, height: height)
        let verticalStackView = UIStackView(frame: stackViewFrame)
        verticalStackView.axis = .vertical
        verticalStackView.alignment = .fill
        verticalStackView.distribution = .fill
        verticalStackView.spacing = 0.0
        //verticalStackView.backgroundColor = UIColor.cyan
        //verticalStackView.layer.borderWidth = 5.0
        //verticalStackView.layer.borderColor = UIColor.orange.cgColor
        zoomScrollView.addSubview(verticalStackView)
        
        return zoomScrollView
    }
    
    /// ズーム用スクロールビューの作成
    ///
    /// - Parameters:
    ///   - subview: <#subview description#>
    ///   - x: <#x description#>
    /// - Returns: <#return value description#>
    private func createZoomScrollView(subview:UIView, x:CGFloat) -> UIScrollView {
        var innerFrame = subview.frame
        innerFrame.origin.x = x
        let zoomScrollView = UIScrollView(frame: innerFrame)
        zoomScrollView.minimumZoomScale = 1
        zoomScrollView.maximumZoomScale = 4
        zoomScrollView.zoomScale = 1.0
        zoomScrollView.delegate = self
        zoomScrollView.showsHorizontalScrollIndicator = false
        zoomScrollView.showsVerticalScrollIndicator = false
        zoomScrollView.contentSize = subview.bounds.size
        zoomScrollView.addSubview(subview)
        // デバッグ用枠線
        //zoomScrollView.layer.borderWidth = 0.5
        //zoomScrollView.layer.borderColor = UIColor.green.cgColor

        return zoomScrollView
    }
    
    /// サブビューの全削除
    ///
    private func removeSubviews() {
        for subview in self.mainScrollView.subviews {
            subview.removeFromSuperview()
        }
    }
    
    /// ポップアップ以外をタッチすると閉じる。
    ///
    /// - Parameters:
    ///   - touches: <#touches description#>
    ///   - event: <#event description#>
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        for touch: UITouch in touches {
            let tag = touch.view!.tag
            print(tag)
            if tag == 1 {
                dismiss(animated: true, completion: nil)
            }
        }
    }

    /// スクロールビューのZoom対象を戻す。
    ///
    /// - Parameter scrollView: スクロールビュー
    /// - Returns: ズーム対象ビュー
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        // return a view that will be scaled. if delegate returns nil, nothing happens
        // スクロールビュー内のサブビュー(イメージビュー)をZoom対象として戻す。
        let zoomView = scrollView.subviews[0]
        return zoomView
    }

    /// スクロール停止時
    /// ページコントロールのカレントページを変更する。
    ///
    /// - Parameter scrollView: スクロールビュー
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.pageControl.currentPage = Int(self.mainScrollView.contentOffset.x / self.mainScrollView.frame.maxX)
    }
    
    /// ページコントロールのタップ
    /// ページコントロールのカレントページに合わせてスクロールする。
    ///
    /// - Parameter sender: <#sender description#>
    @IBAction func pageControlValueChanged(_ sender: UIPageControl) {
        self.mainScrollView.contentOffset.x = self.mainScrollView.frame.maxX * CGFloat(sender.currentPage)
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
