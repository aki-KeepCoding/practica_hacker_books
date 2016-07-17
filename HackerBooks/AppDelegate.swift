//
//  AppDelegate.swift
//  HackerBooks
//
//  Created by Akixe on 3/7/16.
//  Copyright © 2016 AOA. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        do {
            let json = try loadData(fromUrl: NSURL(string:"https://t.co/K9ziV0z3SJ")!)
        
            var books = [Book]()
            for jsonElement in json {
                do {
                    let book = try decode(jsonElement)
                    books.append(book)
                } catch {
                    print("Error reading json \(jsonElement)")
                }
            }
            let model = Library(books: books)
            let device = UIDevice.currentDevice().userInterfaceIdiom
            
            if  device == UIUserInterfaceIdiom.Pad {
                let libraryViewCtrl = LibraryViewController(model: model)
                let libraryNavCtrl = UINavigationController(rootViewController: libraryViewCtrl)

                var book : Book
                if let b = model.book(atIndex: 0, forTagAtIndex: 0) {
                    book = b
                }  else {
                    return true
                }
                
                let bookViewCtrl = BookViewController(model: book)
                let bookNavCtrl = UINavigationController(rootViewController: bookViewCtrl)
                
                let splitViewCtrl = UISplitViewController()
                splitViewCtrl.viewControllers = [libraryNavCtrl, bookNavCtrl]
                libraryViewCtrl.delegate = bookViewCtrl
                //            window = UIWindow(frame: UIScreen.mainScreen().bounds)
                window?.rootViewController = splitViewCtrl


            } else {
                let libraryViewCtrl = LibraryViewController(model: model)
                let libraryNavCtrl = UINavigationController(rootViewController: libraryViewCtrl)
                libraryViewCtrl.delegate = libraryViewCtrl
                
                window?.rootViewController = libraryNavCtrl
                
            }
            window?.makeKeyAndVisible()
            
            
            return true
        } catch {
            fatalError("Error while loading JSON")
        }
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

