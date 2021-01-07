
import Foundation

final class HttpHandler {
    class func request(with urlString: String, completionHandler: @escaping(Result<Data,APIError>) -> Void) {
        guard let url = URL(string: urlString) else {
            completionHandler(.failure(APIError.invalidUrl))
            return
        }
        let request = URLRequest(url: url)
        
        URLSession.shared.get(request: request) { (data, response, error) in
            guard let data = data,
                  let response = response as? HTTPURLResponse,
                  error == nil else {
                // check for fundamental networking error
                print("error", error ?? "Unknown error")
                completionHandler(.failure(APIError.networkError))
                return
            }
            
            guard (200 ... 299) ~= response.statusCode else {                    // check for http errors
                print("statusCode should be 2xx, but is \(response.statusCode)")
                print("response = \(response)")
                completionHandler(.failure(APIError.networkError))
                return
            }
            completionHandler(.success(data))
        }
    }
}

// MARK: URL Builder

enum URLBuilder: StringConvertable {
    case allStations
    case stationByCode(String)
    case getTrainMovement(String,String)
    
    private var  baseUrl: String {
        return "http://api.irishrail.ie/realtime/realtime.asmx/"
    }
    
    var url: String {
        switch self {
        case .allStations:
            return baseUrl + "getAllStationsXML"
        case .stationByCode(let sourceCode):
            return baseUrl + "getStationDataByCodeXML?StationCode=\(sourceCode)"
        case .getTrainMovement(let trainCode, let dateString):
            return baseUrl +  "getTrainMovementsXML?TrainId=\(trainCode)&TrainDate=\(dateString)"
        }
    }
}

// MARK: Protocols & Extentions

public protocol StringConvertable {
    var url: String { get }
}

protocol NetworkLoader {
    func get(request: URLRequest, with completion: @escaping (Data?, URLResponse?, Error?) -> Void)
}

enum APIError: Error {
    case networkError
    case responseErrror
    case invalidUrl
}

extension URLSession: NetworkLoader {
    // call dataTask and resume, passing the completionHandler
    func get(request: URLRequest, with completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        self.dataTask(with: request, completionHandler: completion).resume()
    }
}

extension Date {
    static var today: String {
        let today = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.string(from: today)
    }
}
