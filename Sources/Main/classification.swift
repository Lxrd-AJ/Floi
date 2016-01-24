import Foundation

class Classifier {
    var medianAndDeviation: [(Double,Double)] = []
    var format: [String] = []
    var data: [(classification:String, vector:[Double], ignore:[String])] = []

    init( filename:String ){
        //read the file and Parse the Data into the required format
        if let contentsOfFile = Classifier.readFile(filename) {
            let lines: [String] = contentsOfFile.componentsSeparatedByString("\n");
            var contents : [[String]] = lines.map({ $0.componentsSeparatedByString("\t") })

            self.format = contents[0]; //Dataset specific, the first line contains the format
            self.data = Classifier.parseData( Array(contents[1..<contents.count]) , format: self.format );

            //Normalize the vectors in our data
            let vectors_data:[[Double]] = data.map({ $0.vector });
            let normalized_vectors = normalize( vectors_data );
            for i in 0..<normalized_vectors.count {
                self.data[i].vector = normalized_vectors[i];
            }

        }else{ print("Failed to read File.  Program Complete"); }

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

    class func parseData( contents:[[String]], format:[String] ) -> [(classification:String, vector:[Double], ignore:[String])] {
        var data: [(classification:String, vector:[Double], ignore:[String])] = []
        for line in contents {
            var dataEntry = (classification:"", vector:[Double](), ignore:[String]())
            for i in 0..<line.count {
                switch format[i] {
                    case "num":
                        dataEntry.vector.append( Double(line[i])! );
                    case "comment":
                        dataEntry.ignore.append( line[i] )
                    case "class":
                        dataEntry.classification = line[i]
                    default:
                        break;
                }
            }
            data.append( dataEntry );
        }
        return data;
    }

    class func readFile( path:String , encoding: NSStringEncoding = NSUTF8StringEncoding ) -> String? {
        guard NSFileManager().fileExistsAtPath( path ) else{ return nil }
        do{ return try String( contentsOfFile:path, encoding:encoding ); }
        catch{ print(error) }
        return nil;
    }
}
