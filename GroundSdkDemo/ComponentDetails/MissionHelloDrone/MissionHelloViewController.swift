// Copyright (C) 2020 Parrot Drones SAS
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
import SwiftProtobuf

class MissionHelloViewController: UIViewController, DeviceViewController {

    // Mission Manager
    @IBOutlet weak var missionHelloInstalledLabel: UILabel!
    @IBOutlet weak var missionHelloStateLabel: UILabel!
    @IBOutlet weak var loadButton: UIButton!
    @IBOutlet weak var unloadButton: UIButton!
    @IBOutlet weak var activateButton: UIButton!

    // Mission Hello
    @IBOutlet weak var obstacleLabel: UILabel!
    @IBOutlet weak var missionHelloCountLabel: UILabel!
    @IBOutlet weak var startStopButton: UIButton!

    private let groundSdk = GroundSdk()
    private var deviceUid: String?
    private var missionManagerRef: Ref<MissionManager>?
    static let missionUid = "com.parrot.missions.samples.hello"
    static let packageName = "parrot.missions.samples.hello.airsdk.messages"
    private var messageUid: UInt = 0
    private var onHold: Bool = false

    func setDeviceUid(_ uid: String) {
        deviceUid = uid
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if let drone = groundSdk.getDrone(uid: deviceUid!) {
            missionManagerRef = drone.getPeripheral(Peripherals.missionManager) {  [weak self] missionManager in
                guard let missionManager = missionManager,
                      let self = self else {
                    return
                }
                self.missionManagerChanged(missionManager)
            }
        }
    }
}

extension MissionHelloViewController {

    private func missionManagerChanged(_ missionManager: MissionManager) {
        // Mission manager supported by the drone
        let missions = missionManager.missions
        // `missions` is an array of mission by uid
        guard let mission = missions[MissionHelloViewController.missionUid] else {
            // Should use Mission Updater
            self.missionHelloStateLabel.text = "use MissionUpdater"
            self.startStopButton.isEnabled = false
            self.unloadButton.isHidden = true
            self.loadButton.isHidden = true
            self.activateButton.isHidden = true
            self.loadButton.isHidden = true
            return
        }
        let state = mission.state

        // Mission Hello present
        self.missionHelloInstalledLabel.text = "yes"
        self.loadButton.isHidden = false
        self.unloadButton.isHidden = false
        self.activateButton.isHidden = false

        self.missionHelloStateLabel.text = state.description
        self.unloadButton.isEnabled = state == .idle
        self.loadButton.isEnabled = state == .unloaded
        self.activateButton.isEnabled = state == .idle

        if let message = missionManager.latestMessage {
            if (MissionHelloViewController.packageName + ".Event").serviceId == message.serviceUid {
                self.consume(missionMessage: message)
            }
        }
    }

    private func consume(missionMessage: MissionMessage) {
        let missionUid = missionMessage.missionUid
        let messageUid = missionMessage.messageUid
        let serviceUid = missionMessage.serviceUid
        let payload = missionMessage.payload
        print(
"""
Will extract protobuf data from Hello mission message :
uid : \(missionUid); messageNumber : \(messageUid); packageName : \(serviceUid)
""")
        do {
            let event =
                try Parrot_Missions_Samples_Hello_Airsdk_Messages_Event(serializedData: payload)
            switch event.id {
            case .count(let count):
                self.missionHelloCountLabel.text = "\(count)"
            case .stereoClose(let close):
                self.obstacleLabel.text = close ? "yes" : "no"
            default:
                break
            }
        } catch {
            print("Failed to extract protobuf data from Hello mission message")
        }
    }
}

extension MissionHelloViewController {

    @IBAction func loadPushed(_ sender: UIButton) {
        if let missionManager = missionManagerRef?.value {
            _ = missionManager.load(uid: MissionHelloViewController.missionUid)
        }
    }

    @IBAction func unloadPushed(_ sender: UIButton) {
        if let missionManager = missionManagerRef?.value {
            _ = missionManager.unload(uid: MissionHelloViewController.missionUid)
        }
    }

    @IBAction func activatePushed(_ sender: UIButton) {
        if let missionManager = missionManagerRef?.value {
            _ = missionManager.activate(uid: MissionHelloViewController.missionUid)
        }
    }

    @IBAction func startStopPushed(_ sender: UIButton) {
        if let missionManager = missionManagerRef?.value {
            var command = Parrot_Missions_Samples_Hello_Airsdk_Messages_Command()
            command.id = self.onHold
                ? .say(Google_Protobuf_Empty())
                : .hold(Google_Protobuf_Empty())
            if let payload = try? command.serializedData() {
                let message = Message(messageUid: self.messageUid,
                                           payload: payload)
                missionManager.send(message: message)
                self.messageUid += 1
                self.onHold.toggle()
            }
        }
    }
}

private class Message: MissionMessage {
    let missionUid: String = MissionHelloViewController.missionUid
    let messageUid: UInt
    let serviceUid: UInt = (MissionHelloViewController.packageName + ".Command").serviceId
    let payload: Data

    init(messageUid: UInt, payload: Data) {
            self.messageUid = messageUid
            self.payload = payload
    }
}

/// Extension to compute protobuf service identifier from String.
extension String {

    /// Generates service identifier from String hash.
    var serviceId: UInt {
        var hash: UInt32 = 0

        data(using: .ascii)?.forEach {
            hash &+= UInt32($0)
            hash &+= (hash << 10)
            hash ^= (hash >> 6)
        }

        hash &+= (hash << 3)
        hash ^= (hash >> 11)
        hash &+= (hash << 15)
        hash &= 0xFFFF
        return UInt(hash)
    }
}
