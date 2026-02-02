//
//  JYClipImageToolView.swift
//  JY_UIResourceLibrary
//
//  Created by JYYQLin on 2025/12/8.
//

import UIKit

class JYClipImageToolView: JY_View {
    
    var yq_ratio_click_block: ((_ radio: JYClipImageRatioModel) -> Void)?
    
    private(set) lazy var yq_current_radio = JYClipImageRatioModel.yq_custom()
    
    private(set) lazy var yq_image: UIImage? = nil
    private(set) lazy var yq_ratio_array: [JYClipImageRatioModel] = [JYClipImageRatioModel]()
    
    private lazy var yq_rotate_button: JY_Button = JY_Button()
    private lazy var yq_reduction_button: JY_Button = JY_Button()
    private lazy var yq_collectionView: JY_CollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 20)
        
        let collectionView = JY_CollectionView(frame: .zero, collectionViewLayout: flowLayout)
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
//        collectionView.alpha = 0
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        
        collectionView.register(JYClipImageRatioCell.self, forCellWithReuseIdentifier: JYClipImageRatioCell.yq_ID())
        
        return collectionView
    }()
}

extension JYClipImageToolView {
    func yq_rotate_button_add_target(_ target: Any?, action: Selector, for controlEvents: UIControl.Event) {
        yq_rotate_button.addTarget(target, action: action, for: controlEvents)
    }
    
    func yq_reduction_button_add_target(_ target: Any?, action: Selector, for controlEvents: UIControl.Event) {
        yq_reduction_button.addTarget(target, action: action, for: controlEvents)
    }
}

extension JYClipImageToolView {
    override func yq_add_subviews() {
        super.yq_add_subviews()
        
        addSubview(yq_collectionView)
        addSubview(yq_reduction_button)
        addSubview(yq_rotate_button)
    }
}

extension JYClipImageToolView {
    override func layoutSubviews() {
        super.layoutSubviews()
        
        yq_rotate_button.frame.origin = {
            yq_rotate_button.frame.size = CGSize(width: 44 * yq_scale, height: frame.height)
            yq_rotate_button.setImage(UIImage(named: "1502bb36189cf91f533c4ec0974a6667"), for: .normal)
            return CGPoint(x: 0, y: (frame.height - yq_rotate_button.frame.height) * 0.5)
        }()
        
        yq_reduction_button.frame.origin = {
            yq_reduction_button.frame.size = CGSize(width: 44 * yq_scale, height: frame.height)
            yq_reduction_button.setTitle("还原", for: .normal)
            yq_reduction_button.setTitleColor(UIColor.colorFAFAFB, for: .normal)
            yq_reduction_button.titleLabel?.font = UIFont.yq_pingfang_sc_medium(13 * yq_scale)
            
            return CGPoint(x: frame.width - yq_reduction_button.frame.width, y: (frame.height - yq_reduction_button.frame.height) * 0.5)
        }()
        
        yq_collectionView.frame.origin = {
            let x = yq_rotate_button.frame.maxX + 5 * yq_scale
            yq_collectionView.frame.size = CGSize(width: yq_reduction_button.frame.minX - x, height: 70 * yq_scale)
            
            return CGPoint(x: x, y: (frame.height - yq_collectionView.frame.height) * 0.5)
        }()
        
        reloadData()
    }
    
    private func reloadData() {
        if frame.width > 0 && frame.height > 0 {
            yq_collectionView.isHidden = yq_ratio_array.count <= 1
            yq_collectionView.reloadData()
        }
    }
}

extension JYClipImageToolView {
    func set(ratioArray: [JYClipImageRatioModel]) {
        yq_ratio_array = ratioArray
        yq_current_radio = ratioArray.first ?? JYClipImageRatioModel.yq_custom()
        reloadData()
    }
    
    func set(image: UIImage) {
        yq_image = image
        reloadData()
    }
}

extension JYClipImageToolView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return yq_ratio_array.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: JYClipImageRatioCell.yq_ID(), for: indexPath) as? JYClipImageRatioCell else {
            return JYClipImageRatioCell()
        }
        
        if yq_image != nil {
            cell.set(image: yq_image!)
        }
        
        let ratio = yq_ratio_array[indexPath.row]
        
        cell.set(ratio: ratio, isSelected: ratio == yq_current_radio)
        
        cell.set(scale: yq_scale)
        
        return cell
    }
}

extension JYClipImageToolView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let ratio = yq_ratio_array[indexPath.row]
        
        if ratio == yq_current_radio {
            return
        }
        
        yq_current_radio = ratio
        reloadData()
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        
        yq_ratio_click_block?(yq_current_radio)
    }
}

extension JYClipImageToolView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 60 * yq_scale, height: 70 * yq_scale)
    }
}
