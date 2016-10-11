//
//  ViewController.swift
//  ImageInsights
//
//  Created by Mitul Manish on 11/10/2016.
//  Copyright © 2016 Mitul Manish. All rights reserved.
//

import UIKit
import MobileCoreServices
import FirebaseStorage
import Alamofire

class ViewController: UIViewController {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.hidden = true
        activityIndicator.hidesWhenStopped = true
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func uploadImageToStorage(sender: UIButton) {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .PhotoLibrary
        imagePicker.mediaTypes = [kUTTypeImage as String]
        imagePicker.delegate = self
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    private func uploadImageToStorage(data: NSData) {
        activityIndicator.hidden = false
        activityIndicator.stopAnimating()
        let storageRef = FIRStorage.storage().referenceWithPath("photos/sample.jpg")
        let uploadMetaData = FIRStorageMetadata()
        uploadMetaData.contentType = "image/jpeg"
        storageRef.putData(data, metadata: uploadMetaData) { (metadata, error) in
            if error != nil {
                print(error.debugDescription)
                
            } else {
                print("Success")
                print(metadata?.downloadURL()?.absoluteString)
                if let path = metadata?.downloadURL()?.absoluteString {
                    print(path)
                    self.imageInsights(path)
                }
            }
            self.activityIndicator.stopAnimating()
        }
    }
    
    func imageInsights(imagePath: String) {
        
        let params = ["api_key": "d1a562a2f9cc209934068cbb573c29386ef112f3",
                      "url": "\(imagePath)",
                      "version": "2016-05-19"]
        
        Alamofire.request(.GET, "https://gateway-a.watsonplatform.net/visual-recognition/api/v3/classify", parameters: params).response { (request, response, data, error) in
            do {
                let serverData = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments) as? [String: AnyObject]
                print(serverData)
                if let data = serverData {
                    //print(data)
                }
            } catch {
                
            }
        }
    }


}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        guard let mediaType = info[UIImagePickerControllerMediaType] as? String else {
            return
        }
        
        if mediaType == (kUTTypeImage as String) {
            if let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage,
                imageData = UIImageJPEGRepresentation(originalImage, 0.8) {
                uploadImageToStorage(imageData)
            }
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
}
