    //
//  LibraryViewController.swift
//  HackerBooks
//
//  Created by Akixe on 3/7/16.
//  Copyright © 2016 AOA. All rights reserved.
//

import UIKit

class LibraryViewController: UITableViewController, LibraryViewControllerDelegate {

    let model : Library
    var delegate : LibraryViewControllerDelegate?
    var tagView = true
    
    init(model: Library) {
        self.model = model
        super.init(nibName:nil, bundle:nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Titulo del View
        self.title = "HackerBooks"

        // Añado el boton ABC/Tags para que cuando lo pulsen canbie el tipo de ordenación de la Tabla
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "ABC", style: UIBarButtonItemStyle.Plain, target: self, action: "change")

        // Añado la referencia de la celda personalizada
        //   Lo he tenido que pasar aquí desde el viewWillAppeare. Me daba un error (se enseñaba así en el curso de ios Avanzado)
        //   Posteriormente se confirma en Slack
        let cellNib : UINib = UINib(nibName: "BookViewCell", bundle: nil)
        self.tableView.registerNib(cellNib
            , forCellReuseIdentifier: BookViewCell.cellId())
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        // Alta en notificación de cambios del modelo de libro
        let nc = NSNotificationCenter.defaultCenter()
        // Añado observador
        //   - Dudas con el selector la sintaxis #selector(xxx...) me daba errores...Tengo Swift 2.1 y no he podido migrar a Swift 2.2 :'(
        nc.addObserver(self, selector:"bookModelDidChange:", name: BookDidChange, object: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        if tagView {
            return model.tagCount()
        } else {
            return 1
        }
        
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if tagView {
            return model.bookCountAtTagIndex(section)
        } else {
            return model.totalBookCount()
        }
    }
    
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if tagView {
            return model.tagForIndex(section).name
        } else {
            return nil
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // Según el tipo de vista de tabla (tag|ABC) obtenemos el book que corresponde
        let book = bookAtIndexPath(indexPath)

        // Celda personalizada
        let cell : BookViewCell = tableView.dequeueReusableCellWithIdentifier(BookViewCell.cellId()) as! BookViewCell
        
        // Portada
        // ========
        cell.imageView?.image = book.cover

        // Título
        // ======
        cell.title.text = book.title

        // Autores
        // =======
        // ToDo -> crear clase propia para Author
        cell.authors.text = book.literalAuthors
        

        // Tags
        // ====
        cell.tags.text = book.literalTags
        
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return BookViewCell.cellHeight()
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let book = bookAtIndexPath(indexPath)
        
        delegate?.libraryViewController(self, didSelectBook: book)
        
        
    }
    
    //MARK: - Delegate
    func libraryViewController(viewCtrl: LibraryViewController, didSelectBook book: Book) {
        let bookVC = BookViewController(model: book)
        
        navigationController?.pushViewController(bookVC, animated: true)
    }
    
    //MARK: - Otros
    func change(){
        if self.navigationItem.rightBarButtonItem?.title == "ABC" {
            self.navigationItem.rightBarButtonItem?.title = "Tags"
            tagView = false
            self.tableView.reloadData()
        } else {
            self.navigationItem.rightBarButtonItem?.title = "ABC"
            tagView = true
            self.tableView.reloadData()
        }
    }
        
    func bookAtIndexPath(indexPath: NSIndexPath) -> Book{
        var book: Book?
        if tagView {
            book = model.book(atIndex: indexPath.row, forTag: model.tagForIndex(indexPath.section))
        } else {
            book = model.book(atIndex: indexPath.row)
        }
        
        return book!
    }
    
    
    func bookModelDidChange (notification: NSNotification) {
        model.refreshFavs()
        self.tableView.reloadData()
    }

}


protocol LibraryViewControllerDelegate {
    func libraryViewController(viewCtrl: LibraryViewController, didSelectBook book:Book)
}