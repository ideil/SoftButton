//
//  ViewController.swift
//  SoftButtonExample
//
//  Copyright © 2018 ideil. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func hello(_ sender: Any) {
        print("\(Date()) — Clicked")
    }

}
