//
//  QRcodeViewController.swift
//  QRCodeScanner
//
//  Created by 沈冠州 on 2018/5/9.
//  Copyright © 2018年 沈冠州. All rights reserved.
//

import UIKit
import AVFoundation

public class QRCodeScannerViewController: UIViewController {

    @IBOutlet private weak var cameraView: UIView!
    
    var captureSession:AVCaptureSession?
    var videoPreviewLayer:AVCaptureVideoPreviewLayer?
    var qrCodeFrameView:UIView?
    var imagePicker = UIImagePickerController()
    
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.initCamera()
    }
    
    private func initCamera(){
        
        // 取得 AVCaptureDevice 類別的實體來初始化一個device物件，並提供video
        // 作為媒體型態參數
        let captureDevice = AVCaptureDevice.default(for: AVMediaType.video)
        
        // 使用前面的 device 物件取得 AVCaptureDeviceInput 類別的實體
        var error:NSError?
        
        var input: AVCaptureDeviceInput!
        do{
            input = try AVCaptureDeviceInput(device: captureDevice!) as AVCaptureDeviceInput
        } catch {
            input = nil
        }
        //        let input: AnyObject! = AVCaptureDeviceInput(device: captureDevice)
        
        //            AVCaptureDeviceInput.deviceInputWithDevice(captureDevice,)
        if (error != nil) {
            // 假如有錯誤產生、 單純記錄其狀況，不再繼續。
            print("\(error?.localizedDescription)")
            return
        }
        
        // 初始化 captureSession 物件
        captureSession = AVCaptureSession()
        // 在capture session 設定輸入裝置
        captureSession?.addInput(input!)
        
        // 初始化 AVCaptureMetadataOutput 物件並將其設定作為擷取session的輸出裝置
        let captureMetadataOutput = AVCaptureMetadataOutput()
        captureSession?.addOutput(captureMetadataOutput)
        
        // 設定代理並使用預設的調度佇列來執行回呼（call back）
        captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        captureMetadataOutput.metadataObjectTypes = captureMetadataOutput.availableMetadataObjectTypes
        
        // 初始化影像預覽層，並將其加為 viewPreview 視圖層的子層
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
        videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        
        captureSession?.startRunning()
    }
    
    func initCameraScreen(){
        
        videoPreviewLayer?.frame = self.cameraView.bounds
        self.cameraView.layer.addSublayer(videoPreviewLayer!)
        
        let whiteView = UIView(frame: cameraView.bounds)
        let maskLayer = CAShapeLayer() //create the mask layer
        
        let path = UIBezierPath(rect: cameraView.bounds)
        
        
        let maskWidth = self.cameraView.frame.width * 0.9
        let maskHeight = self.cameraView.frame.height * 0.7
        
        let mainPath6 = UIBezierPath(rect: CGRect(x: self.cameraView.center.x - maskWidth * 0.5, y: self.cameraView.center.y - maskHeight * 0.5 - self.cameraView.frame.origin.y, width: maskWidth, height: maskHeight))
        path.append(mainPath6)
        
        // Give the mask layer the path you just draw
        maskLayer.path = path.cgPath
        // Fill rule set to exclude intersected paths
        maskLayer.fillRule = kCAFillRuleEvenOdd
        
        // By now the mask is a rectangle with a circle cut out of it. Set the mask to the view and clip.
        whiteView.layer.mask = maskLayer
        whiteView.clipsToBounds = true
        
        whiteView.alpha = 0.7
        whiteView.backgroundColor = .black
        
        let codedLabel:UILabel = UILabel()
        //        codedLabel.frame = CGRect(x: 200, y: 400, width: 20, height: 300)
        codedLabel.textAlignment = .center
        codedLabel.text = "*將行動條碼對準畫面即可讀取"
        codedLabel.numberOfLines=1
        codedLabel.textColor=UIColor.darkGray
        codedLabel.font=UIFont.systemFont(ofSize: 18)
        //        codedLabel.backgroundColor=UIColor.lightGray
        whiteView.addSubview(codedLabel)
        
        
        codedLabel.translatesAutoresizingMaskIntoConstraints = false
        codedLabel.leadingAnchor.constraint(equalTo: codedLabel.superview!.leadingAnchor).isActive = true
        codedLabel.bottomAnchor.constraint(equalTo: codedLabel.superview!.bottomAnchor, constant: -30).isActive = true
        codedLabel.widthAnchor.constraint(equalTo: codedLabel.superview!.widthAnchor).isActive = true
        
        //If you are in a VC add to the VC's view (over the image)
        qrCodeFrameView = UIView()
        qrCodeFrameView?.layer.borderColor = UIColor.green.cgColor
        qrCodeFrameView?.layer.borderWidth = 2
        cameraView.addSubview(qrCodeFrameView!)
        cameraView.bringSubview(toFront: qrCodeFrameView!)
        
        cameraView.addSubview(whiteView)
        
        self.drawCameraTargetLock()
    }
    
    //繪製相機鎖定綠色邊角
    func drawCameraTargetLock(){
        
        let maskWidth = self.cameraView.frame.width * 0.9
        let maskHeight = self.cameraView.frame.height * 0.7
        let lineLength = self.cameraView.frame.width * 0.2
        let centerOriginY = self.cameraView.center.y - self.cameraView.frame.origin.y
        
        ///左上角
        let aPath = UIBezierPath()
        
        aPath.move(to: CGPoint(x: self.cameraView.center.x - maskWidth * 0.5 + lineLength, y: centerOriginY - maskHeight * 0.5 - 2.5))
        
        aPath.addLine(to: CGPoint(x: self.cameraView.center.x - maskWidth * 0.5 - 2.5, y: centerOriginY - maskHeight * 0.5 - 2.5))
        
        aPath.addLine(to: CGPoint(x: self.cameraView.center.x - maskWidth * 0.5 - 2.5, y: centerOriginY - maskHeight * 0.5 + lineLength))
        
        let aShapeLayer = CAShapeLayer()
        aShapeLayer.path = aPath.cgPath
        aShapeLayer.strokeColor = UIColor.green.cgColor
        aShapeLayer.lineWidth = 5.0
        aShapeLayer.fillColor = UIColor.clear.cgColor
        
        cameraView.layer.addSublayer(aShapeLayer)
        
        ///右上角
        let bPath = UIBezierPath()
        
        bPath.move(to: CGPoint(x: self.cameraView.center.x + maskWidth * 0.5 - lineLength, y: centerOriginY - maskHeight * 0.5 - 2.5))
        
        bPath.addLine(to: CGPoint(x: self.cameraView.center.x + maskWidth * 0.5 + 2.5, y: centerOriginY - maskHeight * 0.5 - 2.5))
        
        bPath.addLine(to: CGPoint(x: self.cameraView.center.x + maskWidth * 0.5 + 2.5, y: centerOriginY - maskHeight * 0.5 + lineLength))
        
        let bShapeLayer = CAShapeLayer()
        bShapeLayer.path = bPath.cgPath
        bShapeLayer.strokeColor = UIColor.green.cgColor
        bShapeLayer.lineWidth = 5.0
        bShapeLayer.fillColor = UIColor.clear.cgColor
        
        cameraView.layer.addSublayer(bShapeLayer)
        
        
        ///左下角
        let cPath = UIBezierPath()
        
        cPath.move(to: CGPoint(x: self.cameraView.center.x - maskWidth * 0.5 + lineLength, y: centerOriginY + maskHeight * 0.5 + 2.5))
        
        cPath.addLine(to: CGPoint(x: self.cameraView.center.x - maskWidth * 0.5 - 2.5, y: centerOriginY + maskHeight * 0.5 + 2.5))
        
        cPath.addLine(to: CGPoint(x: self.cameraView.center.x - maskWidth * 0.5 - 2.5, y: centerOriginY + maskHeight * 0.5 - lineLength))
        
        let cShapeLayer = CAShapeLayer()
        cShapeLayer.path = cPath.cgPath
        cShapeLayer.strokeColor = UIColor.green.cgColor
        cShapeLayer.lineWidth = 5.0
        cShapeLayer.fillColor = UIColor.clear.cgColor
        
        cameraView.layer.addSublayer(cShapeLayer)
        
        ///右下角
        let dPath = UIBezierPath()
        
        dPath.move(to: CGPoint(x: self.cameraView.center.x + maskWidth * 0.5 - lineLength, y: centerOriginY + maskHeight * 0.5 + 2.5))
        
        dPath.addLine(to: CGPoint(x: self.cameraView.center.x + maskWidth * 0.5 + 2.5, y: centerOriginY + maskHeight * 0.5 + 2.5))
        
        dPath.addLine(to: CGPoint(x: self.cameraView.center.x + maskWidth * 0.5 + 2.5, y: centerOriginY + maskHeight * 0.5 - lineLength))
        
        let dShapeLayer = CAShapeLayer()
        dShapeLayer.path = dPath.cgPath
        dShapeLayer.strokeColor = UIColor.green.cgColor
        dShapeLayer.lineWidth = 5.0
        dShapeLayer.fillColor = UIColor.clear.cgColor
        
        cameraView.layer.addSublayer(dShapeLayer)
    }
}

extension QRCodeScannerViewController: AVCaptureMetadataOutputObjectsDelegate{
    
    public func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        // 檢查 metadataObjects 陣列是否為非空值，它至少需包含一個物件
        if metadataObjects == nil || metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRect.zero
            //            messageLabel.text = "No QR code is detected"
            return
        }
        
        // 取得元資料（metadata）物件
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        //倘若發現的原資料與 QR code 原資料相同，便更新狀態標籤的文字並設定邊界
        let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj as
            AVMetadataMachineReadableCodeObject) as! AVMetadataMachineReadableCodeObject
        qrCodeFrameView?.frame = barCodeObject.bounds
        if metadataObj.stringValue != nil {
            
            print(metadataObj.stringValue)
            captureSession?.stopRunning()
            //                self.qrcode = metadataObj.stringValue
            //                self.test()
        }
    }
}

extension QRCodeScannerViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        self.dismiss(animated: true, completion: { () -> Void in
            
            
        })
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        self.dismiss(animated: true, completion: { () -> Void in
            
            self.captureSession?.startRunning()
        })
    }
}

