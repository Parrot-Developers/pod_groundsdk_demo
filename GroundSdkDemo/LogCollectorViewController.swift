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

import Foundation
import UIKit
import GroundSdk

class LogCollectorViewController: UIViewController {

    @IBOutlet weak var globalStatusLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!

    private let groundSdk = GroundSdk()

    private var logCollectorRef: Ref<LogCollector>?

    private var sources: [LogCollectorSource] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        var rc: RemoteControl?
        let rcListRef = groundSdk.getRemoteControlList(observer: { _ in })
        if let rcEntry = rcListRef.value?.first(where: { $0.state.connectionState == .connected}) {
            rc = groundSdk.getRemoteControl(uid: rcEntry.uid)
        }

        var drone: Drone?
        let droneListRef = groundSdk.getDroneList(observer: { _ in })
        if let droneEntry = droneListRef.value?.first(where: { $0.state.connectionState == .connected}) {
            drone = groundSdk.getDrone(uid: droneEntry.uid)
        }

        let appLogDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("log")
        let dstDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]

        sources = [.application(appLogDir)]
        if let rc = rc {
            sources.append(.remoteControl(rc))
        }
        if let drone = drone {
            sources.append(.drone(drone))
        }

        logCollectorRef = groundSdk.collectLogs(from: Set(sources), toDirectory: dstDir) { logCollector in
            self.globalStatusLabel.text = logCollector?.globalStatus.description
            self.tableView.reloadData()
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        logCollectorRef = nil
    }
}

extension LogCollectorViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "logCollectorCell", for: indexPath)
        if let cell = cell as? LogCollectorCell {
            let source = sources[indexPath.row]
            cell.update(source: source, state: logCollectorRef?.value?.states[source])
        }
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sources.count
    }
}

class LogCollectorCell: UITableViewCell {

    @IBOutlet weak var sourceLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var downloadProgressView: UIProgressView!

    func update(source: LogCollectorSource, state: LogCollectorState?) {
        guard let state = state else {
            return
        }

        sourceLabel.text = source.description
        statusLabel.text = state.status.description
        downloadProgressView.setProgress(Float(state.collectedSize ?? 0) / Float(state.totalSize ?? 1), animated: false)
    }
}
