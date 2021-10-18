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

enum TargetState {
    case drawing
    case pending
    case locked
    case disabled
    case abandoned
    case proposal
}

protocol ProposalDelegate: AnyObject {
    func didSelect(proposalId: UInt)
}

/**
 This view draw itself to show a target rectangle
 This rectangle can have multiple states and so on modifies its border and background color
 */
final class TargetView: UIView {

    // MARK: Public Properties
    var state: TargetState = .drawing {
        didSet {
            drawState()
        }
    }

    // MARK: Private Properties
    private var borderLayer = CAShapeLayer()
    private var dashPattern: [NSNumber] {
        return [6, 2]
    }
    private let radius: CGFloat = 5
    private var uid: UInt = 0
    weak var delegate: ProposalDelegate?

    // MARK: Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    init(frame: CGRect, targetId: UInt) {
        super.init(frame: frame)
        self.uid = targetId
        commonInit()
    }

    private func commonInit() {
        borderLayer.fillColor = nil
        layer.addSublayer(borderLayer)
        layer.cornerRadius = radius
        clipsToBounds = true

        // add singleTap on view
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(handleTap(tap:)))
        singleTap.numberOfTapsRequired = 1
        singleTap.numberOfTouchesRequired = 1
        self.addGestureRecognizer(singleTap)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        drawState()
    }

    // MARK: Private Function
    private func drawState() {
        switch state {
        case .drawing:
            let color = UIColor.blue
            drawBorder(color: color, dashPattern: dashPattern)
            backgroundColor = color.withAlphaComponent(0.3)
        case .pending:
            let color = UIColor.red
            drawBorder(color: color, dashPattern: dashPattern)
            backgroundColor = color.withAlphaComponent(0.3)
        case .locked:
            let color = UIColor.green
            drawBorder(color: color, dashPattern: nil)
            backgroundColor = color.withAlphaComponent(0.3)
        case .disabled:
            let color = UIColor.yellow
            drawBorder(color: color, dashPattern: dashPattern)
            backgroundColor = color.withAlphaComponent(0.3)
        case .abandoned:
            let color = UIColor.red
            drawBorder(color: color, dashPattern: nil)
            backgroundColor = color.withAlphaComponent(0.3)
        case .proposal:
            let color = UIColor.yellow
            drawBorder(color: color, dashPattern: nil)
            backgroundColor = color.withAlphaComponent(0.5)
        }
    }

    private func drawBorder(color: UIColor, dashPattern: [NSNumber]?) {
        // style it
        borderLayer.strokeColor = color.cgColor
        borderLayer.lineDashPattern = dashPattern
        // draw it
        borderLayer.frame = bounds
        borderLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: radius).cgPath
    }

    @objc private func handleTap(tap: UITapGestureRecognizer) {
        delegate?.didSelect(proposalId: uid)
    }
}
