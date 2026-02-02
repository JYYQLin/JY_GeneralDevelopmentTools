//
//  JY_UIFont.swift
//  JY_UIResourceLibrary
//
//  Created by JYYQLin on 2025/12/23.
//

import UIKit

// MARK: - 苹果原生字体 按字重快速调用扩展
extension UIFont {
    // MARK: 1. SF Pro（iOS 13+ 系统默认字体，核心推荐）
    /// SF Pro 极细体 (UltraLight)
    public static func yq_sf_pro_ultra_light(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: "SFProText-Ultralight", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize, weight: .ultraLight)
    }
    
    /// SF Pro 细体 (Thin)
    public static func yq_sf_pro_thin(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: "SFProText-Thin", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize, weight: .thin)
    }
    
    /// SF Pro 轻量体 (Light)
    public static func yq_sf_pro_light(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: "SFProText-Light", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize, weight: .light)
    }
    
    /// SF Pro 常规体 (Regular)
    public static func yq_sf_pro_regular(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: "SFProText-Regular", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize, weight: .regular)
    }
    
    /// SF Pro 中黑体 (Medium)
    public static func yq_sf_pro_medium(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: "SFProText-Medium", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize, weight: .medium)
    }
    
    /// SF Pro 半粗体 (Semibold)
    public static func yq_sf_pro_semibold(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: "SFProText-Semibold", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize, weight: .semibold)
    }
    
    /// SF Pro 粗体 (Bold)
    public static func yq_sf_pro_bold(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: "SFProText-Bold", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize, weight: .bold)
    }
    
    /// SF Pro 特粗体 (Heavy)
    public static func yq_sf_pro_heavy(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: "SFProText-Heavy", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize, weight: .heavy)
    }
    
    /// SF Pro 黑体 (Black)
    public static func yq_sf_pro_black(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: "SFProText-Black", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize, weight: .black)
    }
    
    // MARK: 2. 苹方 PingFang SC (中文系统核心字体)
    /// 苹方简体 极细体 (Ultralight)
    public static func yq_pingfang_sc_ultralight(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: "PingFangSC-Ultralight", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize, weight: .ultraLight)
    }
    
    /// 苹方简体 细体 (Light)
    public static func yq_pingfang_sc_light(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: "PingFangSC-Light", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize, weight: .light)
    }
    
    /// 苹方简体 常规体 (Regular)
    public static func yq_pingfang_sc_regular(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: "PingFangSC-Regular", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize, weight: .regular)
    }
    
    /// 苹方简体 中黑体 (Medium)
    public static func yq_pingfang_sc_medium(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: "PingFangSC-Medium", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize, weight: .medium)
    }
    
    /// 苹方简体 半粗体 (Semibold)
    public static func yq_pingfang_sc_semibold(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: "PingFangSC-Semibold", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize, weight: .semibold)
    }
    
    /// 苹方简体 粗体 (Bold)
    public static func yq_pingfang_sc_bold(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: "PingFangSC-Bold", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize, weight: .bold)
    }
    
    // MARK: 3. 苹方 PingFang TC (繁体) / HK (香港) / MO (澳门)（字重规则和SC一致，示例TC）
    /// 苹方繁体 常规体
    public static func yq_pingfang_tc_regular(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: "PingFangTC-Regular", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize, weight: .regular)
    }
    
    /// 苹方繁体 粗体
    public static func yq_pingfang_tc_bold(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: "PingFangTC-Bold", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize, weight: .bold)
    }
    
    // MARK: 4. Helvetica Neue (经典原生字体)
    /// Helvetica Neue 超轻体
    public static func yq_helvetica_neue_ultra_light(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: "HelveticaNeue-UltraLight", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize, weight: .ultraLight)
    }
    
    /// Helvetica Neue 轻量体
    public static func yq_helvetica_neue_light(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: "HelveticaNeue-Light", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize, weight: .light)
    }
    
    /// Helvetica Neue 常规体
    public static func yq_helvetica_neue_regular(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: "HelveticaNeue", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize, weight: .regular)
    }
    
    /// Helvetica Neue 中黑体
    public static func yq_helvetica_neue_medium(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: "HelveticaNeue-Medium", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize, weight: .medium)
    }
    
    /// Helvetica Neue 粗体
    public static func yq_helvetica_neue_bold(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: "HelveticaNeue-Bold", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize, weight: .bold)
    }
    
    /// Helvetica Neue 特粗体
    public static func yq_helvetica_neue_heavy(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: "HelveticaNeue-Heavy", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize, weight: .heavy)
    }
    
    // MARK: 5. 其他原生字体（Arial/Times New Roman/Courier New）
    /// Arial 常规体
    public static func yq_arial_regular(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: "Arial", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize, weight: .regular)
    }
    
    /// Arial 粗体
    public static func yq_arial_bold(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: "Arial-BoldMT", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize, weight: .bold)
    }
    
    /// Arial 斜体
    public static func yq_arial_italic(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: "Arial-ItalicMT", size: fontSize) ?? UIFont.italicSystemFont(ofSize: fontSize)
    }
    
    /// Times New Roman 常规体
    public static func yq_times_new_roman_regular(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: "TimesNewRomanPSMT", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize, weight: .regular)
    }
    
    /// Times New Roman 粗体
    public static func yq_times_new_roman_bold(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: "TimesNewRomanPS-BoldMT", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize, weight: .bold)
    }
    
    /// Courier New (等宽) 常规体
    public static func yq_courier_new_regular(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: "CourierNewPSMT", size: fontSize) ?? UIFont.monospacedSystemFont(ofSize: fontSize, weight: .regular)
    }
    
    /// Courier New (等宽) 粗体
    public static func yq_courier_new_bold(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: "CourierNewPS-BoldMT", size: fontSize) ?? UIFont.monospacedSystemFont(ofSize: fontSize, weight: .bold)
    }
}

// MARK: - 自定义字体快速调用扩展（覆盖所有指定字体）
extension UIFont {
    // MARK: 中文/自定义特色字体
    /// 猫啃什锦黑
    public static func yq_mao_ken_shen_jin_hei(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: "猫啃什锦黑", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }
    
    /// AaHouDiHei
    public static func yq_aa_hou_di_hei(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: "AaHouDiHei", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }
    
    /// Alimama ShuHeiTi（阿里妈妈书黑体）
    public static func yq_alimama_shu_hei_ti(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: "Alimama ShuHeiTi", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }
    
    /// DingTalk JinBuTi（钉钉进步体）
    public static func yq_ding_talk_jin_bu_ti(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: "DingTalk JinBuTi", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }
    
    /// Douyin Sans（抖音字体）
    public static func yq_douyin_sans(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: "Douyin Sans", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }
    
    /// Source-KeynoteartHans
    public static func yq_source_keynoteart_hans(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: "Source-KeynoteartHans", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }
    
    /// ZiZhiQuXiMaiTi（字志趣喜脉体）
    public static func yq_zi_zhi_qu_xi_mai_ti(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: "ZiZhiQuXiMaiTi", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }
    
    // MARK: 英文/系统基础字体（A开头）
    /// Academy Engraved LET
    public static func yq_academy_engraved_let(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: "Academy Engraved LET", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }
    
    /// Al Nile
    public static func yq_al_nile(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: "Al Nile", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }
    
    /// American Typewriter
    public static func yq_american_typewriter(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: "American Typewriter", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }
    
    /// Apple Color Emoji
    public static func yq_apple_color_emoji(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: "Apple Color Emoji", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }
    
    /// Apple SD Gothic Neo
    public static func yq_apple_sd_gothic_neo(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: "Apple SD Gothic Neo", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }
    
    /// Apple Symbols
    public static func yq_apple_symbols(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: "Apple Symbols", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }
    
    /// Arial
    public static func yq_arial(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: "Arial", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }
    
    /// Arial Black
    public static func yq_arial_black(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: "Arial Black", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize, weight: .black)
    }
    
    /// Arial Hebrew
    public static func yq_arial_hebrew(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: "Arial Hebrew", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }
    
    /// Arial Rounded MT Bold
    public static func yq_arial_rounded_mt_bold(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: "Arial Rounded MT Bold", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize, weight: .bold)
    }
    
    /// Avenir
    public static func yq_avenir(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: "Avenir", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }
    
    /// Avenir Next
    public static func yq_avenir_next(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: "Avenir Next", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }
    
    /// Avenir Next Condensed
    public static func yq_avenir_next_condensed(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: "Avenir Next Condensed", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }
    
    // MARK: 英文/系统基础字体（B开头）
    /// Baskerville
    public static func yq_baskerville(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: "Baskerville", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }
    
    /// Bodoni 72
    public static func yq_bodoni_72(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: "Bodoni 72", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }
    
    /// Bodoni 72 Oldstyle
    public static func yq_bodoni_72_oldstyle(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: "Bodoni 72 Oldstyle", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }
    
    /// Bodoni 72 Smallcaps
    public static func yq_bodoni_72_smallcaps(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: "Bodoni 72 Smallcaps", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }
    
    /// Bodoni Ornaments
    public static func yq_bodoni_ornaments(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: "Bodoni Ornaments", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }
    
    /// Bradley Hand
    public static func yq_bradley_hand(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: "Bradley Hand", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }
    
    // MARK: 英文/系统基础字体（C开头）
    /// Chalkboard SE
    public static func yq_chalkboard_se(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: "Chalkboard SE", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }
    
    /// Chalkduster
    public static func yq_chalkduster(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: "Chalkduster", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }
    
    /// Charter
    public static func yq_charter(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: "Charter", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }
    
    /// Cochin
    public static func yq_cochin(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: "Cochin", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }
    
    /// Copperplate
    public static func yq_copperplate(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: "Copperplate", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }
    
    /// Courier New
    public static func yq_courier_new(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: "Courier New", size: fontSize) ?? UIFont.monospacedSystemFont(ofSize: fontSize, weight: .regular)
    }
    
    // MARK: 多语言/地区特色字体（D开头）
    /// Damascus
    public static func yq_damascus(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: "Damascus", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }
    
    /// Devanagari Sangam MN
    public static func yq_devanagari_sangam_mn(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: "Devanagari Sangam MN", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }
    
    /// Didot
    public static func yq_didot(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: "Didot", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }
    
    /// DIN Alternate
    public static func yq_din_alternate(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: "DIN Alternate", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }
    
    /// DIN Condensed
    public static func yq_din_condensed(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: "DIN Condensed", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }
    
    // MARK: 多语言/地区特色字体（E-Z 其他）
    /// Euphemia UCAS
    public static func yq_euphemia_ucas(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: "Euphemia UCAS", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }
    
    /// Farah
    public static func yq_farah(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: "Farah", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }
    
    /// Futura
    public static func yq_futura(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: "Futura", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }
    
    /// Galvji
    public static func yq_galvji(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: "Galvji", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }
    
    /// Geeza Pro
    public static func yq_geeza_pro(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: "Geeza Pro", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }
    
    /// Georgia
    public static func yq_georgia(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: "Georgia", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }
    
    /// Gill Sans
    public static func yq_gill_sans(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: "Gill Sans", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }
    
    /// Grantha Sangam MN
    public static func yq_grantha_sangam_mn(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: "Grantha Sangam MN", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }
    
    /// Helvetica
    public static func yq_helvetica(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: "Helvetica", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }
    
    /// Helvetica Neue
    public static func yq_helvetica_neue(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: "Helvetica Neue", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }
    
    /// Hiragino Maru Gothic ProN
    public static func yq_hiragino_maru_gothic_pron(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: "Hiragino Maru Gothic ProN", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }
    
    /// Hiragino Mincho ProN
    public static func yq_hiragino_mincho_pron(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: "Hiragino Mincho ProN", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }
    
    /// Hiragino Sans
    public static func yq_hiragino_sans(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: "Hiragino Sans", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }
    
    /// Hoefler Text
    public static func yq_hoefler_text(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: "Hoefler Text", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }
    
    /// Impact
    public static func yq_impact(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: "Impact", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize, weight: .bold)
    }
    
    /// Kailasa
    public static func yq_kailasa(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: "Kailasa", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }
    
    /// Kefa III
    public static func yq_kefa_iii(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: "Kefa III", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }
    
    /// Khmer Sangam MN
    public static func yq_khmer_sangam_mn(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: "Khmer Sangam MN", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }
    
    /// Kohinoor Bangla
    public static func yq_kohinoor_bangla(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: "Kohinoor Bangla", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }
    
    /// Kohinoor Devanagari
    public static func yq_kohinoor_devanagari(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: "Kohinoor Devanagari", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }
    
    /// Kohinoor Gujarati
    public static func yq_kohinoor_gujarati(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: "Kohinoor Gujarati", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }
    
    /// Kohinoor Telugu
    public static func yq_kohinoor_telugu(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: "Kohinoor Telugu", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }
    
    /// Lao Sangam MN
    public static func yq_lao_sangam_mn(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: "Lao Sangam MN", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }
    
    /// Malayalam Sangam MN
    public static func yq_malayalam_sangam_mn(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: "Malayalam Sangam MN", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }
    
    /// Marker Felt
    public static func yq_marker_felt(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: "Marker Felt", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }
    
    /// Menlo
    public static func yq_menlo(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: "Menlo", size: fontSize) ?? UIFont.monospacedSystemFont(ofSize: fontSize, weight: .regular)
    }
    
    /// Mishafi
    public static func yq_mishafi(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: "Mishafi", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }
    
    /// Mukta Mahee
    public static func yq_mukta_mahee(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: "Mukta Mahee", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }
    
    /// Myanmar Sangam MN
    public static func yq_myanmar_sangam_mn(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: "Myanmar Sangam MN", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }
    
    /// Noteworthy
    public static func yq_noteworthy(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: "Noteworthy", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }
    
    /// Noto Nastaliq Urdu
    public static func yq_noto_nastaliq_urdu(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: "Noto Nastaliq Urdu", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }
    
    /// Noto Sans Kannada
    public static func yq_noto_sans_kannada(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: "Noto Sans Kannada", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }
    
    /// Noto Sans Myanmar
    public static func yq_noto_sans_myanmar(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: "Noto Sans Myanmar", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }
    
    /// Noto Sans Oriya
    public static func yq_noto_sans_oriya(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: "Noto Sans Oriya", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }
    
    /// Noto Sans Syriac
    public static func yq_noto_sans_syriac(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: "Noto Sans Syriac", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }
    
    /// Optima
    public static func yq_optima(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: "Optima", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }
    
    /// Palatino
    public static func yq_palatino(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: "Palatino", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }
    
    /// Papyrus
    public static func yq_papyrus(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: "Papyrus", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }
    
    /// Party LET
    public static func yq_party_let(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: "Party LET", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }
    
    /// PingFang HK（苹方香港）
    public static func yq_pingfang_hk(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: "PingFang HK", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }
    
    /// PingFang MO（苹方澳门）
    public static func yq_pingfang_mo(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: "PingFang MO", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }
    
    /// PingFang SC（苹方简体）
    public static func yq_pingfang_sc(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: "PingFang SC", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }
    
    /// PingFang TC（苹方繁体）
    public static func yq_pingfang_tc(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: "PingFang TC", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }
    
    /// Roboto
    // MARK: - 常规样式（非斜体）专属方法
    /// Roboto-Regular 字体
    /// - Parameter fontSize: 字体大小
    /// - Returns: Roboto-Regular 字体，不存在则返回对应系统常规字体
    public static func yq_robotoRegular(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: "Roboto-Regular", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize, weight: .regular)
    }
    
    /// Roboto-Medium 字体
    /// - Parameter fontSize: 字体大小
    /// - Returns: Roboto-Medium 字体，不存在则返回对应系统中等字重字体
    public static func yq_robotoMedium(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: "Roboto-Medium", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize, weight: .medium)
    }
    
    /// Roboto-Bold 字体
    /// - Parameter fontSize: 字体大小
    /// - Returns: Roboto-Bold 字体，不存在则返回对应系统粗体字体
    public static func yq_robotoBold(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: "Roboto-Bold", size: fontSize) ?? UIFont.boldSystemFont(ofSize: fontSize)
    }
    
    /// Roboto-Light 字体
    /// - Parameter fontSize: 字体大小
    /// - Returns: Roboto-Light 字体，不存在则返回对应系统轻量字重字体
    public static func yq_robotoLight(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: "Roboto-Light", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize, weight: .light)
    }
    
    /// Roboto-Black 字体
    /// - Parameter fontSize: 字体大小
    /// - Returns: Roboto-Black 字体，不存在则返回对应系统粗黑字重字体
    public static func yq_robotoBlack(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: "Roboto-Black", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize, weight: .black)
    }
    
    /// Roboto-Thin 字体
    /// - Parameter fontSize: 字体大小
    /// - Returns: Roboto-Thin 字体，不存在则返回对应系统特轻字重字体
    public static func yq_robotoThin(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: "Roboto-Thin", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize, weight: .thin)
    }
    
    // MARK: - 斜体样式专属方法
    /// Roboto-Italic 字体（常规字重斜体）
    /// - Parameter fontSize: 字体大小
    /// - Returns: Roboto-Italic 字体，不存在则返回系统常规斜体字体
    public static func yq_robotoItalic(_ fontSize: CGFloat) -> UIFont {
        let systemRegularFont = UIFont.systemFont(ofSize: fontSize, weight: .regular)
        let systemItalicFont = systemRegularFont.withTraits(traits: .traitItalic) ?? systemRegularFont
        return UIFont(name: "Roboto-Italic", size: fontSize) ?? systemItalicFont
    }
    
    /// Roboto-MediumItalic 字体（中等字重斜体）
    /// - Parameter fontSize: 字体大小
    /// - Returns: Roboto-MediumItalic 字体，不存在则返回系统中等字重斜体字体
    public static func yq_robotoMediumItalic(_ fontSize: CGFloat) -> UIFont {
        let systemMediumFont = UIFont.systemFont(ofSize: fontSize, weight: .medium)
        let systemMediumItalicFont = systemMediumFont.withTraits(traits: .traitItalic) ?? systemMediumFont
        return UIFont(name: "Roboto-MediumItalic", size: fontSize) ?? systemMediumItalicFont
    }
    
    /// Roboto-BoldItalic 字体（粗体斜体）
    /// - Parameter fontSize: 字体大小
    /// - Returns: Roboto-BoldItalic 字体，不存在则返回系统粗体斜体字体
    public static func yq_robotoBoldItalic(_ fontSize: CGFloat) -> UIFont {
        let systemBoldFont = UIFont.boldSystemFont(ofSize: fontSize)
        let systemBoldItalicFont = systemBoldFont.withTraits(traits: .traitItalic) ?? systemBoldFont
        return UIFont(name: "Roboto-BoldItalic", size: fontSize) ?? systemBoldItalicFont
    }
    
    /// Roboto-LightItalic 字体（轻量字重斜体）
    /// - Parameter fontSize: 字体大小
    /// - Returns: Roboto-LightItalic 字体，不存在则返回系统轻量字重斜体字体
    public static func yq_robotoLightItalic(_ fontSize: CGFloat) -> UIFont {
        let systemLightFont = UIFont.systemFont(ofSize: fontSize, weight: .light)
        let systemLightItalicFont = systemLightFont.withTraits(traits: .traitItalic) ?? systemLightFont
        return UIFont(name: "Roboto-LightItalic", size: fontSize) ?? systemLightItalicFont
    }
    
    /// Roboto-BlackItalic 字体（粗黑字重斜体）
    /// - Parameter fontSize: 字体大小
    /// - Returns: Roboto-BlackItalic 字体，不存在则返回系统粗黑字重斜体字体
    public static func yq_robotoBlackItalic(_ fontSize: CGFloat) -> UIFont {
        let systemBlackFont = UIFont.systemFont(ofSize: fontSize, weight: .black)
        let systemBlackItalicFont = systemBlackFont.withTraits(traits: .traitItalic) ?? systemBlackFont
        return UIFont(name: "Roboto-BlackItalic", size: fontSize) ?? systemBlackItalicFont
    }
    
    /// Roboto-ThinItalic 字体（特轻字重斜体）
    /// - Parameter fontSize: 字体大小
    /// - Returns: Roboto-ThinItalic 字体，不存在则返回系统特轻字重斜体字体
    public static func yq_robotoThinItalic(_ fontSize: CGFloat) -> UIFont {
        let systemThinFont = UIFont.systemFont(ofSize: fontSize, weight: .thin)
        let systemThinItalicFont = systemThinFont.withTraits(traits: .traitItalic) ?? systemThinFont
        return UIFont(name: "Roboto-ThinItalic", size: fontSize) ?? systemThinItalicFont
    }
    
    /// Rockwell
    public static func yq_rockwell(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: "Rockwell", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }
    
    /// Savoye LET
    public static func yq_savoye_let(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: "Savoye LET", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }
    
    /// Sinhala Sangam MN
    public static func yq_sinhala_sangam_mn(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: "Sinhala Sangam MN", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }
    
    /// Snell Roundhand
    public static func yq_snell_roundhand(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: "Snell Roundhand", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }
    
    /// STIX Two Math
    public static func yq_stix_two_math(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: "STIX Two Math", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }
    
    /// STIX Two Text
    public static func yq_stix_two_text(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: "STIX Two Text", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }
    
    /// Symbol
    public static func yq_symbol(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: "Symbol", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }
    
    /// Tamil Sangam MN
    public static func yq_tamil_sangam_mn(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: "Tamil Sangam MN", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }
    
    /// Thonburi
    public static func yq_thonburi(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: "Thonburi", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }
    
    /// Times New Roman
    public static func yq_times_new_roman(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: "Times New Roman", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }
    
    /// Trebuchet MS
    public static func yq_trebuchet_ms(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: "Trebuchet MS", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }
    
    /// Verdana
    public static func yq_verdana(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: "Verdana", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }
    
    /// Zapf Dingbats
    public static func yq_zapf_dingbats(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: "Zapf Dingbats", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }
    
    /// Zapfino
    public static func yq_zapfino(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: "Zapfino", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }
}
    
private extension UIFont {
    /// 为字体添加指定样式特征（此处主要用于添加斜体）
    /// - Parameter traits: 字体特征（如 .traitItalic 斜体）
    /// - Returns: 添加特征后的字体，失败则返回原字体
    func withTraits(traits: UIFontDescriptor.SymbolicTraits) -> UIFont? {
        guard let fontDescriptor = self.fontDescriptor.withSymbolicTraits(traits) else {
            return nil
        }
        return UIFont(descriptor: fontDescriptor, size: 0) // size传0保留原字体大小
    }
}
