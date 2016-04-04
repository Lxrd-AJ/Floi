//
//Author: Ibraheem AJ
//  Date: 11/03/2016
// Email: ibraheemaj@icloud.com
//

//import SwiftPriorityQueue

/**
* Hierarchical Classifer 
* Groups structured data into clusters. 
* It utilises a priority queue to group the clusters into a Hierarchial Cluster with the priority being the shortest distance to a    cluster's 
* nearest neighbour
* - todo:
*   [x] Create a `Cluster` struct to represent a cluster
*/
class HierarchicalClassifier {    
    
    var clusters:[Cluster] = []
    lazy var normalizedClusters: [Cluster] = { 
        return normalizeClusters(self.clusters);
    }()
    
    init( filename:String ){
        self.clusters = ClusterParser.parseFile( filename ); 
        //print( self.normalizedClusters )
        //print("Nearest Neighbour")
        //print( self.normalizedClusters[0].nearestNeighbour(self.normalizedClusters)
        
        let sortedClusters = self.normalizedClusters.sort({ (cluster1,cluster2) in 
            let rest = self.normalizedClusters
            return cluster1.distanceToNearestNeighbour(rest) < cluster2.distanceToNearestNeighbour(rest)
        })
        
        let dendogram = self.createTree( sortedClusters[0], clusters:Array(sortedClusters[1..<sortedClusters.count]) )
        prettify(dendogram)
        
    }
    
    /**
    - warning: Incomplete implementation 
    */
    func prettify( tree:Cluster ){
        
        switch tree {
        case .Empty:
            print("--")
        case .ClusterNode(let lhs,_, let name,let rhs):
            print("\t\(name)\n")
            prettify(lhs)
            prettify(rhs)
        }
        
    }
    /**
    Sorts and clusters the elements recursively based on their nearest neighbour and returns a tree/dendogram of the
    clusters 
    */
    func createTree( cluster:Cluster, clusters:[Cluster] ) -> Cluster {
        if clusters.count == 0 { 
            return cluster 
        }else{
            let lhs = cluster
            let rhs = lhs.nearestNeighbour(clusters);
            let name = lhs.values().name + "," + rhs.values().name 
            let newDist = min(lhs,y:rhs,set:clusters).values().distance
            let newCluster = Cluster(name:name,distance:newDist,left:lhs,right:rhs); 
            //print(name)
            return self.createTree( newCluster, clusters: clusters.remove(rhs) )
        }
    }
    
    /**
    Returns the cluster with the whose closest nearest neighbour's distance is lesser than the other in the sample
    space `set`
    */
    private func min( x:Cluster, y:Cluster, set:[Cluster] ) -> Cluster {
        if x.distanceToNearestNeighbour(set) < y.distanceToNearestNeighbour(set){
            return x
        }else{ return y }
    }
    
}
