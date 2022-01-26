//
//  ListViewController.swift
//  TravelBook
//
//  Created by Esin Karan on 25.01.2022.
//

import UIKit
import CoreData

class ListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
  

    @IBOutlet weak var tableView: UITableView!
    
//    Variables
    var placeArray = [String]()
    var idArray = [UUID]()
    var selectedPlaceTitle = ""
    var selectedId = UUID()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addPlace))

        getData()
    }
    override func viewDidAppear(_ animated: Bool) {
         
         NotificationCenter.default.addObserver(self, selector: #selector(getData), name: NSNotification.Name("newDataAdded"), object: nil)
         
     }
    
    @objc func addPlace(){
        
        selectedPlaceTitle = ""
        performSegue(withIdentifier: "toDetailsVC", sender: nil)
    }
    
    @objc func getData(){
        
        placeArray.removeAll(keepingCapacity: false)
        idArray.removeAll(keepingCapacity: false)

        let appDelagete = UIApplication.shared.delegate as! AppDelegate
        let context = appDelagete.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Places")
        fetchRequest.returnsObjectsAsFaults = false

        do{
            let results = try context.fetch(fetchRequest)
            
            if results.count > 0{
                
                for result in results as! [NSManagedObject]{
                    
                    if let place = result.value(forKey: "place") as? String{
                        
                        placeArray.append(place)
                    }
                    
                    if let id = result.value(forKey: "id") as? UUID{
                        
                        idArray.append(id)
                    }
                    tableView.reloadData()
                }
            }
        }catch{
            print("error")
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return placeArray.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = placeArray[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectedPlaceTitle = placeArray[indexPath.row]
        selectedId = idArray[indexPath.row]
        performSegue(withIdentifier: "toDetailsVC", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toDetailsVC"{
            
            let destination = segue.destination as? ViewController
            
            destination?.placeText = selectedPlaceTitle
            destination?.id = selectedId
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete{
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let id = idArray[indexPath.row].uuidString
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Places")
            fetchRequest.predicate = NSPredicate(format: "id =%@",id)
            
            do{
                let results = try context.fetch(fetchRequest)
                
                for result in results as! [NSManagedObject]{
                    
                    if let id = result.value(forKey: "id") as? UUID{
                        
                        if id == idArray[indexPath.row]{
                            
                            context.delete(result)
                            idArray.remove(at: indexPath.row)
                            placeArray.remove(at: indexPath.row)
                            tableView.reloadData()
                            
                            do{
                                
                                try context.save()
                                
                            }catch{
                                print("error")
                                
                            }
                        }
                    }
                }
            }catch{
                
                print("error")
            }
        }
    }
}
