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

class MediaStoreUploadViewController: UIViewController, MediaListViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var resourceCntView: UILabel!
    @IBOutlet weak var fileProgressView: UIProgressView!
    @IBOutlet weak var totalProgressView: UIProgressView!
    @IBOutlet weak var uploadButton: UIBarButtonItem!

    private let groundSdk = GroundSdk()
    private var droneUid: String?
    private var medias: [MediaItem]?
    private var mediaFolderPath: URL?
    private var files: [String]?
    private var uploadRequest: Ref<ResourceUploader>!

    func set(droneUid: String, medias: [MediaItem]) {
        self.droneUid = droneUid
        self.medias = medias
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.allowsMultipleSelection = true

        let fileManager = FileManager.default
        let documentPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let mediaPath = documentPath.appendingPathComponent("medias")

        // create medias directory if needed
        try? fileManager.createDirectory(at: mediaPath, withIntermediateDirectories: false, attributes: nil)

        mediaFolderPath = mediaPath
        files = try? fileManager.contentsOfDirectory(atPath: mediaPath.path)
    }

    func upload(resources: [URL]) {
        if let medias = medias,
           let drone = groundSdk.getDrone(uid: droneUid!),
           let mediaStore: MediaStore = drone.getPeripheral(Peripherals.mediaStore) {

            uploadButton.isEnabled = false

            uploadRequest = mediaStore.newUploader(
                resources: resources,
                target: medias[0]) { [weak self] resourceUploader in
                if let resourceUploader = resourceUploader {
                    self?.resourceCntView.text =
                        "\(resourceUploader.uploadedResourceCount) / \(resourceUploader.totalResourceCount)"
                    self?.fileProgressView.setProgress(resourceUploader.currentFileProgress, animated: false)
                    self?.totalProgressView.setProgress(resourceUploader.totalProgress, animated: false)
                    if resourceUploader.status != .running {
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) { [weak self] in
                            self?.cancel()
                        }
                    }
                } else {
                    self?.cancel()
                }
            }
        } else {
            cancel()
        }
    }

    func cancel() {
        presentingViewController?.dismiss(animated: true)
    }

    @IBAction func upload(_ sender: Any) {
        if let mediaFolderPath = mediaFolderPath,
           let files = files,
           let selectedRows = tableView.indexPathsForSelectedRows {
            let resources = selectedRows.map { indexPath in
                mediaFolderPath.appendingPathComponent(files[indexPath.row])
            }
            upload(resources: resources)
        }
    }

    @IBAction func cancel(_ sender: Any) {
        cancel()
    }
}

extension MediaStoreUploadViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return files?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "filename", for: indexPath)
        if let file = files?[indexPath.row] {
            cell.textLabel?.text = file
        }
        return cell
    }
}

extension MediaStoreUploadViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)!
        cell.accessoryType = .checkmark
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)!
        cell.accessoryType = .none
    }
}
