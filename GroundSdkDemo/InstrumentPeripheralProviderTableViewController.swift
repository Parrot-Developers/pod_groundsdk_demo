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

// swiftlint:disable type_name

class InstrumentPeripheralProviderTableViewController<P>: UITableViewController, DeviceViewController,
                                                            DeviceContentCellDelegate
where P: InstrumentProvider & PeripheralProvider {

    let groundSdk = GroundSdk()
    private(set) var deviceUid: String?
    fileprivate(set) var provider: P?

    /// All cells of the controller indexed by their initial uppercased letter
    private(set) var dataSource = [String: [DeviceContentCell]]()
    /// All initial uppercased letters
    private var sectionIndexTitles = [String]()
    /// The currently visible cells
    private var visibleSource = [String: [DeviceContentCell]]()

    override func numberOfSections(in tableView: UITableView) -> Int {
        sectionIndexTitles.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        visibleSource[sectionIndexTitles[section]]!.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        visibleSource[sectionIndexTitles[indexPath.section]]![indexPath.row]
    }

    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        sectionIndexTitles
    }

    func deviceContentCellVisibilityChanged(atIndexPath indexPath: IndexPath) {
        // when the visibility of a cell changes update the whole section, if they have the same
        // initial letter
        let section = indexPath.section
        let initial = sectionIndexTitles[section]
        let sectionCells = dataSource[initial]!
        visibleSource[initial] = sectionCells.filter { $0.isVisible }
        tableView.reloadSections(IndexSet([section]), with: .automatic)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewController = ((segue.destination as? UINavigationController)?.topViewController
                                 ?? segue.destination) as? DeviceViewController, let droneUid = deviceUid {
            viewController.setDeviceUid(droneUid)
        }
    }

    func setDeviceUid(_ uid: String) {
        deviceUid = uid
    }

    /// Returns the indexPath for the given cell identifier
    func indexPath(forCellIdentifier identifier: String) -> IndexPath {
        let initial = String(identifier.first!).uppercased()
        let section = sectionIndexTitles.firstIndex(of: initial)!
        let row = dataSource[initial]!.firstIndex(where: { $0.identifier == identifier })!
        return IndexPath(row: row, section: section)
    }

    func loadDataSource(cellIdentifiers: [String]) {
        // create a mapping between initials and identifiers starting with that initial
        // e.g.
        // "A" -> ["alarms", "altimeter", "attitudeIndicator"]
        // "Β" -> ["batteryInfo"]
        // etc...
        let alphabeticalGrouped = Dictionary(grouping: cellIdentifiers, by: { id in
            String(id.first!).uppercased()
        })
        // the keys are the section index titles
        sectionIndexTitles = alphabeticalGrouped.keys.sorted()
        // for each identifier create the corresponding cell
        alphabeticalGrouped.forEach { (initial: String, identifiers: [String]) in
            dataSource[initial] = identifiers.map { identifier in
                guard let cell = tableView.dequeueReusableCell(withIdentifier: identifier)
                        as? DeviceContentCell else {
                    preconditionFailure("\(identifier) is not a valid DeviceContentCell identifier.")
                }
                cell.identifier = identifier
                return cell
            }
        }
        // filter only visible cells
        dataSource.forEach { (initial: String, cells: [DeviceContentCell]) in
            visibleSource[initial] = cells.filter { $0.isVisible }
        }
    }
}

class DroneProviderTableViewController: InstrumentPeripheralProviderTableViewController<Drone> {

    var drone: Drone? {
        provider
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if let droneUid = deviceUid {
            provider = groundSdk.getDrone(uid: droneUid) { _ in
                // do nothing
            }
        }
    }
}

class RemoteControlProviderTableViewController: InstrumentPeripheralProviderTableViewController<RemoteControl> {

    var remoteControl: RemoteControl? {
        provider
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if let rcUid = deviceUid {
            provider = groundSdk.getRemoteControl(uid: rcUid) { _ in
                // do nothing
            }
        }
    }
}
