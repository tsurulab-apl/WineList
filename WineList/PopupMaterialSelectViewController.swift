//
//  PopupMaterialSelectViewController.swift
//  WineList
//
//  Created by 鶴澤幸治 on 2017/07/25.
//  Copyright © 2017年 Koji Tsurusawa. All rights reserved.
//

import UIKit


/// 資料選択画面
///
class PopupMaterialSelectViewController: UIViewController,UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    /// セルの枠線幅
    private static let CELL_BORDER_WIDTH = 3.0
    
    /// セルのコーナー曲線
    private static let CELL_CORNER_RADIUS = 20.0

    /// 端末回転時にコレクションビューを再描画するためのフラグ
    private var invalidLayout = false
    
    // 親ビューコントローラーの資料配列の参照
    // セグエの遷移時に親画面で設定する。
    //var materials: [Material] = []

    /// ワイン登録用のビューコントローラー
    /// セグエの遷移時に親画面で設定する。
    var registrationViewController:RegistrationViewController?
    
    // コントロール
    @IBOutlet weak var materialSelectCollectionView: UICollectionView!

    /// 資料リスト
    var materialList: DataList<Material>

    /// イニシャライザ
    ///
    required init?(coder aDecoder: NSCoder) {
        // MaterialList
        self.materialList = ApplicationContext.instance.wineList.materialList
        
        super.init(coder: aDecoder)
        
        // ----------------------------
        // super.initの後にselfを設定可能
        // ----------------------------
        
    }

    /// viewDidLoad
    ///
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // ポップアップの周りを半透明化
        view.backgroundColor = UIColor(colorLiteralRed: 0.0, green: 0.0, blue: 0.0, alpha: 0.5)

        // コレクションビューを複数選択可能に設定
        self.materialSelectCollectionView.allowsMultipleSelection = true
    }

    /// didReceiveMemoryWarning
    ///
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
            //print(tag)
            if tag == 1 {
                //self.saveSelectedMaterial()
                dismiss(animated: true, completion: nil)
            }
        }
    }

    /// 端末回転の開始
    /// レイアウトの無効化フラグをtrueに設定する。
    ///
    /// - Parameters:
    ///   - size: サイズ
    ///   - coordinator: コーディネーター
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        // レイアウトの無効化フラグをtrueに設定
        // 実際のレイアウト変更は、AutoLayoutによるレイアウトが確定するviewDidLayoutSubviewsで実施する。
        self.invalidLayout = true
    }

    
    /// 画面レイアウトの確定
    /// 端末回転時にコレクションビューを再描画する。
    /// viewWillTransition時にinvalidLayoutフラグをtrueにし本メソッドで判定する。
    ///
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if self.invalidLayout {
            //self.materialSelectCollectionView.collectionViewLayout.invalidateLayout() //不要
            self.materialSelectCollectionView.reloadData()
        }
        self.invalidLayout = false
    }
    
    /// 選択された資料を保存する。
    /// TODO:削除
/*******
    func saveSelectedMaterial() {
        self.registrationViewController?.materials.removeAll()
        if let indexPaths = self.materialSelectCollectionView.indexPathsForSelectedItems {
            for indexPath in indexPaths {
                //print(indexPath.row)
                let material = self.materialList.get(indexPath.row)
                self.registrationViewController?.materials.append(material)
            }
        }
    }
*********/
    
    /// コレクションビューに資料を２列で表示するため、
    /// コレクションビューの幅の半分のセルサイズを返す
    /// ViewControllerにUICollectionViewDelegateFlowLayoutを設定する。
    ///
    /// - Parameters:
    ///   - collectionView: コレクションビュー
    ///   - collectionViewLayout: コレクションビューレイアウト
    ///   - indexPath: インデックスパス
    /// - Returns: セルサイズ
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        //let cellSize:CGFloat = self.view.frame.size.width/2-2
        let collectionViewSize = collectionView.frame.size
        let cellSize:CGFloat = collectionViewSize.width/2 - 4
        // 正方形で返すためにwidth,heightを同じにする
        return CGSize(width: cellSize, height: cellSize)
    }

    /// コレクションビューのセルを戻す。
    ///
    /// - Parameters:
    ///   - collectionView: コレクションビュー
    ///   - indexPath: インデックスパス
    /// - Returns: 資料セル
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // Cell はストーリーボードで設定したセルのID
        let materialCell:MaterialSelectCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "MaterialCell", for: indexPath) as! MaterialSelectCollectionViewCell

        //print("indexPath.row=\(indexPath.row)")

        // 画像配列の番号で指定された要素の名前の画像をUIImageとする
        let material = self.materialList.get(indexPath.row)

        // UIImageをUIImageViewのimageとして設定
        if let image = material.data {
            materialCell.dataImageView.image = UIImage(data: image)
        }

        // 名前をラベルに設定
        materialCell.nameLabel.text = material.name

        // 選択時の枠線設定
        materialCell.layer.borderWidth = CGFloat(PopupMaterialSelectViewController.CELL_BORDER_WIDTH)
        materialCell.layer.cornerRadius = CGFloat(PopupMaterialSelectViewController.CELL_CORNER_RADIUS)
        materialCell.layer.masksToBounds = true

        let selected = self.isSelected(material:material)
        if selected {
            // scrollPositionを設定するとスクロール中に本メソッドが呼ばれてセルを再生成する際に
            // 意図しないポジション変更が発生してしまう。
            // 設定例:UICollectionViewScrollPosition.centeredVertically
            // そのため、scrollPositonには、空の[]を設定する。
            // また、selectItemではisSelectedは更新されないため、明示的に設定する。
            self.materialSelectCollectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
            materialCell.isSelected = true
        }
        self.set(materialCell: materialCell, selected: selected)
        return materialCell
    }

    /// 資料セルの選択状態設定
    ///
    /// - Parameters:
    ///   - materialCell: 資料セル
    ///   - selected: 選択状態 true:選択 false:非選択
    func set(materialCell:MaterialSelectCollectionViewCell, selected:Bool) {
        if selected {
            materialCell.layer.borderColor = UIColor.blue2.cgColor
        } else {
            materialCell.layer.borderColor = UIColor.clear.cgColor
        }
    }

    /// 資料の選択判定
    ///
    /// - Parameter material: 資料
    /// - Returns: 選択状態 true:選択 false:非選択
    func isSelected(material:Material) -> Bool {
        let selected = (self.registrationViewController?.materialsWork.contains(material))!
//        var selected:Bool = false
//        for selectMaterial in (self.registrationViewController?.materials)! {
//            if selectMaterial === material {
//                selected = true
//                break
//            }
//        }
        return selected
    }

    /// セクションの数を戻す。
    ///
    /// - Parameter collectionView: コレクションビュー
    /// - Returns: セクション数
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        // section数は１つ
        return 1
    }

    /// セルの数を戻す。
    ///
    /// - Parameters:
    ///   - collectionView: コレクションビュー
    ///   - section: セクション番号
    /// - Returns: セルの数
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // 要素数を入れる、要素以上の数字を入れると表示でエラーとなる
        //return self.photos.count;
        return self.materialList.count()
    }

    /// セル選択時
    /// セルの枠線を選択状態に変更し、資料ワーク領域に資料を登録する。
    ///
    /// - Parameters:
    ///   - collectionView: コレクションビュー
    ///   - indexPath: インデックスパス
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let materialCell = collectionView.cellForItem(at: indexPath) as! MaterialSelectCollectionViewCell
        self.set(materialCell: materialCell, selected: true)
        self.save(indexPath: indexPath, selected: true)
        //print(materialCell.nameLabel.text!)
    }

    /// 選択解除時
    /// セルの枠線を非選択状態に変更し、資料ワーク領域の資料を削除する。
    ///
    /// - Parameters:
    ///   - collectionView: コレクションビュー
    ///   - indexPath: インデックスパス
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let materialCell = collectionView.cellForItem(at: indexPath) as! MaterialSelectCollectionViewCell
        self.set(materialCell: materialCell, selected: false)
        self.save(indexPath: indexPath, selected: false)
        //print(materialCell.nameLabel.text!)
    }
    
    /// 選択もしくは選択解除された資料を資料ワークに反映する。
    ///
    /// - Parameters:
    ///   - indexPath: 資料セルのインデックスパス
    ///   - selected: 選択状態 true:選択 false:非選択
    func save(indexPath: IndexPath, selected:Bool) {
        let material = self.materialList.get(indexPath.row)
        if selected {
            // 選択時には追加する。
            self.registrationViewController?.materialsWork.insert(material)
        } else {
            // 選択解除時には削除する。
            self.registrationViewController?.materialsWork.remove(material)
        }
    }

    /*******
    /// スクロール中(debug用)
    ///
    /// - Parameter scrollView: スクロールビュー
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print("contentOffset.y=\(scrollView.contentOffset.y)")
    }
    *********/

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
