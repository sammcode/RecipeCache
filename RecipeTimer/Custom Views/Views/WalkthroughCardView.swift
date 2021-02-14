//
//  WalkthroughCardView.swift
//  RecipeTimer
//
//  Created by Sam McGarry on 7/24/20.
//  Copyright © 2020 Sam McGarry. All rights reserved.
//

import UIKit

protocol WalkthroughCardViewDataSource: class {

    /// Determines the number of cards to be added into the
    /// SwipeableCardViewContainer. Not all cards will initially
    /// be visible, but as cards are swiped away new cards will
    /// appear until this number of cards is reached.
    ///
    /// - Returns: total number of cards to be shown
    func numberOfCards() -> Int

    /// Provides the Card View to be displayed within the
    /// SwipeableCardViewContainer. This view's frame will
    /// be updated depending on its current index within the stack.
    ///
    /// - Parameter index: index of the card to be displayed
    /// - Returns: card view to display
    func card(forItemAtIndex index: Int) -> WalkthroughCardView
}

protocol WalkthroughCardViewDelegate: class {
    func startCountDown(card: WalkthroughCardView)
}

class WalkthroughCardView: UIView {

    private var backView : UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.layer.zPosition = 0
        v.backgroundColor = UIColor(named: "background")
        v.layer.cornerRadius = 15
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOffset = CGSize(width: 0.0, height: 6.0)
        v.layer.shadowRadius = 8
        v.layer.shadowOpacity = 0.5
        v.clipsToBounds = true
        v.layer.masksToBounds = false
        return v
    }()
    
    private var backViewTitle : UILabel = {
        let lbl = UILabel()
        if DeviceType.isiPadPro {
            lbl.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        }else if DeviceType.isiPad11inch {
            lbl.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        }
        else if DeviceType.isiPad {
            lbl.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        }else if DeviceType.isiPhone8Standard || DeviceType.isiPhone8PlusStandard {
            lbl.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        }else if DeviceType.isiPhoneSE {
            lbl.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        }else {
            lbl.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        }
        lbl.textColor = UIColor.white
        lbl.textAlignment = .center
        lbl.numberOfLines = 0
        lbl.adjustsFontSizeToFitWidth = true
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.layer.zPosition = 1
        return lbl
    }()
    
    private var titleLabel: UILabel = {
        let lbl = UILabel()
        if DeviceType.isiPadPro {
            lbl.font = UIFont.systemFont(ofSize: 70, weight: .bold)
        }else if DeviceType.isiPad11inch {
            lbl.font = UIFont.systemFont(ofSize: 70, weight: .bold)
        }
        else if DeviceType.isiPad {
            lbl.font = UIFont.systemFont(ofSize: 70, weight: .bold)
        }else if DeviceType.isiPhone8Standard || DeviceType.isiPhone8PlusStandard {
            lbl.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        }else if DeviceType.isiPhoneSE {
            lbl.font = UIFont.systemFont(ofSize: 26, weight: .bold)
        }else {
            lbl.font = UIFont.systemFont(ofSize: 45, weight: .bold)
        }
        lbl.textColor = UIColor.white
        lbl.textAlignment = .center
        lbl.numberOfLines = 0
        lbl.contentMode = .scaleToFill
        lbl.adjustsFontSizeToFitWidth = true
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.layer.zPosition = 1
        lbl.layer.shadowColor = UIColor.black.cgColor
        lbl.layer.shadowOffset = CGSize(width: 0.0, height: 6.0)
        lbl.layer.shadowRadius = 8
        lbl.layer.shadowOpacity = 0.5
        lbl.clipsToBounds = true
        lbl.layer.masksToBounds = false
        return lbl
    }()
    
    var timerLabel: UILabel = {
        let lbl = UILabel()
        if DeviceType.isiPadPro {
            lbl.font = UIFont.systemFont(ofSize: 50, weight: .bold)
        }else if DeviceType.isiPad11inch {
            lbl.font = UIFont.systemFont(ofSize: 50, weight: .bold)
        }
        else if DeviceType.isiPad {
            lbl.font = UIFont.systemFont(ofSize: 50, weight: .bold)
        }else if DeviceType.isiPhone8Standard || DeviceType.isiPhone8PlusStandard {
            lbl.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        }else if DeviceType.isiPhoneSE {
            lbl.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        }else {
            lbl.font = UIFont.systemFont(ofSize: 36, weight: .bold)
        }
        lbl.textColor = UIColor.white
        lbl.textAlignment = .center
        lbl.numberOfLines = 0
        lbl.contentMode = .scaleToFill
        lbl.adjustsFontSizeToFitWidth = true
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.layer.zPosition = 1
        lbl.layer.shadowColor = UIColor.black.cgColor
        lbl.layer.shadowOffset = CGSize(width: 0.0, height: 6.0)
        lbl.layer.shadowRadius = 8
        lbl.layer.shadowOpacity = 0.5
        lbl.clipsToBounds = true
        lbl.layer.masksToBounds = false
        return lbl
    }()
    
    private var notesLabel: UILabel = {
        let lbl = UILabel()
        if DeviceType.isiPadPro {
            lbl.font = UIFont.systemFont(ofSize: 40, weight: .bold)
        }else if DeviceType.isiPad11inch {
            lbl.font = UIFont.systemFont(ofSize: 40, weight: .bold)
        }
        else if DeviceType.isiPad {
            lbl.font = UIFont.systemFont(ofSize: 40, weight: .bold)
        }else if DeviceType.isiPhone8Standard || DeviceType.isiPhone8PlusStandard {
            lbl.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        }else if DeviceType.isiPhoneSE {
            lbl.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        }else {
            lbl.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        }
        lbl.textColor = UIColor.white
        lbl.textAlignment = .center
        lbl.numberOfLines = 0
        lbl.contentMode = .scaleToFill
        lbl.adjustsFontSizeToFitWidth = true
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.layer.zPosition = 1
        lbl.layer.shadowColor = UIColor.black.cgColor
        lbl.layer.shadowOffset = CGSize(width: 0.0, height: 6.0)
        lbl.layer.shadowRadius = 8
        lbl.layer.shadowOpacity = 0.5
        lbl.clipsToBounds = true
        lbl.layer.masksToBounds = false
        return lbl
    }()
    
    weak var delegate: WalkthroughCardViewDelegate!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(backview: String, title: String, timer: String, notes: String, backviewColor: UIColor, backviewTitleColor: UIColor, delegate: WalkthroughCardViewDelegate){
        self.init(frame: .zero)
        self.delegate = delegate
        backViewTitle.text = backview
        titleLabel.text = title
        timerLabel.text = timer
        notesLabel.text = notes
        backView.backgroundColor = backviewColor
        backViewTitle.textColor = backviewTitleColor
    }
    
    func configure(){
        print("configure was called")
        setUpBackViewConstraints()
        setUpBackViewTitleConstraints()
        setUpTitleLabelConstraints()
        setUpTimerLabelConstraints()
        setUpNotesLabelConstraints()
    }
    
    func setUpBackViewConstraints(){
        addSubview(backView)
        
        //let height = DeviceType.isiPhone8Standard || DeviceType.isiPhone8PlusStandard ? ScreenSize.width * 0.9 : ScreenSize.width * 1.25
        
        let height: CGFloat!
        let constant: CGFloat!
        
        if DeviceType.isiPadPro {
            height = ScreenSize.width * 0.8
            constant = -50
            print("success")
        }else if DeviceType.isiPad11inch {
            height = ScreenSize.width * 0.8
            constant = -50
        }else if DeviceType.isiPadAir {
            height = ScreenSize.width * 0.8
            constant = -50
        }else if DeviceType.isiPad7thGen {
            height = ScreenSize.width * 0.8
            constant = -50
        }else if DeviceType.isiPad {
            height = ScreenSize.width * 0.8
            constant = -50
            print("double success")
        }else if DeviceType.isiPhone8Standard || DeviceType.isiPhone8PlusStandard {
            height = ScreenSize.width * 0.9
            constant = -50
        }else if DeviceType.isiPhoneSE {
            height = ScreenSize.width
            constant = -20
        }else {
            height = ScreenSize.width * 1.25
            constant = -40
        }
        
        backView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        backView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: constant).isActive = true
        backView.heightAnchor.constraint(equalToConstant: height).isActive = true
        backView.widthAnchor.constraint(equalToConstant: ScreenSize.width * 0.9).isActive = true
    }
    
    func setUpBackViewTitleConstraints(){
        backView.addSubview(backViewTitle)
        backViewTitle.anchor(top: backView.topAnchor, left: backView.leftAnchor, bottom: nil, right: nil, paddingTop: 10, paddingLeft: 20, paddingBottom: 0, paddingRight: 0, width: 0, height: 0, enableInsets: false)
    }
    
    func setUpTitleLabelConstraints(){
        backView.addSubview(titleLabel)
        titleLabel.centerXAnchor.constraint(equalTo: backView.centerXAnchor).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: backView.leadingAnchor).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: backView.trailingAnchor).isActive = true
        titleLabel.anchor(top: backView.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 40, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: ScreenSize.width * 0.75, height: 0, enableInsets: false)
    }
    
    func setUpTimerLabelConstraints(){
        backView.addSubview(timerLabel)
        timerLabel.centerXAnchor.constraint(equalTo: backView.centerXAnchor).isActive = true
        timerLabel.anchor(top: titleLabel.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 10, paddingLeft: 0, paddingBottom: 20, paddingRight: 0, width: ScreenSize.width * 0.85, height: 0, enableInsets: false)
    }
    
    func setUpNotesLabelConstraints(){
        backView.addSubview(notesLabel)
        notesLabel.centerXAnchor.constraint(equalTo: backView.centerXAnchor).isActive = true
        notesLabel.anchor(top: nil, left: nil, bottom: backView.bottomAnchor, right: nil, paddingTop: 10, paddingLeft: 0, paddingBottom: 20, paddingRight: 0, width: ScreenSize.width * 0.85, height: 0, enableInsets: false)
    }

}
