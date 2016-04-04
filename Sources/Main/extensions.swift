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