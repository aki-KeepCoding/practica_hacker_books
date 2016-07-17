//
//  JSONProcessing.swift
//  HackerBooks
//
//  Created by Akixe on 3/7/16.
//  Copyright © 2016 AOA. All rights reserved.
//

import Foundation
import UIKit

typealias JSONObject = AnyObject
typealias JSONDictionary = [String: JSONObject]
typealias JSONArray = [JSONDictionary]

func decode(json: JSONDictionary) throws -> Book {

    guard let title = json["title"] as? String else{
        throw HackerBooksError.MissingBookTitle
    }
    
    guard let   urlString = json["pdf_url"] as? String,
                bookURL = NSURL(string: urlString) else {
                    throw HackerBooksError.BadBookFile
    }

    var authors : [String] = [String]()
    if let authorsStrList = json["authors"] as? String {
        authors = authorsStrList.characters.split{$0 == ","}.map(String.init)
    }
    
    var tags : [Tag] = [Tag]()
    if let tagsStrList = json["tags"] as? String {
        tags = tagsStrList.characters.split{$0 == ","}
                .map(String.init)
                .map({$0.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())})
                .map(Tag.init)
    }
    
    let coverURL : NSURL?
    if  let coverString = json["image_url"] as? String{
        coverURL = NSURL(string:coverString)
    } else {
        coverURL = nil
    }
    
    
   return Book(title: title, authors: authors, tags: tags, coverURL: coverURL, bookURL: bookURL)
}



func loadFromLocalFile(fileName name: String, withExtension ext: String) throws -> NSData? {
    let fm = NSFileManager.defaultManager()
    do {
        print("Cargando datos desde cache...")
        var url = try fm.URLForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomain: NSSearchPathDomainMask.UserDomainMask, appropriateForURL: nil, create: true)
        url = url.URLByAppendingPathComponent("data.json")
        return NSData(contentsOfURL: url)
    } catch {
        throw HackerBooksError.ErrorLoadingData("Desde fichero local")
    }
}



func loadFromInternet(url: NSURL) throws -> NSData {
    if let  data = NSData(contentsOfURL: url) {
        do {
            try saveData(data)
        }catch{
            print("No se han podido guardar los datos")
        }
        return data
    } else {
        throw HackerBooksError.JSONParsingError
    }

}

func dataToJson(data: NSData) throws -> JSONArray {
    if let  maybeArray = try? NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers) as? JSONArray,
        jsonArray = maybeArray {
            return jsonArray
    } else {
        throw HackerBooksError.JSONParsingError
    }
    
}


func loadData(fromUrl url: NSURL) throws -> JSONArray {
    var data: NSData?

    do {
        if let localData = try loadFromLocalFile(fileName: "data", withExtension: "json") {
            data = localData
        } else {
            if let inetData = try? loadFromInternet(url) {
                data = inetData
            } else {
                throw HackerBooksError.ErrorLoadingData("No se puede cargar ningún dato")
            }
        }
    } catch {
            throw HackerBooksError.ErrorLoadingData("NO se han podido cargar los datos")
    }

    if  let d: NSData = data!,
        let jsonArray = try? dataToJson(d) {
        return jsonArray
    } else {
        throw HackerBooksError.JSONParsingError
    }
    
    
}

func saveData(data:NSData) throws {
    let fm = NSFileManager.defaultManager()
    do {
        print("Guardando datos en cache...")
        var url = try fm.URLForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomain: NSSearchPathDomainMask.UserDomainMask, appropriateForURL: nil, create: true)
        url = url.URLByAppendingPathComponent("data.json")
        data.writeToURL(url, atomically: true)
    }catch{
        throw HackerBooksError.CantSaveDataToLocalFile
    }
}



