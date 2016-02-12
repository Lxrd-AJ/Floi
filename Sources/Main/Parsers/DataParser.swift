import Foundation

protocol DataParser {
    //All Data Parsers for each Dataset should adopt this protocol for our classifier to utilise them
    var format: [String]? {get set}
    func parseFile( filename:String ) -> [(classification:String, vector:[Double], ignore:[String])]
}
