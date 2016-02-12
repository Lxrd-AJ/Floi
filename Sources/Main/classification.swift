
import Foundation

class Classifier {
    var medianAndDeviation: [(Double,Double)] = []
    //var format: [String] = []
    var data: [(classification:String, vector:[Double], ignore:[String])] = []
    let numOfBuckets = 10

    init( bucketPrefix:String, testBucketNumber:Int, dataParser:DataParser ){
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

        //Test
        // print("\nTesting Bucket");
        // let file = "Temp/\(bucketPrefix)-\(testBucketNumber).txt"
        // let result = testBucket(file, parser:dataParser)
        // print( result );
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
        return nearestNeighbour( normalizeVector(vector) )
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
