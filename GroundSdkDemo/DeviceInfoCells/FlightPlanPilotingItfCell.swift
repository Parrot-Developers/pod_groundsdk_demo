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

import UIKit
import GroundSdk

class FlightPlanPilotingItfCell: PilotingItfProviderContentCell {

    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var unavailabilityReasonsLabel: UILabel!
    @IBOutlet weak var latestActivationErrorLabel: UILabel!
    @IBOutlet weak var latestUploadStateLabel: UILabel!
    @IBOutlet weak var flightPlanFileIsKnownLabel: UILabel!
    @IBOutlet weak var isPausedLabel: UILabel!
    @IBOutlet weak var latestMissionItemExecutedLabel: UILabel!
    @IBOutlet weak var latestMissionItemSkippedLabel: UILabel!
    @IBOutlet weak var flightPlanIdLabel: UILabel!
    @IBOutlet weak var recoveryInfoLabel: UILabel!
    @IBOutlet weak var activationBt: UIButton!
    @IBOutlet weak var restartBt: UIButton!
    @IBOutlet weak var activationAtItemBt: UIButton!
    @IBOutlet weak var restartAtItemBt: UIButton!
    @IBOutlet weak var activationAtItemV2Bt: UIButton!
    @IBOutlet weak var restartAtItemV2Bt: UIButton!
    @IBOutlet weak var interpreterType: UISegmentedControl!
    @IBOutlet weak var disconnectionPolicyType: UISegmentedControl!
    @IBOutlet weak var clearRecoveryInfoBt: UIButton!
    @IBOutlet weak var stopBt: UIButton!
    @IBOutlet weak var cleanBeforeRecoveryBt: UIButton!

    var viewController: UIViewController?

    private var pilotingItf: Ref<FlightPlanPilotingItf>?

    override func set(pilotingItfProvider provider: PilotingItfProvider) {
        super.set(pilotingItfProvider: provider)
        pilotingItf = provider.getPilotingItf(PilotingItfs.flightPlan) { [weak self] pilotingItf in
            guard let self = self, let pilotingItf = pilotingItf else {
                self?.hide()
                return
            }
            self.show()
            self.stateLabel.text = "\(pilotingItf.state)"
            self.unavailabilityReasonsLabel.text = pilotingItf.unavailabilityReasons.map { $0.description }
            .joined(separator: ", ")
            self.latestActivationErrorLabel.text = pilotingItf.latestActivationError.description
            self.latestUploadStateLabel.text = pilotingItf.latestUploadState.description
            self.flightPlanFileIsKnownLabel.text = pilotingItf.flightPlanFileIsKnown ? "true" : "false"
            self.isPausedLabel.text = pilotingItf.isPaused ? "true" : "false"
            self.latestMissionItemExecutedLabel.text = pilotingItf.latestMissionItemExecuted?.description ?? "-"
            self.latestMissionItemSkippedLabel.text = pilotingItf.latestMissionItemSkipped?.description ?? "-"
            self.flightPlanIdLabel.text = pilotingItf.flightPlanId?.description ?? "-"
            self.activationAtItemV2Bt.titleLabel?.numberOfLines = 2
            self.restartAtItemV2Bt.titleLabel?.numberOfLines = 2
            self.activationAtItemV2Bt.titleLabel?.textAlignment = .center
            self.restartAtItemV2Bt.titleLabel?.textAlignment = .center

            if let recoveryInfo = pilotingItf.recoveryInfo {
                self.recoveryInfoLabel.text = "ID: \(recoveryInfo.id)"
                + " customId: \(recoveryInfo.customId)"
                + " item: \(recoveryInfo.latestMissionItemExecuted)"
                + " time: \(recoveryInfo.runningTime)s"
                + " resourceId: \(recoveryInfo.resourceId)"
            } else {
                self.recoveryInfoLabel.text = "-"
            }

            switch pilotingItf.state {
            case .active:
                self.activationBt.setTitle("Deactivate", for: .normal)
                self.activationBt.isEnabled = true
                self.activationAtItemBt.isEnabled = false
                self.activationAtItemV2Bt.isEnabled = false
                self.cleanBeforeRecoveryBt.isEnabled = false
            case .idle:
                self.activationBt.setTitle("Activate", for: .normal)
                self.activationBt.isEnabled = true
                self.activationAtItemBt.isEnabled = pilotingItf.activateAtMissionItemSupported
                self.activationAtItemV2Bt.isEnabled = pilotingItf.activateAtMissionItemV2Supported
                self.cleanBeforeRecoveryBt.isEnabled = true
            case .unavailable:
                self.activationBt.isEnabled = false
                self.activationAtItemBt.isEnabled = false
                self.activationAtItemV2Bt.isEnabled = false
                self.cleanBeforeRecoveryBt.isEnabled = true
            }

            if pilotingItf.state != .unavailable && pilotingItf.isPaused {
                self.restartBt.isEnabled = true
                self.restartAtItemBt.isEnabled = pilotingItf.activateAtMissionItemSupported
                self.restartAtItemV2Bt.isEnabled = pilotingItf.activateAtMissionItemV2Supported
            } else {
                self.restartBt.isEnabled = false
                self.restartAtItemBt.isEnabled = false
                self.restartAtItemV2Bt.isEnabled = false
            }

            self.disconnectionPolicyType.isEnabled = pilotingItf.activateAtMissionItemV2Supported
            self.clearRecoveryInfoBt.isEnabled = pilotingItf.recoveryInfo != nil
            self.stopBt.isEnabled = pilotingItf.state == .active || pilotingItf.isPaused
        }
    }

    @IBAction func uploadPushed(_ sender: Any) {

        let fileManager = FileManager.default
        let documentPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let flightPlanFolderPath = documentPath.appendingPathComponent("flightPlans")

        // create flightPlan directory if needed
        try? fileManager.createDirectory(at: flightPlanFolderPath, withIntermediateDirectories: false, attributes: nil)

        let alert = UIAlertController(title: "Flight plan file", message: "Choose the flight plan file to use.\n" +
            "Files should be put in Documents/flightPlans.",
                                      preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        let handler: (UIAlertAction) -> Void = { action in
            if let filename = action.title {
                self.pilotingItf?.value?.uploadFlightPlan(
                    filepath: flightPlanFolderPath.appendingPathComponent(filename).path)
            }
        }
        if let flightPlans = try? fileManager.contentsOfDirectory(atPath: flightPlanFolderPath.path) {
            for flightPlan in flightPlans {
                alert.addAction(UIAlertAction(title: flightPlan, style: .default, handler: handler))
            }
        }
        if let presenter = alert.popoverPresentationController {
            presenter.sourceView = self
            presenter.sourceRect = self.bounds
        }

        viewController?.present(alert, animated: true, completion: nil)
    }

    @IBAction func activatePushed(_ sender: Any) {
        if let pilotingItf = pilotingItf?.value {
            if pilotingItf.state == .active {
                _ = pilotingItf.deactivate()
            } else if pilotingItf.state == .idle {
                _ = pilotingItf.activate(restart: false,
                                         interpreter: interpreterType.selectedSegmentIndex == 0 ? .legacy : .standard)
            }
        }
    }

    @IBAction func restartPushed(_ sender: Any) {
        if let pilotingItf = pilotingItf?.value {
            _ = pilotingItf.activate(restart: true,
                                     interpreter: interpreterType.selectedSegmentIndex == 0 ? .legacy : .standard)
        }
    }

    @IBAction func activateAtItemPushed(_ sender: Any) {
        if let pilotingItf = pilotingItf?.value,
           pilotingItf.state == .idle && pilotingItf.activateAtMissionItemSupported {
            let alert = UIAlertController(title: "Activate at mission item", message: nil,
                                          preferredStyle: .alert)
            alert.addTextField { textField in
                textField.placeholder = "Mission item index"
                textField.keyboardType = .numberPad
            }
            alert.addAction(UIAlertAction(title: "Activate", style: .default) { [unowned self] _ in
                let missionItemTextField = alert.textFields![0] as UITextField
                var missionItemInt = Int(missionItemTextField.text ?? "0") ?? 0
                missionItemInt = missionItemInt < 0 ? 0 : missionItemInt
                _ = pilotingItf.activate(restart: false,
                                         interpreter: self.interpreterType.selectedSegmentIndex == 0 ?
                                            .legacy : .standard,
                                         missionItem: UInt(missionItemInt))
            })
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            if let presenter = alert.popoverPresentationController {
                presenter.sourceView = self
                presenter.sourceRect = self.bounds
            }

            viewController?.present(alert, animated: true, completion: nil)
        }
    }

    @IBAction func restartAtItemPushed(_ sender: Any) {
        if let pilotingItf = pilotingItf?.value,
           pilotingItf.state == .idle && pilotingItf.activateAtMissionItemSupported {
            let alert = UIAlertController(title: "Restart at mission item", message: nil,
                                          preferredStyle: .alert)
            alert.addTextField { textField in
                textField.placeholder = "Mission item index"
                textField.keyboardType = .numberPad
            }
            alert.addAction(UIAlertAction(title: "Restart", style: .default) { [unowned self] _ in
                let missionItemTextField = alert.textFields![0] as UITextField
                var missionItemInt = Int(missionItemTextField.text ?? "0") ?? 0
                missionItemInt = missionItemInt < 0 ? 0 : missionItemInt

                _ = pilotingItf.activate(restart: true,
                                         interpreter: interpreterType.selectedSegmentIndex == 0 ?
                                            .legacy : .standard,
                                         missionItem: UInt(missionItemInt))
            })
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            if let presenter = alert.popoverPresentationController {
                presenter.sourceView = self
                presenter.sourceRect = self.bounds
            }

            viewController?.present(alert, animated: true, completion: nil)
        }
    }


    @IBAction func activateAtItemV2Pushed(_ sender: Any) {
        if let pilotingItf = pilotingItf?.value,
           pilotingItf.state == .idle && pilotingItf.activateAtMissionItemV2Supported {
            let alert = UIAlertController(title: "Activate at mission item", message: nil,
                                          preferredStyle: .alert)
            alert.addTextField { textField in
                textField.placeholder = "Mission item index"
                textField.keyboardType = .numberPad
            }
            alert.addAction(UIAlertAction(title: "Activate", style: .default) { [unowned self] _ in
                let missionItemTextField = alert.textFields![0] as UITextField
                let missionItemInt = UInt(missionItemTextField.text ?? "0") ?? 0
                let interpreter: FlightPlanInterpreter =
                self.interpreterType.selectedSegmentIndex == 0 ? .legacy : .standard
                let disconnectionPolicy: FlightPlanDisconnectionPolicy =
                self.disconnectionPolicyType.selectedSegmentIndex == 0 ? .returnToHome : .continue

                _ = pilotingItf.activate(restart: false,
                                         interpreter: interpreter,
                                         missionItem: missionItemInt,
                                         disconnectionPolicy: disconnectionPolicy)
            })
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            if let presenter = alert.popoverPresentationController {
                presenter.sourceView = self
                presenter.sourceRect = self.bounds
            }

            viewController?.present(alert, animated: true, completion: nil)
        }
    }

    @IBAction func restartAtItemV2Pushed(_ sender: Any) {
        if let pilotingItf = pilotingItf?.value,
           pilotingItf.state == .idle && pilotingItf.activateAtMissionItemV2Supported {
            let alert = UIAlertController(title: "Restart at mission item", message: nil,
                                          preferredStyle: .alert)
            alert.addTextField { textField in
                textField.placeholder = "Mission item index"
                textField.keyboardType = .numberPad
            }
            alert.addAction(UIAlertAction(title: "Restart", style: .default) { [unowned self] _ in
                let missionItemTextField = alert.textFields![0] as UITextField
                let missionItemInt = UInt(missionItemTextField.text ?? "0") ?? 0
                let interpreter: FlightPlanInterpreter =
                self.interpreterType.selectedSegmentIndex == 0 ? .legacy : .standard
                let disconnectionPolicy: FlightPlanDisconnectionPolicy =
                self.disconnectionPolicyType.selectedSegmentIndex == 0 ? .returnToHome : .continue

                _ = pilotingItf.activate(restart: true,
                                         interpreter: interpreter,
                                         missionItem: missionItemInt,
                                         disconnectionPolicy: disconnectionPolicy
                )
            })
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            if let presenter = alert.popoverPresentationController {
                presenter.sourceView = self
                presenter.sourceRect = self.bounds
            }

            viewController?.present(alert, animated: true, completion: nil)
        }
    }

    @IBAction func clearRecoveryInfoPushed(_ sender: Any) {
        pilotingItf?.value?.clearRecoveryInfo()
    }

    @IBAction func stopPushed(_ sender: Any) {
        _ = pilotingItf?.value?.stop()
    }

    @IBAction func cleanBeforeRecoveryPushed(_ sender: Any) {
        if let pilotingItf = pilotingItf?.value,
           pilotingItf.state != .active {
            let alert = UIAlertController(title: "Clean before recovery", message: nil,
                                          preferredStyle: .alert)
            alert.addTextField { textField in
                textField.placeholder = "Custom ID"
                textField.text = pilotingItf.recoveryInfo?.customId ?? ""
                textField.keyboardType = .default
            }
               alert.addTextField { textField in
                   textField.placeholder = "Resource ID"
                   textField.text = pilotingItf.recoveryInfo?.resourceId ?? ""
                   textField.keyboardType = .default
               }
            alert.addAction(UIAlertAction(title: "Clean", style: .default) { _ in
                let customIdTextField = alert.textFields![0] as UITextField
                let customId = customIdTextField.text ?? ""
                let resourceIdTextField = alert.textFields![1] as UITextField
                let resourceId = resourceIdTextField.text ?? ""
                _ = pilotingItf.cleanBeforeRecovery(customId: customId, resourceId: resourceId) { result in
                    print("cleanBeforeRecovery completed with result \(result.description)")
                }
            })
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            if let presenter = alert.popoverPresentationController {
                presenter.sourceView = self
                presenter.sourceRect = self.bounds
            }

            viewController?.present(alert, animated: true, completion: nil)
        }
    }
}
