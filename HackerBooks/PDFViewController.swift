//
//  PDFViewController.swift
//  HackerBooks
//
//  Created by Akixe on 14/7/16.
//  Copyright © 2016 AOA. All rights reserved.
//

import UIKit

class PDFViewController: UIViewController {

    @IBOutlet weak var webView: UIWebView!
    var model : Book
    
    init(model: Book) {
        self.model = model
        super.init(nibName:nil, bundle:nil)
    }
	
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        syncModelAndView()
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func syncModelAndView () {
        if let bookData = model.bookPDF {
            webView.loadData(bookData, MIMEType: "application/pdf", textEncodingName: "", baseURL: model.bookURL)
        }
    }
    
    

}
