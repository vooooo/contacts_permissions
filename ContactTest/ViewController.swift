//
//  ViewController.swift
//  ContactTest
//
//  Created by Vu Nguyen on 1/6/16.
//  Copyright © 2016 Avid AI. All rights reserved.
//

import UIKit
import Contacts

class ViewController: UIViewController {

    let contactStore = CNContactStore()
    
    /*
    *
    *
    */
    @IBAction func tapGetContacts(sender: UIButton) {

        self.requestForAccess() {
            (accessGranted) -> Void in
            
            if accessGranted == true {

                let keysToFetch =  [
                    CNContactFormatter.descriptorForRequiredKeysForStyle(.FullName),
                    CNContactEmailAddressesKey,
                    CNContactPhoneNumbersKey,
                    CNContactPostalAddressesKey,
                    CNContactImageDataAvailableKey,
                    CNContactThumbnailImageDataKey,
                    CNContactInstantMessageAddressesKey,
                    CNContactSocialProfilesKey,
                    CNContactRelationsKey
                ]
            
                // Get all the containers
                var allContainers: [CNContainer] = []
                do {
                    allContainers = try self.contactStore.containersMatchingPredicate(nil)
                } catch {
                    print("Error fetching containers")
                }
                
                var results: [CNContact] = []
                
                // Iterate all containers and append their contacts to our results array
                for container in allContainers {
                    let fetchPredicate = CNContact.predicateForContactsInContainerWithIdentifier(container.identifier)
                    
                    do {
                        let containerResults = try self.contactStore.unifiedContactsMatchingPredicate(fetchPredicate, keysToFetch: keysToFetch)
                        results.appendContentsOf(containerResults)
                    } catch {
                        print("Error fetching results for container")
                    }
                }
                
                for result in results {
                    print("\nCONTACT RESULT:")
                    print(result)
                    
                    
                    /*
                    *
                    *
                    */
                    var name = ""
                    
                    if (!result.givenName.isEmpty) {
                        name = result.givenName
                    }
                    
                    if (!result.familyName.isEmpty) {
                        name += " \(result.familyName)"
                    }
                    print("NAME:\n\t\(name)")
                    
                    /*
                    *
                    *
                    */
                    if (!result.phoneNumbers.isEmpty) {
                        print("PHONE:")
                        for phone in result.phoneNumbers {
                            let p = phone.value as! CNPhoneNumber
                            print("\t\(p.stringValue)")
                        }
                    }
                    
                    /*
                    *
                    *
                    */
                    if (!result.emailAddresses.isEmpty) {
                        print("EMAIL:")
                        for email in result.emailAddresses {
                            print("\t\(email.value)")
                        }
                    }
                    
                    /*
                    *
                    *
                    */
                    if (!result.postalAddresses.isEmpty) {
                        print("POSTAL CODE:")

                        for address in result.postalAddresses {
                            let a = address.value as! CNPostalAddress
                            print("\t\(a.postalCode)")
                        }
                    }

                }
                
            }

        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    *
    *
    */
    func showMessage(message: String) {
        let alertController = UIAlertController(title: "contacts VU", message: message, preferredStyle: UIAlertControllerStyle.Alert)
        
        let dismissAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) { (action) -> Void in
        }
        
        alertController.addAction(dismissAction)
        self.presentViewController(alertController, animated: true, completion: nil)

    }

    /*
    *
    *
    */
    func requestForAccess(completionHandler: (accessGranted: Bool) -> Void) {
        let authorizationStatus = CNContactStore.authorizationStatusForEntityType(CNEntityType.Contacts)
        
        switch authorizationStatus {
        case .Authorized:
            completionHandler(accessGranted: true)
            
        case .Denied, .NotDetermined:
            self.contactStore.requestAccessForEntityType(CNEntityType.Contacts, completionHandler: { (access, accessError) -> Void in
                if access {
                    completionHandler(accessGranted: access)
                }
                else {
                    if authorizationStatus == CNAuthorizationStatus.Denied {
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            let message = "\(accessError!.localizedDescription)\n\nPlease allow the app to access your contacts through the Settings."
                            self.showMessage(message)
                        })
                    }
                }
            })
            
        default:
            completionHandler(accessGranted: false)
        }
    }
}

