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

class Camera2EditorViewController: UITableViewController, DeviceViewController {

    let groundSdk = GroundSdk()
    var droneUid: String?
    var editor: Camera2Editor?

    @IBOutlet weak var complete: UILabel!

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
    }

    override func viewDidAppear(_ animated: Bool) {
        if let editor = editor {
            updateEditorDisplay(editor: editor)
        }
    }

    func updateEditorDisplay(editor: Camera2Editor) {
        complete.text = editor.complete.description

        // mode
        cameraMode.text = editor[Camera2Params.mode]?.value?.description ?? "-"

        // photo
        photoMode.text = editor[Camera2Params.photoMode]?.value?.description ?? "-"
        photoDynamicRange.text = editor[Camera2Params.photoDynamicRange]?.value?.description ?? "-"
        photoResolution.text = editor[Camera2Params.photoResolution]?.value?.description ?? "-"
        photoFormat.text = editor[Camera2Params.photoFormat]?.value?.description ?? "-"
        photoFileFormat.text = editor[Camera2Params.photoFileFormat]?.value?.description ?? "-"
        photoDigitalSignature.text = editor[Camera2Params.photoDigitalSignature]?.value?.description ?? "-"
        photoBracketing.text = editor[Camera2Params.photoBracketing]?.value?.description ?? "-"
        photoBurst.text = editor[Camera2Params.photoBurst]?.value?.description ?? "-"
        timelapseCaptureInterval.text = editor[Camera2Params.photoTimelapseInterval].description
        gpslapseCaptureInterval.text = editor[Camera2Params.photoGpslapseInterval].description
        photoStreamingMode.text = editor[Camera2Params.photoStreamingMode]?.value?.description ?? "-"

        // recording
        recordingMode.text = editor[Camera2Params.videoRecordingMode]?.value?.description ?? "-"
        recordingDynamicRange.text = editor[Camera2Params.videoRecordingDynamicRange]?.value?.description ?? "-"
        recordingCodec.text = editor[Camera2Params.videoRecordingCodec]?.value?.description ?? "-"
        recordingResolution.text = editor[Camera2Params.videoRecordingResolution]?.value?.description ?? "-"
        recordingFramerate.text = editor[Camera2Params.videoRecordingFramerate]?.value?.description ?? "-"
        recordingBitrate.text = editor[Camera2Params.videoRecordingBitrate]?.value?.description ?? "-"
        audioRecordingMode.text = editor[Camera2Params.audioRecordingMode]?.value?.description ?? "-"
        autoRecordMode.text = editor[Camera2Params.autoRecordMode]?.value?.description ?? "-"

        // exposure
        exposureMode.text = editor[Camera2Params.exposureMode]?.value?.description ?? "-"
        manualShutterSpeed.text = editor[Camera2Params.shutterSpeed]?.value?.description ?? "-"
        manualIso.text = editor[Camera2Params.isoSensitivity]?.value?.description ?? "-"
        maximumIso.text = editor[Camera2Params.maximumIsoSensitivity]?.value?.description ?? "-"
        evCompensation.text = editor[Camera2Params.exposureCompensation]?.value?.description ?? "-"
        autoExposureMeteringMode.text = editor[Camera2Params.autoExposureMeteringMode]?.value?.description ?? "-"

        // white balance
        whiteBalanceMode.text = editor[Camera2Params.whiteBalanceMode]?.value?.description ?? "-"
        whiteBalanceTemperature.text = editor[Camera2Params.whiteBalanceTemperature]?.value?.description ?? "-"

        // styles
        activeStyle.text = editor[Camera2Params.imageStyle]?.value?.description ?? "-"
        styleSaturation.text = editor[Camera2Params.imageSaturation].description
        styleContrast.text = editor[Camera2Params.imageContrast].description
        styleSharpness.text = editor[Camera2Params.imageSharpness].description

        // alignement offset
        alignmentOffsetPitch.text = editor[Camera2Params.alignmentOffsetPitch].description
        alignmentOffsetRoll.text = editor[Camera2Params.alignmentOffsetRoll].description
        alignmentOffsetYaw.text = editor[Camera2Params.alignmentOffsetYaw].description

        // zoom
        zoomMaxSpeed.text = editor[Camera2Params.zoomMaxSpeed].description
        zoomVelocityControlMode.text = editor[Camera2Params.zoomVelocityControlQualityMode]?.value?.description ?? "-"

        // storage policy
        storagePolicy.text = editor[Camera2Params.storagePolicy]?.value?.description ?? "-"
    }

    func setupChooseEnumViewController<T: CustomStringConvertible>(target: ChooseEnumViewController,
                                                                   configParam: Camera2EditableParam<T>) {
        target.initialize(data: ChooseEnumViewController.Data(
            dataSource: [T](configParam.currentSupportedValues.sorted { $0.description < $1.description }),
            selectedValue: configParam.value?.description,
            itemDidSelect: { [weak self] value in
                configParam.value = value as? T
                if let editor = self?.editor {
                    self?.updateEditorDisplay(editor: editor)
                }
            }
        ))
    }

    func setupChooseDoubleParamViewController(target: ChooseDoubleParamViewController,
                                              configParam: Camera2EditableDouble,
                                              title: String) {
        target.initialize(data: ChooseDoubleParamViewController.Data(
            value: configParam.overallSupportedValues?.clamp(configParam.value ?? 0) ?? 0,
            range: configParam.currentSupportedValues,
            title: title,
            valueChanged: { [weak self] value in
                configParam.value = value
                if let editor = self?.editor {
                    self?.updateEditorDisplay(editor: editor)
                }
            }
        ))
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let cell = sender as? UITableViewCell
        if let reuseIdentifier = cell?.reuseIdentifier,
            let action = CellAction(reuseIdentifier),
            let editor = editor {

            switch action {
            case .enumValue(let value):
                // can force cast destination into ChooseEnumViewController
                let target = segue.destination as! ChooseEnumViewController
                switch value {
                case .cameraMode:
                    if let configParam = editor[Camera2Params.mode] {
                        setupChooseEnumViewController(target: target, configParam: configParam)
                    }
                case .photoMode:
                    if let configParam = editor[Camera2Params.photoMode] {
                        setupChooseEnumViewController(target: target, configParam: configParam)
                    }
                case .photoDynamicRange:
                    if let configParam = editor[Camera2Params.photoDynamicRange] {
                        setupChooseEnumViewController(target: target, configParam: configParam)
                    }
                case .photoResolution:
                    if let configParam = editor[Camera2Params.photoResolution] {
                        setupChooseEnumViewController(target: target, configParam: configParam)
                    }
                case .photoFormat:
                    if let configParam = editor[Camera2Params.photoFormat] {
                        setupChooseEnumViewController(target: target, configParam: configParam)
                    }
                case .photoFileFormat:
                    if let configParam = editor[Camera2Params.photoFileFormat] {
                        setupChooseEnumViewController(target: target, configParam: configParam)
                    }
                case .photoDigitalSignature:
                    if let configParam = editor[Camera2Params.photoDigitalSignature] {
                        setupChooseEnumViewController(target: target, configParam: configParam)
                    }
                case .photoBracketing:
                    if let configParam = editor[Camera2Params.photoBracketing] {
                        setupChooseEnumViewController(target: target, configParam: configParam)
                    }
                case .photoBurst:
                    if let configParam = editor[Camera2Params.photoBurst] {
                        setupChooseEnumViewController(target: target, configParam: configParam)
                    }
                case .photoStreamingMode:
                    if let configParam = editor[Camera2Params.photoStreamingMode] {
                        setupChooseEnumViewController(target: target, configParam: configParam)
                    }
                case .videoRecordingMode:
                    if let configParam = editor[Camera2Params.videoRecordingMode] {
                        setupChooseEnumViewController(target: target, configParam: configParam)
                    }
                case .videoRecordingDynamicRange:
                    if let configParam = editor[Camera2Params.videoRecordingDynamicRange] {
                        setupChooseEnumViewController(target: target, configParam: configParam)
                    }
                case .videoRecordingCodec:
                    if let configParam = editor[Camera2Params.videoRecordingCodec] {
                        setupChooseEnumViewController(target: target, configParam: configParam)
                    }
                case .videoRecordingResolution:
                    if let configParam = editor[Camera2Params.videoRecordingResolution] {
                        setupChooseEnumViewController(target: target, configParam: configParam)
                    }
                case .videoRecordingFramerate:
                    if let configParam = editor[Camera2Params.videoRecordingFramerate] {
                        setupChooseEnumViewController(target: target, configParam: configParam)
                    }
                case .videoRecordingBitrate:
                    if let configParam = editor[Camera2Params.videoRecordingBitrate] {
                        setupChooseEnumViewController(target: target, configParam: configParam)
                    }
                case .audioRecordingMode:
                    if let configParam = editor[Camera2Params.audioRecordingMode] {
                        setupChooseEnumViewController(target: target, configParam: configParam)
                    }
                case .autoRecordMode:
                    if let configParam = editor[Camera2Params.autoRecordMode] {
                        setupChooseEnumViewController(target: target, configParam: configParam)
                    }
                case .exposureMode:
                    if let configParam = editor[Camera2Params.exposureMode] {
                        setupChooseEnumViewController(target: target, configParam: configParam)
                    }
                case .maximumIsoSensitivity:
                    if let configParam = editor[Camera2Params.maximumIsoSensitivity] {
                        setupChooseEnumViewController(target: target, configParam: configParam)
                    }
                case .isoSensitivity:
                    if let configParam = editor[Camera2Params.isoSensitivity] {
                        setupChooseEnumViewController(target: target, configParam: configParam)
                    }
                case .shutterSpeed:
                    if let configParam = editor[Camera2Params.shutterSpeed] {
                        setupChooseEnumViewController(target: target, configParam: configParam)
                    }
                case .exposureCompensation:
                    if let configParam = editor[Camera2Params.exposureCompensation] {
                        setupChooseEnumViewController(target: target, configParam: configParam)
                    }
                case .whiteBalanceMode:
                    if let configParam = editor[Camera2Params.whiteBalanceMode] {
                        setupChooseEnumViewController(target: target, configParam: configParam)
                    }
                case .whiteBalanceTemperature:
                    if let configParam = editor[Camera2Params.whiteBalanceTemperature] {
                        setupChooseEnumViewController(target: target, configParam: configParam)
                    }
                case .imageStyle:
                    if let configParam = editor[Camera2Params.imageStyle] {
                        setupChooseEnumViewController(target: target, configParam: configParam)
                    }
                case .zoomVelocityControlQualityMode:
                    if let configParam = editor[Camera2Params.zoomVelocityControlQualityMode] {
                        setupChooseEnumViewController(target: target, configParam: configParam)
                    }
                case .autoExposureMeteringMode:
                    if let configParam = editor[Camera2Params.autoExposureMeteringMode] {
                        setupChooseEnumViewController(target: target, configParam: configParam)
                    }
                case .storagePolicy:
                    if let configParam = editor[Camera2Params.storagePolicy] {
                        setupChooseEnumViewController(target: target, configParam: configParam)
                    }
                }
            case .doubleValue(let value):
                // can force cast destination into ChooseDoubleParamViewController
                let target = segue.destination as! ChooseDoubleParamViewController
                switch value {
                case .photoTimelapseInterval:
                    if let configParam = editor[Camera2Params.photoTimelapseInterval] {
                        setupChooseDoubleParamViewController(target: target, configParam: configParam,
                                                             title: "Photo timelapse interval")
                    }
                case .photoGpslapseInterval:
                    if let configParam = editor[Camera2Params.photoGpslapseInterval] {
                        setupChooseDoubleParamViewController(target: target, configParam: configParam,
                                                             title: "Photo gpslapse interval")
                    }
                case .imageContrast:
                    if let configParam = editor[Camera2Params.imageContrast] {
                        setupChooseDoubleParamViewController(target: target, configParam: configParam,
                                                             title: "Image constrast")
                    }
                case .imageSaturation:
                    if let configParam = editor[Camera2Params.imageSaturation] {
                        setupChooseDoubleParamViewController(target: target, configParam: configParam,
                                                             title: "Image saturation")
                    }
                case .imageSharpness:
                    if let configParam = editor[Camera2Params.imageSharpness] {
                        setupChooseDoubleParamViewController(target: target, configParam: configParam,
                                                             title: "Image sharpness")
                    }
                case .zoomMaxSpeed:
                    if let configParam = editor[Camera2Params.zoomMaxSpeed] {
                        setupChooseDoubleParamViewController(target: target, configParam: configParam,
                                                             title: "Zoom max speed")
                    }
                case .alignmentOffsetPitch:
                    if let configParam = editor[Camera2Params.alignmentOffsetPitch] {
                        setupChooseDoubleParamViewController(target: target, configParam: configParam,
                                                             title: "Alignment offset pitch")
                    }
                case .alignmentOffsetRoll:
                    if let configParam = editor[Camera2Params.alignmentOffsetRoll] {
                        setupChooseDoubleParamViewController(target: target, configParam: configParam,
                                                             title: "Alignment offset roll")
                    }
                case .alignmentOffsetYaw:
                    if let configParam = editor[Camera2Params.alignmentOffsetYaw] {
                        setupChooseDoubleParamViewController(target: target, configParam: configParam,
                                                             title: "Alignment offset yaw")
                    }
                }
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
            }
            performSegue(withIdentifier: segueIdentifier, sender: cell)
        } else {
            tableView.deselectRow(at: indexPath, animated: false)
        }
    }

    @IBAction func clear() {
        if let editor = editor {
            editor.clear()
            updateEditorDisplay(editor: editor)
        }
    }

    @IBAction func autoComplete() {
        if let editor = editor {
            editor.autoComplete()
            updateEditorDisplay(editor: editor)
        }
    }

    @IBAction func commit() {
        if let editor = editor {
            _ = editor.commit()
            updateEditorDisplay(editor: editor)
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
        case whiteBalanceMode
        case whiteBalanceTemperature
        case imageStyle
        case zoomVelocityControlQualityMode
        case autoExposureMeteringMode
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
            case "whiteBalanceMode":
                self = .enumValue(.whiteBalanceMode)
            case "whiteBalanceTemperature":
                self = .enumValue(.whiteBalanceTemperature)
            case "imageStyle":
                self = .enumValue(.imageStyle)
            case "zoomVelocityControlQualityMode":
                self = .enumValue(.zoomVelocityControlQualityMode)
            case "autoExposureMeteringMode":
                self = .enumValue(.autoExposureMeteringMode)
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
            default:
                return nil
            }
        }
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

extension Optional where Wrapped == Camera2EditableDouble {
    var description: String {
        switch self {
        case .none:
            return "-"
        case .some(let param):
            if let value = param.value {
                return String(format: "%.2f", value)
            } else {
                return "-"
            }
        }
    }
}
