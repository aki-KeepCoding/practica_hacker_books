//
//  Library.swift
//  HackerBooks
//
//  Created by Akixe on 3/7/16.
//  Copyright © 2016 AOA. All rights reserved.
//

import Foundation

typealias BookSet = Set<Book>

class Library {
    typealias BooksArray = [Book]

    var bookcase = [Tag: BookSet]()
    var tags = [Tag]()
    
    var books : BooksArray
    
    // He decidido que la librería es el mejor sitio para almacenar estos dos tags "standard"
    //  Al final he decidido generar estas etiquetas particulares en la misma librería
    static let favoriteTag = Tag("Favoritos", priority: 2)
    static let noTag = Tag("Sin Tags", priority: 0)
   
    
    init(books: BooksArray){
        self.books = books
        self.books.sortInPlace()
        
        for book in self.books {
            // Reparto los libros en su tag dentro del Dicionario [tag: arrayDeLibros]
            if book.tags.count > 0 { //El libro lleva tags
                for tag in book.tags {
                    addBook(book, toTag: tag)
                }
            } else { // El libro no lleva tags, lo añadimos a noTag
                addBook(book, toTag: Library.noTag)
            }
        }
        // Añado libros al tag Favoritos si corresponde
        loadFavorites()
        // Cargo el array de tags para poder recuperarlos en e Tableview
        loadTags()
    }
    
    func addBook(book: Book, toTag tag: Tag) {
        if bookcase[tag] == nil {  // No existe el tag, lo creamos
            bookcase[tag] = BookSet()
        }
        bookcase[tag]?.insert(book) // Añadimos el libro al contenedor del tag
    }
    
    func book(atIndex index: Int, forTag tag: Tag) -> Book? { // Devuelvo un opcional porque he supuesto que puede haber tatgs sin libros (favoritos y noTag por ejemplo)
        let booksAtTag = bookcase[tag]! // Convertimos el Set a Array para poder acceder por index
        let booksArray = Array(booksAtTag)
        let sortedBooks = booksArray.sort()
        if sortedBooks.count > 0 {
            return sortedBooks[index]
        } else  {
            return nil
        }
    }

    func book(atIndex index: Int, forTagAtIndex tagIndex: Int) -> Book? { // Devuelvo un opcional porque he supuesto que puede haber tatgs sin libros (favoritos y noTag por ejemplo)
        let tag = tags[tagIndex]
        let booksAtTag = bookcase[tag]! // Convertimos el Set a Array para poder acceder por index
        let booksArray = Array(booksAtTag)
        let sortedBooks = booksArray.sort()
        if sortedBooks.count > 0 {
            return sortedBooks[index]
        } else  {
            return nil
        }
    }

    
    func book(atIndex index: Int) -> Book? {
        return books[index]
    }
    
    func bookCountAtTagIndex(index: Int) -> Int {
        let tag = tags[index]
        
        if let bookSet = bookcase[tag] {
            return bookSet.count
        } else {
            return 0
        }
    }
    
    func totalBookCount() -> Int {
        return books.count
    }
    
    func tagCount() -> Int {
        return tags.count
    }
    
    func tagForIndex(index: Int) -> Tag {
        return tags[index]
    }
    
    func refreshFavs() {
        loadFavorites()
        loadTags()
    }
    
    func loadFavorites() {
        bookcase.removeValueForKey(Library.favoriteTag)
        for book in self.books {
            // Añado el libro al tag Favoritos si corresponde
            if book.favorite == true {
                addBook(book, toTag: Library.favoriteTag)
            }
        }
    }
    
    func loadTags(){
        tags = Array(bookcase.keys)
        tags.sortInPlace()
    }
    
}