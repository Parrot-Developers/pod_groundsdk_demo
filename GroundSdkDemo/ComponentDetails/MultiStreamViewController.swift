// Copyright (C) 2019 Parrot Drones SAS
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

import GroundSdk

class MultiStreamViewController: UIViewController, DeviceViewController {

    @IBOutlet weak var streamView: StreamView!
    @IBOutlet weak var startStreamSwitch: UISwitch!
    @IBOutlet weak var sourceSelectionBtn: UIButton!

    @IBOutlet weak var streamPlayPauseBtn: UIButton!
    @IBOutlet weak var streamStopBtn: UIButton!
    @IBOutlet weak var streamPlayStateLabel: UILabel!
    @IBOutlet weak var streamStateLabel: UILabel!

    private let groundSdk = GroundSdk()
    private var droneUid: String?
    private var streamServer: Ref<StreamServer>?
    private var mediaStoreRef: Ref<MediaStore>?
    private var mediaListRef: Ref<[MediaItem]>?
    private var mediaList: [MediaItem]?

    private var cameraLive: Ref<CameraLive>?
    private var mediaReplay: Ref<MediaReplay>?
    private var fileReplay: Ref<FileReplay>?

    private var sourceName: String?

    func setDeviceUid(_ uid: String) {
        droneUid = uid
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUi()
        startDroneMonitors()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopDroneMonitors()
    }

    private func startDroneMonitors() {
        if let droneUid = droneUid, let drone = groundSdk.getDrone(uid: droneUid) {
            streamServer = drone.getPeripheral(Peripherals.streamServer) { [unowned self] streamServer in
                if let streamServer = streamServer {
                    startStreamSwitch.isOn = streamServer.enabled
                }
            }

            mediaStoreRef = drone.getPeripheral(Peripherals.mediaStore) { [unowned self] mediaStore in
                if let mediaStore = mediaStore {
                    startMediaStoreListMonitor(mediaStore: mediaStore)
                } else {
                    stopMediaStoreListMonitor()
                }
            }
        }
    }

    private func stopDroneMonitors() {
        streamView.setStream(stream: nil)
        streamServer = nil
        mediaStoreRef = nil

        stopMediaStoreListMonitor()

        cameraLive = nil
        mediaReplay = nil
        fileReplay = nil

        streamView.setStream(stream: nil)
    }

    private func startMediaStoreListMonitor(mediaStore: MediaStore) {
        guard mediaListRef == nil else { return }

        mediaListRef = mediaStore.newList { [unowned self] mediaList in
            self.mediaList = mediaList
        }
    }

    private func stopMediaStoreListMonitor() {
        mediaListRef = nil
        mediaList = nil
    }

    @IBAction func startStream(_ sender: UISwitch) {
        streamServer?.value?.enabled = sender.isOn
    }

    private func addCameraLiveSourceChoices(alert: UIAlertController) {
        alert.addAction(
            UIAlertAction(title: "frontCamera", style: .default,
                          handler: { [weak self] _ in
                            self?.cameraLiveSourceSelected(source: .frontCamera, name: "frontCamera")
                          })
        )
        alert.addAction(
            UIAlertAction(title: "frontStereoCameraLeft", style: .default,
                          handler: { [weak self] _ in
                            self?.cameraLiveSourceSelected(source: .frontStereoCameraLeft,
                                                           name: "frontStereoCameraLeft")
                          })
        )
        alert.addAction(
            UIAlertAction(title: "frontStereoCameraRight", style: .default,
                          handler: { [weak self] _ in
                            self?.cameraLiveSourceSelected(source: .frontStereoCameraRight,
                                                           name: "frontStereoCameraRight")
                          })
        )
        alert.addAction(
            UIAlertAction(title: "disparity", style: .default,
                          handler: { [weak self] _ in
                            self?.cameraLiveSourceSelected(source: .disparity, name: "disparity")
                          })
        )
        alert.addAction(
            UIAlertAction(title: "verticalCamera", style: .default,
                          handler: { [weak self] _ in
                            self?.cameraLiveSourceSelected(source: .verticalCamera, name: "verticalCamera")
                          })
        )
        alert.addAction(
            UIAlertAction(title: "frontStereoCameraLeft", style: .default,
                          handler: { [weak self] _ in
                            self?.cameraLiveSourceSelected(source: .frontStereoCameraLeft,
                                                           name: "frontStereoCameraLeft")
                          })
        )
    }

    private func addMediaReplaySourceChoices(alert: UIAlertController) {
        mediaList?.forEach {
            guard $0.type == .video else { return }

            if let resource = $0.resources.first(where: { return $0.streamable}) {
                let track = resource.getAvailableTracks()?.first ?? .defaultVideo
                if let source = MediaReplaySourceFactory.videoTrackOf(resource: resource, track: track) {
                    let srcName = "replay:\($0.name)"
                    alert.addAction(
                        UIAlertAction(title: srcName, style: .default,
                                      handler: { [weak self] _ in
                                        self?.mediaReplaySourceSelected(source: source, name: srcName)
                                      })
                    )
                }
            }
        }
    }

    private func addMediaFileSourceChoices(alert: UIAlertController) {
        getVideoFileList().forEach { url in
            let srcName = "file:\(url.lastPathComponent)"
            alert.addAction(
                UIAlertAction(title: srcName, style: .default,
                              handler: { [weak self] _ in
                                self?.fileSourceSelected(fileUrl: url, name: srcName)
                              })
            )
        }
    }

    private func getVideoFileList() -> [URL] {
        let videoFileList: [URL]
        let fileManager = FileManager.default
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
            .appendingPathComponent("medias")
        do {
            let fileUrls = try fileManager.contentsOfDirectory(at: documentsPath,
                                                               includingPropertiesForKeys: nil,
                                                               options: .skipsHiddenFiles)
            videoFileList = fileUrls.filter { $0.pathExtension.lowercased() == "mp4" }
        } catch {
            videoFileList = []
        }
        return videoFileList
    }

    private func updateUi() {
        sourceSelectionBtn.setTitle(sourceName ?? "source", for: .normal)

        if let stream = cameraLive?.value {
            updateUiCameraLive(stream: stream)
        } else if let stream = mediaReplay?.value {
            updateUiMediaReplay(stream: stream)
        } else if let stream = fileReplay?.value {
            updateUiFileReplay(stream: stream)
        } else {
            streamPlayPauseBtn.isEnabled = false
            streamStopBtn.isEnabled = false
            streamPlayPauseBtn.setTitle("-", for: .normal)
            streamStateLabel.text = "-"
            streamPlayStateLabel.text = "-"
            streamView.setStream(stream: nil)
        }
    }

    private func updateUiCameraLive(stream: CameraLive) {
        streamPlayPauseBtn.isEnabled = true
        streamStopBtn.isEnabled = stream.playState == .playing
        streamPlayPauseBtn.setTitle(stream.playState == .playing ? "Pause" : "Play", for: .normal)
        streamStateLabel.text = stream.state.description
        streamPlayStateLabel.text = stream.playState.description
        streamView.setStream(stream: stream)
    }

    private func updateUiMediaReplay(stream: MediaReplay) {
        streamPlayPauseBtn.isEnabled = true
        streamStopBtn.isEnabled = stream.playState == .playing
        streamPlayPauseBtn.setTitle(stream.playState == .playing ? "Pause" : "Play", for: .normal)
        streamStateLabel.text = stream.state.description
        streamPlayStateLabel.text = stream.playState.description
        streamView.setStream(stream: stream)
    }

    private func updateUiFileReplay(stream: FileReplay) {
        streamPlayPauseBtn.isEnabled = true
        streamStopBtn.isEnabled = stream.playState == .playing
        streamPlayPauseBtn.setTitle(stream.playState == .playing ? "Pause" : "Play", for: .normal)
        streamStateLabel.text = stream.state.description
        streamPlayStateLabel.text = stream.playState.description
        streamView.setStream(stream: stream)
    }

    @IBAction func selectSource(_ sender: UIButton) {
        let alert = UIAlertController(title: "Source Selection",
                                      message: nil,
                                      preferredStyle: .actionSheet)

        // Cameras lives
        addCameraLiveSourceChoices(alert: alert)

        // Media replays
        addMediaReplaySourceChoices(alert: alert)

        // Media files
        addMediaFileSourceChoices(alert: alert)

        present(alert, animated: true)
    }

    private func cameraLiveSourceSelected(source: CameraLiveSource, name: String) {
        cameraLive = streamServer?.value?.live(source: source) { [unowned self] stream in

            if cameraLive == nil, let stream = stream {
                updateUiCameraLive(stream: stream)
            } else {
                updateUi()
            }
        }
        mediaReplay = nil
        sourceName = name
        updateUi()
    }

    private func mediaReplaySourceSelected(source: MediaReplaySource, name: String) {
        cameraLive = nil
        mediaReplay = streamServer?.value?.replay(source: source) { [unowned self] stream in
            if mediaReplay == nil, let stream = stream {
                updateUiMediaReplay(stream: stream)
            } else {
                updateUi()
            }
        }
        sourceName = name
        updateUi()
    }
    private func fileSourceSelected(fileUrl: URL, name: String) {
        let source = FileReplayFactory.videoTrackOf(file: fileUrl, track: .defaultVideo)
        fileReplay = groundSdk.replay(source: source) { [unowned self] stream in
            if fileReplay == nil, let stream = stream {
                updateUiFileReplay(stream: stream)
            } else {
                updateUi()
            }
        }
        sourceName = name
        updateUi()
    }

    @IBAction func playPauseStream(_ sender: UIButton) {
        if let stream = cameraLive?.value {
            if stream.playState == .playing {
                _ = stream.pause()
            } else {
                _ = stream.play()
            }
        } else if let stream = mediaReplay?.value {
            if stream.playState == .playing {
                _ = stream.pause()
            } else {
                _ = stream.play()
            }
        } else if let stream = fileReplay?.value {
            if stream.playState == .playing {
                _ = stream.pause()
            } else {
                _ = stream.play()
            }
        }
    }

    @IBAction func stopStream(_ sender: UIButton) {
        if let cameraLive = cameraLive, cameraLive.value?.state != .stopped {
            cameraLive.value?.stop()
        } else if let replay = mediaReplay, replay.value?.state != .stopped {
            replay.value?.stop()
        } else if let replay = fileReplay, replay.value?.state != .stopped {
            replay.value?.stop()
        }
    }
}
