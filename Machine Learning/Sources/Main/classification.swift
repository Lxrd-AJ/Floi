/**
* @Author: AJ Ibraheem <AJ>
* @Date:   2016-02-20T09:17:17+00:00
* @Email:  ibraheemaj@icloud.com
* @Last modified by:   AJ
* @Last modified time: 2016-02-20T09:18:07+00:00
*/

import Foundation
/**
    A Nearest neigbour classifier.
    It uses the k Nearest Neighbour classifier approach
*/
class Classifier {
    var medianAndDeviation: [(Double,Double)] = []
    var data: [(classification:String, attribute:[String], vector:[Double], ignore:[String])] = []
    var k: Int //NB: Should be a let constant but atm it generates an Error Undefined symbols for architecture x86_64:
    let numOfBuckets = 10

    init( bucketPrefix:String, testBucketNumber:Int, dataParser:DataParser, k:Int = 1 ){ //By default if K not specified
        self.k = k
        //read in each file and Parse the Data into the required format from the buckets
        for i in 0..<numOfBuckets {
            if i == testBucketNumber { continue; }
            let filename = "Temp/\(bucketPrefix)-\(i).txt"
            self.data += dataParser.parseFile( filename )
        }

        //Normalize the vectors in our data
        let vectors_data:[[Double]] = self.data.map({ $0.vector });
        let normalized_vectors = normalize( vectors_data );
        for i in 0..<normalized_vectors.count {
            self.data[i].vector = normalized_vectors[i];
        }
    }

    //Returns the Map of the test Results
    func testBucket( bucketFileName:String , parser:DataParser ) -> [String:[String:Int]]{
        var totals: [String:[String:Int]] = [:]
        let data = parser.parseFile( bucketFileName );

        for datum in data {
            let realClass = datum.classification
            let classifiedAs = self.classify( datum.vector )

            if totals[realClass] == nil { totals[realClass] = [:] }
            if totals[realClass]![classifiedAs] == nil { totals[realClass]![classifiedAs] = 0 }

            totals[realClass]![classifiedAs]! += 1
        }

        return totals
    }

    func classify( vector:[Double] ) -> String {
        return kNearestNeigbour( normalizeVector(vector) )
        //return nearestNeighbour( normalizeVector(vector) )
    }

    func kNearestNeigbour( vector:[Double] ) -> String {
        //Map a tuple (current entry in self.data, manhattan distance) and sort the returned tuple, sort using elem 1 which is manhattan distance
        let neighbours = self.data.map({ ($0,manhattan($0.vector,vector2:vector)) }).sort({ $0.1 < $1.1 }).prefix(self.k)
        //Implement the voting system for the neighbours
        var votes:[String:Int] = [:]
        for neigbour in neighbours {
            let _class = neigbour.0.classification
            if votes[_class] == nil { votes[_class] = 1 }
            else{ votes[_class]! += 1 }
        }
        //Keys sorted by highest votes, Convert the dictionary to an array of tuples and sorted
        let voteTuples: [(String,Int)] = votes.keys.map({ ($0,votes[$0]!) }).sort({ $0.1 > $1.1 }) //highest first

        //TODO: Account for the situtation where there is a tie in the votes
        return voteTuples.first!.0
    }

    func nearestNeighbour( vector:[Double] ) -> String {
        let distances = self.data.map({ ($0,manhattan($0.vector,vector2:vector)) }).sort({ $0.1 < $1.1 })
        let nearest = distances.first!
        return nearest.0.classification
    }

    func manhattan( vector1:[Double], vector2:[Double] ) -> Double {
        return Array(zip(vector1,vector2)).map({ abs($0.0 - $0.1) }).reduce(0, combine:+)
    }

    func normalizeVector( vector:[Double] ) -> [Double] {
        var result: [Double] = []
        for i in 0..<vector.count {
            let (median,asd) = self.medianAndDeviation[i]
            result.append( (vector[i] - median) / asd )
        }
        return result
    }

    //Assuming all entries in data have the same length, use the first element as the template
    func normalize( data:[[Double]] ) -> [[Double]] {
        let columns: [[Double]] = flatten(data)
        var normalized_columns: [[Double]] = []
        for column in columns {
            let _median = median( column )
            let asd = absoluteStandardDeviation( column, median: _median )
            self.medianAndDeviation.append( (_median,asd) )// 😩😩 Mutating global function here, sorry cuz i have to! 😩
            normalized_columns.append( column.map({ ($0 - _median)/asd }) )
        }
        return unflatten(normalized_columns)
    }

    func unflatten( data:[[Double]] ) -> [[Double]] {
        return flatten(data)
    }

    //Recieves data like [[a,b],[c,d],[e,f]] returns [[a,c,e],[b,d,f]]
    func flatten( data:[[Double]] ) -> [[Double]] {
        if let template = data.first {
            var result: [[Double]] = []
            for col_num in 0..<template.count { result.append( data.map({ $0[col_num] }) ) }
            return result
        }else{ return [] }
    }

    func absoluteStandardDeviation( data:[Double], median:Double ) -> Double {
        return data.reduce(0,combine:{ (total,datum) in total + abs((datum - median)) }) / Double(data.count)
    }

    func median( data:[Double] ) -> Double {
        guard data.count != 0 else { return 0 }
        guard data.count != 1 else { return data.first! }

        let sortedData = data.sort();
        let remainder = sortedData.count % 2
        if remainder == 1 {
            return sortedData[(sortedData.count / 2 )]
        }else{
            //Remainder is 0
            let idx = (sortedData.count/2)
            return (sortedData[idx] + sortedData[idx-1])/2
        }
    }

}
