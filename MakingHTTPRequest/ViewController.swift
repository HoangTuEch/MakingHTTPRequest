//
//  ViewController.swift
//  MakingHTTPRequest
//
//  Created by DatND2 on 7/25/22.
//

import UIKit
import Alamofire

class ViewController: UIViewController {
    lazy var button: UIButton! = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .darkGray
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(didTaped(_:)), for: .touchUpInside)
        button.tag = 1
        button.setTitle("Tap", for: .normal)
        return button
    }()
    
    lazy var label: UILabel! = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.font = .systemFont(ofSize: 20)
        return label
        
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setConstraint()
        // Do any additional setup after loading the view.
    }

    @objc func didTaped(_ sender: UIButton){
        APIServices.instance.getData(of: ResponsePost.self, isHandleError: true, completionHandler: { [weak self] response in
            guard let weakSelf = self else { return }
            weakSelf.label.text = response.body
        })
    }
    
    private func setConstraint() {
        self.view.addSubview(button)
        self.view.addSubview(label)
        
        NSLayoutConstraint.activate([
            button.heightAnchor.constraint(equalToConstant: 60),
            button.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width/2),
            button.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
        
            label.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 100),
            label.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0),
            label.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0)])
    }
}

final class APIServices {
    static let instance = APIServices()
    
    func getData<T: Decodable>(of t: T.Type, isHandleError: Bool = false, isUseHeader: Bool = false, completionHandler: @escaping (T) -> Void) {
        var headers: HTTPHeaders? = nil
        if isUseHeader {
            headers = [HTTPHeader(name: "Authorization", value: "pmJAdo5N26WW74kCEy6RRvIdCScFCbAtKc2o0FNy")]
        }
        
        AF.request("https://jsonplaceholder.typicode.com/posts/1", method: .get, headers: headers)
            .responseAPI(of: T.self, completionHandler: { response in
                switch response {
                case .success(let data):
                    completionHandler(data)
                case .failure(let error):
                    if isHandleError {
                        showAlert(message: error.localizedDescription)
                    } else {
                        print("==========> \(error)")
                    }
                }
            })
    }
}

public func showAlert(message: String) {
    let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
    let OKAction = UIAlertAction(title: "OK", style: .default) { action in
        print("You've pressed OK Button")
    }
    alertController.addAction(OKAction)
    guard let window = UIApplication.firstKeyWindowForConnectedScenes,
          let rootVC = window.rootViewController else {
              return
          }
    rootVC.present(alertController, animated: true, completion: nil)
}


extension UIApplication {
    static var firstKeyWindowForConnectedScenes: UIWindow? {
        UIApplication.shared
            // Of all connected scenes...
            .connectedScenes.lazy

            // ... grab all foreground active window scenes ...
            .compactMap { $0.activationState == .foregroundActive ? ($0 as? UIWindowScene) : nil }

            // ... finding the first one which has a key window ...
            .first(where: { $0.keyWindow != nil })?

            // ... and return that window.
            .keyWindow
    }
}
