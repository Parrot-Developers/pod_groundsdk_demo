//// Copyright (C) 2018 Parrot Drones SAS
////
////    Redistribution and use in source and binary forms, with or without
////    modification, are permitted provided that the following conditions
////    are met:
////    * Redistributions of source code must retain the above copyright
////      notice, this list of conditions and the following disclaimer.
////    * Redistributions in binary form must reproduce the above copyright
////      notice, this list of conditions and the following disclaimer in
////      the documentation and/or other materials provided with the
////      distribution.
////    * Neither the name of the Parrot Company nor the names
////      of its contributors may be used to endorse or promote products
////      derived from this software without specific prior written
////      permission.
////
////    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
////    "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
////    LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
////    FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
////    PARROT COMPANY BE LIABLE FOR ANY DIRECT, INDIRECT,
////    INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
////    BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS
////    OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED
////    AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
////    OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT
////    OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
////    SUCH DAMAGE.
//
//import UIKit
//import GroundSdk
//
//class GimbalOffsetsCorrectionViewController: UIViewController, DeviceViewController {
//
//    @IBOutlet weak var rollOffset: NumSettingView!
//    @IBOutlet weak var pitchOffset: NumSettingView!
//    @IBOutlet weak var yawOffset: NumSettingView!
////    @IBOutlet weak var streamView: LiveStreamView!
//
//    private let groundSdk = GroundSdk()
//    private var deviceUid: String?
//    private var gimbal: Ref<Gimbal>?
//    private var liveStream: Ref<StreamServer>?
//
//    func setDeviceUid(_ uid: String) {
//        deviceUid = uid
//    }
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        let drone = groundSdk.getDrone(uid: deviceUid!)
//
//        if let drone = drone {
//
//            liveStream = drone.getPeripheral(Peripherals.streamServer) { liveStream in
//                liveStream?.enabled = true
//            }
//            streamView.drone = drone
//
//            if let gimbal = drone.getPeripheral(Peripherals.gimbal) {
//                gimbal.startOffsetsCorrectionProcess()
//            }
//            gimbal = drone.getPeripheral(Peripherals.gimbal) { [weak self] gimbal in
//                if let gimbal = gimbal {
//                    let correctionProcess = gimbal.offsetsCorrectionProcess
//                    self?.rollOffset.updateWith(doubleSetting: correctionProcess?.offsetsCorrection[.roll])
//                    self?.rollOffset.isEnabled = correctionProcess?.correctableAxes.contains(.roll) ?? false
//
//                    self?.pitchOffset.updateWith(doubleSetting: correctionProcess?.offsetsCorrection[.pitch])
//                    self?.pitchOffset.isEnabled = correctionProcess?.correctableAxes.contains(.pitch) ?? false
//
//                    self?.yawOffset.updateWith(doubleSetting: correctionProcess?.offsetsCorrection[.yaw])
//                    self?.yawOffset.isEnabled = correctionProcess?.correctableAxes.contains(.yaw) ?? false
//                } else {
//                    self?.performSegue(withIdentifier: "exit", sender: self)
//                }
//            }
//        }
//    }
//
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        streamView.start()
//    }
//
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        if let gimbal = gimbal?.value {
//            gimbal.stopOffsetsCorrectionProcess()
//        }
//        streamView.stop()
//    }
//
//    @IBAction func cancelPushed(_ sender: UIButton) {
//        if let gimbal = gimbal?.value {
//            gimbal.stopOffsetsCorrectionProcess()
//            performSegue(withIdentifier: "exit", sender: self)
//        }
//    }
//
//    @IBAction func valueDidChange(_ sender: NumSettingView) {
//        let axis: GimbalAxis?
//        if sender == rollOffset {
//            axis = .roll
//        } else if sender == pitchOffset {
//            axis = .pitch
//        } else if sender == yawOffset {
//            axis = .yaw
//        } else {
//            axis = nil
//        }
//
//        if let axis = axis, let offset = gimbal?.value?.offsetsCorrectionProcess?.offsetsCorrection[axis] {
//            offset.value = Double(sender.value)
//        }
//    }
//}
