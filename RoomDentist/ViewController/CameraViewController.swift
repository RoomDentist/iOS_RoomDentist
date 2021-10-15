//
//  CameraViewController.swift
//  RoomDentist
//
//  Created by LDH on 2021/10/09.
//

import UIKit
import AVFoundation
import Photos
import Firebase
import Alamofire

class CameraViewController: UIViewController {
    // TODO: 초기 설정 1
    // MARK: CaptureSession
    // MARK: AVCaptureDeviceInput
    // MARK: AVCapturePhotoOutput
    // MARK: DispatchQueue
    // MARK: AVCaptureDevice -> 카메라 찾아주는 것.
    
    let storage = Storage.storage().reference().child("users")
    let captureSession = AVCaptureSession()
    var videoDeviceInput: AVCaptureDeviceInput! // 혼자 객체가아닌 나중에 디바이스 넣어줄 것이라 var로 설정. 카메라 토글 시키기 위해서
    let photoOutput = AVCapturePhotoOutput()
    var cameraImage = UIImage()
    var DateModels = DateModel()
    var imageCount = 0
    
    let sessionQueue = DispatchQueue(label: "sesstion Queue")
    let videoDeviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInDualCamera, .builtInWideAngleCamera, .builtInTrueDepthCamera], mediaType: .video, position: .unspecified) // 앞에꺼인지, 뒤에꺼인지 아직 안정해서

    @IBOutlet weak var previewView: PreviewView!
    @IBOutlet weak var captureButton: UIButton!
    @IBOutlet weak var blurBGView: UIVisualEffectView!
    @IBOutlet weak var switchButton: UIButton!
    @IBOutlet weak var prevButton: UIButton!
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // TODO: 초기 설정 2
        previewView.session = captureSession // 이렇게 연결 시키기
        sessionQueue.async {
            self.setupSession()
            self.startSession()
        }
        setupUI()
        // MARK: 저장하기 전 사진 개수 파악
        refreshCount()
    }
    
    func setupUI() {
        captureButton.layer.cornerRadius = captureButton.bounds.height / 2
        captureButton.layer.masksToBounds = true
        
        blurBGView.layer.cornerRadius = captureButton.bounds.height / 2
        blurBGView.layer.masksToBounds = true
        
    }    
    
    @IBAction func prevPageEvent(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func switchCamera(sender: Any) {
        // TODO: 카메라는 1개 이상이어야함
        guard videoDeviceDiscoverySession.devices.count > 1 else {
            return
        }
        
        // TODO: 반대 카메라 찾아서 재설정
        // - 반대 카메라 찾기
        // - 새로운 디바이스 가지고 세션을 업데이트
        // - 카메라 토글 버튼 업데이트
        
        sessionQueue.async {
            // - 반대 카메라 찾기
            let currentVideoDevice = self.videoDeviceInput.device
            let currentPosition = currentVideoDevice.position // 프로퍼티로 제공
            let isFront = currentPosition == .front
            let preferredPosition: AVCaptureDevice.Position = isFront ? .back : .front
            
            let devices = self.videoDeviceDiscoverySession.devices
            var newVideoDevice: AVCaptureDevice?
            
            newVideoDevice = devices.first(where: { device in
                return preferredPosition == device.position
            })
            
            // - 새로운 디바이스 가지고 세션을 업데이트
            // update capture Session
            if let newDevice = newVideoDevice {
                
                do {
                    let videoDeviceInput = try AVCaptureDeviceInput(device: newDevice)
                    self.captureSession.beginConfiguration()
                    self.captureSession.removeInput(self.videoDeviceInput) // 기존의 인풋 제거
                    
                    // ADD new device input
                    if self.captureSession.canAddInput(videoDeviceInput) {
                        self.captureSession.addInput(videoDeviceInput)
                        self.videoDeviceInput = videoDeviceInput
                    } else {
                        self.captureSession.addInput(self.videoDeviceInput)
                    }
                    
                    self.captureSession.commitConfiguration()
                    
                    // 아이콘 업데이트, UI는 mainqueue에서 진행 필.
                    DispatchQueue.main.async {
                        self.updateSwitchCameraIcon(position: preferredPosition)
                    }
                    
                } catch let error {
                    print("[카메라뷰] error occured while creating device input \(error.localizedDescription)")
                }
            }
        }
    }
    
    func updateSwitchCameraIcon(position: AVCaptureDevice.Position) {
        // TODO: Update ICON
        switch position {
        case .front:
            let image = #imageLiteral(resourceName: "ic_camera_front")
            switchButton.setImage(image, for: .normal)
        case .back:
            let image = #imageLiteral(resourceName: "ic_camera_rear")
            switchButton.setImage(image, for: .normal)
        default:
            break
        }
    }
    
    @IBAction func capturePhoto(_ sender: UIButton) {
        // TODO: photoOutput의 capturePhoto 메소드
        // - 오리엔테이션
        // - photo output setting
        
        let videoPreviewLayerOrientation = self.previewView.videoPreviewLayer.connection?.videoOrientation // 현재 캡쳐 세션 오리엔테이션 가져오기
        sessionQueue.async {
            let connection = self.photoOutput.connection(with: .video)
            connection?.videoOrientation = videoPreviewLayerOrientation!
            
            let setting = AVCapturePhotoSettings()
            self.photoOutput.capturePhoto(with: setting, delegate: self) // photo Output에 사진찍자 알려주기
        }
    }
    
    func savePhotoLibrary(image: UIImage) {
        // TODO: capture한 이미지 포토라이브러리에 저장
        
        PHPhotoLibrary.requestAuthorization { status in
            if status == .authorized {
                // 허락 받았으니 저장
                PHPhotoLibrary.shared().performChanges {
                    PHAssetChangeRequest.creationRequestForAsset(from: image) // 이미지를 포토 라이브러리에 넣겠다.
                } completionHandler: { (success, error) in
                    print("----> 이미지 저장 완료 했나? \(success)")
                }

            } else {
                // 다시 요청
                print("---> 권한을 아직 받지 못함")
            }
        }
        
        // MARK: imagePicker 실행
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self //3
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true)
    }
}

extension CameraViewController {
    // MARK: - Setup session and preview
    func setupSession() {
        // TODO: captureSession 구성하기
        // - presetSetting 하기
        // - beginConfiguration
        // - Add Video Input
        // - Add Photo Output
        // - commitConfiguration
        
        captureSession.sessionPreset = .photo
        captureSession.beginConfiguration() // 나 구성 시작할거야! 알리기
        
        // ADD VideoInput
        var defaultVideoDevice: AVCaptureDevice?
        
        guard let camera = videoDeviceDiscoverySession.devices.first else {
            captureSession.commitConfiguration()
            return
        }
        do {
            let videoDeviceInput = try AVCaptureDeviceInput(device: camera)
            if captureSession.canAddInput(videoDeviceInput) {
                captureSession.addInput(videoDeviceInput)
                self.videoDeviceInput = videoDeviceInput
            } else {
                captureSession.commitConfiguration()
                return
            }
        } catch let error {
            captureSession.commitConfiguration()
            return
        }
        
        // ADD Photo Output
        photoOutput.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])], completionHandler: nil) // 어떤 포맷으로 저장할 지
        
        if captureSession.canAddOutput(photoOutput) {
            captureSession.addOutput(photoOutput)
        } else {
            captureSession.commitConfiguration()
            return
        }
        
        captureSession.commitConfiguration() //  구성 끝!
    }
    
    func startSession() {
        // TODO: session Start
        sessionQueue.async {
            if !self.captureSession.isRunning {
                self.captureSession.startRunning()
            }
        }
    }
    
    func stopSession() {
        // TODO: session Stop
        sessionQueue.async {
            if self.captureSession.isRunning {
                self.captureSession.stopRunning()
            }
        }
    }
}

extension CameraViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        // TODO: capturePhoto delegate method 구현
        guard error == nil else { return }
        guard let imageData = photo.fileDataRepresentation() else { return }
        guard let image = UIImage(data: imageData) else { return }
        self.savePhotoLibrary(image: image)
    }
}

// MARK: imagePicker Delegate
extension CameraViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            cameraImage = pickedImage
            self.saveUserImage(img: self.cameraImage)
        } else {
            dismiss(animated: true, completion: nil)
        }
        dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
    }
        
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: 파일 업로드
extension CameraViewController {
    func saveUserImage(img: UIImage) {
        var date = DateModels.date
        var data = Data()
        data = img.jpegData(compressionQuality: 1)!
        let filePath = Auth.auth().currentUser?.uid
        let metaData = StorageMetadata()
        metaData.contentType = "image/png"
        print("[카메라뷰] 저장 전 이미지 개수는? : \(self.imageCount)")
        storage.child(filePath!).child(date).child("\(self.imageCount + 1).png").putData(data, metadata: metaData) { [self] (metaData, error) in if let error = error {
                print(error.localizedDescription)
                return
            } else {
                print("[카메라뷰] 업로드 성공")
                self.postData(uid: "\(filePath!)", imageCount: self.imageCount + 1)
                dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func refreshCount() {
        let filePath = Auth.auth().currentUser?.uid
        DateModel.checkFileMetadates(uid: filePath!, date: DateModels.date, completion: {
            self.imageCount = $0
            print("[카메라뷰] API에서 count : \(self.imageCount)")
        })
    }
    
    func postData(uid: String, imageCount: Int) {
        let url = "https://roomdentist.tunahouse97.com/Auth"
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 10
        
        // POST 로 보낼 정보
        let params = ["uid": "\(uid)", "numbers": "\(imageCount)"] as Dictionary

        // httpBody 에 parameters 추가
        do {
            try request.httpBody = JSONSerialization.data(withJSONObject: params, options: [])
        } catch {
            print("http Body Error")
        }
        
        AF.request(request).responseString { (response) in
            switch response.result {
            case .success:
                print("POST 성공")
            case .failure(let error):
                print("🚫 Alamofire Request Error\nCode:\(error._code), Message: \(error.errorDescription!)")
            }
        }
        dismiss(animated: true, completion: nil)
    }
}
