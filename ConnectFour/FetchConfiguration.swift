import Foundation

protocol FetchConfigurationProtocol {
    func fetchRemoteConfiguration(_ completion: @escaping (Configuration?, Error?) -> ())
}

class FetchConfiguration: NSObject, FetchConfigurationProtocol {
    let urlString = "https://private-75c7a5-blinkist.apiary-mock.com/connectFour/configuration"

    public func fetchRemoteConfiguration(_ completion: @escaping (Configuration?, Error?) -> ()) {
        guard let configurationURL = URL(string: urlString) else {
            return
        }
        URLSession.shared.dataTask(with: configurationURL) { data, response, error in
            if let data = data {
                do {
                    let decoder = JSONDecoder()
                    let configuration = try decoder.decode([Configuration].self, from: data)
                    completion(configuration[0], nil)
                } catch let error {
                    completion(nil, error)
                }
            }
        }.resume()
    }
}
