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

class DeviceInfoViewController<P>: UIViewController, DeviceViewController
where P: InstrumentProvider & PeripheralProvider {

    @IBOutlet weak var modelLabel: UILabel!
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var forgetButton: UIButton!
    @IBOutlet weak var connectButton: UIButton!
    weak private var tabViewController: UITabBarController?

    private let tabBarControllerSegue = "tabBarController"

    let groundSdk = GroundSdk()
    private(set) var deviceUid: String?
    var provider: P?
    var nameRef: Ref<String>?
    var stateRef: Ref<DeviceState>?

    override func viewDidLoad() {
        super.viewDidLoad()

        tabBarController?.selectedIndex = 0
    }

    override func viewWillAppear(_ animated: Bool) {
        if provider == nil {
            _ = navigationController?.popViewController(animated: animated)
        }

        super.viewWillAppear(animated)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewController = ((segue.destination as? UINavigationController)?.topViewController
                                 ?? segue.destination) as? DeviceViewController, let droneUid = deviceUid {
            viewController.setDeviceUid(droneUid)
        }
        if segue.identifier == tabBarControllerSegue {
            tabViewController = segue.destination as? UITabBarController
            setDeviceUid(deviceUid!)
        }
    }

    func setState(_ state: DeviceState) {
        stateLabel.text = state.description

        forgetButton.isEnabled = state.canBeForgotten
        connectButton.isEnabled = state.canBeConnected || state.canBeDisconnected
        if state.connectionState == .disconnected {
            connectButton.setTitle("Connect", for: UIControl.State())
        } else {
            connectButton.setTitle("Disconnect", for: UIControl.State())
        }
    }

    func setDeviceUid(_ uid: String) {
        deviceUid = uid
        if let viewControllers = tabViewController?.viewControllers {
            for child in  viewControllers where child is DeviceViewController {
                (child as! DeviceViewController).setDeviceUid(uid)
            }
        }
    }

    @IBAction func forget(_ sender: UIButton) {}

    @IBAction func connectDisconnect(_ sender: UIButton) {}

    @IBAction func showDefaultDetail(unwindSegue: UIStoryboardSegue) {
        if let splitViewController = splitViewController, splitViewController.isCollapsed {
            _ = navigationController?.popViewController(animated: true)
        } else {
            performSegue(withIdentifier: "showDefault", sender: self)
        }
    }
}
