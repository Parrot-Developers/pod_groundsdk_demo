// Copyright (C) 2022 Parrot Drones SAS
//
//    Redistribution and use in source and binary forms, with or without
//    modification, are permitted provided that the following conditions
//    are met:
//    * Redistributions of source code must retain the above copyright
//      notice, this list of conditions and the following disclaimer.
//    * Redistributions in binary form must reproduce the above copyright
//      notice, this list of conditions and the following disclaimer in
//      the documentation and/or other materials provided with the
//      distribution.
//    * Neither the name of the Parrot Company nor the names
//      of its contributors may be used to endorse or promote products
//      derived from this software without specific prior written
//      permission.
//
//    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
//    "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
//    LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
//    FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
//    PARROT COMPANY BE LIABLE FOR ANY DIRECT, INDIRECT,
//    INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
//    BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS
//    OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED
//    AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
//    OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT
//    OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
//    SUCH DAMAGE.

import UIKit
import GroundSdk

class DebugShellViewController: UIViewController, DeviceViewController {

    private let groundSdk = GroundSdk()
    private var droneUid: String?
    private var debugShellRef: Ref<DebugShell>?

    @IBOutlet private weak var stateLabel: UILabel!
    @IBOutlet private weak var publicKeyTextView: UITextView!
    @IBOutlet private weak var disableButton: UIButton!
    @IBOutlet private weak var enableButton: UIButton!
    @IBOutlet private weak var bottomConstraint: NSLayoutConstraint!

    private var keyboardWillShowObserver: NSObjectProtocol?
    private var keyboardWillHideObserver: NSObjectProtocol?

    deinit {
        self.keyboardWillShowObserver.map { NotificationCenter.default.removeObserver($0) }
        self.keyboardWillHideObserver.map { NotificationCenter.default.removeObserver($0) }
    }

    func setDeviceUid(_ uid: String) {
        droneUid = uid
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        publicKeyTextView.textContainerInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        self.keyboardWillShowObserver =
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification,
                                               object: nil,
                                               queue: .main) { [weak self] notification in
            guard let self = self else { return }
            let userInfo = notification.userInfo!
            let keyboardInfo = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
            let keyboardSize = keyboardInfo.cgRectValue.size
            let duration = TimeInterval((userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber)
                .doubleValue)
            let curve = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as! NSNumber
            let options = UIView.AnimationOptions(rawValue: UInt(curve.intValue << 16))
            UIView.animate(withDuration: duration, delay: 0, options: options, animations: {
                self.bottomConstraint.constant = keyboardSize.height
            }, completion: nil)
        }
        self.keyboardWillHideObserver =
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification,
                                               object: nil,
                                               queue: .main) { [weak self] notification in
            guard let self = self else { return }
            let userInfo = notification.userInfo!
            let duration = TimeInterval((userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber)
                .doubleValue)
            let curve = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as! NSNumber
            let options = UIView.AnimationOptions(rawValue: UInt(curve.intValue << 16))
            UIView.animate(withDuration: duration, delay: 0, options: options, animations: {
                self.bottomConstraint.constant = 0
            }, completion: nil)
        }
        guard let drone = groundSdk.getDrone(uid: droneUid!) else {
            return
        }
        debugShellRef = drone
            .getPeripheral(Peripherals.debugShell) { [weak self] debugShell in
                guard let debugShell = debugShell, let `self` = self else {
                    self?.performSegue(withIdentifier: "exit", sender: self)
                    return
                }
                self.stateLabel.text = debugShell.state.value.description
                if case .enabled(publicKey: let key) = debugShell.state.value {
                    self.publicKeyTextView.text = key
                }
                self.disableButton.isEnabled = debugShell.state.value != .disabled
                self.enableButton.isEnabled = !(self.publicKeyTextView.text?.isEmpty ?? true)
            }
    }

    @IBAction private func disableAction(_ sender: Any) {
        debugShellRef?.value?.state.value = .disabled
    }

    @IBAction private func enableAction(_ sender: Any) {
        guard let publicKey = publicKeyTextView.text else {
            return
        }
        debugShellRef?.value?.state.value = .enabled(publicKey: publicKey)
    }
}

extension DebugShellViewController: UITextViewDelegate {

    func textViewDidChange(_ textView: UITextView) {
        self.disableButton.isEnabled = debugShellRef?.value?.state.value != .disabled
        self.enableButton.isEnabled = !(textView
            .text?.isEmpty ?? true)
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
        }
        return true
    }
}
