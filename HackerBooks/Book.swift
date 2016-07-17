//
//  Book.swift
//  HackerBooks
//
//  Created by Akixe on 3/7/16.
//  Copyright © 2016 AOA. All rights reserved.
//

import Foundation
import UIKit

let BookDidChange = "Book Model did change"
class Book {
    let title : String
    let authors : [String]
    let tags : [Tag]
    var literalAuthors: String {
        get {
            return authors.joinWithSeparator(", ")
        }
    }
    var literalTags: String {
        get {
            var tagsList = [String]()
            for tag in tags {
                tagsList.append(tag.name)
            }
            return tagsList.joinWithSeparator(", ")

        }
    }
    
    // Propiedad computada cover -> Cargo la imagen desde local o remoto
    let coverURL : NSURL? // Considero Cover opcional para trastear con opcionales guards e if-lets. Así de masoca, a lo loco ;P
    var cover: UIImage? {
        get {
            // Desempaqueto coverURL opcional. Si no tiene url
            guard let cURL : NSURL = coverURL else {
                return nil
            }
            // Intento cargar imagen desde Cache
            guard let _coverImgData = tryLoadFromCache(withContentsOfURL: cURL) else {
                return nil
            }
            // Si he llegado es que tengo la imagen
            return UIImage(data: _coverImgData)
        }
    }
    
    // Propiedad computada bookPDF -> Cargo el PDF desde local o remoto
    let bookURL : NSURL
    var bookPDF: NSData? {
        get {
            // Intento cargar imagen desde Cache
            guard let _bookData = tryLoadFromCache(withContentsOfURL: bookURL) else {
                return nil
            }
            return _bookData
        }
    }
    
    // Propiedad computada favorite
    //   Usa NSUserData para persistir la información
    var favorite: Bool {
        get {
            return getFavFromNSUserData(String(self.hashValue))
        }
        set(newValue) {
            // Guardo favorito en NSUserData para persistir
            setFavAtNSUserData(String(self.hashValue), value: newValue)
            
            // Notificar cambio de Favorito
            let nc = NSNotificationCenter.defaultCenter()
            let notif = NSNotification(name: BookDidChange, object: self, userInfo:["bookModelChange": self])
            nc.postNotification(notif)

        }
    }
    
    
    // Inicializador principal
    init(title: String,
        authors: [String],
        tags: [Tag],
        coverURL: NSURL?,
        bookURL: NSURL) {
            self.title = title
            self.authors = authors
            self.tags = tags
            self.coverURL = coverURL
            self.bookURL = bookURL
    }
    
    func tryLoadFromCache(withContentsOfURL url: NSURL) -> NSData? {
        do {
            // Intento obtener la extensión del fichero. Si no se puede aborto (sin imagen)
            guard let ext = url.pathExtension else {
                return nil
            }
            // Obtengo ref a FileManager
            let fm = NSFileManager.defaultManager() // FileManager

            print("Cargando datos desde caché...(\(String(url)))")
            
            // Obtengo Path local de cache (guardo como hash + extensión de fichero, así evito problemas con posibles nombres de fichero iguales)
            var localURL = try fm.URLForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomain: NSSearchPathDomainMask.UserDomainMask, appropriateForURL: nil, create: true)
            localURL = localURL.URLByAppendingPathComponent(String(self.hashValue) + "." + ext)
            
            // Obtengo datos de Path local
            let data = NSData(contentsOfURL: localURL)
            
            // Intento desempaquetar. Si tiene datos devuelvo la imagen
            if let d : NSData = data {
                print("Existe en caché. Recuperando fichero de caché...")
                return d
            } else {

                // Cargo datos de remoto
                if let d = NSData(contentsOfURL: url){
                    print("Guardando datos en cache...")
                    // Guardo datos en caché
                    d.writeToURL(localURL, atomically: true)
                    // Devuelvo imagen
                    return d
                }
            }
        } catch {
            // Si hay algún error devuelvo nil (Sin datos)
            return nil
        }
        return nil // El compi me obliga... no le vale el catch? falta más I+D (Investigación + Desesperación)
    }
    
    
    func getFavFromNSUserData(key: String) -> Bool {
        let userDefaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        if let value = userDefaults.objectForKey(key) as? Bool {
            return value
        } else {
            return false
        }
    }
    
    func setFavAtNSUserData(key: String, value: Bool){
        let userDefaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setObject(value, forKey: key)
        userDefaults.synchronize()
    }
}

extension Book: Hashable {
    // Creo un hash único para cada libro
    var hashValue: Int {
        return self.title.hashValue ^ self.authors.joinWithSeparator(",").hashValue
    }
}

extension Book: Equatable { }
func ==(lhs: Book, rhs: Book) -> Bool {
    return  lhs.title == rhs.title &&
            lhs.literalAuthors == rhs.literalAuthors
}

extension Book: Comparable { }
func <(lhs: Book, rhs: Book) -> Bool {
    if lhs.favorite == rhs.favorite {
        return  lhs.title < rhs.title
    } else if lhs.favorite == true {
        return true
    } else {
        return false
    }
}
