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

class MissionUpdaterUploadDetailCell: UITableViewCell {

    @IBOutlet weak var filePath: UILabel!
    @IBOutlet weak var upload: UIButton!
    @IBOutlet weak var progressView: UIProgressView!
}

class MissionUpdaterOverwriteCell: UITableViewCell {
    @IBOutlet weak var overwriteSwitch: UISwitch!
}

class MissionUpdaterPostponeCell: UITableViewCell {
    @IBOutlet weak var postponeSwitch: UISwitch!
}

class MissionUpdaterLocalMissionTVC: UITableViewController, DeviceViewController {
    private let groundSdk = GroundSdk()
    private var droneUid: String?
    private var missions: [String] = []
    private var missionUpdaterRef: Ref<MissionUpdater>?
    private var missionUpdater: MissionUpdater?
    private var missionUploadTag: Int?
    private var overwriteBool: Bool = true
    private var postponeValue: Bool = false

    func setDeviceUid(_ uid: String) {
        droneUid = uid
    }

    override func viewDidLoad() {
        let documentPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let missionsFolderPath = documentPath.appendingPathComponent("missions")
        let fileManager = FileManager.default
        if let missions = try? fileManager.contentsOfDirectory(atPath: missionsFolderPath.path) {
            self.missions = missions
            self.tableView.reloadData()
        }

        if let drone = groundSdk.getDrone(uid: droneUid!) {
            missionUpdaterRef = drone.getPeripheral(Peripherals.missionsUpdater) { [weak self] missions in
                self?.missionUpdater = missions
                if let row = self?.missionUploadTag {
                    let indexPath = IndexPath(row: row, section: 1)
                    self?.tableView.reloadRows(at: [indexPath], with: .none)
                }
                if self?.missionUpdater?.currentProgress == nil {
                    self?.missionUploadTag = nil
                }
            }
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "OverwriteCell", for: indexPath)
            if let cell = cell as? MissionUpdaterOverwriteCell {
                cell.overwriteSwitch.isOn = overwriteBool
            }
            return cell
        } else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostponeCell", for: indexPath)
            if let cell = cell as? MissionUpdaterPostponeCell {
                cell.postponeSwitch.isOn = postponeValue
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MissionUploadCell", for: indexPath)

            if let cell = cell as? MissionUpdaterUploadDetailCell {
                cell.filePath.text = missions[indexPath.row]
                cell.upload.tag = indexPath.row
                if let missionUpdater = missionUpdater {
                    if let progress = missionUpdater.currentProgress {
                        cell.progressView.isHidden = false
                        cell.progressView.progress = Float(progress) / 100
                    } else {
                        cell.progressView.isHidden = true
                    }
                }
            }
        return cell
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return missions.count
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "files should be put in Documents/missions"
        } else {
            return "List of local files"
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 40
        } else {
            return 120
        }
    }

    @IBAction func uploadMission(_ sender: UIButton) {
        let documentPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let missionsFolderPath = documentPath.appendingPathComponent("missions")
        let value = missions[sender.tag]
        let finalPath = missionsFolderPath.appendingPathComponent(value)

        missionUploadTag = sender.tag
        _ = missionUpdater?.upload(filePath: finalPath, overwrite: overwriteBool, postpone: postponeValue)

    }

    @IBAction func overwrite(_ sender: UISwitch) {
        overwriteBool = sender.isOn
    }

    @IBAction func postpone(_ sender: UISwitch) {
        postponeValue = sender.isOn
    }
}
