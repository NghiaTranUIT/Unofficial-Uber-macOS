//
//  SearchBarView.swift
//  UberGo
//
//  Created by Nghia Tran on 6/5/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Cocoa
import UberGoCore

class SearchBarView: NSView {

    // MARK: - Variable
    fileprivate var viewModel: SearchBarViewModel?
    fileprivate var actionSearchView: ActionSearchBarView!

    // MARK: - Init
    override func awakeFromNib() {
        super.awakeFromNib()

        self.initCommon()
        self.initActionSearchView()
        self.binding()
    }

    fileprivate func binding() {
        if self.viewModel == nil {
            let viewModel = SearchBarViewModel()

            self.viewModel = viewModel
        }
    }
}

extension SearchBarView {

    fileprivate func initCommon() {
        self.wantsLayer = true
        self.layer?.backgroundColor = NSColor.white.cgColor
    }

    fileprivate func initActionSearchView() {
        let actionView = ActionSearchBarView.viewFromNib(with: BundleType.app)!
        actionView.configureView(with: self)
        self.actionSearchView = actionView
    }

    func configureView(with parentView: NSView) {
        self.translatesAutoresizingMaskIntoConstraints = false

        parentView.addSubview(self)
        let top = NSLayoutConstraint(item: self,
                                     attribute: .top,
                                     relatedBy: .equal,
                                     toItem: parentView,
                                     attribute: .top,
                                     multiplier: 1,
                                     constant: 28)
        let left = NSLayoutConstraint(item: self,
                                      attribute: .left,
                                      relatedBy: .equal,
                                      toItem: parentView,
                                      attribute: .left,
                                      multiplier: 1,
                                      constant: 28)
        let right = NSLayoutConstraint(item: self,
                                       attribute: .right,
                                       relatedBy: .equal,
                                       toItem: parentView,
                                       attribute: .right,
                                       multiplier: 1,
                                       constant: -28)
        let width = NSLayoutConstraint(item: self,
                                       attribute: .height,
                                       relatedBy: .equal,
                                       toItem: nil, attribute: .notAnAttribute,
                                       multiplier: 1,
                                       constant: 56)
        parentView.addConstraints([top, left, right, width])
    }

}
// MARK: - XIBInitializable
extension SearchBarView: XIBInitializable {
    typealias XibType = SearchBarView
}
