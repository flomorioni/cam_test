//
//  ViewController.swift
//  Cam
//
//  Created by Mohraz, Karim on 1/5/17.
//  Copyright © 2017 KM. All rights reserved.
//

import UIKit
import MobileCoreServices

class ViewController: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var newMedia: Bool?
    var classificationResult: String?
    var urlRequest: URLRequest?
    var session: URLSession?
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var labelProduct: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //configure_request()
        // set up the session
        // let config = URLSessionConfiguration.default
        session = URLSession.shared //URLSession(configuration: config)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func useCamera(_ sender: AnyObject) {
        if UIImagePickerController.isSourceTypeAvailable(
            UIImagePickerControllerSourceType.camera) {
            
            let imagePicker = UIImagePickerController()
            
            imagePicker.delegate = self
            imagePicker.sourceType =
                UIImagePickerControllerSourceType.camera
            imagePicker.mediaTypes = [kUTTypeImage as String]
            imagePicker.allowsEditing = false
            
            self.present(imagePicker, animated: true,
                         completion: nil)
            newMedia = true
        }
    }
    
    @IBAction func useCameraRoll(_ sender: AnyObject) {
        if UIImagePickerController.isSourceTypeAvailable(
            UIImagePickerControllerSourceType.savedPhotosAlbum) {
            let imagePicker = UIImagePickerController()
            
            imagePicker.delegate = self
            imagePicker.sourceType =
                UIImagePickerControllerSourceType.photoLibrary
            imagePicker.mediaTypes = [kUTTypeImage as String]
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true,
                         completion: nil)
            newMedia = false
        }
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let mediaType = info[UIImagePickerControllerMediaType] as! NSString
        
        self.dismiss(animated: true, completion: nil)
        
        if mediaType.isEqual(to: kUTTypeImage as String) {
            let image = info[UIImagePickerControllerOriginalImage]
                as! UIImage
            
            imageView.image = image
            
            if (newMedia == true) {
                UIImageWriteToSavedPhotosAlbum(image, self,
                                               #selector(ViewController.image(image:didFinishSavingWithError:contextInfo:)), nil)
            } else if mediaType.isEqual(to: kUTTypeMovie as String) {
                // Code to support video here
            }
            
        }
    }
    
    func image(image: UIImage, didFinishSavingWithError error: NSErrorPointer, contextInfo:UnsafeRawPointer) {
        
        if error != nil {
            let alert = UIAlertController(title: "Save Failed",
                                          message: "Failed to save image",
                                          preferredStyle: UIAlertControllerStyle.alert)
            
            let cancelAction = UIAlertAction(title: "OK",
                                             style: .cancel, handler: nil)
            
            alert.addAction(cancelAction)
            self.present(alert, animated: true,
                         completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func classify(_ sender: Any) {
        let lower : UInt32 = 1
        let upper : UInt32 = 500
        let randomNumber = arc4random_uniform(upper - lower) + lower
        configure_request(record: randomNumber)
        makeGetCall()
    }
    
    func configure_request(record: UInt32) {
        // Set up the URL request
        let todoEndpoint: String = "https://jsonplaceholder.typicode.com/comments/" + String(record)
        guard let url = URL(string: todoEndpoint) else {
            print("Error: cannot create URL")
            return
        }
        urlRequest = URLRequest(url: url)
        
        self.labelProduct.text = "sending request ..."
        self.labelProduct.backgroundColor = UIColor.orange
      }

    func makeGetCall() {
        // make the request
        let task = session?.dataTask(with: urlRequest!) {
            (data, response, error) in
            // check for any errors
            guard error == nil else {
                print("error calling GET on /comments/#")
               // print(error)
                return
            }
            // make sure we got data
            guard let responseData = data else {
                print("Error: did not receive data")
                return
            }
            // parse the result as JSON, since that's what the API provides
            do {
                guard let todo = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: AnyObject] else {
                    print("error trying to convert data to JSON")
                    return
                }
                // now we have the todo, let's just print it to prove we can access it
                print("The email is: " + todo.description)
                
                // the todo object is a dictionary
                // so we just access the title using the "title" key
                // so check for a title and print it if we have one
                guard let todoTitle = todo["email"] as? String else {
                    print("Could not get todo title from JSON")
                    return
                }
                
                DispatchQueue.main.async {
                    self.labelProduct.backgroundColor = UIColor.lightGray
                    self.classificationResult = "The output is: " + todoTitle
                    self.labelProduct.text = self.classificationResult
                }
                
            } catch  {
                print("error trying to convert data to JSON")
                return
            }
        }
        
        task?.resume()
    }
    
}

