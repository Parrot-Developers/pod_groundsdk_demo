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

class MissionManagerViewController: UITableViewController, DeviceViewController, MissionManagerDelegate {
    private let groundSdk = GroundSdk()
    private var droneUid: String?
    private var missionManagerRef: Ref<MissionManager>?
    private var missionManager: MissionManager?
    private var arrayKey = [String]()

    func setDeviceUid(_ uid: String) {
        droneUid = uid
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if let drone = groundSdk.getDrone(uid: droneUid!) {
            missionManagerRef = drone.getPeripheral(Peripherals.missionManager) { [weak self] missions in
                self?.missionManager = missions
                if missions != nil, let `self` = self {
                    self.arrayKey.removeAll()
                    if let missionsList = missions?.missions {
                        for mission in missionsList {
                            self.arrayKey.append(mission.key)
                        }
                        if let suggestedActivation = self.missionManager?.suggestedActivation {
                            let alert = UIAlertController(title: "Suggested Activation",
                                message: suggestedActivation, preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                            alert.addAction(UIAlertAction(title: "Activate", style: .default, handler: { action in
                                  switch action.style {
                                  case .default:
                                    self.missionManager?.activate(uid: suggestedActivation)
                                  default:
                                    break
                            }}))
                            self.present(alert, animated: true, completion: nil)
                        }
                    }
                    self.tableView.reloadData()
                } else {
                    self?.performSegue(withIdentifier: "exit", sender: self)
                }
            }
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            return tableView.dequeueReusableCell(withIdentifier: "MissionDeactivateCell", for: indexPath)
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MissionDetailCell", for: indexPath)

            if let cell = cell as? MissionManagerDetailCell {
                if let mission = missionManager?.missions[self.arrayKey[indexPath.row]] {
                    switch mission.state {
                    case .unavailable:
                        cell.stateLabel?.text = "unavailable"
                        cell.unloadButton.isEnabled = false
                        cell.loadButton.isEnabled = mission.unavailabilityReason != .none ? true : false
                        cell.activateButton.isEnabled = false
                    case .idle:
                        cell.stateLabel?.text = "idle"
                        cell.unloadButton.isEnabled = true
                        cell.loadButton.isEnabled = false
                        cell.activateButton.isEnabled = true
                    case .active:
                        cell.stateLabel?.text = "active"
                        cell.unloadButton.isEnabled = true
                        cell.loadButton.isEnabled = false
                        cell.activateButton.isEnabled = false
                    case .unloaded:
                        cell.stateLabel?.text = "unload"
                        cell.unloadButton.isEnabled = false
                        cell.loadButton.isEnabled = true
                        cell.activateButton.isEnabled = false
                    case .activating:
                        cell.stateLabel?.text = "activating"
                        cell.unloadButton.isEnabled = false
                        cell.loadButton.isEnabled = false
                        cell.activateButton.isEnabled = false
                    }
                    if missionManager?.suggestedActivation != nil {
                        cell.nameLabel.textColor = .green
                    } else {
                        cell.nameLabel.textColor = cell.descriptionLabel.textColor
                    }
                    cell.uidLabel.text = String(mission.uid)
                    cell.nameLabel.text = mission.name
                    cell.descriptionLabel.text = mission.description
                    cell.versionLabel.text = mission.version
                    cell.firmwareMinVersionLabel.text = mission.minTargetVersion?.description ?? ""
                    cell.firmwareMaxVersionLabel.text = mission.maxTargetVersion?.description ?? ""
                    cell.targetModelLabel.text = mission.targetModelId?.description ?? ""
                    cell.stateLabel.text = mission.state.description
                    cell.unavailabilityReasonLabel.text = mission.unavailabilityReason.description
                    cell.mission = mission
                    cell.delegate = self
                }
            }
            return cell
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return self.arrayKey.count
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            missionManager?.deactivate()
        }
    }

    func load(uid: String) {
        missionManager?.load(uid: uid)
    }

    func unload(uid: String) {
        missionManager?.unload(uid: uid)
    }

    func activate(uid: String) {
        missionManager?.activate(uid: uid)
    }
}
