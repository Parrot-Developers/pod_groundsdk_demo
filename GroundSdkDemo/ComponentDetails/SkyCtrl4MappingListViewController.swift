// Copyright (C) 2021 Parrot Drones SAS
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

class SkyCtrl4MappingListViewController: UIViewController, DeviceViewController {

    private let addEntrySegue = "addEntry"
    private let editEntrySegue = "editEntry"

    private let groundSdk = GroundSdk()
    private var rcUid: String?
    private var skyCtrl4Gamepad: Ref<SkyCtrl4Gamepad>?

    private var currentDroneModel: Drone.Model?
    private var currentMappings: [SkyCtrl4MappingEntry]?

    @IBOutlet private weak var tabBar: UITabBar!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var addBt: UIBarButtonItem!
    @IBOutlet private weak var resetBt: UIBarButtonItem!

    private var entryToEdit: SkyCtrl4MappingEntry?

    func setDeviceUid(_ uid: String) {
        rcUid = uid
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // force tableview autolayout
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80

        if let remoteControl = groundSdk.getRemoteControl(uid: rcUid!) {
            skyCtrl4Gamepad =
                remoteControl.getPeripheral(Peripherals.skyCtrl4Gamepad) { [weak self] skyCtrl4Gamepad in
                    if let skyCtrl4Gamepad = skyCtrl4Gamepad {
                        self?.updateTabBar(skyCtrl4Gamepad: skyCtrl4Gamepad)

                        self?.reloadDataIfNeeded(skyCtrl4Gamepad: skyCtrl4Gamepad)
                    } else {
                        self?.performSegue(withIdentifier: "exit", sender: self)
                    }
            }
        }
    }

    private func updateTabBar(skyCtrl4Gamepad: SkyCtrl4Gamepad) {
        var tabBarItems = [UITabBarItem]()
        for supportedDrone in skyCtrl4Gamepad.supportedDroneModels {
            let image: UIImage?
            switch supportedDrone {
            case .anafi4k, .anafi2, .anafiThermal, .anafiUa, .anafiUsa, .anafi3, .anafi3Usa:
                image = #imageLiteral(resourceName: "anafi.png")
            default:
                image = nil
            }
            let tabBarItem = UITabBarItem(title: supportedDrone.description, image: image, tag: supportedDrone.rawValue)
            tabBarItem.badgeValue = (skyCtrl4Gamepad.activeDroneModel == supportedDrone) ? "*" : nil

            tabBarItems.append(tabBarItem)
        }
        tabBarItems.sort(by: { return $0.tag <= $1.tag })
        if tabBar.items == nil || tabBarItems != tabBar.items! {
            tabBar.setItems(tabBarItems, animated: false)
        }

        if currentDroneModel == nil {
            if skyCtrl4Gamepad.activeDroneModel != nil {
                currentDroneModel = skyCtrl4Gamepad.activeDroneModel
            } else if tabBarItems.count > 0 {
                currentDroneModel = Drone.Model(rawValue: tabBarItems[0].tag)
            }
        }

        if currentDroneModel != nil {
            var tabItem: UITabBarItem?
            tabBarItems.forEach {
                if Drone.Model(rawValue: $0.tag) == currentDroneModel {
                    tabItem = $0
                    return
                }
            }
            tabBar.selectedItem = tabItem
        }
        addBt.isEnabled = currentDroneModel != nil
        resetBt.isEnabled = currentDroneModel != nil
    }

    private func reloadDataIfNeeded(skyCtrl4Gamepad: SkyCtrl4Gamepad?) {
        if let skyCtrl4Gamepad = skyCtrl4Gamepad, let currentDroneModel = self.currentDroneModel {
            let mappingsSet = skyCtrl4Gamepad.mapping(forModel: currentDroneModel)!
            if self.currentMappings == nil || Set(self.currentMappings!) != mappingsSet {
                self.currentMappings = Array(mappingsSet).sorted { entry1, entry2 in
                    if let btEntry1 = entry1 as? SkyCtrl4ButtonsMappingEntry,
                        let btEntry2 = entry2 as? SkyCtrl4ButtonsMappingEntry {
                        return btEntry1.action.rawValue < btEntry2.action.rawValue
                    } else if let btEntry1 = entry1 as? SkyCtrl4ButtonsMappingEntry,
                        let btEntry2 = entry2 as? SkyCtrl4ButtonsMappingEntry {
                        return btEntry1.action.rawValue < btEntry2.action.rawValue
                    } else {
                        return entry1.type.rawValue < entry2.type.rawValue
                    }
                }
                self.tableView.reloadData()
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let mappingEditVC = segue.destination as? SkyCtrl4MappingEditViewController,
            (segue.identifier == addEntrySegue ||  segue.identifier == editEntrySegue) {
            mappingEditVC.droneModel = currentDroneModel!
            mappingEditVC.setDeviceUid(rcUid!)
            if segue.identifier == editEntrySegue {
                mappingEditVC.entry = entryToEdit!
                entryToEdit = nil
            }
        }
    }

    @IBAction func onResetMapping(_ sender: AnyObject) {
        if let currentDroneModel = currentDroneModel {
            skyCtrl4Gamepad?.value?.resetMapping(forModel: currentDroneModel)
        }
    }
}

extension SkyCtrl4MappingListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentMappings?.count ?? 0
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell

        let editEntry: (_ entry: SkyCtrl4MappingEntry) -> Void = {
            self.entryToEdit = $0
            self.performSegue(withIdentifier: self.editEntrySegue, sender: self)
        }

        // since there are items, we can assume that currentMappings is not nil
        let mappingEntry = currentMappings![indexPath.row]
        switch mappingEntry.type {
        case .buttons:
            cell = tableView.dequeueReusableCell(withIdentifier: "buttonsMapping", for: indexPath)
            if let buttonsEntry = mappingEntry as? SkyCtrl4ButtonsMappingEntry,
                let cell = cell as? SkyCtrl4ButtonsMappingEntryCell {
                cell.updateWith(buttonEntry: buttonsEntry, editEntry: editEntry)
            }
        case .axis:
            cell = tableView.dequeueReusableCell(withIdentifier: "axisMapping", for: indexPath)
            if let axisEntry = mappingEntry as? SkyCtrl4AxisMappingEntry,
                let cell = cell as? SkyCtrl4AxisMappingEntryCell {
                cell.updateWith(axisEntry: axisEntry, editEntry: editEntry)
            }
        }
        return cell
    }
}

extension SkyCtrl4MappingListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { _, indexPath in
            self.tableView.beginUpdates()
            let mappingToDelete = self.currentMappings!.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
            self.tableView.endUpdates()
            self.skyCtrl4Gamepad?.value?.unregister(mappingEntry: mappingToDelete)
        }

        return [delete]
    }
}

extension SkyCtrl4MappingListViewController: UITabBarDelegate {
    public func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        currentDroneModel = Drone.Model(rawValue: item.tag)
        reloadDataIfNeeded(skyCtrl4Gamepad: skyCtrl4Gamepad?.value)
    }
}

class SkyCtrl4MappingEntryCell: UITableViewCell {
    private var entry: SkyCtrl4MappingEntry?
    private var editEntry: ((_ entry: SkyCtrl4MappingEntry) -> Void)?

    @IBAction func onEditPushed(_ sender: AnyObject) {
        if let editEntry = editEntry, let entry = entry {
            editEntry(entry)
        }
    }

    func updateWith(entry: SkyCtrl4MappingEntry, editEntry: ((_ entry: SkyCtrl4MappingEntry) -> Void)?) {
        self.entry = entry
        self.editEntry = editEntry
    }
}

class SkyCtrl4ButtonsMappingEntryCell: SkyCtrl4MappingEntryCell {
    @IBOutlet weak var action: UILabel!
    @IBOutlet weak var buttons: UILabel!

    func updateWith(buttonEntry: SkyCtrl4ButtonsMappingEntry, editEntry: ((_ entry: SkyCtrl4MappingEntry) -> Void)?) {
        super.updateWith(entry: buttonEntry, editEntry: editEntry)
        action.text = buttonEntry.action.description
        buttons.text = buttonEntry.buttonEvents.map({ $0.description }).description
    }
}

class SkyCtrl4AxisMappingEntryCell: SkyCtrl4MappingEntryCell {
    @IBOutlet weak var action: UILabel!
    @IBOutlet weak var buttons: UILabel!
    @IBOutlet weak var axis: UILabel!

    func updateWith(axisEntry: SkyCtrl4AxisMappingEntry, editEntry: ((_ entry: SkyCtrl4MappingEntry) -> Void)?) {
        super.updateWith(entry: axisEntry, editEntry: editEntry)
        action.text = axisEntry.action.description
        axis.text = axisEntry.axisEvent.description
        buttons.text = axisEntry.buttonEvents.map({ $0.description }).description
    }
}
