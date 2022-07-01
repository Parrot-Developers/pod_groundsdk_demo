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

import Foundation
import UIKit
import GroundSdk

protocol DeviceContentCellDelegate: AnyObject {
    func deviceContentCellVisibilityChanged(atIndexPath indexPath: IndexPath)
}

class DeviceContentCell: UITableViewCell {
    weak var delegate: DeviceContentCellDelegate?
    var identifier: String = ""
    private var indexPath: IndexPath = IndexPath(row: 0, section: 0)

    @IBOutlet private var bottomConstraint: NSLayoutConstraint?

    private(set) var isVisible = false

    func initContent(forIndexPath indexPath: IndexPath, delegate: DeviceContentCellDelegate) {
        self.delegate = delegate
        self.indexPath = indexPath
        assert(bottomConstraint != nil, "You have forgotten to link the bottom constraint of the"
               + " main vertical stack view in the storyboard editor")
    }

    func show() {
        if !isVisible {
            isVisible = true
            bottomConstraint?.isActive = true
            delegate?.deviceContentCellVisibilityChanged(atIndexPath: indexPath)
        }
    }

    func hide() {
        if isVisible {
            isVisible = false
            bottomConstraint?.isActive = false
            delegate?.deviceContentCellVisibilityChanged(atIndexPath: indexPath)
        }
    }
}

class PilotingItfProviderContentCell: DeviceContentCell {

    func initContent(forIndexPath indexPath: IndexPath,
                     provider: PilotingItfProvider,
                     delegate: DeviceContentCellDelegate) {
        initContent(forIndexPath: indexPath, delegate: delegate)
        set(pilotingItfProvider: provider)
    }

    func set(pilotingItfProvider provider: PilotingItfProvider) { }
}

class InstrumentProviderContentCell: DeviceContentCell {

    func initContent(forIndexPath indexPath: IndexPath,
                     provider: InstrumentProvider,
                     delegate: DeviceContentCellDelegate) {
        initContent(forIndexPath: indexPath, delegate: delegate)
        set(instrumentProvider: provider)
    }

    func set(instrumentProvider provider: InstrumentProvider) { }
}

class PeripheralProviderContentCell: DeviceContentCell {

    func initContent(forIndexPath indexPath: IndexPath,
                     provider: PeripheralProvider,
                     delegate: DeviceContentCellDelegate) {
        initContent(forIndexPath: indexPath, delegate: delegate)
        set(peripheralProvider: provider)
    }

    func set(peripheralProvider provider: PeripheralProvider) { }
}
