//
//  BookViewController.swift
//  HackerBooks
//
//  Created by Akixe on 3/7/16.
//  Copyright © 2016 AOA. All rights reserved.
//

import UIKit

class BookViewController: UIViewController, LibraryViewControllerDelegate {
    @IBOutlet weak var theTitle: UILabel!
    @IBOutlet weak var authors: UILabel!
    @IBOutlet weak var labels: UILabel!
    @IBOutlet weak var coverImg: UIImageView!
    @IBOutlet weak var favbtn: UIButton!

    var model : Book
    

    init(model:Book) {
        self.model = model
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func syncModelWithView(){
        title = "Detalle"
        theTitle.text = model.title
        authors.text = model.literalAuthors
        labels.text = model.literalTags
        coverImg.image = model.cover
        favbtn.selected = model.favorite
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        favbtn.selected = true
        favbtn.setImage(UIImage(named: "starredOn"), forState: .Selected)
        favbtn.setImage(UIImage(named: "starredOff"), forState: .Normal)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        syncModelWithView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    @IBAction func openPDF(sender: AnyObject) {
        let pdfViewCtrl = PDFViewController(model: model)
        navigationController?.pushViewController(pdfViewCtrl, animated: false)
        //Hacer push sobre NavigationController
    }
    
    @IBAction func favSelected(sender: UIButton) {
        favbtn.selected = !favbtn.selected
        if sender.selected {
            model.favorite = true
        } else {
            model.favorite = false
        }
    }

    //MARK: - Delegate
    func libraryViewController(viewCtrl: LibraryViewController, didSelectBook book: Book) {
        // El comportamiento que he pensado para salir de la vista PDF era 
        //   el quitar la vista de PDFViewCtrl cuando seleccione otro libro
        //   en el TableView...En el curso vimos otra implementación cargando
        //   el wiki correspondiente al nuevo Character de SW, pero en este caso 
        //   he preferido pelearme (me ha costado dar con esta solución, el patrón
        //   delegado es lo que más me esta costando "pillar")
        self.navigationController?.popViewControllerAnimated(true) // el popViewController permite quitar la vista "detalle" del navigation controller

        
        //Actualizar modelo
        self.model = book
        //Sincronizar vistas con nuevo modelo
        syncModelWithView()
    }
}
