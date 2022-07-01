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

    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var modemStatusLabel: UILabel!
    @IBOutlet private weak var imeiLabel: UILabel!
    @IBOutlet private weak var simStatusLabel: UILabel!
    @IBOutlet private weak var simIccidLabel: UILabel!
    @IBOutlet private weak var simImsiLabel: UILabel!
    @IBOutlet private weak var registrationStatusLabel: UILabel!
    @IBOutlet private weak var networkStatusLabel: UILabel!
    @IBOutlet private weak var operatorLabel: UILabel!
    @IBOutlet private weak var technologyLabel: UILabel!
    @IBOutlet private weak var isRoamingAllowedLabel: UILabel!
    @IBOutlet private weak var isPinCodeRequestedLabel: UILabel!
    @IBOutlet private weak var pinRemainingTriesLabel: UILabel!

    @IBOutlet private weak var isApnManualSwitch: UISwitch!
    @IBOutlet private weak var apnUrlLabel: UILabel!
    @IBOutlet private weak var apnUrlTextField: UITextField!
    @IBOutlet private weak var apnUsernameLabel: UILabel!
    @IBOutlet private weak var apnUsernameTextField: UITextField!
    @IBOutlet private weak var apnPasswordLabel: UILabel!
    @IBOutlet private weak var apnPasswordTextField: UITextField!

    @IBOutlet private weak var pincodeLabel: UILabel!
    @IBOutlet private weak var pincodeTextField: UITextField!
    @IBOutlet private weak var pincodeButton: UIButton!
    @IBOutlet private weak var resetStateLabel: UILabel!

    @IBOutlet private weak var scrollView: UIScrollView!

    private var keyboardWillShowObserver: NSObjectProtocol?
    private var keyboardWillHideObserver: NSObjectProtocol?

    private let groundSdk = GroundSdk()
    private var deviceUid: String?
    private var cellular: Ref<Cellular>?

    private var indexPathSelected: IndexPath?

    func setDeviceUid(_ uid: String) {
        self.deviceUid = uid
    }

    deinit {
        self.keyboardWillShowObserver.map { NotificationCenter.default.removeObserver($0) }
        self.keyboardWillHideObserver.map { NotificationCenter.default.removeObserver($0) }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if let drone = groundSdk.getDrone(uid: deviceUid!) {
            self.cellular = drone.getPeripheral(Peripherals.cellular) { [weak self] cellular in
                guard let self = self else { return }
                if let cellular = cellular {
                    self.isApnManualSwitch.isOn = cellular.apnConfigurationSetting.isManual
                    self.showHideApnsettings()
                    self.pincodeLabel.isHidden = !cellular.isPinCodeRequested
                    self.pincodeTextField.isHidden = !cellular.isPinCodeRequested
                    self.pincodeButton.isHidden = !cellular.isPinCodeRequested
                    self.modemStatusLabel.text = "\(cellular.modemStatus.description)"
                    self.imeiLabel.text = "\(cellular.imei)"
                    self.simStatusLabel.text = "\(cellular.simStatus.description)"
                    self.simIccidLabel.text = "\(cellular.simIccid)"
                    self.simImsiLabel.text = "\(cellular.simImsi)"
                    self.registrationStatusLabel.text = "\(cellular.registrationStatus.description)"
                    self.networkStatusLabel.text = "\(cellular.networkStatus.description)"
                    self.operatorLabel.text = "\(cellular.operator)"
                    self.technologyLabel.text = "\(cellular.technology.description)"
                    self.isRoamingAllowedLabel.text = cellular.isRoamingAllowed.value ? "yes" : "no"
                    self.isPinCodeRequestedLabel.text = cellular.isPinCodeRequested ? "yes" : "no"
                    self.pinRemainingTriesLabel.text = "\(cellular.pinRemainingTries)"
                    self.resetStateLabel.text = "\(cellular.resetState)"
                    self.tableView.reloadData()
                } else {
                    self.performSegue(withIdentifier: "exit", sender: self)
                }
            }
        }

        self.keyboardWillShowObserver =
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification,
                                               object: nil,
                                               queue: .main) { [weak self] notification in
            guard let self = self else { return }
            let userInfo = notification.userInfo!
            let keyboardInfo = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
            let keyboardSize = keyboardInfo.cgRectValue.size
            let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height + 20, right: 0)
            self.scrollView.contentInset = contentInsets
            self.scrollView.scrollIndicatorInsets = contentInsets
        }
        self.keyboardWillHideObserver =
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification,
                                               object: nil,
                                               queue: .main) { [weak self] _ in
            guard let self = self else { return }
            self.scrollView.contentInset = .zero
            self.scrollView.scrollIndicatorInsets = .zero
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
        if let cellular = self.cellular?.value {
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
        if let cellular = self.cellular?.value {
            guard let pincode = self.pincodeTextField.text else {
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
        _ = self.cellular?.value?.resetSettings()
    }

    func isPinCodeValid(pinCode: String) -> Bool {
        let pincodeRegex = "^[0-9]{4}$"
        let pinPredicate = NSPredicate(format: "SELF MATCHES %@", pincodeRegex)
        return pinPredicate.evaluate(with: pinCode) as Bool
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let cellular = cellular?.value,
           let target = segue.destination as? ChooseEnumViewController,
           self.indexPathSelected != nil {
            if self.indexPathSelected!.section == 0 {
                target.title = "Mode"
                target.initialize(data: ChooseEnumViewController.Data(
                    dataSource: CellularMode.allCases,
                    selectedValue: cellular.mode.value.description,
                    itemDidSelect: { [unowned self] value in
                        self.cellular?.value?.mode.value = value as! CellularMode
                    }
                ))
            } else {
                target.title = "Network Mode"
                target.initialize(data: ChooseEnumViewController.Data(
                    dataSource: CellularNetworkMode.allCases,
                    selectedValue: cellular.networkMode.value.description,
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
        self.indexPathSelected = indexPath
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
