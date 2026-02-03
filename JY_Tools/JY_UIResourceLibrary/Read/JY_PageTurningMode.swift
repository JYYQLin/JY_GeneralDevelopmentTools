//
//  JY_PageTurningMode.swift
//  JY_UIResourceLibrary
//
//  Created by JYYQLin on 2026/1/27.
//

//  MARK: 翻页模式
public enum JY_PageTurningMode: Int {
    /**  仿真 */
    case simulation = 0
    /**  左右滑动 */
    case pageLeftToRight = 1
    /**  上下滑动 */
    case pageUpToDown = 2
    /**  无动画 */
    case noAnimation = 3
    /**  覆盖 */
    case cover = 4
    
    var title: String {
        switch self {
        case .simulation: return "仿真翻页"
        case .pageLeftToRight: return "左右翻页"
        case .pageUpToDown: return "上下翻页"
        case .noAnimation: return "无动画"
        case .cover: return "覆盖"
        }
    }
}

//  MARK: 行距
public enum JY_LineSpacing: Int {
    
    /** 标准 */
    case standard = 15
    
    /** 紧凑 */
    case compact = 10
    /** 更紧凑 */
    case moreCompact = 5
    
    /** 松散 */
    case loose = 20
    /** 更松散 */
    case moreLoose = 25
    
}
