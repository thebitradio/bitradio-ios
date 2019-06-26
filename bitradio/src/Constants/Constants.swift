//
//  Constants.swift
//  breadwallet
//
//  Created by Adrian Corscadden on 2016-10-24.
//  Copyright © 2016 breadwallet LLC. All rights reserved.
//

import UIKit

let π: CGFloat = .pi

struct Padding {
    subscript(multiplier: Int) -> CGFloat {
        get {
            return CGFloat(multiplier) * 8.0
        }
    }
}

struct C {
    static let padding = Padding()
    struct Sizes {
        static let buttonHeight: CGFloat = 64.0
        static let headerHeight: CGFloat = 48.0
        static let footerHeight: CGFloat = 56.0
        static let largeHeaderHeight: CGFloat = 220.0
        static let logoAspectRatio: CGFloat = 125.0/417.0
        static let logoWidthPercentage: CGFloat = 0.7
    }
    static var defaultTintColor: UIColor = {
        return UIView().tintColor
    }()
    
    struct Colors {
        static let background = UIColor(red: 0x4c/255, green: 0x4c / 255, blue: 0x48 / 255, alpha: 1.0) // #191a2a #89794a
        static let text = UIColor.white // #ffffff
        static let lightText = UIColor(red: 0x6d / 255, green: 0x6d / 255, blue: 0x7e / 255, alpha: 1.0) // #6d6d7e
        static let cardBackground = UIColor(red: 0x01 / 255, green: 0x0f / 255, blue: 0x0f / 255, alpha: 1.0) // #2e2e47 #010f0f
		static let lightGrey = UIColor(red: 0xaa / 255, green: 0xaa / 255, blue: 0xaa / 255, alpha: 1.0) // #aaaaaa
        static let blueGrey = UIColor(red: 0x9c / 255, green: 0x9e / 255, blue: 0x9b / 255, alpha: 1.0) // #9c9e9b
        static let greyBlue = UIColor(red: 0x8d / 255, green: 0x8e / 255, blue: 0x66 / 255, alpha: 1.0) // #66688f #8d8e66
        static let dark2 = UIColor(red: 0x0d / 255, green: 0x0e / 255, blue: 0x16 / 255, alpha: 1.0) // #191a2a #0d0e16
        static let dark3 = UIColor(red: 0x58 / 255, green: 0x5e / 255, blue: 0x34 / 255, alpha: 1.0) // #2e2f47 #585e34
        static let blue = UIColor(red: 0xb7 / 255, green: 0x9c / 255, blue: 0x03 / 255, alpha: 1.0) // #025DBA #b79c03
        static let weirdGreen = UIColor(red: 0x3f / 255, green: 0x37 / 255, blue: 0x7b / 255, alpha: 1.0) //#3fe77b
        static let weirdRed = UIColor(red: 0xFF / 255, green: 0x22 / 255, blue: 0x16 / 255, alpha: 1) // #ff7416 #ff2216
        static let favoriteYellow = UIColor(red: 0xEA / 255, green: 0xD3 / 255, blue: 0x34 / 255, alpha: 1) // #EAD334
        
        //Bitradio rebrand
        static let newBackgroundWhite = C.Colors.background
        static let SegmentedControl = UIColor(red: 0x28 / 255, green: 0x28 / 255, blue: 0x00 / 255, alpha: 1.0) //282800
    }
    
    static let bip39CreationTime = TimeInterval() //TODO
    
    static let animationDuration: TimeInterval = 0.3
    static let secondsInDay: TimeInterval = 86400
    static let maxMoney: UInt64 = 21000000*100000000
    static let satoshis: UInt64 = 100000000
    static let walletQueue = "io.bitrad.wallet.queue"
    static let btcCurrencyCode = "DGB"
    static let null = "(null)"
    static let maxMemoLength = 250
    static let maxContactNameLength = 30
	//FIXME: We need a valid feedback email address.
    static let feedbackEmail = "support@bitrad.io"
	static let reviewLink = "https://itunes.apple.com/us/app/bitradio-wallet/id1328006562?action=write-review"
    static var standardPort: UInt16 {
		return E.isTestnet ? 12024 : 12024
    }
	//FIXME: Before shipping to production, change this to Bitradio.sqlite
	static let sqliteFileName = "BreadWallet.sqlite"
    
    static let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    static let applicationTitle = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? "Bitradio"
}
