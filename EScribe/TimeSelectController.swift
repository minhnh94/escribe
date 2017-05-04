//
//  TimeSelectController.swift
//  EScribe
//
//  Created by minhnh on 4/28/17.
//
//

import UIKit

protocol DoneButtonClickedDelegate: class {
    func doneButtonDidClicked(stringFilter: Int, timeRangeFilter: Int)
}

class TimeSelectController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    weak var doneBtnDelegate: DoneButtonClickedDelegate?
    var timeRangeSetting: Int!
    var selectionArray = ["Today", "Within a week", "Within a month"]

    @IBOutlet weak var stringValueFilterSegment: UISegmentedControl!
    @IBOutlet weak var timeRangeTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Action
    
    @IBAction func doneClicked(_ sender: UIBarButtonItem) {
        doneBtnDelegate?.doneButtonDidClicked(stringFilter: stringValueFilterSegment.selectedSegmentIndex, timeRangeFilter: timeRangeSetting)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelClicked(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }

    // MARK: - Table view delegates
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectionArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TimeRangeFilterCell", for: indexPath)
        
        cell.textLabel?.text = selectionArray[indexPath.row]
        if indexPath.row == timeRangeSetting {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let beforeCell = tableView.cellForRow(at: IndexPath(row: timeRangeSetting, section: 0))
        beforeCell?.accessoryType = .none
        let afterCell = tableView.cellForRow(at: indexPath)
        afterCell?.accessoryType = .checkmark
        timeRangeSetting = indexPath.row
    }

}
