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

class MicrohardViewController: UITableViewController, DeviceViewController {

    private let groundSdk = GroundSdk()
    private var rcUid: String?
    private var microhard: Ref<Microhard>?

    @IBOutlet weak var state: UILabel!
    @IBOutlet weak var powerOnOffBtn: UIButton!
    @IBOutlet weak var networkId: UITextField!
    @IBOutlet weak var encryptionKey: UITextField!
    @IBOutlet weak var pairingChannelLabel: UILabel!
    @IBOutlet weak var pairingPowerLabel: UILabel!
    @IBOutlet weak var pairingBandwidthLabel: UILabel!
    @IBOutlet weak var pairingEncryptionLabel: UILabel!
    @IBOutlet weak var connectionChannelLabel: UILabel!
    @IBOutlet weak var connectionPowerLabel: UILabel!
    @IBOutlet weak var connectionBandwidthLabel: UILabel!
    @IBOutlet weak var pairingStatus: UILabel!
    @IBOutlet weak var pairDeviceBtn: UIButton!

    var pairingChannel: UInt?
    var pairingPower: UInt?
    var pairingBandwidth: MicrohardBandwidth?
    var pairingEncryption: MicrohardEncryption?
    var connectionChannel: UInt?
    var connectionPower: UInt?
    var connectionBandwidth: MicrohardBandwidth?

    func setDeviceUid(_ uid: String) {
        rcUid = uid
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        networkId.text = ""
        encryptionKey.text = ""
        pairingChannelLabel.text = ""
        pairingPowerLabel.text = ""
        pairingBandwidthLabel.text = ""
        pairingEncryptionLabel.text = ""
        connectionChannelLabel.text = ""
        connectionPowerLabel.text = ""
        connectionBandwidthLabel.text = ""
        updatePairDeviceBtn()

        if let remoteControl = groundSdk.getRemoteControl(uid: rcUid!) {
            microhard = remoteControl.getPeripheral(Peripherals.microhard) { [weak self] microhard in
                if let microhard = microhard, let `self` = self {
                    self.state.text = microhard.state.description
                    if microhard.state == .offline {
                        self.powerOnOffBtn.setTitle("Power On", for: .normal)
                    } else {
                        self.powerOnOffBtn.setTitle("Shutdown", for: .normal)
                    }
                    self.pairingStatus.text = microhard.pairingStatus?.description ?? "-"
                    self.updatePairDeviceBtn()
                } else {
                    self?.performSegue(withIdentifier: "exit", sender: self)
                }
            }
        }
    }

    private func prepareChooseEnum(target: ChooseEnumViewController,
                                   reuseIdentifier: String,
                                   microhard: Microhard) {
        switch reuseIdentifier {
        case "pairingBandwidth":
            target.initialize(data: ChooseEnumViewController.Data(
                dataSource: [MicrohardBandwidth](microhard.supportedBandwidths),
                selectedValue: pairingBandwidth?.description,
                itemDidSelect: { [unowned self] value in
                    self.pairingBandwidth = value as? MicrohardBandwidth
                    self.pairingBandwidthLabel.text = self.pairingBandwidth?.description
                    self.updatePairDeviceBtn()
                }
            ))
        case "pairingEncryption":
            target.initialize(data: ChooseEnumViewController.Data(
                dataSource: [MicrohardEncryption](microhard.supportedEncryptions),
                selectedValue: pairingEncryption?.description,
                itemDidSelect: { [unowned self] value in
                    self.pairingEncryption = value as? MicrohardEncryption
                    self.pairingEncryptionLabel.text = self.pairingEncryption?.description
                    self.updatePairDeviceBtn()
                }
            ))
        case "connectionBandwidth":
            target.initialize(data: ChooseEnumViewController.Data(
                dataSource: [MicrohardBandwidth](microhard.supportedBandwidths),
                selectedValue: connectionBandwidth?.description,
                itemDidSelect: { [unowned self] value in
                    self.connectionBandwidth = value as? MicrohardBandwidth
                    self.connectionBandwidthLabel.text = self.connectionBandwidth?.description
                    self.updatePairDeviceBtn()
                }
            ))
        default:
            return
        }
    }

    private func prepareChooseNumber(target: ChooseIntViewController,
                                     reuseIdentifier: String,
                                     microhard: Microhard) {
        switch reuseIdentifier {
        case "pairingChannel":
            target.initialize(data: ChooseIntViewController.Data(
                value: microhard.supportedChannelRange.clamp(pairingChannel ?? 0),
                range: microhard.supportedChannelRange,
                title: "Pairing Channel",
                valueChanged: { [unowned self] value in
                    self.pairingChannel = value
                    self.pairingChannelLabel.text = "\(value)"
                    self.updatePairDeviceBtn()
                }
            ))
        case "pairingPower":
            target.initialize(data: ChooseIntViewController.Data(
                value: microhard.supportedPowerRange.clamp(pairingPower ?? 0),
                range: microhard.supportedPowerRange,
                title: "Pairing Power",
                valueChanged: { [unowned self] value in
                    self.pairingPower = value
                    self.pairingPowerLabel.text = "\(value)"
                    self.updatePairDeviceBtn()
                }
            ))
        case "connectionChannel":
            target.initialize(data: ChooseIntViewController.Data(
                value: microhard.supportedChannelRange.clamp(connectionChannel ?? 0),
                range: microhard.supportedChannelRange,
                title: "Connection Channel",
                valueChanged: { [unowned self] value in
                    self.connectionChannel = value
                    self.connectionChannelLabel.text = "\(value)"
                    self.updatePairDeviceBtn()
                }
            ))
        case "connectionPower":
            target.initialize(data: ChooseIntViewController.Data(
                value: microhard.supportedPowerRange.clamp(connectionPower ?? 0),
                range: microhard.supportedPowerRange,
                title: "Connection Power",
                valueChanged: { [unowned self] value in
                    self.connectionPower = value
                    self.connectionPowerLabel.text = "\(value)"
                    self.updatePairDeviceBtn()
                }
            ))
        default:
            return
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let cell = sender as? UITableViewCell
        if let reuseIdentifier = cell?.reuseIdentifier,
           let microhard = microhard?.value {
            switch segue.destination {
            case let target as ChooseEnumViewController:
                prepareChooseEnum(target: target, reuseIdentifier: reuseIdentifier, microhard: microhard)
            case let target as ChooseIntViewController:
                prepareChooseNumber(target: target, reuseIdentifier: reuseIdentifier, microhard: microhard)
            default:
                return
            }
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        if let reuseIdentifier = cell?.reuseIdentifier {
            let segueIdentifier: String
            switch reuseIdentifier {
            case "pairingChannel", "pairingPower", "connectionChannel", "connectionPower":
                segueIdentifier = "selectIntValue"
            case "pairingBandwidth", "pairingEncryption", "connectionBandwidth":
                segueIdentifier = "selectEnumValue"
            default:
                return
            }
            performSegue(withIdentifier: segueIdentifier, sender: cell)
        } else {
            tableView.deselectRow(at: indexPath, animated: false)
        }
    }

    @IBAction func powerOnOff() {
        if microhard?.value?.state == .offline {
            _ = microhard?.value?.powerOn()
        } else {
            _ = microhard?.value?.shutdown()
        }
    }

    private func updatePairDeviceBtn() {
        if !(networkId.text != nil
                && encryptionKey.text != nil
                && pairingChannel != nil
                && pairingPower != nil
                && pairingBandwidth != nil
                && pairingEncryption != nil
                && connectionChannel != nil
                && connectionPower != nil
                && connectionBandwidth != nil) {
            pairDeviceBtn.setTitle("Uncomplete parameters", for: .disabled)
            pairDeviceBtn.isEnabled = false
        } else if microhard?.value?.state.canPair != true {
            pairDeviceBtn.setTitle("Can't pair in this state", for: .disabled)
            pairDeviceBtn.isEnabled = false
        } else {
            pairDeviceBtn.isEnabled = true
        }
    }

    @IBAction func pairDevice() {
        if let networkId = networkId.text,
           let encryptionKey = encryptionKey.text,
           let pairingChannel = pairingChannel,
           let pairingPower = pairingPower,
           let pairingBandwdth = pairingBandwidth,
           let pairingEncryption = pairingEncryption,
           let connectionChannel = connectionChannel,
           let connectionPower = connectionPower,
           let connectionBandwidth = connectionBandwidth {
            let pairingParameters = MicrohardPairingParameters(channel: pairingChannel,
                                                               power: pairingPower,
                                                               bandwidth: pairingBandwdth,
                                                               encryption: pairingEncryption)
            let connectionParameters = MicrohardConnectionParameters(channel: connectionChannel,
                                                                     power: connectionPower,
                                                                     bandwidth: connectionBandwidth)
            _ = microhard?.value?.pairDevice(networkId: networkId,
                                             encryptionKey: encryptionKey,
                                             pairingParameters: pairingParameters,
                                             connectionParameters: connectionParameters)
        }
    }
}

extension MicrohardViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        updatePairDeviceBtn()
        return true
    }
}
