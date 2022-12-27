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

class OnboardTrackerHudViewController: UIViewController, DeviceViewController {

    @IBOutlet weak var streamView: StreamView!
    @IBOutlet weak var proposalAndtrackingView: ProposalAndTrackingView!
    @IBOutlet weak var dismissButton: UIButton!
    @IBOutlet weak var removeAllButton: UIButton!
    private let groundSdk = GroundSdk()
    private var droneUid: String?
    private var drone: Drone?
    private var streamServerRef: Ref<StreamServer>?
    private var liveStreamRef: Ref<CameraLive>?
    private var frameTimeStamp: UInt64?
    private var sink: StreamSink?
    private var cookie: UInt = 1
    private var droneStateRef: Ref<DeviceState>?
    private var onboardTrackerRef: Ref<OnboardTracker>?
    private var onboardTracker: OnboardTracker?

    func setDeviceUid(_ uid: String) {
        droneUid = uid
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        proposalAndtrackingView.delegate = self

        streamView.contentZoneListener = { [weak self] contentZone in
            if let contentZone =  self?.streamView.contentZone {

                let scaleFactor = UIScreen.main.scale
                let frame = CGRect(x: contentZone.minX / scaleFactor,
                                   y: contentZone.minY / scaleFactor,
                                   width: contentZone.width / scaleFactor,
                                   height: contentZone.height / scaleFactor)
                self?.proposalAndtrackingView.contentZone = frame
                self?.proposalAndtrackingView.frame = frame
            }
        }

        if let droneUid = droneUid {
            drone = groundSdk.getDrone(uid: droneUid) { [unowned self] _ in
                self.dismiss(self)
            }
        }
        if drone == nil {
            dismiss(self)
        }

        listenPilotingItf()
        listenState()

        dismissButton.layer.cornerRadius = dismissButton.frame.height / 2
        dismissButton.layer.borderWidth = 1
        dismissButton.layer.borderColor = UIColor.black.cgColor

        removeAllButton.layer.cornerRadius = removeAllButton.frame.height / 2
        removeAllButton.layer.borderWidth = 1
        removeAllButton.layer.borderColor = UIColor.black.cgColor
    }

    override func viewWillDisappear(_ animated: Bool) {
        stopImageProcessing()
    }

    private func listenPilotingItf() {
        onboardTrackerRef = drone?.getPeripheral(Peripherals.onboardTracker) { [weak self] onboardTracker in
            self?.onboardTracker = onboardTracker
        }
    }

    private func listenState() {
        droneStateRef = drone?.getState { [weak self] state in
            if state?.connectionState != .connected {
                self?.dismiss(self!)
            } else if state?.connectionState == .connected {
                self?.startImageProcessing()
            }
        }
    }

    // MARK: Private functions
    private func startImageProcessing() {
        // opensink
        streamServerRef = drone?.getPeripheral(Peripherals.streamServer) { [weak self] streamServer in
            if let streamServer = streamServer {
                self?.liveStreamRef = streamServer.live { [weak self] liveStream in
                    if let self = self {
                        if let liveStream = liveStream {
                            self.streamView?.setStream(stream: liveStream)
                            if liveStream.state != .started {
                                _ = liveStream.play()
                            }
                            if self.sink == nil {
                                self.sink = liveStream.openSink(
                                    config: RawVideoSinkConfig(dispatchQueue: DispatchQueue.main, listener: self))
                            }
                        }
                    }
                }
            }
        }
    }

    func stopImageProcessing() {
        streamView.setStream(stream: nil)
        sink = nil
        liveStreamRef = nil
        streamServerRef = nil
        proposalAndtrackingView.clearTracking()
        proposalAndtrackingView.clearProposal()
    }

    @IBAction func dismiss(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func removeAll(_ sender: AnyObject) {
        onboardTracker?.removeAllTargets()
    }

    private func trackingStatusDidUpdate(_ info: Vmeta_TimedMetadata) {
        frameTimeStamp = info.camera.timestamp
        if info.hasTracking {
            proposalAndtrackingView.trackingStatusDidChange(info.tracking, cookie: cookie)
        } else if info.hasProposal {
            proposalAndtrackingView.proposalStatusDidChange(info.proposal)
        } else {
            proposalAndtrackingView.clearTracking()
            proposalAndtrackingView.clearProposal()
        }
    }
}

// MARK: ProposalAndTrackingDelegate Protocol Implementation
extension OnboardTrackerHudViewController: ProposalAndTrackingDelegate {
    func didDrawSelection(_ frame: CGRect) {
        let x = Float(frame.minX / proposalAndtrackingView.frame.width)
        let y = Float(frame.minY / proposalAndtrackingView.frame.height)
        let width = Float(frame.width / proposalAndtrackingView.frame.width)
        let height = Float(frame.height / proposalAndtrackingView.frame.height)

        if let frameTimeStamp = frameTimeStamp, let onboardTracker = onboardTracker {
            cookie += 1
            var rectRequest = onboardTracker.ofRect(timestamp: frameTimeStamp, horizontalPosition: x,
                                                    verticalPosition: y, width: width, height: height)
            rectRequest.cookie = cookie
            onboardTracker.replaceAllTargetsBy(trackingRequest: rectRequest)
        }
    }

    func didSelectProposal(proposalId: UInt) {
        if let frameTimeStamp = frameTimeStamp, let onboardTracker = onboardTracker {
            cookie += 1
            var proposalRequest = onboardTracker.ofProposal(timestamp: frameTimeStamp, proposalId: proposalId)
            proposalRequest.cookie = cookie
            onboardTracker.replaceAllTargetsBy(trackingRequest: proposalRequest)
        }
    }
}

extension OnboardTrackerHudViewController: RawVideoSinkListener {
    func didStart(sink: RawVideoSink, videoFormat: VideoFormat) {}

    func didStop(sink: RawVideoSink) {}

    func frameReady(sink: RawVideoSink, frame: RawVideoSinkFrame) {
        if let metadata = frame.metadata {
            self.trackingStatusDidUpdate(metadata)
        }
    }
}
