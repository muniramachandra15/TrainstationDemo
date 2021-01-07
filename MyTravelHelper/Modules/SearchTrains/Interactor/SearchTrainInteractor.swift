//
//  SearchTrainInteractor.swift
//  MyTravelHelper
//
//  Created by Satish on 11/03/19.
//  Copyright © 2019 Sample. All rights reserved.
//

import Foundation
import XMLParsing

class SearchTrainInteractor: PresenterToInteractorProtocol {
    var _sourceStationCode = String()
    var _destinationStationCode = String()
    var presenter: InteractorToPresenterProtocol?
    
    func fetchallStations() {
        if Reach().isNetworkReachable() == true {
            HttpHandler.request(with: URLBuilder.allStations.url) {  result in
                switch result {
                case .failure(let error):
                    print(error)
                case .success(let data):
                    let station = try? XMLDecoder().decode(Stations.self, from: data)
                    self.presenter!.stationListFetched(list: station!.stationsList)
                }
            }
        } else {
            self.presenter!.showNoInterNetAvailabilityMessage()
        }
    }
    
    func fetchTrainsFromSource(sourceCode: String, destinationCode: String) {
        _sourceStationCode = sourceCode
        _destinationStationCode = destinationCode
        if Reach().isNetworkReachable() {
            HttpHandler.request(with: URLBuilder.stationByCode(sourceCode).url) {  result in
                switch result {
                case .failure(let error):
                    print(error)
                case .success(let data):
                    let stationData = try? XMLDecoder().decode(StationData.self, from: data)
                    if let _trainsList = stationData?.trainsList {
                        self.proceesTrainListforDestinationCheck(trainsList: _trainsList)
                    } else {
                        self.presenter!.showNoTrainAvailbilityFromSource()
                    }
                }
            }
        } else {
            self.presenter!.showNoInterNetAvailabilityMessage()
        }
    }
    
    private func proceesTrainListforDestinationCheck(trainsList: [StationTrain]) {
        var _trainsList = trainsList
        let group = DispatchGroup()
        
        for index  in 0...trainsList.count-1 {
            group.enter()
            let url = URLBuilder.getTrainMovement(trainsList[index].trainCode, Date.today).url
            if Reach().isNetworkReachable() {
                HttpHandler.request(with: url) {  result in
                    switch result {
                    case .failure(let error):
                        print(error)
                    case .success(let data):
                        let trainMovements = try? XMLDecoder().decode(TrainMovementsData.self, from: data)
                        if let _movements = trainMovements?.trainMovements {
                            let sourceIndex = _movements.firstIndex(where: {$0.locationCode.caseInsensitiveCompare(self._sourceStationCode) == .orderedSame})
                            let destinationIndex = _movements.firstIndex(where: {$0.locationCode.caseInsensitiveCompare(self._destinationStationCode) == .orderedSame})
                            let desiredStationMoment = _movements.filter{$0.locationCode.caseInsensitiveCompare(self._destinationStationCode) == .orderedSame}
                            let isDestinationAvailable = desiredStationMoment.count == 1
                            
                            if isDestinationAvailable  && sourceIndex! < destinationIndex! {
                                _trainsList[index].destinationDetails = desiredStationMoment.first
                            }
                        }
                        group.leave()
                    }
                }
                
            } else {
                self.presenter!.showNoInterNetAvailabilityMessage()
            }
        }
        
        group.notify(queue: DispatchQueue.main) {
            let sourceToDestinationTrains = _trainsList.filter{$0.destinationDetails != nil}
            self.presenter!.fetchedTrainsList(trainsList: sourceToDestinationTrains)
        }
    }
}

