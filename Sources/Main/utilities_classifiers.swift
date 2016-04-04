
import Foundation 

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

func normalizeClusters( clusters:[Cluster] ) -> [Cluster] {
    var normalizedClusters = clusters
        //Normalize the distance attribute for each cluster 
        if case let .ClusterNode(_,distance,_,_) = clusters.first! {
            for col_num in 0..<distance.count {//for the current column
                //Extract the column vectors 
                let col_vectors: [Double] = clusters.map({ cluster in
                    switch cluster {
                        case let .ClusterNode(_,dist,_,_):
                            return dist[ col_num ];
                        default:
                            return 0
                    }
                })
                let _median = median( col_vectors )
                let asd = absoluteStandardDeviation( col_vectors, median:_median)
                
                normalizedClusters = normalizedClusters.map({ cluster in 
                    switch cluster {
                        case let .ClusterNode(_,dist,name,_):
                            var _dist = dist 
                            _dist[col_num] = (dist[col_num] - _median) / asd
                            return Cluster(name:name, distance:_dist)
                        default:
                            break;
                    }
                    return cluster
                })
            }//end for 
            return normalizedClusters
        }else{ return []; }
}