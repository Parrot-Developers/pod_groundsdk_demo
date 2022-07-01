// Copyright (C) 2019 Parrot Drones SAS
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

class RcInfoViewController: DeviceInfoViewController<RemoteControl> {

    @IBOutlet weak var shutDownLabel: UILabel!
    @IBOutlet weak var appActionLabel: UILabel!
    @IBOutlet weak var appActionLabelHeightConstraint: NSLayoutConstraint!
    private var appActionLabelHeight: CGFloat = 0

    private var remoteControl: RemoteControl? {
        provider
    }

    private var gsdkActionGamePadObserverToken: NSObjectProtocol?

    private enum ToastState {
        case hidden
        case showing
        case shown
        case hidding
    }

    private var appActionLabelState = ToastState.hidden
    private var appActionHideTimer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()

        appActionLabelHeight = appActionLabelHeightConstraint.constant
        appActionLabelHeightConstraint.constant = 0

        if let rcUid = deviceUid {
            provider = groundSdk.getRemoteControl(uid: rcUid) { [weak self] _ in
                _ = self?.navigationController?.popViewController(animated: true)
            }
        }
        // get the drone
        if let remoteControl = remoteControl {
            // header
            modelLabel.text = remoteControl.model.description
            nameRef = remoteControl.getName { [unowned self] name in
                self.title = name!
            }
            stateRef = remoteControl.getState { [unowned self] state in
                // state is never nil
                self.setState(state!)
            }
        }
    }

    override func setState(_ state: DeviceState) {
        super.setState(state)

        if state.durationBeforeShutDown == 0 {
            shutDownLabel.text = "No shutdown planned"
        } else {
            shutDownLabel.text = "Shudown in \(Int(state.durationBeforeShutDown))s"
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        gsdkActionGamePadObserverToken = NotificationCenter.default.addObserver(
            forName: NSNotification.Name.GsdkActionGamepadAppAction, object: nil, queue: nil,
            using: { [unowned self] notification in
                if self.appActionLabelState == .hidden {
                    self.appActionLabelHeightConstraint.constant = 0
                } else if self.appActionLabelState == .hidding {
                    self.appActionLabel.layer.removeAllAnimations()
                }

                // set the text
                let appAction = notification.userInfo?[GsdkActionGamepadAppActionKey] as! ButtonsMappableAction
                self.appActionLabel.text = "App action received: \(appAction.description)"

                // delay the hidding operation
                if let appActionHideTimer = self.appActionHideTimer {
                    appActionHideTimer.invalidate()
                }
                self.appActionHideTimer = Timer.scheduledTimer(
                    timeInterval: 2.0, target: self, selector: #selector(self.hideAppActionLabel), userInfo: nil,
                    repeats: false)

                // show if it is in state hidden or hidding
                if self.appActionLabelState == .hidden || self.appActionLabelState == .hidding {
                    self.appActionLabelState = .showing
                    UIView.animate(withDuration: 0.7, delay: 0.0, options: .curveEaseIn, animations: {
                        self.appActionLabelHeightConstraint.constant = self.appActionLabelHeight
                    }, completion: { _ in
                        self.appActionLabelState = .shown
                    })
                }
            })

        super.viewWillAppear(animated)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        gsdkActionGamePadObserverToken.map { NotificationCenter.default.removeObserver($0) }
        gsdkActionGamePadObserverToken = nil
    }

    @objc
    private func hideAppActionLabel() {
        appActionLabelState = .hidding
        UIView.animate(withDuration: 0.7, delay: 0.0, options: .curveEaseOut, animations: {
            self.appActionLabelHeightConstraint.constant = 0
        }, completion: { finished in
            if finished {
                self.appActionLabelState = .hidden
            }
        })
    }

    @IBAction override func forget(_ sender: UIButton) {
        _ = remoteControl?.forget()
    }

    @IBAction override func connectDisconnect(_ sender: UIButton) {
        if let connectionState = stateRef?.value?.connectionState {
            if connectionState == DeviceState.ConnectionState.disconnected {
                _ = remoteControl?.connect()
            } else {
                _ = remoteControl?.disconnect()
            }
        }
    }
}
