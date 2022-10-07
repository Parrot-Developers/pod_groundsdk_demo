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

protocol ProposalAndTrackingDelegate: AnyObject {
    func didDrawSelection(_ frame: CGRect)
    func didSelectProposal(proposalId: UInt)
}

public class ProposalAndTrackingView: UIView {

    private var trackingList: [UInt: Target]?
    private var currentCookie: UInt = 0
    private var proposalViews = [UInt: TargetView]()
    private var trackingView: TargetView?
    weak var delegate: ProposalAndTrackingDelegate?
    private var didAskToAutoSelect = false
    private var framingViewDisplayed = false
    private var framingViewStartLocation = CGPoint.zero
    var contentZone: CGRect?

    // MARK: Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(pan:)))
        addGestureRecognizer(pan)

        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(longPress:)))
        longPress.minimumPressDuration = 0.5
        addGestureRecognizer(longPress)
    }

    // MARK: Public Functions
    func trackingStatusDidChange(_ metadata: Vmeta_TrackingMetadata?, cookie: UInt) {
        currentCookie = cookie
        if let metadata = metadata {
            guard trackingView?.state != .drawing, (cookie == metadata.cookie || cookie == 1) else { return }
            if !metadata.hasTarget {
                clearTracking()
            } else {
                clearProposal()
                let state = computeState(from: metadata.state)
                if let contentZone = contentZone {
                    let x = CGFloat(metadata.target.x) * contentZone.width
                    let y = CGFloat(metadata.target.y) * contentZone.height
                    let rect = CGRect(
                        origin: CGPoint(x: x, y: y),
                        size: CGSize(width: CGFloat(metadata.target.width) * contentZone.width,
                                     height: CGFloat(metadata.target.height) * contentZone.height)
                    )
                    updateTarget(frame: rect, state: state)
                }
            }
        }
    }

    func proposalStatusDidChange(_ metadata: Vmeta_TrackingProposalMetadata?) {
        guard trackingView?.state != .drawing else {
            return
        }
        if let metadata = metadata {
            if metadata.proposals.isEmpty {
                clearProposal()
            } else {
                clearTracking()
                var arrayUId = [UInt]()
                for proposal in metadata.proposals {
                    arrayUId.append(UInt(proposal.uid))
                    if let contentZone = contentZone {
                        let x = CGFloat(proposal.x) * self.frame.width
                        let y = CGFloat(proposal.y) * self.frame.height

                        let rect = CGRect(origin: CGPoint(x: x, y: y),
                                          size: CGSize(width: CGFloat(proposal.width) * contentZone.width,
                                                       height: CGFloat(proposal.height) * contentZone.height))
                        // add targets
                        if proposalViews[UInt(proposal.uid)] != nil {
                            // update frame
                            proposalViews[UInt(proposal.uid)]?.frame = rect
                        } else {
                            // add view
                            let view = TargetView(frame: rect, targetId: UInt(proposal.uid))
                            view.state = .proposal
                            view.delegate = self
                            addSubview(view)
                            proposalViews[UInt(proposal.uid)] = view
                        }
                    }
                }

                // remove
                for proposal in proposalViews where arrayUId.firstIndex(of: proposal.key) == nil {
                    proposal.value.removeFromSuperview()
                    proposalViews.removeValue(forKey: proposal.key)
                }
            }
        }
    }

    private func computeState(from trackingStatus: Vmeta_TrackingState) -> TargetState {
        if trackingStatus == .tsSearching {
            return .pending
        } else if trackingStatus == .tsTracking {
            return .locked
        } else {
            return .drawing
        }
    }

    func clearTracking() {
        trackingView?.removeFromSuperview()
        trackingView = nil
    }

    func clearProposal() {
        for proposal in proposalViews {
            proposalViews[proposal.key]?.removeFromSuperview()
        }
        proposalViews = [:]
    }

    private func updateTarget(frame: CGRect, state: TargetState) {
        if trackingView == nil {
            let view = TargetView(frame: frame)
            addSubview(view)
            trackingView = view
        } else if state != .pending {
            trackingView?.frame = frame
        }
        trackingView?.state = state
    }

    // MARK: Gestures
    @objc private func handleLongPress(longPress: UILongPressGestureRecognizer) {
        guard trackingView != nil else { return }

        let location = longPress.location(in: self)

        switch longPress.state {
        case .began:
            framingViewStartLocation = location
        case .changed:
            framingViewStartLocation = location
        case .ended:
            framingViewStartLocation = CGPoint.zero
        default:
            break
        }
    }

    @objc private func handlePan(pan: UIPanGestureRecognizer) {
        let translation = pan.translation(in: self)

        if framingViewDisplayed {
            pan.setTranslation(.zero, in: self)
        } else {
            let location = pan.location(in: self)
            let startingPoint = CGPoint(x: location.x - translation.x,
                                        y: location.y - translation.y)
            var targetFrame = CGRect(origin: originFrom(p1: location, p2: startingPoint),
                                     size: sizeFrom(p1: location, p2: startingPoint))

            targetFrame = targetFrame.intersection(bounds)

            if pan.state == .ended {
                didAskToAutoSelect = false
                // notify delegate
                delegate?.didDrawSelection(targetFrame)
                updateTarget(frame: targetFrame, state: .pending)
            } else {
                updateTarget(frame: targetFrame, state: .drawing)
            }
        }
    }

    private func longPressureTranslation(for location: CGPoint) -> CGPoint {
        return CGPoint(x: location.x - framingViewStartLocation.x,
                       y: location.y - framingViewStartLocation.y)
    }

    // MARK: Helpers
    private func originFrom(p1: CGPoint, p2: CGPoint) -> CGPoint {
        let x = min(p1.x, p2.x)
        let y = min(p1.y, p2.y)
        return CGPoint(x: x, y: y)
    }

    private func sizeFrom(p1: CGPoint, p2: CGPoint) -> CGSize {
        let width = max(1, abs(p1.x - p2.x))
        let height = max(1, abs(p1.y - p2.y))
        return CGSize(width: width, height: height)
    }
}

extension ProposalAndTrackingView: ProposalDelegate {
    func didSelect(proposalId: UInt) {
        self.delegate?.didSelectProposal(proposalId: proposalId)
    }
}
