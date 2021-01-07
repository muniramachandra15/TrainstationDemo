//
//  SearchTrainViewController.swift
//  MyTravelHelper
//
//  Created by Satish on 11/03/19.
//  Copyright © 2019 Sample. All rights reserved.
//

import UIKit
import SwiftSpinner
import DropDown

class SearchTrainViewController: UIViewController {
    @IBOutlet weak var destinationTextField: UITextField!
    @IBOutlet weak var sourceTxtField: UITextField!
    @IBOutlet weak var trainsListTable: UITableView!
    @IBOutlet weak var buttonFavourite: UIButton!
    var txtField: UITextField!

    var stationsList:[Station] = [Station]()
    var trains:[StationTrain] = [StationTrain]()
    var presenter:ViewToPresenterProtocol?
    var dropDown = DropDown()
    var transitPoints:(source:String,destination:String) = ("","")

    override func viewDidLoad() {
        super.viewDidLoad()
        trainsListTable.isHidden = true
        
        if let favourite = UserDefaults.shared.getFavourite() {
            buttonFavourite.isHidden = false
            buttonFavourite.setImage(UIImage(systemName: "star.fill"), for: .normal)
            buttonFavourite.setTitle(favourite, for: .normal)
        } else {
            buttonFavourite.isHidden = true
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        if stationsList.count == 0 {
            SwiftSpinner.useContainerView(view)
            SwiftSpinner.show("Please wait loading station list ....")
            presenter?.fetchallStations()
        }
    }

    @IBAction func searchTrainsTapped(_ sender: Any) {
        view.endEditing(true)
        showProgressIndicator(view: self.view)
        presenter?.searchTapped(source: transitPoints.source, destination: transitPoints.destination)
    }
    
    @IBAction func setTextToActiveTextField(_ sender: Any) {
        if let favourite = UserDefaults.shared.getFavourite(), let txtFld = self.txtField {
            txtFld.text = favourite
        }
    }
}

extension SearchTrainViewController:PresenterToViewProtocol {
    func showNoInterNetAvailabilityMessage() {
        trainsListTable.isHidden = true
        hideProgressIndicator(view: self.view)
        showAlert(title: "No Internet", message: "Please Check you internet connection and try again", actionTitle: "Okay")
    }

    func showNoTrainAvailbilityFromSource() {
        Queue.main {
            self.trainsListTable.isHidden = true
            hideProgressIndicator(view: self.view)
        }
        showAlert(title: "No Trains", message: "Sorry No trains arriving source station in another 90 mins", actionTitle: "Okay")
    }

    func updateLatestTrainList(trainsList: [StationTrain]) {
        hideProgressIndicator(view: self.view)
        trains = trainsList
        Queue.main {
            self.trainsListTable.isHidden = false
            self.trainsListTable.reloadData()
        }
       
    }

    func showNoTrainsFoundAlert() {
        
        Queue.main {
            self.trainsListTable.isHidden = true
            hideProgressIndicator(view: self.view)
            self.trainsListTable.isHidden = true
        }
        showAlert(title: "No Trains", message: "Sorry No trains Found from source to destination in another 90 mins", actionTitle: "Okay")
    }

    func showAlert(title:String,message:String,actionTitle:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: actionTitle, style: UIAlertAction.Style.default, handler: nil))
        Queue.main {
            self.present(alert, animated: true, completion: nil)
        }
    }

    func showInvalidSourceOrDestinationAlert() {
        trainsListTable.isHidden = true
        hideProgressIndicator(view: self.view)
        showAlert(title: "Invalid Source/Destination", message: "Invalid Source or Destination Station names Please Check", actionTitle: "Okay")
    }

    func saveFetchedStations(stations: [Station]?) {
        if let _stations = stations {
          self.stationsList = _stations
        }
        SwiftSpinner.hide()
    }
}

extension SearchTrainViewController:UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.txtField = textField
        dropDown = DropDown()
        dropDown.anchorView = textField
        dropDown.direction = .bottom
        dropDown.arrowIndicationX = 24.0
        dropDown.bottomOffset = CGPoint(x: 0, y:(dropDown.anchorView?.plainView.bounds.height)!)
        dropDown.dataSource = stationsList.map {$0.stationDesc}
        dropDown.selectionAction = { (index: Int, item: String) in
            if textField == self.sourceTxtField {
                self.transitPoints.source = item
            }else {
                self.transitPoints.destination = item
            }
            textField.text = item
        }
        dropDown.show()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        dropDown.hide()
        return textField.resignFirstResponder()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let inputedText = textField.text {
            var desiredSearchText = inputedText
            if string != "\n" && !string.isEmpty{
                desiredSearchText = desiredSearchText + string
            }else {
                desiredSearchText = String(desiredSearchText.dropLast())
            }

            let datastore = stationsList.map { $0.stationDesc}
            dropDown.dataSource = datastore
            dropDown.show()
            dropDown.reloadAllComponents()
        }
        return true
    }
}

@available(iOS 13.0, *)
@available(iOS 13.0, *)
extension SearchTrainViewController:UITableViewDataSource,UITableViewDelegate, FavouriteDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trains.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "train", for: indexPath) as! TrainInfoCell
        cell.delegate = self
        let train = trains[indexPath.row]
        cell.trainCode.text = train.trainCode
        cell.souceInfoLabel.text = train.stationFullName
        cell.sourceTimeLabel.text = train.expDeparture
        if let _destinationDetails = train.destinationDetails {
            cell.destinationInfoLabel.text = _destinationDetails.locationFullName
            cell.destinationTimeLabel.text = _destinationDetails.expDeparture
        }
           
        if let _ = UserDefaults.shared.getFavourite() {
            cell.favouriteButton.setImage(UIImage(systemName: "star"), for: .normal)
        } else {
            cell.favouriteButton.setImage(UIImage(systemName: "star.fill"), for: .normal)
        }

        return cell
    }
   
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
    
    func btnFavouriteTapped(cell: TrainInfoCell) {
            //Get the indexpath of cell where button was tapped
        guard let indexPath = trainsListTable.indexPath(for:cell) else {return}
        print(indexPath.row)
        let train = trains[indexPath.row]
        if let _ = UserDefaults.shared.getFavourite() {
            UserDefaults.shared.removeFavourite(name: train.stationFullName)
            cell.favouriteButton.setImage(UIImage(systemName: "star"), for: .normal)
            self.buttonFavourite.isHidden = true
        } else {
            cell.favouriteButton.setImage(UIImage(systemName: "star.fill"), for: .normal)
            UserDefaults.shared.setFavourite(name: train.stationFullName)
            self.buttonFavourite.isHidden = false
        }
    }
}
//1. delegate method
protocol FavouriteDelegate: AnyObject {
    func btnFavouriteTapped(cell: TrainInfoCell)
}
