//
//  PopupMaterialReferenceViewController.swift
//  WineList
//
//  Created by 鶴澤幸治 on 2017/08/02.
//  Copyright © 2017年 Koji Tsurusawa. All rights reserved.
//

import UIKit

class PopupMaterialReferenceViewController: UIViewController,UIScrollViewDelegate {
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

//        // 端末の向きがかわったらNotificationを呼ばす設定
//        NotificationCenter.default.addObserver(self, selector: Selector(("onOrientationChange:")), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    
    /// didReceiveMemoryWarning
    ///
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
/***********
    /// viewWillAppear
    ///
    /// - Parameter animated: <#animated description#>
    override func viewWillAppear(_ animated: Bool) {
        print("### viewWillAppear")
    }

    
    /// viewDidAppear
    ///
    /// - Parameter animated: <#animated description#>
    override func viewDidAppear(_ animated: Bool) {
        print("### viewDidAppear")
    }

    /// viewWillTransition
    /// 画面回転開始時
    ///
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        print("### viewWillTransition")
    }
*******************/

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
        //let popupSize = self.popupView.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
        //let width = self.view.frame.width * 0.8
        //let height = self.view.frame.height * 0.8

        var count:Int = 0
        var x:CGFloat = 0.0
        if let wine = self.wine {
            if let materials = wine.materials {
                for material in materials {
                    if let data = (material as! Material).data {
                        // イメージビューの生成
                        let image = UIImage(data: data)
                        let imageView = UIImageView(image: image)
                        imageView.contentMode = UIViewContentMode.scaleAspectFit
                        //imageView.layer.borderWidth = 0.5
                        //imageView.layer.borderColor = UIColor.red.cgColor
                        imageView.frame.size.width = width
                        imageView.frame.size.height = height
//                        var rect = imageView.frame
//                        rect.size.width = width
//                        rect.size.height = height
//                        //rect.origin.x = x
//                        imageView.frame = rect

                        // ズーム用スクロールビューの作成
                        let zoomScrollView = self.createZoomScrollView(subview: imageView, x: x)

                        // スライダー用スクロールビューにズーム用スクロールビューを追加
                        self.mainScrollView.addSubview(zoomScrollView)
                        
                        count += 1
                        x += width
                    }
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
    
    ///
    /// サブビューの全削除
    ///
    private func removeSubviews() {
        for subview in self.mainScrollView.subviews {
            subview.removeFromSuperview()
        }
    }
    
    ///
    /// ポップアップ以外をタッチすると閉じる。
    ///
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

    ///
    /// スクロールビューのZoom対象を戻す。
    ///
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        // return a view that will be scaled. if delegate returns nil, nothing happens
        // スクロールビュー内のサブビュー(イメージビュー)をZoom対象として戻す。
        let zoomView = scrollView.subviews[0]
        return zoomView
    }

    ///
    /// スクロール停止時
    /// ページコントロールのカレントページを変更する。
    ///
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.pageControl.currentPage = Int(self.mainScrollView.contentOffset.x / self.mainScrollView.frame.maxX)
    }
    
    ///
    /// ページコントロールのタップ
    /// ページコントロールのカレントページに合わせてスクロールする。
    ///
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
