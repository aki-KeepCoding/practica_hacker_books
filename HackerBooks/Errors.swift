//
//  Errors.swift
//  HackerBooks
//
//  Created by Akixe on 3/7/16.
//  Copyright © 2016 AOA. All rights reserved.
//

import Foundation

enum HackerBooksError : ErrorType {
    case MissingBookTitle
    case BadBookFile
    case JSONParsingError
    case ErrorLoadingData(String)
    case CantSaveDataToLocalFile
    
}