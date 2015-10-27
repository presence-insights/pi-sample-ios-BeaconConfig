//
//© Copyright 2015 IBM Corp.
//
//Licensed under the Apache License, Version 2.0 (the "License");
//you may not use this file except in compliance with the License.
//You may obtain a copy of the License at
//
//http://www.apache.org/licenses/LICENSE-2.0
//
//Unless required by applicable law or agreed to in writing, software
//distributed under the License is distributed on an "AS IS" BASIS,
//WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//See the License for the specific language governing permissions and
//limitations under the License.


import UIKit
import CoreData

class SetttingsTableViewController: UITableViewController {
    
    var myData: Array<AnyObject> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let results: NSArray = retrieveAllDC("Beacon")
        if (results.count > 0){
            for res in results {
                myData.append(res)
            }
        }
        else{
            print("Nothing in DB")
        }
        
       

                
    }
    @IBOutlet weak var SettingsButton: UIBarButtonItem!
    
    @IBAction func SettingAction(sender: AnyObject) {
        self.performSegueWithIdentifier("settingTransition", sender: nil)
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return myData.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let CellID: String = "Cell"
        let cell : UITableViewCell = tableView.dequeueReusableCellWithIdentifier(CellID)! as UITableViewCell
        
        
        cell.textLabel!.text = myData[indexPath.row].key
        
        return cell
    }
    
    
    
    // Override to support conditional editing of the table view.]
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    
    
    
    //Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            deleteDC("Beacon", key: myData[indexPath.row] as! NSManagedObject)
            myData.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        let choice : String! = myData[indexPath.row].key
        let value : String! = myData[indexPath.row].value
        let object: NSManagedObject! = myData[indexPath.row] as! NSManagedObject
        
        var inputTextField: UITextField?
        var inputTextField2: UITextField?
        let Prompt = UIAlertController(title: "Update Beacon", message: "Please Enter the updated Beacon Name and UUID. \n (Need to provide both to update) \n Current Information: \n Beacon Name: \(choice) \n UUID: \(value)", preferredStyle: UIAlertControllerStyle.Alert)
        Prompt.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: nil))
        Prompt.addAction(UIAlertAction(title: "Update/ok", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            //Now do whatever you want with inputTextField (remember to unwrap the optional)
            //need to store to DBa
            if(inputTextField!.text != "" && inputTextField2!.text != ""){
                print("1")
                self.deleteDC("Beacon", key: object)
                self.saveDC("Beacon", key: inputTextField!.text!, value: inputTextField2!.text!.uppercaseString)
            }
            else if (inputTextField!.text == "" && inputTextField2!.text !=  ""){
                print("2")
                self.updateDC("Beacon", key: choice, value: inputTextField2!.text!.uppercaseString)
                
            }
            else if (inputTextField!.text != "" && inputTextField2!.text == ""){
                print("3")
                self.saveDC("Beacon", key: inputTextField!.text!, value: value)
            }
            self.refresh()
            
        }))
        Prompt.addTextFieldWithConfigurationHandler({(textField: UITextField) in
            textField.placeholder = "Beacon Name"
            textField.secureTextEntry = false
            inputTextField = textField
        })
        Prompt.addTextFieldWithConfigurationHandler({(textField2: UITextField) in
            textField2.placeholder = "UUID"
            textField2.secureTextEntry = false
            inputTextField2 = textField2
        })
        presentViewController(Prompt, animated: true, completion: nil)
        
    }
    
    @IBAction func AddAction(sender: AnyObject) {
        
        
        var inputTextField: UITextField?
        var inputTextField2: UITextField?
        let Prompt = UIAlertController(title: "Enter Beacon Information", message: "Please Enter the Beacon Name and UUID.", preferredStyle: UIAlertControllerStyle.Alert)
        Prompt.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: nil))
        Prompt.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            //Now do whatever you want with inputTextField (remember to unwrap the optional)
            //need to store to DB

            self.saveDC("Beacon", key: inputTextField!.text!, value: inputTextField2!.text!.uppercaseString)
            self.refresh()

       
            
        }))
        Prompt.addTextFieldWithConfigurationHandler({(textField: UITextField) in
            textField.placeholder = "Beacon Name"
            textField.secureTextEntry = false
            inputTextField = textField
        })
        Prompt.addTextFieldWithConfigurationHandler({(textField2: UITextField) in
            textField2.placeholder = "UUID"
            textField2.secureTextEntry = false
            inputTextField2 = textField2
        })
        presentViewController(Prompt, animated: true, completion: nil)
        
        



    }
    
    
    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
    
    }
    */
    
    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // Return NO if you do not want the item to be re-orderable.
    return true
    }
    */
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    }
    */
    
    func alert(titleInput : String , messageInput : String){
        let alert = UIAlertController(title: titleInput, message: messageInput, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "ok", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    func saveDC( entityName : String, key: String, value: String ) {
        let appDel:AppDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
        let context:NSManagedObjectContext = appDel.managedObjectContext!
        //var request = NSFetchRequest(entityName: entityName)
        
        //create newkey object
        let newStore = NSEntityDescription.insertNewObjectForEntityForName(entityName, inManagedObjectContext: context) 
        //set value (value, key)
        newStore.setValue(key , forKey: "key")
        newStore.setValue(value, forKey: "value")
        
        do {
            try context.save()
        } catch _ {
        }
        print("finish Save DC")
  
    }
    func retrieveSpecificDC ( entityName : String , key:String) -> String {
        let appDel:AppDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
        let context:NSManagedObjectContext = appDel.managedObjectContext!
        let request = NSFetchRequest(entityName: entityName)
        request.returnsObjectsAsFaults = false;
        request.predicate = NSPredicate(format: "key = %@", key)
        
        
        let results : NSArray = try! context.executeFetchRequest(request)
        if (results.count > 0){
            let res = results[0] as! NSManagedObject
            return res.valueForKey("value") as! String
        }
        else{
            print("Potential error or no results!")
            return ""
        }
        
        
    }
    func retrieveAllDC (entityName : String ) -> NSArray {
        let appDel:AppDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
        let context:NSManagedObjectContext = appDel.managedObjectContext!
        let request = NSFetchRequest(entityName: entityName)
        request.returnsObjectsAsFaults = false;
        let results : NSArray = try! context.executeFetchRequest(request)
        return results
        
        
    }

    func updateDC ( entityName: String, key: String, value: String){
        let appDel:AppDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
        let context:NSManagedObjectContext = appDel.managedObjectContext!
        
        let request = NSFetchRequest(entityName: entityName)
        request.predicate = NSPredicate(format: "key = %@", key)
        
        if let fetchResults = (try? appDel.managedObjectContext!.executeFetchRequest(request)) as? [NSManagedObject] {
            if fetchResults.count != 0{
                let managedObject = fetchResults[0]
                managedObject.setValue(value, forKey: "value")
                do {
                    try context.save()
                } catch _ {
                }
            }
        }
    }
    func deleteDC (entityName: String, key: NSManagedObject){
        let appDel:AppDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
        let context:NSManagedObjectContext = appDel.managedObjectContext!
        context.deleteObject(key)
        do {
            try context.save()
        } catch _ {
        }
    }
    func refresh(){
        // Updating your data here...
        myData.removeAll(keepCapacity: false)
        let results: NSArray = retrieveAllDC("Beacon")
        if (results.count > 0){
            for res in results {
                myData.append(res)
            }
        }
        else{
            print("Nothing in DB")
        }

        self.tableView.reloadData()
        self.refreshControl?.endRefreshing()
    }
    
   
}
