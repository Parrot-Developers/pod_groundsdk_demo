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

class StereoVisionSensorCalibViewController: UIViewController, DeviceViewController {

    @IBOutlet weak var calibrationProcessStateLabel: UILabel!
    @IBOutlet weak var indicationLabel: UILabel!
    @IBOutlet weak var renderView: UIView!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var computingIndicator: UIActivityIndicatorView!

    private let groundSdk = GroundSdk()
    private var deviceUid: String?
    private var stereoVisionSensor: Ref<StereoVisionSensor>?
    private var currentPositionLayers: [CAShapeLayer] = []
    private var requiredPositionLayers: [CAShapeLayer] = []

    let prefix = "love_"

    func setDeviceUid(_ uid: String) {
        deviceUid = uid
    }

    // In this view, we do want the screen to keep alive
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.isIdleTimerDisabled = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        if let stereoVisionSensor = stereoVisionSensor?.value {
            if (stereoVisionSensor.calibrationProcessState) != nil {
                stereoVisionSensor.cancelCalibration()
            }
        }
        super.viewWillDisappear(animated)
        UIApplication.shared.isIdleTimerDisabled = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        indicationLabel.text = ""
        calibrationProcessStateLabel.text = ""
        computingIndicator.isHidden = true

        if let drone = groundSdk.getDrone(uid: deviceUid!) {
            stereoVisionSensor = drone.getPeripheral(Peripherals.stereoVisionSensor) { [weak self] stereoVisionSensor in
                self?.actionButton.setTitle("Start", for: .normal)
                if let stereoVisionSensor = stereoVisionSensor {
                    if let calibrationProcessState = stereoVisionSensor.calibrationProcessState {
                        self?.actionButton.setTitle("Stop", for: .normal)

                        self?.calibrationProcessStateLabel.text = """
                        \(calibrationProcessState.currentStep + 1) /  \(stereoVisionSensor.calibrationStepCount)
                        """

                        self?.indicationLabel.text = self?.indicationText(from: calibrationProcessState.indication)

                        if let requiredPosition = calibrationProcessState.requiredPosition {
                            // Clean previous position
                            for layer in self?.requiredPositionLayers ?? [] {
                                layer.removeFromSuperlayer()
                                self?.requiredPositionLayers.removeAll()
                            }

                            // Plan
                            let requiredPositionLayer = CAShapeLayer()
                            self?.view.layer.addSublayer(requiredPositionLayer)
                            requiredPositionLayer.lineJoin = CAShapeLayerLineJoin.miter
                            requiredPositionLayer.strokeColor = UIColor.red.cgColor
                            requiredPositionLayer.fillColor = UIColor.clear.cgColor
                            let path = UIBezierPath()
                            path.move(to: (self?.pointCorrected(
                                point: CGPoint(x: requiredPosition.getLeftTopVertex().getX(),
                                               y: requiredPosition.getLeftTopVertex().getY())))!)
                            path.addLine(to: (self?.pointCorrected(
                                point: CGPoint(x: requiredPosition.getRightTopVertex().getX(),
                                               y: requiredPosition.getRightTopVertex().getY())))!)
                            path.addLine(to: (self?.pointCorrected(
                                point: CGPoint(x: requiredPosition.getRightBottomVertex().getX(),
                                               y: requiredPosition.getRightBottomVertex().getY())))!)
                            path.addLine(to: (self?.pointCorrected(
                                point: CGPoint(x: requiredPosition.getLeftBottomVertex().getX(),
                                               y: requiredPosition.getLeftBottomVertex().getY())))!)
                            path.close()
                            requiredPositionLayer.path = path.cgPath

                            // left top point
                            let leftTopPath = UIBezierPath(arcCenter: (self?.pointCorrected(
                                point: CGPoint(x: requiredPosition.getLeftTopVertex().getX(),
                                               y: requiredPosition.getLeftTopVertex().getY())))!,
                                                           radius: CGFloat(12),
                                                           startAngle: CGFloat(0),
                                                           endAngle: CGFloat(Double.pi * 2),
                                                           clockwise: true)
                            let leftTopLayer = CAShapeLayer()
                            leftTopLayer.path = leftTopPath.cgPath
                            leftTopLayer.fillColor = UIColor(named: (self?.prefix ?? "love_")
                                + "left_top")?.cgColor
                            self?.view.layer.addSublayer(leftTopLayer)

                            // right top point
                            let rightTopPath = UIBezierPath(arcCenter: (self?.pointCorrected(
                                point: CGPoint(x: requiredPosition.getRightTopVertex().getX(),
                                               y: requiredPosition.getRightTopVertex().getY())))!,
                                                            radius: CGFloat(12),
                                                            startAngle: CGFloat(0),
                                                            endAngle: CGFloat(Double.pi * 2),
                                                            clockwise: true)
                            let rightTopLayer = CAShapeLayer()
                            rightTopLayer.path = rightTopPath.cgPath
                            rightTopLayer.fillColor = UIColor(named: (self?.prefix ?? "love_")
                                + "right_top")?.cgColor
                            self?.view.layer.addSublayer(rightTopLayer)

                            // right bottom point
                            let rightBottomPath = UIBezierPath(arcCenter: (self?.pointCorrected(
                                point: CGPoint(x: requiredPosition.getRightBottomVertex().getX(),
                                               y: requiredPosition.getRightBottomVertex().getY())))!,
                                                               radius: CGFloat(12),
                                                               startAngle: CGFloat(0),
                                                               endAngle: CGFloat(Double.pi * 2),
                                                               clockwise: true)
                            let rightBottomLayer = CAShapeLayer()
                            rightBottomLayer.path = rightBottomPath.cgPath
                            rightBottomLayer.fillColor = UIColor(named: (self?.prefix ?? "love_")
                                + "right_bottom")?.cgColor
                            self?.view.layer.addSublayer(rightBottomLayer)

                            // left bottom point
                            let leftBottomPath = UIBezierPath(arcCenter: (self?.pointCorrected(
                                point: CGPoint(x: requiredPosition.getLeftBottomVertex().getX(),
                                               y: requiredPosition.getLeftBottomVertex().getY())))!,
                                                              radius: CGFloat(12),
                                                              startAngle: CGFloat(0),
                                                              endAngle: CGFloat(Double.pi * 2),
                                                              clockwise: true)
                            let leftBottomLayer = CAShapeLayer()
                            leftBottomLayer.path = leftBottomPath.cgPath
                            leftBottomLayer.fillColor = UIColor(named: (self?.prefix ?? "love_")
                                + "left_bottom")?.cgColor
                            self?.view.layer.addSublayer(leftBottomLayer)

                            self?.requiredPositionLayers.append(contentsOf: [requiredPositionLayer, leftTopLayer,
                                                            rightTopLayer, rightBottomLayer, leftBottomLayer])
                        }

                        for layer in self?.currentPositionLayers ?? [] {
                            layer.removeFromSuperlayer()
                            self?.currentPositionLayers.removeAll()
                        }

                        if self?.shouldShow(from: calibrationProcessState.indication) ?? false {
                            if let currentPosition = calibrationProcessState.currentPosition {
                                // Plan
                                let currentPositionLayer = CAShapeLayer()
                                self?.view.layer.addSublayer(currentPositionLayer)
                                currentPositionLayer.lineWidth = 2
                                currentPositionLayer.lineJoin = CAShapeLayerLineJoin.miter
                                currentPositionLayer.fillColor = UIColor(named: (self?.prefix ?? "love_")
                                    + "primary")?.cgColor

                                let path = UIBezierPath()
                                path.move(to: (self?.pointCorrected(
                                    point: CGPoint(x: currentPosition.getLeftTopVertex().getX(),
                                                   y: currentPosition.getLeftTopVertex().getY())))!)
                                path.addLine(to: (self?.pointCorrected(
                                    point: CGPoint(x: currentPosition.getRightTopVertex().getX(),
                                                   y: currentPosition.getRightTopVertex().getY())))!)
                                path.addLine(to: (self?.pointCorrected(
                                    point: CGPoint(x: currentPosition.getRightBottomVertex().getX(),
                                                   y: currentPosition.getRightBottomVertex().getY())))!)
                                path.addLine(to: (self?.pointCorrected(
                                    point: CGPoint(x: currentPosition.getLeftBottomVertex().getX(),
                                                   y: currentPosition.getLeftBottomVertex().getY())))!)
                                path.close()
                                currentPositionLayer.path = path.cgPath

                                // left top point
                                let leftTopPath = UIBezierPath(arcCenter: (self?.pointCorrected(
                                    point: CGPoint(x: currentPosition.getLeftTopVertex().getX(),
                                                   y: currentPosition.getLeftTopVertex().getY())))!,
                                                               radius: CGFloat(12),
                                                               startAngle: CGFloat(0),
                                                               endAngle: CGFloat(Double.pi * 2),
                                                               clockwise: true)
                                let leftTopLayer = CAShapeLayer()
                                leftTopLayer.path = leftTopPath.cgPath
                                leftTopLayer.fillColor = UIColor.clear.cgColor
                                leftTopLayer.strokeColor = UIColor(named: (self?.prefix ?? "love_") +
                                    "left_top")?.cgColor
                                leftTopLayer.lineWidth = 1
                                self?.view.layer.addSublayer(leftTopLayer)

                                // right top point
                                let rightTopPath = UIBezierPath(arcCenter: (self?.pointCorrected(
                                    point: CGPoint(x: currentPosition.getRightTopVertex().getX(),
                                                   y: currentPosition.getRightTopVertex().getY())))!,
                                                                radius: CGFloat(12),
                                                                startAngle: CGFloat(0),
                                                                endAngle: CGFloat(Double.pi * 2),
                                                                clockwise: true)
                                let rightTopLayer = CAShapeLayer()
                                rightTopLayer.path = rightTopPath.cgPath
                                rightTopLayer.fillColor = UIColor.clear.cgColor
                                rightTopLayer.strokeColor = UIColor(named: (self?.prefix ?? "love_")
                                    + "right_top")?.cgColor
                                rightTopLayer.lineWidth = 1
                                self?.view.layer.addSublayer(rightTopLayer)

                                // right bottom point
                                let rightBottomPath = UIBezierPath(arcCenter: self!.pointCorrected(
                                    point: CGPoint(x: currentPosition.getRightBottomVertex().getX(),
                                                   y: currentPosition.getRightBottomVertex().getY())),
                                                                   radius: CGFloat(12),
                                                                   startAngle: CGFloat(0),
                                                                   endAngle: CGFloat(Double.pi * 2),
                                                                   clockwise: true)
                                let rightBottomLayer = CAShapeLayer()
                                rightBottomLayer.path = rightBottomPath.cgPath
                                rightBottomLayer.fillColor = UIColor.clear.cgColor
                                rightBottomLayer.strokeColor = UIColor(named: (self?.prefix ?? "love_")
                                    + "right_bottom")?.cgColor
                                rightBottomPath.lineWidth = 1
                                self?.view.layer.addSublayer(rightBottomLayer)

                                // left bottom point
                                let leftBottomPath = UIBezierPath(arcCenter: self!.pointCorrected(
                                    point: CGPoint(x: currentPosition.getLeftBottomVertex().getX(),
                                                   y: currentPosition.getLeftBottomVertex().getY())),
                                                                  radius: CGFloat(12),
                                                                  startAngle: CGFloat(0),
                                                                  endAngle: CGFloat(Double.pi * 2),
                                                                  clockwise: true)
                                let leftBottomLayer = CAShapeLayer()
                                leftBottomLayer.path = leftBottomPath.cgPath
                                leftBottomLayer.fillColor = UIColor.clear.cgColor
                                leftBottomLayer.strokeColor = UIColor(named: (self?.prefix ?? "love_")
                                    + "left_bottom")?.cgColor
                                leftBottomLayer.lineWidth = 1
                                self?.view.layer.addSublayer(leftBottomLayer)

                                self?.currentPositionLayers.append(contentsOf: [currentPositionLayer, leftTopLayer,
                                                                                rightTopLayer, rightBottomLayer,
                                                                                leftBottomLayer])
                            }
                        }

                        if let requiredPosition = calibrationProcessState.requiredPosition {
                            if let requiredRotation = calibrationProcessState.requiredRotation {
                                print("""
                                    requiredRotation X: \(requiredRotation.xAngle)
                                    Y: \(requiredRotation.yAngle)
                                    """)

                                let requiredBallPath = UIBezierPath(
                                    arcCenter: (self?.ballCorrected( rotation: requiredRotation,
                                                                     frame: requiredPosition))!,
                                    radius: CGFloat(12),
                                    startAngle: CGFloat(0),
                                    endAngle: CGFloat(Double.pi * 2),
                                    clockwise: true)
                                let requiredBallLayer = CAShapeLayer()
                                requiredBallLayer.path = requiredBallPath.cgPath
                                requiredBallLayer.strokeColor = UIColor(named: (self?.prefix ?? "love_")
                                + "ball")?.cgColor
                                requiredBallLayer.fillColor = UIColor.clear.cgColor
                                self?.view.layer.addSublayer(requiredBallLayer)
                                self?.requiredPositionLayers.append(requiredBallLayer)
                            }
                        }

                        if self?.shouldShow(from: calibrationProcessState.indication) ?? false {
                            if let requiredPosition = calibrationProcessState.requiredPosition {
                                if let currentRotation = calibrationProcessState.currentRotation {
                                    let currentBallPath = UIBezierPath(
                                        arcCenter: (self?.ballCorrected( rotation: currentRotation,
                                                                         frame: requiredPosition))!,
                                        radius: CGFloat(10),
                                        startAngle: CGFloat(0),
                                        endAngle: CGFloat(Double.pi * 2),
                                        clockwise: true)
                                    let currentBallLayer = CAShapeLayer()
                                    currentBallLayer.path = currentBallPath.cgPath
                                    currentBallLayer.fillColor = UIColor(named: (self?.prefix ?? "love_")
                                    + "ball")?.cgColor
                                    self?.view.layer.addSublayer(currentBallLayer)
                                    self?.currentPositionLayers.append(currentBallLayer)
                                }
                            }
                        }
                        if calibrationProcessState.isComputing {
                            self?.computingIndicator.isHidden = false
                            self?.computingIndicator.startAnimating()
                            for layer in self?.currentPositionLayers ?? [] { layer.removeFromSuperlayer() }
                            for layer in self?.requiredPositionLayers ?? [] { layer.removeFromSuperlayer() }
                            self?.indicationLabel.text = "Computing"
                        } else {
                            self?.computingIndicator.isHidden = true
                            self?.computingIndicator.stopAnimating()
                        }
                        if calibrationProcessState.result != .none {
                            let alertController =
                                UIAlertController(title: "Calibration result",
                                                  message: calibrationProcessState.result.description,
                                                  preferredStyle: .alert)
                            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                            self?.present(alertController, animated: true, completion: nil)
                        }
                    } else {
                        self?.calibrationProcessStateLabel.text = "\(stereoVisionSensor.calibrationStepCount) steps"
                    }
                } else {
                    self?.performSegue(withIdentifier: "exit", sender: self)
                }
            }
        }
    }

    func shouldShow(from indication: StereoVisionIndication) -> Bool {
        var bReturn = true
        if indication == .checkBoardAndCameras ||
            indication == .placeWithinSight ||
            indication == .none || indication == .none {
            bReturn = false
        }
        return bReturn
    }

    func pointCorrected(point: CGPoint) -> CGPoint {
        return CGPoint(x: renderView.frame.origin.x + point.x * renderView.frame.size.width,
                       y: renderView.frame.origin.y + point.y * renderView.frame.size.height)
    }

    func ballCorrected(rotation: StereoVisionRotation, frame: StereoVisionFrame) -> CGPoint {
        var newCenter: CGPoint = CGPoint()
        let ratioX: Double = rotation.xAngle / 90.0
        let ratioY: Double = rotation.yAngle / 90.0
        let rightValueX = (1.0 + ratioX) * (frame.getRightTopVertex().getX() + frame.getRightBottomVertex().getX())
        let leftValueX = (1.0 - ratioX) * (frame.getLeftTopVertex().getX() + frame.getLeftBottomVertex().getX())
        newCenter.x = CGFloat((rightValueX + leftValueX) / 4.0)
        let bottomValueY = (1.0 + ratioY) * (frame.getLeftBottomVertex().getY() + frame.getRightBottomVertex().getY())
        let topValueY = (1.0 - ratioY) * (frame.getLeftTopVertex().getY() + frame.getRightTopVertex().getY())
        newCenter.y = CGFloat((bottomValueY + topValueY) / 4.0)
        return pointCorrected(point: newCenter)
    }

    func indicationText(from indication: StereoVisionIndication) -> String? {
        var szImageName = ""
        switch indication {
        case .none:
            szImageName = ""
        case .checkBoardAndCameras:
            szImageName = "Board is partially hidden"
        case .placeWithinSight:
            szImageName = "Board out of frame"
        case .moveAway:
            szImageName = "Move the board away from the drone"
        case .moveCloser:
            szImageName = "Bring the board toward the drone"
        case .moveLeft:
            szImageName = "Move the board to the left"
        case .moveRight:
            szImageName = "Move the board to the right"
        case .moveUpward:
            szImageName = "Move the board up"
        case .moveDownward:
            szImageName = "Move the board down"
        case .turnClockwise:
            szImageName = "Rotate the board to the right"
        case .turnCounterClockwise:
            szImageName = "Rotate the board to the left"
        case .tiltLeft, .tiltRight, .tiltForward, .tiltBackward:
            szImageName = "Place the ball in the circle"
        case .stop:
            szImageName = "Don't move"
        }

        return (szImageName.count > 0) ? szImageName : nil
    }

    @IBAction func actionPushed(_ sender: UIButton) {
        if let stereoVisionSensor = stereoVisionSensor?.value {
            if (stereoVisionSensor.calibrationProcessState) != nil {
                stereoVisionSensor.cancelCalibration()
                cleanLayers()
            } else {
                stereoVisionSensor.startCalibration()
            }
        }
    }

    func cleanLayers() {
        for layer in self.currentPositionLayers { layer.removeFromSuperlayer() }
        for layer in self.requiredPositionLayers { layer.removeFromSuperlayer() }
    }
}
