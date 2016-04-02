import Foundation 

//http://airspeedvelocity.net/2015/07/22/a-persistent-tree-using-indirect-enums-in-swift/
indirect enum Cluster {
    case Empty 
    case ClusterNode( left:Cluster, distance:[Double], content:String, right:Cluster )
    
    init(){ self = .Empty }
    
    init( name:String, distance:[Double] ){
      self = .ClusterNode(left:.Empty,distance:distance,content:name,right:.Empty)
    }
    
    init( name:String, distance:[Double], left:Cluster, right:Cluster ){
        self = .ClusterNode(left:left,distance:distance,content:name,right:right)
    } 
    
    func values() -> (name:String, distance:[Double]){
        switch self {
            case .Empty:
                return ("",[])
            case .ClusterNode(_,let dist,let cnt,_):
                return (cnt,dist)
        }
    }
    
    /**
    Returns the Euclidean distance between the current cluster to the specified cluster 
    */
    func distanceTo( cluster: Cluster ) -> Double {
        switch (cluster,self) {
        case (.Empty,_):
            return 0.0
        case (.ClusterNode(_,let vector1,_,_), .ClusterNode(_,let vector2,_,_) ):
            let sumSqaures = Array(zip(vector1,vector2)).map({ ($0.0 - $0.1) ^^ 2 }).reduce(0, combine:+)
            return sqrt( sumSqaures )
        default:
            return 0.0
        }
    }
    
    /**
    The Nearest Neighbour using the Euclidean distance function 
    */
    func nearestNeighbour( clusters:[Cluster] ) -> Cluster {
        //check if `self` in `clusters` and remove if present
        guard clusters.count > 1 else { return clusters[0] }
        let clusters = clusters.remove(self)
        return clusters.sort({ return (self.distanceTo($0)) < (self.distanceTo($1)) }).first! //print("\($0)\n\($1)");
    }
    
    func distanceToNearestNeighbour( clusters:[Cluster] ) -> Double {
        let nearestNeighbour = self.nearestNeighbour(clusters)
        return self.distanceTo( nearestNeighbour )
    }
}

extension Cluster: Equatable {
}
func ==(lhs: Cluster, rhs:Cluster) -> Bool {
    switch(lhs,rhs){
        case (.ClusterNode(_,_,let c1,_),.ClusterNode(_,_,let c2,_)) where c1 == c2:
            return true 
        case (.Empty,.Empty):
            return true 
        default:
            return false 
    }
}

extension Array where Element: Equatable{
    /**
    Returns an array without the specified paramter if it was present
    */
    func remove( cluster:Element ) -> [Element]{
        let idx = self.indexOf(cluster)
        var result = Array(self)
        if let index = idx {
            result.removeAtIndex(index)
        }
        return result
    }
    
    /**
    Helper function to remove an array of elements
    */
    func remove( clusters:[Element] ) -> [Element]{
        var result:[Element] = []
        for i in 0..<clusters.count {
            result = self.remove(clusters[i])
        }
        return result;
    }
}