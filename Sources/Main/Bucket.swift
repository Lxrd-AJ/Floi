import Foundation

/*
    A Bucket class for Data Stratification to use for cross validation,
*/
class Bucket {

    //Make different Buckets to ensure each bucket contains an appropriate representation of the entire dataset
    class func makeBuckets( filename:String, bucketName:String, separator:String, classColumn:Int ) -> Void {
        let numOfBuckets = 10
        var buckets: [Int:[[String]]] = [:]
        var data:[String:[[String]]] = [:]
        //first read in the data and divide by category
        do {
            let contentsOfFile: String = try String(contentsOfFile:filename, encoding:NSUTF8StringEncoding );
            let lines: [String] = contentsOfFile.componentsSeparatedByString("\n").filter({ $0 != "" })
            let _contents: [[String]] = lines.map({ $0.componentsSeparatedByString("\t") })
            let _ = _contents[0]
            let contents = Array( _contents[1..<_contents.count])

            //Separate the data into categories
            for line in contents {
                let key = line[ classColumn ]
                guard data[key] != nil else { data[key] = []; data[key]!.append(line); continue }
                data[key]!.append(line)
            }

            //Initialize the empty buckets
            for i in 0..<numOfBuckets { buckets[i] = [] }

            //For each category, put the data into the buckets
            for key in data.keys {
                //randomize the order of instances for each class/key
                let shuffledData = data[key]!.shuffle()
                var b = 0 //bucket number
                //divide into buckets
                for item in shuffledData {
                    buckets[b]!.append(item)
                    b = (b+1) % numOfBuckets
                }
            }

            //Save the buckets to disk
            for bNo in 0..<numOfBuckets {
                let contents = buckets[bNo]
                var file = ""
                for line in contents! { //contents is an array of lines
                    file += line.reduce("", combine:{ return $0 + $1 + "\t" }) + "\n"
                }
                let filename = "Temp/\(bucketName)\(bNo).txt"
                do{
                    try file.writeToFile( filename, atomically:false, encoding: NSUTF8StringEncoding )
                }catch{ print("Error: Failed to save file \(filename)"); }
            }

        }catch{ print(error); }
    }
}
