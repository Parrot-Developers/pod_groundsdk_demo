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

class BatteryInfoCell: InstrumentProviderContentCell {

    @IBOutlet private weak var batteryLevelLabel: UILabel!
    @IBOutlet private weak var isChargingLabel: UILabel!
    @IBOutlet private weak var batteryHealthLabel: UILabel!
    @IBOutlet private weak var cycleCountLabel: UILabel!
    @IBOutlet private weak var serialLabel: UILabel!
    @IBOutlet private weak var temperatureLabel: UILabel!
    @IBOutlet private weak var batteryConfigurationDateLabel: UILabel!
    @IBOutlet private weak var batteryCellCountLabel: UILabel!
    @IBOutlet private weak var batteryCellVoltageLabel: UILabel!
    @IBOutlet private weak var designCapacityLabel: UILabel!
    @IBOutlet private weak var fullChargeCapacityLabel: UILabel!
    @IBOutlet private weak var remainingCapacityLabel: UILabel!
    @IBOutlet private weak var cellVoltageContainer: UIStackView!
    // it is not weak on purpose, as it is dynamically being removed from its superview.
    @IBOutlet private var unavailableCellVoltagesLabel: UILabel!
    @IBOutlet private weak var hardwareRevisionLabel: UILabel!
    @IBOutlet private weak var firmwareVersionLabel: UILabel!
    @IBOutlet private weak var gaugeVersionLabel: UILabel!
    @IBOutlet private weak var usbVersionLabel: UILabel!
    private var cellVoltagesStackViews = [UIStackView]()

    private var batteryInfo: Ref<BatteryInfo>?

    private static var configurationDateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.locale = Locale.autoupdatingCurrent
        df.setLocalizedDateFormatFromTemplate("ddMMyyyy")
        return df
    }()

    override func set(instrumentProvider provider: InstrumentProvider) {
        super.set(instrumentProvider: provider)

        batteryInfo = provider.getInstrument(Instruments.batteryInfo) { [unowned self] batteryInfo in
            if let batteryInfo = batteryInfo {
                self.batteryLevelLabel.text = "\(batteryInfo.batteryLevel)%"
                self.isChargingLabel.text = batteryInfo.isCharging ? "YES" : "NO"
                self.batteryHealthLabel.text = batteryInfo.batteryHealth.map { "\($0)%"} ?? "-"
                self.cycleCountLabel.text = batteryInfo.cycleCount.map { "\($0)"} ?? "-"
                self.serialLabel.text = batteryInfo.batteryDescription?.serial ?? "-"
                self.temperatureLabel.text = batteryInfo.temperature.map {
                    "\(Int(Double($0) - 273.15))ºC"
                } ?? "-"
                // description
                self.batteryConfigurationDateLabel.text = batteryInfo
                    .batteryDescription?.configurationDate.map {
                        "\(BatteryInfoCell.configurationDateFormatter.string(from: $0))"
                    } ?? "-"
                self.batteryCellCountLabel.text = batteryInfo
                    .batteryDescription.map { "\($0.cellCount)" } ?? "-"
                self.batteryCellVoltageLabel.text = batteryInfo
                    .batteryDescription.map {
                        formatMilliVoltageToVoltage($0.cellMinVoltage)
                        + "/" + formatMilliVoltageToVoltage($0.cellMaxVoltage)
                    } ?? "-"
                // capacity
                self.designCapacityLabel.text = batteryInfo.batteryDescription
                    .map { "\($0.designCapacity) mAh" } ?? "-"
                self.fullChargeCapacityLabel.text = batteryInfo.capacity
                    .map { "\($0.fullChargeCapacity) mAh" } ?? "-"
                self.remainingCapacityLabel.text = batteryInfo.capacity
                    .map { "\($0.remainingCapacity) mAh" } ?? "-"
                // cell voltages
                self.unavailableCellVoltagesLabel.removeFromSuperview()
                self.cellVoltagesStackViews.forEach {
                    $0.removeFromSuperview()
                }
                if batteryInfo.cellVoltages.isEmpty {
                    self.cellVoltagesStackViews = []
                    self.unavailableCellVoltagesLabel.text = "-"
                    self.cellVoltageContainer.addArrangedSubview(self.unavailableCellVoltagesLabel)
                } else {
                    self.cellVoltagesStackViews = batteryInfo.cellVoltages
                        .enumerated()
                        .map(cellVoltage(index:cellVoltage:))
                    self.cellVoltagesStackViews.forEach {
                        self.cellVoltageContainer.addArrangedSubview($0)
                    }
                }

                self.hardwareRevisionLabel.text = batteryInfo.version
                    .map { "\($0.hardwareRevision)" } ?? "-"
                self.firmwareVersionLabel.text = batteryInfo.version
                    .map { "\($0.firmwareVersion)" } ?? "-"
                self.gaugeVersionLabel.text = batteryInfo.version
                    .map { "\($0.gaugeVersion)" } ?? "-"
                self.usbVersionLabel.text = batteryInfo.version
                    .map { "\($0.usbVersion)" } ?? "-"

                self.show()
            } else {
                self.hide()
            }
        }
    }

    private func cellVoltage(index: Int, cellVoltage: UInt?) -> UIStackView {
        let label = UILabel(frame: .zero)
        label.text = "Cell \(index)"
        let value = UILabel(frame: .zero)
        value.text = cellVoltage.map(formatMilliVoltageToVoltage) ?? "-"
        let horizontalContainer = UIStackView(arrangedSubviews: [label, value])
        value.setContentHuggingPriority(.init(rawValue: 251), for: .horizontal)
        horizontalContainer.axis = .horizontal
        horizontalContainer.alignment = .fill
        horizontalContainer.distribution = .fill
        horizontalContainer.spacing = 0
        return horizontalContainer
    }
}

private func formatMilliVoltageToVoltage<N>(_ value: N) -> String where N: BinaryInteger {
    let voltage = Double(value)/1000.0
    if #available(iOS 15.0, *) {
        return "\(voltage.formatted(.number.precision(.fractionLength(2))))V"
    } else {
        return "\(String(format: "%.2f", voltage))V"
    }
}
