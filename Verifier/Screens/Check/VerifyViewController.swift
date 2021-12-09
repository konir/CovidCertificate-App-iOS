//
/*
 * Copyright (c) 2021 Ubique Innovation AG <https://www.ubique.ch>
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 *
 * SPDX-License-Identifier: MPL-2.0
 */

import Foundation

class VerifyViewController: ViewController {
    private let scannerViewController = VerifyScannerViewController()
    private let checkViewController = VerifyCheckViewController()

    private var mode: CheckModeUIObject?

    // MARK: - View

    override func viewDidLoad() {
        super.viewDidLoad()

        UIStateManager.shared.addObserver(self) { [weak self] state in
            guard let strongSelf = self else { return }
            strongSelf.mode = CheckModesHelper.mode(for: state.checkMode.key)
            strongSelf.updateUI()
        }

        setup()
        setupInteraction()
    }

    // MARK: - Setup

    private func setup() {
        addSubviewController(scannerViewController) { make in
            make.edges.equalToSuperview()
        }

        addSubviewController(checkViewController) { make in
            make.edges.equalToSuperview()
        }

        checkViewController.view.isUserInteractionEnabled = false
    }

    public func dismissResult() {
        checkViewController.dismissResult()
    }

    private func setupInteraction() {
        scannerViewController.scanningSucceededCallback = { [weak self] holder in
            guard let strongSelf = self else { return }
            strongSelf.checkViewController.view.accessibilityViewIsModal = true
            strongSelf.checkViewController.view.isUserInteractionEnabled = true

            UIAccessibility.post(notification: .screenChanged, argument: strongSelf.checkViewController.view)

            if let m = strongSelf.mode {
                strongSelf.checkViewController.mode = m
                strongSelf.checkViewController.holder = holder
            }
        }

        scannerViewController.dismissTouchUpCallback = { [weak self] in
            guard let strongSelf = self else { return }

            strongSelf.dismiss(animated: true, completion: nil)
        }

        checkViewController.okPressedTouchUpCallback = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.checkViewController.view.accessibilityViewIsModal = false
            strongSelf.checkViewController.view.isUserInteractionEnabled = false

            UIAccessibility.post(notification: .screenChanged, argument: strongSelf.checkViewController.view)
            strongSelf.scannerViewController.restart()
        }
    }

    private func updateUI() {}
}
