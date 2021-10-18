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

class Camera2ViewController: UITableViewController, DeviceViewController {

    let groundSdk = GroundSdk()
    var droneUid: String?
    private var exposureIndicator: Ref<Camera2ExposureIndicator>?
    private var exposureLock: Ref<Camera2ExposureLock>?
    private var whiteBalanceLock: Ref<Camera2WhiteBalanceLock>?
    private var mediaMetadata: Ref<Camera2MediaMetadata>?
    private var recording: Ref<Camera2Recording>?
    private var photoCapture: Ref<Camera2PhotoCapture>?
    private var photoProgressIndicator: Ref<Camera2PhotoProgressIndicator>?
    private var zoom: Ref<Camera2Zoom>?

    // config
    @IBOutlet weak var cameraMode: UILabel!

    @IBOutlet weak var photoMode: UILabel!
    @IBOutlet weak var photoDynamicRange: UILabel!
    @IBOutlet weak var photoResolution: UILabel!
    @IBOutlet weak var photoFormat: UILabel!
    @IBOutlet weak var photoFileFormat: UILabel!
    @IBOutlet weak var photoDigitalSignature: UILabel!
    @IBOutlet weak var photoBracketing: UILabel!
    @IBOutlet weak var photoBurst: UILabel!
    @IBOutlet weak var gpslapseCaptureInterval: UILabel!
    @IBOutlet weak var timelapseCaptureInterval: UILabel!
    @IBOutlet weak var photoStreamingMode: UILabel!

    @IBOutlet weak var recordingMode: UILabel!
    @IBOutlet weak var recordingDynamicRange: UILabel!
    @IBOutlet weak var recordingCodec: UILabel!
    @IBOutlet weak var recordingResolution: UILabel!
    @IBOutlet weak var recordingFramerate: UILabel!
    @IBOutlet weak var recordingBitrate: UILabel!
    @IBOutlet weak var recordingHyperlapse: UILabel!
    @IBOutlet weak var audioRecordingMode: UILabel!
    @IBOutlet weak var autoRecordMode: UILabel!

    @IBOutlet weak var exposureMode: UILabel!
    @IBOutlet weak var manualShutterSpeed: UILabel!
    @IBOutlet weak var manualIso: UILabel!
    @IBOutlet weak var maximumIso: UILabel!
    @IBOutlet weak var evCompensation: UILabel!
    @IBOutlet weak var autoExposureMeteringMode: UILabel!

    @IBOutlet weak var whiteBalanceMode: UILabel!
    @IBOutlet weak var whiteBalanceTemperature: UILabel!

    @IBOutlet weak var activeStyle: UILabel!
    @IBOutlet weak var styleSaturation: UILabel!
    @IBOutlet weak var styleContrast: UILabel!
    @IBOutlet weak var styleSharpness: UILabel!

    @IBOutlet weak var zoomMaxSpeed: UILabel!
    @IBOutlet weak var zoomVelocityControlMode: UILabel!

    @IBOutlet weak var alignmentOffsetPitch: UILabel!
    @IBOutlet weak var alignmentOffsetRoll: UILabel!
    @IBOutlet weak var alignmentOffsetYaw: UILabel!

    @IBOutlet weak var storagePolicy: UILabel!

    // exposure indicator
    @IBOutlet weak var exposureIndicatorShutterSpeed: UILabel!
    @IBOutlet weak var exposureIndicatorIsoSensitivity: UILabel!
    @IBOutlet weak var exposureIndicatorLockRegion: UILabel!

    // exposure lock
    @IBOutlet weak var exposureLockMode: UILabel!

    // white balance lock
    @IBOutlet weak var whiteBalanceLockMode: UILabel!

    // media metadata
    @IBOutlet weak var metadataCopyright: UITextField!
    @IBOutlet weak var metadataCustomId: UITextField!
    @IBOutlet weak var metadataCustomTitle: UITextField!

    // recording
    @IBOutlet weak var recordingState: UILabel!
    @IBOutlet weak var recordingStartStopBtn: UIButton!

    // photo capture
    @IBOutlet weak var photoCaptureState: UILabel!
    @IBOutlet weak var photoCaptureStartStopBtn: UIButton!

    // photo progress indicator
    @IBOutlet weak var photoRemainingTime: UILabel!
    @IBOutlet weak var photoRemainingDistance: UILabel!

    // zoom
    @IBOutlet weak var zoomLevel: UILabel!
    @IBOutlet weak var zoomMaxLevel: UILabel!
    @IBOutlet weak var zoomMaxLossLessLevel: UILabel!
    @IBOutlet weak var zoomBt: UIButton!

    func setDeviceUid(_ uid: String) {
        droneUid = uid
    }

    // section in tableview
    private enum Section: Int {
        case modeConfig
        case photoConfig
        case recordingConfig
        case streamingConfig
        case exposureConfig
        case whiteBalanceConfig
        case stylesConfig
        case zoomConfig
        case configure
        case alignmentOffsetConfig
        case exposureIndicator
        case exposureLock
        case whiteBalanceLock
        case mediaMetadata
        case recording
        case photoCapture
        case photoProgressIndicator
        case zoom
    }

    func updateCamera(camera: Camera2) {
        self.updateConfigDisplay(config: camera.config)

        if self.exposureIndicator == nil {
            self.exposureIndicator
                = camera.getComponent(Camera2Components.exposureIndicator) { [weak self] exposure in
                    if let `self` = self {
                        self.updateExposureIndicatorDisplay(exposureIndicator: exposure)
                    }
            }
        }

        if self.exposureLock == nil {
            self.exposureLock
                = camera.getComponent(Camera2Components.exposureLock) { [weak self] exposure in
                    if let `self` = self {
                        self.updateExposureLockDisplay(exposureLock: exposure)
                    }
            }
        }

        if self.whiteBalanceLock == nil {
            self.whiteBalanceLock
                = camera.getComponent(Camera2Components.whiteBalanceLock) { [weak self] whiteBalance in
                    if let `self` = self {
                        self.updateWhiteBalanceLockDisplay(whiteBalanceLock: whiteBalance)
                    }
            }
        }

        if self.mediaMetadata == nil {
            self.mediaMetadata
                = camera.getComponent(Camera2Components.mediaMetadata) { [weak self] mediaMetadata in
                    if let `self` = self {
                        self.updateMediaMetadataDisplay(mediaMetadata: mediaMetadata)
                    }
            }
        }

        if self.recording == nil {
            self.recording
                = camera.getComponent(Camera2Components.recording) { [weak self] recording in
                    if let `self` = self {
                        self.updateRecordingDisplay(recording: recording)
                    }
            }
        }

        if self.photoCapture == nil {
            self.photoCapture
                = camera.getComponent(Camera2Components.photoCapture) { [weak self] photo in
                    if let `self` = self {
                        self.updatePhotoCaptureDisplay(photoCapture: photo)
                    }
            }
        }

        if self.photoProgressIndicator == nil {
            self.photoProgressIndicator
                = camera.getComponent(Camera2Components.photoProgressIndicator) { [weak self] photo in
                    if let `self` = self {
                        self.updatePhotoProgressIndicatorDisplay(photoProgressIndicator: photo)
                    }
            }
        }

        if self.zoom == nil {
            self.zoom = camera.getComponent(Camera2Components.zoom) { [weak self] zoom in
                if let `self` = self {
                    self.updateZoomDisplay(zoom: zoom)
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        updateExposureIndicatorDisplay(exposureIndicator: nil)
        updateExposureLockDisplay(exposureLock: nil)
        updateWhiteBalanceLockDisplay(whiteBalanceLock: nil)
        updateMediaMetadataDisplay(mediaMetadata: nil)
        updateRecordingDisplay(recording: nil)
        updatePhotoCaptureDisplay(photoCapture: nil)
        updatePhotoProgressIndicatorDisplay(photoProgressIndicator: nil)
        updateZoomDisplay(zoom: nil)
    }

    func updateConfigDisplay(config: Camera2Config) {
        // mode
        tableView.enable(section: Section.modeConfig.rawValue, on: !config.updating)
        cameraMode.text = config[Camera2Params.mode]?.value.description

        // photo
        tableView.enable(section: Section.photoConfig.rawValue, on: !config.updating)
        photoMode.text = config[Camera2Params.photoMode]?.value.description ?? "-"
        photoDynamicRange.text = config[Camera2Params.photoDynamicRange]?.value.description ?? "-"
        photoResolution.text = config[Camera2Params.photoResolution]?.value.description ?? "-"
        photoFormat.text = config[Camera2Params.photoFormat]?.value.description ?? "-"
        photoFileFormat.text = config[Camera2Params.photoFileFormat]?.value.description ?? "-"
        photoDigitalSignature.text = config[Camera2Params.photoDigitalSignature]?.value.description ?? "-"
        photoBracketing.text = config[Camera2Params.photoBracketing]?.value.description ?? "-"
        photoBurst.text = config[Camera2Params.photoBurst]?.value.description ?? "-"
        timelapseCaptureInterval.text = config[Camera2Params.photoTimelapseInterval].description
        gpslapseCaptureInterval.text = config[Camera2Params.photoGpslapseInterval].description
        photoStreamingMode.text = config[Camera2Params.photoStreamingMode]?.value.description ?? "-"

        // recording
        tableView.enable(section: Section.recordingConfig.rawValue, on: !config.updating)
        recordingMode.text = config[Camera2Params.videoRecordingMode]?.value.description ?? "-"
        recordingDynamicRange.text = config[Camera2Params.videoRecordingDynamicRange]?.value.description ?? "-"
        recordingCodec.text = config[Camera2Params.videoRecordingCodec]?.value.description ?? "-"
        recordingResolution.text = config[Camera2Params.videoRecordingResolution]?.value.description ?? "-"
        recordingFramerate.text = config[Camera2Params.videoRecordingFramerate]?.value.description ?? "-"
        recordingBitrate.text = config[Camera2Params.videoRecordingBitrate]?.value.description ?? "-"
        audioRecordingMode.text = config[Camera2Params.audioRecordingMode]?.value.description ?? "-"
        autoRecordMode.text = config[Camera2Params.autoRecordMode]?.value.description ?? "-"

        // exposure
        tableView.enable(section: Section.exposureConfig.rawValue, on: !config.updating)
        exposureMode.text = config[Camera2Params.exposureMode]?.value.description ?? "-"
        manualShutterSpeed.text = config[Camera2Params.shutterSpeed]?.value.description ?? "-"
        manualIso.text = config[Camera2Params.isoSensitivity]?.value.description ?? "-"
        maximumIso.text = config[Camera2Params.maximumIsoSensitivity]?.value.description ?? "-"
        evCompensation.text = config[Camera2Params.exposureCompensation]?.value.description ?? "-"
        autoExposureMeteringMode.text = config[Camera2Params.autoExposureMeteringMode]?.value.description ?? "-"

        // white balance
        tableView.enable(section: Section.whiteBalanceConfig.rawValue, on: !config.updating)
        whiteBalanceMode.text = config[Camera2Params.whiteBalanceMode]?.value.description ?? "-"
        whiteBalanceTemperature.text = config[Camera2Params.whiteBalanceTemperature]?.value.description ?? "-"

        // styles
        tableView.enable(section: Section.stylesConfig.rawValue, on: !config.updating)
        activeStyle.text = config[Camera2Params.imageStyle]?.value.description ?? "-"
        styleSaturation.text = config[Camera2Params.imageSaturation].description
        styleContrast.text = config[Camera2Params.imageContrast].description
        styleSharpness.text = config[Camera2Params.imageSharpness].description

        // alignement offset
        alignmentOffsetPitch.text = config[Camera2Params.alignmentOffsetPitch].description
        alignmentOffsetRoll.text = config[Camera2Params.alignmentOffsetRoll].description
        alignmentOffsetYaw.text = config[Camera2Params.alignmentOffsetYaw].description

        // zoom
        tableView.enable(section: Section.zoomConfig.rawValue, on: !config.updating)
        zoomMaxSpeed.text = config[Camera2Params.zoomMaxSpeed].description
        zoomVelocityControlMode.text = config[Camera2Params.zoomVelocityControlQualityMode]?.value.description ?? "-"

        // storage policy
        storagePolicy.text = config[Camera2Params.storagePolicy]?.value.description ?? "-"
    }

    func updateExposureIndicatorDisplay(exposureIndicator: Camera2ExposureIndicator?) {
        tableView.enable(section: Section.exposureIndicator.rawValue, on: exposureIndicator != nil)

        if let exposureIndicator = exposureIndicator {
            exposureIndicatorShutterSpeed.text = exposureIndicator.shutterSpeed.description
            exposureIndicatorIsoSensitivity.text = exposureIndicator.isoSensitivity.description
            if let lockRegion = exposureIndicator.lockRegion {
                exposureIndicatorLockRegion.text = String(format: "x:%.2f y:%.2f w:%.2f h:%.2f", lockRegion.centerX,
                                                          lockRegion.centerY, lockRegion.width, lockRegion.height)
            } else {
                exposureIndicatorLockRegion.text = "-"
            }
        } else {
            exposureIndicatorShutterSpeed.text = "-"
            exposureIndicatorIsoSensitivity.text = "-"
            exposureIndicatorLockRegion.text = "-"
        }
    }

    func updateExposureLockDisplay(exposureLock: Camera2ExposureLock?) {
        tableView.enable(section: Section.exposureLock.rawValue,
                         on: exposureLock != nil && !exposureLock!.updating)

        if let exposureLock = exposureLock {
            exposureLockMode.text = exposureLock.mode.description
        } else {
            exposureLockMode.text = "-"
        }
    }

    func updateWhiteBalanceLockDisplay(whiteBalanceLock: Camera2WhiteBalanceLock?) {
        tableView.enable(section: Section.whiteBalanceLock.rawValue,
                         on: whiteBalanceLock != nil && !whiteBalanceLock!.updating)

        whiteBalanceLockMode.text = whiteBalanceLock?.mode.description ?? "-"
    }

    func updateMediaMetadataDisplay(mediaMetadata: Camera2MediaMetadata?) {
        tableView.enable(section: Section.mediaMetadata.rawValue,
                         on: mediaMetadata != nil && !mediaMetadata!.updating)

        metadataCopyright.text = mediaMetadata?.copyright ?? ""
        metadataCustomId.text = mediaMetadata?.customId ?? ""
        metadataCustomTitle.text = mediaMetadata?.customTitle ?? ""
    }

    func updateRecordingDisplay(recording: Camera2Recording?) {
        tableView.enable(section: Section.recording.rawValue, on: recording != nil)

        if let recording = recording {
            recordingState.text = recording.state.description
            if recording.state.canStart {
                recordingStartStopBtn.isEnabled = true
                recordingStartStopBtn.setTitle("Start Recording", for: .normal)
            } else if recording.state.canStop {
                recordingStartStopBtn.isEnabled = true
                recordingStartStopBtn.setTitle("Stop Recording", for: .normal)
            } else {
                recordingStartStopBtn.isEnabled = false
            }
        } else {
            recordingState.text = "-"
            recordingStartStopBtn.isEnabled = false
            recordingStartStopBtn.setTitle("Not available", for: .normal)
        }
    }

    func updatePhotoCaptureDisplay(photoCapture: Camera2PhotoCapture?) {
        tableView.enable(section: Section.photoCapture.rawValue, on: photoCapture != nil)

        if let photoCapture = photoCapture {
            photoCaptureState.text = photoCapture.state.description
            if photoCapture.state.canStart {
                photoCaptureStartStopBtn.isEnabled = true
                photoCaptureStartStopBtn.setTitle("Start Photo Capture", for: .normal)
            } else if photoCapture.state.canStop {
                photoCaptureStartStopBtn.isEnabled = true
                photoCaptureStartStopBtn.setTitle("Stop Photo Capture", for: .normal)
            } else {
                photoCaptureStartStopBtn.isEnabled = false
            }
        } else {
            photoCaptureState.text = "-"
            photoCaptureStartStopBtn.isEnabled = false
            photoCaptureStartStopBtn.setTitle("Not available", for: .normal)
        }
    }

    func updatePhotoProgressIndicatorDisplay(photoProgressIndicator: Camera2PhotoProgressIndicator?) {
        tableView.enable(section: Section.photoProgressIndicator.rawValue, on: photoProgressIndicator != nil)

        if let remainingTime = photoProgressIndicator?.remainingTime {
            photoRemainingTime.text = "\(remainingTime)ms"
        } else {
            photoRemainingTime.text = "-"
        }
        if let remainingDistance = photoProgressIndicator?.remainingDistance {
            photoRemainingDistance.text = "\(remainingDistance)m"
        } else {
            photoRemainingDistance.text = "-"
        }
    }

    func updateZoomDisplay(zoom: Camera2Zoom?) {
        tableView.enable(section: Section.zoom.rawValue, on: zoom != nil)

        if let zoom = zoom {
            zoomBt.isEnabled = true
            zoomLevel.text = String(format: "%.2f", zoom.level)
            zoomMaxLevel.text = String(format: "%.2f", zoom.maxLevel)
            zoomMaxLossLessLevel.text = String(format: "%.2f", zoom.maxLossLessLevel)
        } else {
            zoomBt.isEnabled = false
            zoomLevel.text = "-"
            zoomMaxLevel.text = "-"
            zoomMaxLossLessLevel.text = "-"
        }
    }

    func setupChooseEnumViewController<T: CustomStringConvertible>(target: ChooseEnumViewController,
                                                                   editor: Camera2Editor,
                                                                   configParam: Camera2EditableParam<T>) {
        target.initialize(data: ChooseEnumViewController.Data(
            dataSource: [T](configParam.overallSupportedValues.sorted { $0.description < $1.description }),
            selectedValue: configParam.value?.description,
            itemDidSelect: { value in
                configParam.value = value as? T
                _ = editor.autoComplete().commit()
        }
        ))
    }

    func setupChooseDoubleParamViewController(target: ChooseDoubleParamViewController,
                                              editor: Camera2Editor,
                                              configParam: Camera2EditableDouble,
                                              title: String) {
        target.initialize(data: ChooseDoubleParamViewController.Data(
            value: configParam.overallSupportedValues?.clamp(configParam.value ?? 0) ?? 0,
            range: configParam.overallSupportedValues,
            title: title,
            valueChanged: { value in
                configParam.value = value
                _ = editor.autoComplete().commit()
        }
        ))
    }

    func prepare(camera: Camera2, for segue: UIStoryboardSegue, sender: Any?) {
        let cell = sender as? UITableViewCell
        if let reuseIdentifier = cell?.reuseIdentifier,
            let action = CellAction(reuseIdentifier) {

            switch action {
            case .enumValue(let value):
                // can force cast destination into ChooseEnumViewController
                let target = segue.destination as! ChooseEnumViewController
                let editor = camera.config.edit(fromScratch: false)
                switch value {
                case .cameraMode:
                    if let configParam = editor[Camera2Params.mode] {
                        setupChooseEnumViewController(target: target, editor: editor, configParam: configParam)
                    }
                case .photoMode:
                    if let configParam = editor[Camera2Params.photoMode] {
                        setupChooseEnumViewController(target: target, editor: editor, configParam: configParam)
                    }
                case .photoDynamicRange:
                    if let configParam = editor[Camera2Params.photoDynamicRange] {
                        setupChooseEnumViewController(target: target, editor: editor, configParam: configParam)
                    }
                case .photoResolution:
                    if let configParam = editor[Camera2Params.photoResolution] {
                        setupChooseEnumViewController(target: target, editor: editor, configParam: configParam)
                    }
                case .photoFormat:
                    if let configParam = editor[Camera2Params.photoFormat] {
                        setupChooseEnumViewController(target: target, editor: editor, configParam: configParam)
                    }
                case .photoFileFormat:
                    if let configParam = editor[Camera2Params.photoFileFormat] {
                        setupChooseEnumViewController(target: target, editor: editor, configParam: configParam)
                    }
                case .photoDigitalSignature:
                    if let configParam = editor[Camera2Params.photoDigitalSignature] {
                        setupChooseEnumViewController(target: target, editor: editor, configParam: configParam)
                    }
                case .photoBracketing:
                    if let configParam = editor[Camera2Params.photoBracketing] {
                        setupChooseEnumViewController(target: target, editor: editor, configParam: configParam)
                    }
                case .photoBurst:
                    if let configParam = editor[Camera2Params.photoBurst] {
                        setupChooseEnumViewController(target: target, editor: editor, configParam: configParam)
                    }
                case .photoStreamingMode:
                    if let configParam = editor[Camera2Params.photoStreamingMode] {
                        setupChooseEnumViewController(target: target, editor: editor, configParam: configParam)
                    }
                case .videoRecordingMode:
                    if let configParam = editor[Camera2Params.videoRecordingMode] {
                        setupChooseEnumViewController(target: target, editor: editor, configParam: configParam)
                    }
                case .videoRecordingDynamicRange:
                    if let configParam = editor[Camera2Params.videoRecordingDynamicRange] {
                        setupChooseEnumViewController(target: target, editor: editor, configParam: configParam)
                    }
                case .videoRecordingCodec:
                    if let configParam = editor[Camera2Params.videoRecordingCodec] {
                        setupChooseEnumViewController(target: target, editor: editor, configParam: configParam)
                    }
                case .videoRecordingResolution:
                    if let configParam = editor[Camera2Params.videoRecordingResolution] {
                        setupChooseEnumViewController(target: target, editor: editor, configParam: configParam)
                    }
                case .videoRecordingFramerate:
                    if let configParam = editor[Camera2Params.videoRecordingFramerate] {
                        setupChooseEnumViewController(target: target, editor: editor, configParam: configParam)
                    }
                case .videoRecordingBitrate:
                    if let configParam = editor[Camera2Params.videoRecordingBitrate] {
                        setupChooseEnumViewController(target: target, editor: editor, configParam: configParam)
                    }
                case .audioRecordingMode:
                    if let configParam = editor[Camera2Params.audioRecordingMode] {
                        setupChooseEnumViewController(target: target, editor: editor, configParam: configParam)
                    }
                case .autoRecordMode:
                    if let configParam = editor[Camera2Params.autoRecordMode] {
                        setupChooseEnumViewController(target: target, editor: editor, configParam: configParam)
                    }
                case .exposureMode:
                    if let configParam = editor[Camera2Params.exposureMode] {
                        setupChooseEnumViewController(target: target, editor: editor, configParam: configParam)
                    }
                case .maximumIsoSensitivity:
                    if let configParam = editor[Camera2Params.maximumIsoSensitivity] {
                        setupChooseEnumViewController(target: target, editor: editor, configParam: configParam)
                    }
                case .isoSensitivity:
                    if let configParam = editor[Camera2Params.isoSensitivity] {
                        setupChooseEnumViewController(target: target, editor: editor, configParam: configParam)
                    }
                case .shutterSpeed:
                    if let configParam = editor[Camera2Params.shutterSpeed] {
                        setupChooseEnumViewController(target: target, editor: editor, configParam: configParam)
                    }
                case .exposureCompensation:
                    if let configParam = editor[Camera2Params.exposureCompensation] {
                        setupChooseEnumViewController(target: target, editor: editor, configParam: configParam)
                    }
                case .autoExposureMeteringMode:
                    if let configParam = editor[Camera2Params.autoExposureMeteringMode] {
                        setupChooseEnumViewController(target: target, editor: editor, configParam: configParam)
                    }
                case .whiteBalanceMode:
                    if let configParam = editor[Camera2Params.whiteBalanceMode] {
                        setupChooseEnumViewController(target: target, editor: editor, configParam: configParam)
                    }
                case .whiteBalanceTemperature:
                    if let configParam = editor[Camera2Params.whiteBalanceTemperature] {
                        setupChooseEnumViewController(target: target, editor: editor, configParam: configParam)
                    }
                case .imageStyle:
                    if let configParam = editor[Camera2Params.imageStyle] {
                        setupChooseEnumViewController(target: target, editor: editor, configParam: configParam)
                    }
                case .zoomVelocityControlQualityMode:
                    if let configParam = editor[Camera2Params.zoomVelocityControlQualityMode] {
                        setupChooseEnumViewController(target: target, editor: editor, configParam: configParam)
                    }
                case .storagePolicy:
                    if let configParam = editor[Camera2Params.storagePolicy] {
                        setupChooseEnumViewController(target: target, editor: editor, configParam: configParam)
                    }
                }
            case .doubleValue(let value):
                // can force cast destination into ChooseDoubleParamViewController
                let target = segue.destination as! ChooseDoubleParamViewController
                let editor = camera.config.edit(fromScratch: false)
                switch value {
                case .photoTimelapseInterval:
                    if let configParam = editor[Camera2Params.photoTimelapseInterval] {
                        setupChooseDoubleParamViewController(target: target, editor: editor, configParam: configParam,
                                                             title: "Photo timelapse interval")
                    }
                case .photoGpslapseInterval:
                    if let configParam = editor[Camera2Params.photoGpslapseInterval] {
                        setupChooseDoubleParamViewController(target: target, editor: editor, configParam: configParam,
                                                             title: "Photo gpslapse interval")
                    }
                case .imageContrast:
                    if let configParam = editor[Camera2Params.imageContrast] {
                        setupChooseDoubleParamViewController(target: target, editor: editor, configParam: configParam,
                                                             title: "Image constrast")
                    }
                case .imageSaturation:
                    if let configParam = editor[Camera2Params.imageSaturation] {
                        setupChooseDoubleParamViewController(target: target, editor: editor, configParam: configParam,
                                                             title: "Image saturation")
                    }
                case .imageSharpness:
                    if let configParam = editor[Camera2Params.imageSharpness] {
                        setupChooseDoubleParamViewController(target: target, editor: editor, configParam: configParam,
                                                             title: "Image sharpness")
                    }
                case .zoomMaxSpeed:
                    if let configParam = editor[Camera2Params.zoomMaxSpeed] {
                        setupChooseDoubleParamViewController(target: target, editor: editor, configParam: configParam,
                                                             title: "Zoom max speed")
                    }
                case .alignmentOffsetPitch:
                    if let configParam = editor[Camera2Params.alignmentOffsetPitch] {
                        setupChooseDoubleParamViewController(target: target, editor: editor, configParam: configParam,
                                                             title: "Alignment offset pitch")
                    }
                case .alignmentOffsetRoll:
                    if let configParam = editor[Camera2Params.alignmentOffsetRoll] {
                        setupChooseDoubleParamViewController(target: target, editor: editor, configParam: configParam,
                                                             title: "Alignment offset roll")
                    }
                case .alignmentOffsetYaw:
                    if let configParam = editor[Camera2Params.alignmentOffsetYaw] {
                        setupChooseDoubleParamViewController(target: target, editor: editor, configParam: configParam,
                                                             title: "Alignment offset yaw")
                    }
                }
            case .whiteBalanceLockMode:
                // can force cast destination into ChooseEnumViewController
                let target = segue.destination as! ChooseEnumViewController
                if let whiteBalanceLock = whiteBalanceLock?.value {
                    target.initialize(data: ChooseEnumViewController.Data(
                        dataSource: [Camera2WhiteBalanceLockMode](whiteBalanceLock.supportedModes),
                        selectedValue: whiteBalanceLock.mode.description,
                        itemDidSelect: { [unowned self] value in
                            self.whiteBalanceLock?.value?.mode = value as! Camera2WhiteBalanceLockMode
                        }
                    ))
                }
            case .exposureLock:
                (segue.destination as! Camera2ExposureLockViewController).setDeviceUid(droneUid!)
            }
        } else if segue.identifier == "controlZoom" {
            (segue.destination as! Camera2ZoomViewController).setDeviceUid(droneUid!)
        } else if segue.identifier == "configure" {
            (segue.destination as! Camera2EditorViewController).setDeviceUid(droneUid!)
        }
    }

    @IBAction func startStopRecording() {
        if let recording = recording?.value {
            if recording.state.canStart {
                recording.start()
            } else if recording.state.canStop {
                recording.stop()
            }
        }
    }

    @IBAction func startStopPhotoCapture() {
        if let photoCapture = photoCapture?.value {
            if photoCapture.state.canStart {
                photoCapture.start()
            } else if photoCapture.state.canStop {
                photoCapture.stop()
            }
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        if let reuseIdentifier = cell?.reuseIdentifier, let action = CellAction(reuseIdentifier) {
            let segueIdentifier: String
            switch action {
            case .enumValue:
                segueIdentifier = "selectEnumValue"
            case .doubleValue:
                segueIdentifier = "selectNumValue"
            case .exposureLock:
                segueIdentifier = "exposureLock"
            case .whiteBalanceLockMode:
                segueIdentifier = "selectEnumValue"
            }
            performSegue(withIdentifier: segueIdentifier, sender: cell)
        } else {
            tableView.deselectRow(at: indexPath, animated: false)
        }
    }

    // Parameters with enum value
    private enum EnumValue {
        case cameraMode
        case photoMode
        case photoDynamicRange
        case photoResolution
        case photoFormat
        case photoFileFormat
        case photoDigitalSignature
        case photoBracketing
        case photoBurst
        case photoStreamingMode
        case videoRecordingMode
        case videoRecordingDynamicRange
        case videoRecordingCodec
        case videoRecordingResolution
        case videoRecordingFramerate
        case videoRecordingBitrate
        case audioRecordingMode
        case autoRecordMode
        case exposureMode
        case maximumIsoSensitivity
        case isoSensitivity
        case shutterSpeed
        case exposureCompensation
        case autoExposureMeteringMode
        case whiteBalanceMode
        case whiteBalanceTemperature
        case imageStyle
        case zoomVelocityControlQualityMode
        case storagePolicy
    }

    // Parameters with Double value
    private enum DoubleValue {
        case photoTimelapseInterval
        case photoGpslapseInterval
        case imageContrast
        case imageSaturation
        case imageSharpness
        case zoomMaxSpeed
        case alignmentOffsetPitch
        case alignmentOffsetRoll
        case alignmentOffsetYaw
    }

    /// Action triggered by the cell selection.
    private enum CellAction {
        /// "selectEnumValue" segue will be triggered
        case enumValue(EnumValue)
        /// "selectDoubleValue" segue will be triggered
        case doubleValue(DoubleValue)
        /// "exposureLock" segue will be triggered
        case exposureLock
        /// "selectEnumValue" segue will be triggered
        case whiteBalanceLockMode

        init?(_ strVal: String) {
            switch strVal {
            case "cameraMode":
                self = .enumValue(.cameraMode)
            case "photoMode":
                self = .enumValue(.photoMode)
            case "photoDynamicRange":
                self = .enumValue(.photoDynamicRange)
            case "photoResolution":
                self = .enumValue(.photoResolution)
            case "photoFormat":
                self = .enumValue(.photoFormat)
            case "photoFileFormat":
                self = .enumValue(.photoFileFormat)
            case "photoDigitalSignature":
                self = .enumValue(.photoDigitalSignature)
            case "photoBracketing":
                self = .enumValue(.photoBracketing)
            case "photoBurst":
                self = .enumValue(.photoBurst)
            case "photoStreamingMode":
                self = .enumValue(.photoStreamingMode)
            case "videoRecordingMode":
                self = .enumValue(.videoRecordingMode)
            case "videoRecordingDynamicRange":
                self = .enumValue(.videoRecordingDynamicRange)
            case "videoRecordingCodec":
                self = .enumValue(.videoRecordingCodec)
            case "videoRecordingResolution":
                self = .enumValue(.videoRecordingResolution)
            case "videoRecordingFramerate":
                self = .enumValue(.videoRecordingFramerate)
            case "videoRecordingBitrate":
                self = .enumValue(.videoRecordingBitrate)
            case "audioRecordingMode":
                self = .enumValue(.audioRecordingMode)
            case "autoRecordMode":
                self = .enumValue(.autoRecordMode)
            case "exposureMode":
                self = .enumValue(.exposureMode)
            case "maximumIsoSensitivity":
                self = .enumValue(.maximumIsoSensitivity)
            case "isoSensitivity":
                self = .enumValue(.isoSensitivity)
            case "shutterSpeed":
                self = .enumValue(.shutterSpeed)
            case "exposureCompensation":
                self = .enumValue(.exposureCompensation)
            case "autoExposureMeteringMode":
                self = .enumValue(.autoExposureMeteringMode)
            case "whiteBalanceMode":
                self = .enumValue(.whiteBalanceMode)
            case "whiteBalanceTemperature":
                self = .enumValue(.whiteBalanceTemperature)
            case "imageStyle":
                self = .enumValue(.imageStyle)
            case "zoomVelocityControlQualityMode":
                self = .enumValue(.zoomVelocityControlQualityMode)
            case "storagePolicy":
                self = .enumValue(.storagePolicy)
            case "photoTimelapseInterval":
                self = .doubleValue(.photoTimelapseInterval)
            case "photoGpslapseInterval":
                self = .doubleValue(.photoGpslapseInterval)
            case "imageContrast":
                self = .doubleValue(.imageContrast)
            case "imageSaturation":
                self = .doubleValue(.imageSaturation)
            case "imageSharpness":
                self = .doubleValue(.imageSharpness)
            case "zoomMaxSpeed":
                self = .doubleValue(.zoomMaxSpeed)
            case "alignmentOffsetPitch":
                self = .doubleValue(.alignmentOffsetPitch)
            case "alignmentOffsetRoll":
                self = .doubleValue(.alignmentOffsetRoll)
            case "alignmentOffsetYaw":
                self = .doubleValue(.alignmentOffsetYaw)
            case "exposureLockMode":
                self = .exposureLock
            case "whiteBalanceLockMode":
                self = .whiteBalanceLockMode
            default:
                return nil
            }
        }
    }
}

extension Camera2ViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField === metadataCopyright {
            if let copyright = textField.text {
                mediaMetadata?.value?.copyright = copyright
            }
        } else if textField === metadataCustomId {
            if let customId = textField.text {
                mediaMetadata?.value?.customId = customId
            }
        } else if textField === metadataCustomTitle {
            if let customTitle = textField.text {
                mediaMetadata?.value?.customTitle = customTitle
            }
        }
        return true
    }
}

private extension UITableView {
    func enable(section: Int, on: Bool) {
        for cellIndex in 0..<numberOfRows(inSection: section) {
            cellForRow(at: IndexPath(item: cellIndex, section: section))?.enable(on: on)
        }
    }
}

private extension UITableViewCell {
    func enable(on: Bool) {
        for view in contentView.subviews {
            view.isUserInteractionEnabled = on
            view.alpha = on ? 1 : 0.5
        }
    }
}

extension Optional where Wrapped == Camera2Double {
    var description: String {
        switch self {
        case .none:
            return "-"
        case .some(let param):
            return String(format: "%.2f", param.value)
        }
    }
}
