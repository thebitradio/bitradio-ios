//
//  SyncViewController.swift
//  breadwallet
//
//  Created by v912086 on 23.05.18.
//  Copyright © 2018 breadwallet LLC. All rights reserved.
//

import UIKit

class AnimatedWaveView: UIView {
    private let waveColor: UIColor
    init(color: UIColor) {
        waveColor = color
        super.init(frame: CGRect())
        backgroundColor = waveColor
    }
    
    func startAnimation() {
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class BottomDesignedLabel: UILabel {
    private var offsetY: CGFloat = 0.0
    
    func setOffsetY(_ y: CGFloat) {
        self.offsetY = y
        setNeedsDisplay()
    }
    
    override func drawText(in rect: CGRect) {
        if let str = text {
            let strAsNS = str as NSString
            let labelStringSize = strAsNS.boundingRect(with: CGSize(width: self.frame.width, height: CGFloat.greatestFiniteMagnitude),
                                                       options: NSStringDrawingOptions.usesLineFragmentOrigin,
                                                       attributes: [NSAttributedStringKey.font: font],
                                                       context: nil).size
            super.drawText(in: CGRect(x: 0, y: rect.size.height - labelStringSize.height + offsetY, width: self.frame.width, height: ceil(labelStringSize.height)))
        }
    }
}

class SyncViewController: UIViewController, Subscriber {

    private let syncStateLabel = UILabel(font: .customBody(size: 20), color: C.Colors.text)
    
    private let syncPercentageCenteringView = UIView()
    //private let syncPercentageLabel = BottomDesignedLabel(font: .customMedium(size: 160), color: C.Colors.weirdGreen)
    private let syncPercentageLabel = BottomDesignedLabel(font: UIFont(name: "Helvetica", size: 160)!, color: C.Colors.weirdGreen)
    private let syncPercentageSignLabel = UILabel(font: .customBold(size: 70), color: UIColor.gray)
    
    private let blockHeightCaptionLabel = UILabel(font: .customBody(size: 13), color: UIColor.gray)
    private let blockHeightLabel = UILabel(font: .customBody(size: 36), color: UIColor.white)
    private let progressCaptionLabel = UILabel(font: .customBody(size: 13), color: UIColor.gray)
    private let progressLabel = UILabel(font: .customBody(size: 20), color: UIColor.blue) // attributed text of syncdate / currentdate
    
    private let animatedWaveView = AnimatedWaveView(color: UIColor(red: 0x19 / 255, green: 0x1b / 255, blue: 0x2a / 255, alpha: 1)) // #191b2a
    
    private let store: Store
    
    init(store: Store) {
        self.store = store
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        addSubviews()
        addConstraints()
        sampleData()
        
        style()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //subscribe()
        super.viewWillAppear(animated)
        //print("SUBSCRIBED")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        //store.unsubscribe(self)
        super.viewWillDisappear(animated)
    }
    

    
    func updateSyncState(state: SyncState?, percentage: Double? = nil, blockHeight: UInt32? = nil, date: Date? = nil) {
        // update state label
        if let state = state {
            syncStateLabel.text = {
                switch(state) {
                    case .syncing:
                        return "\(S.SyncingView.syncing)..."
                    case .connecting:
                        return "\(S.SyncingView.connecting)..."
                    case .success:
                        return "" // ToDo: Success message?
                }
            }()
        }
        
        // update percentage
        if let percentage = percentage {
            let r = Int(round(percentage))
            syncPercentageLabel.text = "\(r)"
        }
        
        // update block height
        if let blockHeight = blockHeight {
            let numberFormatter = NumberFormatter()
            numberFormatter.groupingSeparator = " "
            numberFormatter.numberStyle = .decimal
            let number = numberFormatter.string(from: NSNumber(value: blockHeight))
            blockHeightLabel.text = number
        }
        
        // update date view
        if let date = date {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM yyyy"
            
            let dateStr1 = date.timeIntervalSince1970 > 0 ? formatter.string(from: date) : "-- "
            let dateStr2 = formatter.string(from: Date())
            
            let attr1 = NSMutableAttributedString(string: dateStr1, attributes: [NSAttributedStringKey.foregroundColor: C.Colors.weirdGreen])
            let attrS = NSAttributedString(string: " / ", attributes: nil)
            let attr2 = NSAttributedString(string: dateStr2, attributes: [NSAttributedStringKey.foregroundColor: UIColor.blue])
            
            attr1.append(attrS)
            attr1.append(attr2)
            
            progressLabel.attributedText = attr1
        }
    }
    
    //private func
    
    private func sampleData() {
        syncStateLabel.text = "Connecting..."
        syncPercentageLabel.text = "0"
        blockHeightCaptionLabel.text = "BLOCK HEIGHT"
        progressCaptionLabel.text = "PROGRESS"
        
        blockHeightLabel.text = "--"
        
        // set date
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        
        let dateStr1 = "-- "
        let dateStr2 = formatter.string(from: Date())
        
        let attr1 = NSMutableAttributedString(string: dateStr1, attributes: [NSAttributedStringKey.foregroundColor: C.Colors.weirdGreen])
        let attrS = NSAttributedString(string: " / ", attributes: nil)
        let attr2 = NSAttributedString(string: dateStr2, attributes: [NSAttributedStringKey.foregroundColor: UIColor.blue])
        
        attr1.append(attrS)
        attr1.append(attr2)
        
        progressLabel.attributedText = attr1
    }
    
    private func addSubviews() {
        super.viewDidLoad()
        
        view.addSubview(animatedWaveView)
        animatedWaveView.addSubview(blockHeightCaptionLabel)
        animatedWaveView.addSubview(blockHeightLabel)
        animatedWaveView.addSubview(progressCaptionLabel)
        animatedWaveView.addSubview(progressLabel)
        
        view.addSubview(syncStateLabel)
        
        syncPercentageCenteringView.addSubview(syncPercentageLabel)
        syncPercentageCenteringView.addSubview(syncPercentageSignLabel)
        view.addSubview(syncPercentageCenteringView)
    }
    
    private func addConstraints() {
        // bottom view
        animatedWaveView.constrain([
            animatedWaveView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            animatedWaveView.leftAnchor.constraint(equalTo: view.leftAnchor),
            animatedWaveView.rightAnchor.constraint(equalTo: view.rightAnchor),
            animatedWaveView.heightAnchor.constraint(equalToConstant: 300),
        ])
        
        blockHeightCaptionLabel.constrain([
            blockHeightCaptionLabel.leftAnchor.constraint(equalTo: animatedWaveView.leftAnchor, constant: 20),
            blockHeightCaptionLabel.topAnchor.constraint(equalTo: animatedWaveView.topAnchor, constant: 60),
            blockHeightCaptionLabel.widthAnchor.constraint(equalToConstant: 85),
            blockHeightCaptionLabel.heightAnchor.constraint(equalToConstant: 40),
        ])
        
        blockHeightLabel.constrain([
            blockHeightLabel.leftAnchor.constraint(equalTo: blockHeightCaptionLabel.rightAnchor, constant: 10),
            blockHeightLabel.topAnchor.constraint(equalTo: blockHeightCaptionLabel.topAnchor),
            blockHeightLabel.rightAnchor.constraint(equalTo: animatedWaveView.rightAnchor, constant: -10),
            blockHeightLabel.heightAnchor.constraint(equalToConstant: 40),
        ])
        
        progressCaptionLabel.constrain([
            progressCaptionLabel.leftAnchor.constraint(equalTo: animatedWaveView.leftAnchor, constant: 20),
            progressCaptionLabel.topAnchor.constraint(equalTo: blockHeightCaptionLabel.topAnchor, constant: 50),
            progressCaptionLabel.widthAnchor.constraint(equalToConstant: 85),
            progressCaptionLabel.heightAnchor.constraint(equalToConstant: 40),
        ])
        
        progressLabel.constrain([
            progressLabel.leftAnchor.constraint(equalTo: progressCaptionLabel.rightAnchor, constant: 10),
            progressLabel.topAnchor.constraint(equalTo: progressCaptionLabel.topAnchor),
            progressLabel.rightAnchor.constraint(equalTo: animatedWaveView.rightAnchor, constant: -10),
            progressLabel.heightAnchor.constraint(equalToConstant: 40),
        ])
 
        // top
        syncStateLabel.constrain([
            syncStateLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
            syncStateLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            syncStateLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
        ])
        
        syncPercentageCenteringView.constrain([
            syncPercentageCenteringView.topAnchor.constraint(equalTo: syncStateLabel.bottomAnchor, constant: 45),
            //syncPercentageCenteringView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10),
            //syncPercentageCenteringView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10),
            syncPercentageCenteringView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            syncPercentageCenteringView.heightAnchor.constraint(equalToConstant: 150),
            //syncPercentageCenteringView.widthAnchor.constraint(greaterThanOrEqualToConstant: 200)
        ])
        
        syncPercentageLabel.constrain([
            syncPercentageLabel.leftAnchor.constraint(equalTo: syncPercentageCenteringView.leftAnchor, constant: 0),
            // syncPercentageLabel.topAnchor.constraint(equalTo: syncPercentageCenteringView.topAnchor, constant: 0),
            syncPercentageLabel.bottomAnchor.constraint(equalTo: syncPercentageCenteringView.bottomAnchor, constant: 0),
        ])
        
        syncPercentageSignLabel.constrain([
            syncPercentageSignLabel.leftAnchor.constraint(equalTo: syncPercentageLabel.rightAnchor, constant: 0),
            syncPercentageSignLabel.bottomAnchor.constraint(equalTo: syncPercentageLabel.bottomAnchor, constant: 0),
            syncPercentageSignLabel.rightAnchor.constraint(equalTo: syncPercentageCenteringView.rightAnchor)
        ])
    }
    
    private func style() {
        view.backgroundColor = C.Colors.background
        
        syncStateLabel.textAlignment = .center
        syncPercentageSignLabel.text = "%"
        blockHeightCaptionLabel.numberOfLines = 2
        
        // remove font padding
        syncPercentageLabel.setOffsetY(24)
        
        progressLabel.numberOfLines = 2
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
