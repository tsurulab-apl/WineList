//
//  LaunchViewController.swift
//  WineList
//
//  Created by 鶴澤幸治 on 2017/09/17.
//  Copyright © 2017年 Koji Tsurusawa. All rights reserved.
//

import UIKit

/// 起動画面
///
class LaunchViewController: UIViewController, UIScrollViewDelegate {

    // コントロール
    @IBOutlet weak var mainScrollView: UIScrollView!
    @IBOutlet weak var mainStackView: UIStackView!

    /// viewDidLoad
    ///
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.mainScrollView.delegate = self
    }

    /// didReceiveMemoryWarning
    ///
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /// スクロールビューのZoom対象を戻す。
    ///
    /// - Parameter scrollView: スクロールビュー
    /// - Returns: ズーム対象のビュー
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        // return a view that will be scaled. if delegate returns nil, nothing happens
        return self.mainStackView
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
