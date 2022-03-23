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

class MissionUpdaterViewController: UITableViewController, DeviceViewController, MissionUpdaterDelegate {
    private let groundSdk = GroundSdk()
    private var droneUid: String?
    private var missionUpdaterRef: Ref<MissionUpdater>?
    private var missionUpdater: MissionUpdater?
    private var arrayKey = [String]()

    func setDeviceUid(_ uid: String) {
        droneUid = uid
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if let drone = groundSdk.getDrone(uid: droneUid!) {
            missionUpdaterRef = drone.getPeripheral(Peripherals.missionsUpdater) { [weak self] missions in
                self?.missionUpdater = missions
                if missions != nil, let `self` = self {
                    self.arrayKey.removeAll()
                    if let missionsList = missions?.missions {
                        for mission in missionsList {
                            self.arrayKey.append(mission.key)
                        }
                    }
                    self.tableView.reloadData()
                } else {
                    self?.performSegue(withIdentifier: "exit", sender: self)
                }
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        self.missionUpdater?.browse()
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MissionUpdaterUploadDetailCell", for: indexPath)
            cell.textLabel?.text = "List of local missions ready to upload"
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MissionUpdaterDetailCell", for: indexPath)
            if let cell = cell as? MissionUpdaterDetailCell {
                if let mission = missionUpdater?.missions[self.arrayKey[indexPath.row]] {
                    cell.uidLabel.text = String(mission.uid)
                    cell.nameLabel.text = mission.name
                    cell.descriptionLabel.text = mission.description
                    cell.versionLabel.text = mission.version
                    cell.firmwareMinVersionLabel.text = mission.minTargetVersion?.description ?? ""
                    cell.firmwareMaxVersionLabel.text = mission.maxTargetVersion?.description ?? ""
                    cell.targetModelLabel.text = mission.targetModelId?.description ?? ""
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

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "MissionLocalListSegue" {
            if let viewController = segue.destination as? MissionUpdaterLocalMissionTVC {
                viewController.setDeviceUid(droneUid!)
            }

        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 && indexPath.section == 0 {
            performSegue(withIdentifier: "MissionLocalListSegue", sender: nil)
        }
    }

    func delete(uid: String) {
        missionUpdater?.delete(uid: uid, success: { (success) in
            if success {
                self.missionUpdater?.browse()
            }
        })
    }

    @IBAction func finalize(_ sender: UIButton) {
        self.missionUpdater?.complete()
    }
}
