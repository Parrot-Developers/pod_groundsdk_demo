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

class CellularViewController: UIViewController, DeviceViewController {

    @IBOutlet weak var modemStatusLabel: UILabel!
    @IBOutlet weak var imeiLabel: UILabel!
    @IBOutlet weak var simStatusLabel: UILabel!
    @IBOutlet weak var simIccidLabel: UILabel!
    @IBOutlet weak var simImsiLabel: UILabel!
    @IBOutlet weak var registrationStatusLabel: UILabel!
    @IBOutlet weak var networkStatusLabel: UILabel!
    @IBOutlet weak var operatorLabel: UILabel!
    @IBOutlet weak var technologyLabel: UILabel!
    @IBOutlet weak var isRoamingAllowedLabel: UILabel!
    @IBOutlet weak var isPinCodeRequestedLabel: UILabel!
    @IBOutlet weak var pinRemainingTriesLabel: UILabel!

    @IBOutlet weak var isApnManualSwitch: UISwitch!
    @IBOutlet weak var apnUrlLabel: UILabel!
    @IBOutlet weak var apnUrlTextField: UITextField!
    @IBOutlet weak var apnUsernameLabel: UILabel!
    @IBOutlet weak var apnUsernameTextField: UITextField!
    @IBOutlet weak var apnPasswordLabel: UILabel!
    @IBOutlet weak var apnPasswordTextField: UITextField!

    @IBOutlet weak var pincodeLabel: UILabel!
    @IBOutlet weak var pincodeTextField: UITextField!
    @IBOutlet weak var pincodeButton: UIButton!
    @IBOutlet weak var resetStateLabel: UILabel!

    private let groundSdk = GroundSdk()
    private var deviceUid: String?
    private var cellular: Ref<Cellular>?

    private var indexPathSelected: IndexPath?

    func setDeviceUid(_ uid: String) {
        deviceUid = uid
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if let drone = groundSdk.getDrone(uid: deviceUid!) {
            cellular = drone.getPeripheral(Peripherals.cellular) { [weak self] cellular in
                if let cellular = cellular {
                    self?.isApnManualSwitch.isOn = cellular.apnConfigurationSetting.isManual
                    self?.showHideApnsettings()
                    self?.pincodeLabel.isHidden = !cellular.isPinCodeRequested
                    self?.pincodeTextField.isHidden = !cellular.isPinCodeRequested
                    self?.pincodeButton.isHidden = !cellular.isPinCodeRequested
                    self?.modemStatusLabel.text = "\(cellular.modemStatus.description)"
                    self?.imeiLabel.text = "\(cellular.imei)"
                    self?.simStatusLabel.text = "\(cellular.simStatus.description)"
                    self?.simIccidLabel.text = "\(cellular.simIccid)"
                    self?.simImsiLabel.text = "\(cellular.simImsi)"
                    self?.registrationStatusLabel.text = "\(cellular.registrationStatus.description)"
                    self?.networkStatusLabel.text = "\(cellular.networkStatus.description)"
                    self?.operatorLabel.text = "\(cellular.operator)"
                    self?.technologyLabel.text = "\(cellular.technology.description)"
                    self?.isRoamingAllowedLabel.text = cellular.isRoamingAllowed.value ? "yes" : "no"
                    self?.isPinCodeRequestedLabel.text = cellular.isPinCodeRequested ? "yes" : "no"
                    self?.pinRemainingTriesLabel.text = "\(cellular.pinRemainingTries)"
                    self?.resetStateLabel.text = "\(cellular.resetState)"
                } else {
                    self?.performSegue(withIdentifier: "exit", sender: self)
                }
            }
        }
    }

    func showHideApnsettings() {
        self.apnUrlLabel.isHidden = !self.isApnManualSwitch.isOn
        self.apnUrlTextField.isHidden = !self.isApnManualSwitch.isOn
        self.apnUsernameLabel.isHidden = !self.isApnManualSwitch.isOn
        self.apnUsernameTextField.isHidden = !self.isApnManualSwitch.isOn
        self.apnPasswordLabel.isHidden = !self.isApnManualSwitch.isOn
        self.apnPasswordTextField.isHidden = !self.isApnManualSwitch.isOn
    }

    @IBAction func apnSwitchValueChanged(_ sender: Any) {
        showHideApnsettings()
    }

    @IBAction func sendApnPushed(_ sender: UIButton) {
        if let cellular = cellular?.value {
            if self.isApnManualSwitch.isOn {
                _ = cellular.apnConfigurationSetting.setToAuto()
            } else {
                _ = cellular.apnConfigurationSetting.setToManual(url: self.apnUrlTextField.text ?? "" ,
                                                                 username: self.apnUsernameTextField.text ?? "",
                                                                 password: self.apnPasswordTextField.text ?? "")
            }
        }
    }

    @IBAction func sendPinCodePushed(_ sender: UIButton) {
        if let cellular = cellular?.value {
            guard let pincode = pincodeTextField.text else {
                return
            }
            if !isPinCodeValid(pinCode: pincode) {
                let alertController =
                    UIAlertController(title: "PIN code",
                                      message: "The PIN code is not in a correct format",
                                      preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alertController, animated: true, completion: nil)
                return
            }
            _ = cellular.enterPinCode(pincode: pincode)
        }
    }

    @IBAction func sendResetSettings(_ sender: UIButton) {
        _ = cellular?.value?.resetSettings()
    }

    func isPinCodeValid(pinCode: String) -> Bool {
        let pincodeRegex = "^[0-9]{4}$"
        let pinPredicate = NSPredicate(format: "SELF MATCHES %@", pincodeRegex)
        return pinPredicate.evaluate(with: pinCode) as Bool
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if cellular?.value != nil, let target = segue.destination
            as? ChooseEnumViewController, indexPathSelected != nil {
            var arrayValues = [String]()
            if indexPathSelected!.section == 0 {
                for elements in CellularMode.allCases {
                    arrayValues.append(elements.description)
                }
                target.title = "Mode"
                target.initialize(data: ChooseEnumViewController.Data(
                    dataSource: arrayValues,
                    selectedValue: nil,
                    itemDidSelect: { [unowned self] value in
                        self.cellular?.value?.mode.value = value as! CellularMode
                    }
                ))
            } else {
                for elements in CellularNetworkMode.allCases {
                    arrayValues.append(elements.description)
                }
                target.title = "Network Mode"
                target.initialize(data: ChooseEnumViewController.Data(
                    dataSource: arrayValues,
                    selectedValue: nil,
                    itemDidSelect: { [unowned self] value in
                        self.cellular?.value?.networkMode.value = value as! CellularNetworkMode
                    }
                ))
            }
        }
    }
}

extension CellularViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        indexPathSelected = indexPath
        performSegue(withIdentifier: "selectEnumValue", sender: self)
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellularCell", for: indexPath)
        if let cellular = cellular?.value {
            if indexPath.section == 0 {
                cell.textLabel?.text = cellular.mode.value.description
            } else {
                cell.textLabel?.text = cellular.networkMode.value.description
            }
        }
        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (cellular?.value) != nil {
            if section == 0 {
                return "Cellular mode"
            } else {
                return "Cellular Network mode"
            }
        }
        return ""
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
}

extension CellularViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
