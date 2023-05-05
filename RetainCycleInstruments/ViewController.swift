//
//  ViewController.swift
//  RetainCycleInstruments
//
//  Created by Joseph Langat on 04/05/2023.
//  Weak and Unowned Self Closure Memory Leak Fixes

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Show Red", style: .plain, target: self, action: #selector(handleShowRedController))
    }
    @objc func handleShowRedController() {
        navigationController?.pushViewController(RedController(), animated: true)
    }
}

class Service {
    static let shared = Service()
    
    func fetchData(completion: @escaping (Error?) ->()) {
        guard let url = URL(string: "https://www.google.com") else {return}
        URLSession.shared.dataTask(with: url) { (_, _, _) in
            completion(nil)
        }
    }
}

class RedController: UITableViewController {
    deinit {
        print("OS reclaiming memmory for  RedContoller - NO Retain Cycle/Leak!")
    }
    var refreshTableViewClosure: ((Data?, Error?) -> ())?
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundColor = .red
        
        Service.shared.fetchData { [weak self] (err) in
            if let err = err {
                return
            }
            self?.showAlert()
        }
        
        refreshTableViewClosure = { [weak self](data, err) in
            self?.showAlert()
        }
        //notification center retain cycle with closure
//        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "someNotificationName"), object: nil, queue: .main) { [unowned self] (notification) in
//            self.showAlert()
//        }
    }
    func showAlert() {
        let alertController = UIAlertController(title: "Alert", message: "Message!!!", preferredStyle: .alert)
        present(alertController, animated: true)
    }
}
/*
 Within iOS applications, the problem with this code is that unless we get notified of a particular notification, we won't be able to deallocate memory. Instead, inside the closure, we respond by calling this show alert function. I'm going to run this application again. For those of you who are unaware, there is already a retain cycle that we're introducing by using these "self". Let's confirm that the retain cycle is actually there by clicking on "show read" and hitting the back button to pop our read controller off. In the bottom console area, we're not seeing this deinitializer print statement of OS reclaiming memory, so that's how we can confirm that there's a memory leak. Notification Center is actually capturing "self" as a strong reference inside of Notification Center, meaning that when you're trying to deallocate the memory for this read controller, Notification Center has a reference to it, so it's not able to correctly deallocate that space. The way to actually fix this is to go ahead and say "weak" and "self" right in front of the variables for your closure. Whenever you introduce "self" as "weak" like this, you have to make sure to use a question mark for the optional chaining. The difference between the "weak" and the "unowned" is pretty difficult to explain, but if you're able to guarantee that this "self" guy will never be nil, then you can use the "unowned" self. It's kind of what I wanted to show you in today's video, and I guess before I end today's lesson, maybe I'll talk about something else as well. Sometimes when you do something like this, you can say "var" and something like "refresh table view closure". If you have this closure, you can declare a roof as "refresh table view closure" and set it equal to some kind of closure.
 */
