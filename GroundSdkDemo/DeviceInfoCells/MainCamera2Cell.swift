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

class MainCamera2Cell: PeripheralProviderContentCell {

    private var camera: Ref<MainCamera2>?
    private var exposureIndicator: Ref<Camera2ExposureIndicator>?
    private var exposureLock: Ref<Camera2ExposureLock>?
    private var whiteBalanceLock: Ref<Camera2WhiteBalanceLock>?
    private var recording: Ref<Camera2Recording>?
    private var photoCapture: Ref<Camera2PhotoCapture>?
    private var photoProgressIndicator: Ref<Camera2PhotoProgressIndicator>?
    private var zoom: Ref<Camera2Zoom>?

    @IBOutlet weak var activeLabel: UILabel!
    @IBOutlet weak var exposureLabel: UILabel!
    @IBOutlet weak var exposureLockLabel: UILabel!
    @IBOutlet weak var whiteBalanceLockLabel: UILabel!
    @IBOutlet weak var recordingLabel: UILabel!
    @IBOutlet weak var photoCaptureLabel: UILabel!
    @IBOutlet weak var photoProgressLabel: UILabel!
    @IBOutlet weak var zoomLabel: UILabel!

    override func set(peripheralProvider provider: PeripheralProvider) {
        super.set(peripheralProvider: provider)
        camera = provider.getPeripheral(Peripherals.mainCamera2) { [unowned self] camera in
            if let camera = camera {
                self.activeLabel.text = camera.isActive.description

                if self.exposureIndicator == nil {
                    self.exposureLabel.text = "-"
                    self.exposureIndicator
                        = camera.getComponent(Camera2Components.exposureIndicator) { [unowned self] exposure in
                            if let exposure = exposure {
                                self.exposureLabel.text = "\(exposure.isoSensitivity) \(exposure.shutterSpeed)"
                            } else {
                                self.exposureLabel.text = "-"
                            }
                    }
                }

                if self.exposureLock == nil {
                    self.exposureLockLabel.text = "-"
                    self.exposureLock
                        = camera.getComponent(Camera2Components.exposureLock) { [unowned self] exposureLock in
                            if let exposureLock = exposureLock {
                                self.exposureLockLabel.text = exposureLock.mode.description
                            } else {
                                self.exposureLockLabel.text = "-"
                            }
                    }
                }
                if self.whiteBalanceLock == nil {
                    self.whiteBalanceLockLabel.text = "-"
                    self.whiteBalanceLock
                        = camera.getComponent(Camera2Components.whiteBalanceLock) { [unowned self] whiteBalanceLock in
                            if let whiteBalanceLock = whiteBalanceLock {
                                self.whiteBalanceLockLabel.text = whiteBalanceLock.mode.description
                            } else {
                                self.whiteBalanceLockLabel.text = "-"
                            }
                    }
                }

                if self.recording == nil {
                    self.recordingLabel.text = "-"
                    self.recording
                        = camera.getComponent(Camera2Components.recording) { [unowned self] recording in
                            if let recording = recording {
                                self.recordingLabel.text = recording.state.description
                            } else {
                                self.recordingLabel.text = "-"
                            }
                    }
                }

                if self.photoCapture == nil {
                    self.photoCaptureLabel.text = "-"
                    self.photoCapture
                        = camera.getComponent(Camera2Components.photoCapture) { [unowned self] photoCapture in
                            if let photoCapture = photoCapture {
                                self.photoCaptureLabel.text = photoCapture.state.description
                            } else {
                                self.photoCaptureLabel.text = "-"
                            }
                    }
                }

                if self.photoProgressIndicator == nil {
                    self.photoProgressLabel.text = "-"
                    self.photoProgressIndicator
                        = camera.getComponent(Camera2Components.photoProgressIndicator) { [unowned self] photo in
                            if let photoProgress = photo {
                                if let remainingDistance = photoProgress.remainingDistance {
                                    self.photoProgressLabel.text = "\(remainingDistance)m"
                                } else if let remainingTime = photoProgress.remainingTime {
                                    self.photoProgressLabel.text = "\(remainingTime)s"
                                } else {
                                    self.photoProgressLabel.text = "-"
                                }
                            } else {
                                self.photoProgressLabel.text = "-"
                            }
                    }
                }

                if self.zoom == nil {
                    self.zoomLabel.text = "-"
                    self.zoom = camera.getComponent(Camera2Components.zoom) { [unowned self] zoom in
                        if let zoom = zoom {
                            self.zoomLabel.text = "\(zoom.level)"
                        } else {
                            self.zoomLabel.text = "-"
                        }
                    }
                }

                self.show()
            } else {
                self.exposureIndicator = nil
                self.exposureLock = nil
                self.whiteBalanceLock = nil
                self.recording = nil
                self.photoCapture = nil
                self.photoProgressIndicator = nil
                self.zoom = nil

                self.hide()
            }
        }
    }
}
