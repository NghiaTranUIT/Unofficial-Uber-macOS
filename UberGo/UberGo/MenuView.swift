//
//  MenuView.swift
//  UberGo
//
//  Created by Nghia Tran on 9/15/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Cocoa
import RxCocoa
import RxSwift
import UberGoCore

class MenuView: NSView {

    // MARK: - OUTLET
    @IBOutlet fileprivate weak var avatarImageView: NSImageView!
    @IBOutlet fileprivate weak var usernameLbl: NSTextField!
    @IBOutlet fileprivate weak var startLbl: NSTextField!

    // MARK: - Variable
    fileprivate let disposeBag = DisposeBag()

    override func awakeFromNib() {
        super.awakeFromNib()

        initCommon()
        binding()
    }

    // MARK: - Action
    @IBAction func paymentBtnOnTap(_ sender: NSButton) {
    }

    @IBAction func yourTripBtnOnTap(_ sender: NSButton) {
    }

    @IBAction func helpBtnOnTap(_ sender: NSButton) {
    }

    @IBAction func settingBtnOnTap(_ sender: NSButton) {
    }

    @IBAction func legalBtnOnTap(_ sender: NSButton) {
    }

    // MARK: - Public
    public func configureLayout(_ parentView: NSView) {
        translatesAutoresizingMaskIntoConstraints = false
        parentView.addSubview(self)
        edges(to: parentView)
    }
}

// MARK: - Binding
extension MenuView {

    fileprivate func initCommon() {
        // Border
        avatarImageView.wantsLayer = true
        avatarImageView.layer?.cornerRadius = 32
        avatarImageView.layer?.contentsGravity = kCAGravityResizeAspect
    }

    fileprivate func binding() {
        guard let user = UberAuth.share.currentUser else { return }

        // Profile
        user.requestUserProfile()
        user.userProfileObjVar
            .asDriver()
            .filterNil()
            .drive(onNext: {[weak self] profile in
                guard let `self` = self else { return }
                self.usernameLbl.stringValue = profile.fullName
                self.avatarImageView.asyncDownloadImage(profile.picture)
            })
            .disposed(by: disposeBag)
    }
}
extension MenuView: XIBInitializable {
    typealias XibType = MenuView
}
