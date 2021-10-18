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

class AnimationsViewController: UITableViewController, DeviceViewController {

    private let groundSdk = GroundSdk()
    private var droneUid: String?
    private var animations: Ref<Animation>?
    private var pilotingItf: Ref<AnimationPilotingItf>?

    private var pilotingMode: [PilotingMode] = []
    private var animationType: [AnimationType] = []

    private var indexPathSelected: IndexPath?

    func setDeviceUid(_ uid: String) {
        droneUid = uid
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if let drone = groundSdk.getDrone(uid: droneUid!) {
            pilotingItf = drone.getPilotingItf(PilotingItfs.animation) { [weak self] pilotingItf in
                if let pilotingItf = pilotingItf {
                    if let keys = pilotingItf.supportedAnimations?.keys {
                        self?.pilotingMode = Array(keys)
                    }
                    if let keys = pilotingItf.availabilityIssues?.keys {
                        self?.animationType = Array(keys)
                    }
                    self?.tableView.reloadData()
                } else {
                    self?.performSegue(withIdentifier: "exit", sender: self)
                }
            }
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        indexPathSelected = indexPath
        performSegue(withIdentifier: "selectEnumValue", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let pilotingItf = pilotingItf?.value, let target = segue.destination
            as? ChooseEnumViewController, indexPathSelected != nil {
            var arrayValues = [String]()
            var title = ""
            if indexPathSelected!.section == 0,
                let array = (pilotingItf.supportedAnimations?[pilotingMode[indexPathSelected!.row]]) {
                for elements in array {
                    arrayValues.append(elements.description)
                }
                title = pilotingMode[indexPathSelected!.row].description
            } else if let array = (pilotingItf.availabilityIssues?[animationType[indexPathSelected!.row]]) {
                for elements in array {
                    arrayValues.append(elements.description)
                }
                title = animationType[indexPathSelected!.row].description
            }
            target.initialize(data: ChooseEnumViewController.Data(
                dataSource: arrayValues,
                selectedValue: nil,
                itemDidSelect: { _ in }
            ))
            target.title = title
        }

    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Animation supported for mode"
        } else {
            return "Missing requierements for animation"
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "animationCell", for: indexPath)
        if indexPath.section == 0 {
            cell.textLabel?.text = pilotingMode[indexPath.row].description
        } else {
            cell.textLabel?.text = animationType[indexPath.row].description
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var returnValue = 0
        if let pilotingItf = pilotingItf?.value {
            if section == 0 {
                returnValue = pilotingItf.supportedAnimations?.keys.count ?? 0
            } else {
                returnValue = pilotingItf.availabilityIssues?.keys.count ?? 0
            }
        }
        return returnValue
    }
}
