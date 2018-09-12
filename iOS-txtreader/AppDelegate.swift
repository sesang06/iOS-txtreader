//
//  AppDelegate.swift
//  iOS-txtreader
//
//  Created by 조세상 on 2018. 8. 23..
//  Copyright © 2018년 조세상. All rights reserved.
//

import UIKit
import CoreData
import Alamofire

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
       
        
        
        // Override point for customization after application launch.
        window = UIWindow(frame : UIScreen.main.bounds)
      
        let fileManager = FileManager.default
        let dirPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
        let vc = DocumentBrowserViewController()
        vc.dirPath = dirPath
       let nav = UINavigationController(rootViewController: vc)
//        nav.navigationBar.isTranslucent = false
        
        
        let revealController = SWRevealViewController()
        
        let frontNavigationController =  nav
        let rearNavigationController = OptionsViewController()
        
        revealController.frontViewController = frontNavigationController
        revealController.rearViewController = rearNavigationController
        vc.isMain = true
        
        window?.rootViewController = revealController

        
//        nav.navigationBar.tintColor = Constants.primaryColor
//        nav.navigationBar.barTintColor = Constants.primaryColor
        //
        
//        window?.rootViewController = nav
          window?.makeKeyAndVisible()
        return true
    }
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
       
        guard let shouldOpenInPlace = options[UIApplicationOpenURLOptionsKey.openInPlace] as? Bool else {
            return false
        }
        
        if (shouldOpenInPlace){
            if let root = self.window?.rootViewController as? UINavigationController{
                let vc = OtherTextViewController()
                let document = TextDocument(fileURL: url)
                vc.content = document
                root.pushViewController(vc, animated:true )
                
            }
        }else {
            do {
                
                let data = try Data(contentsOf: url)
                let fileManager = FileManager.default
                let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
                
                if let fileURL = documentDirectory.appendingPathComponent(url.lastPathComponent).newFileURL{
                    try data.write(to: fileURL)
                    //                window = UIWindow(frame : UIScreen.main.bounds)
                    
                    let fileManager = FileManager.default
                    let dirPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
                    
                    if let root = self.window?.rootViewController as? UINavigationController{
                        let vc = OtherTextViewController()
                        let document = TextDocument(fileURL: fileURL)
                        vc.content = document
                        //                    let fileManager = FileManager.default
                        //                    let dirPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
                        //                    let vc = DocumentBrowserViewController()
                        //                    vc.dirPath = dirPath
                        root.pushViewController(vc, animated:true )
                        
                    }
                }
                
                // Do something with the file
            } catch {
                print("Unable to load data: \(error)")
            }
        }
      
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    // MARK: - utility routines
    lazy var applicationDocumentsDirectory: URL = {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()
    
    // MARK: - Core Data stack (generic)
    lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = Bundle.main.url(forResource: "iOS_txtreader", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("iOS_txtreader").appendingPathExtension("sqlite")
        
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch {
            let dict : [String : Any] = [NSLocalizedDescriptionKey        : "Failed to initialize the application's saved data" as NSString,
                                         NSLocalizedFailureReasonErrorKey : "There was an error creating or loading the application's saved data." as NSString,
                                         NSUnderlyingErrorKey             : error as NSError]
            
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            fatalError("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
        }
        
        return coordinator
    }()
    
    // MARK: - Core Data stack (iOS 9)
    @available(iOS 9.0, *)
    lazy var managedObjectContext: NSManagedObjectContext = {
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator
        return managedObjectContext
    }()
    
    // MARK: - Core Data stack (iOS 10)
    @available(iOS 10.0, *)
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "iOS_txtreader")
        container.loadPersistentStores(completionHandler: {
            (storeDescription, error) in
            if let error = error as NSError?
            {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        )
        
        return container
    }()
    
    // MARK: - Core Data context
    lazy var databaseContext : NSManagedObjectContext = {
        if #available(iOS 10.0, *) {
            return self.persistentContainer.viewContext
        } else {
            return self.managedObjectContext
        }
    }()
    
    // MARK: - Core Data save
    func saveContext () {
        do {
            if databaseContext.hasChanges {
                try databaseContext.save()
            }
        } catch {
            let nserror = error as NSError
            
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
    

    
}
