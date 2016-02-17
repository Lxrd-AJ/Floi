
class Recommender {
    var frequencies: [String:[String:Int]] = [:]
    var deviations: [String:[String:Double]] = [:]
    var data: [String:[String:Double]]

    init( data:[String:[String:Double]] ){
        self.data = data;
    }

    //TODO: Check if there is a bug in this function
    func computeDeviations( data: [String:[String:Double]] ) {
        for (_,ratings) in data {
            for (item,rating) in ratings {
                self.frequencies[item] = [:]
                self.deviations[item] = [:]
                //for each item2 & rating2 in that set of  ratings
                for (item2,rating2) in ratings {
                    if item != item2 {
                        self.frequencies[item]![item2] = 0
                        self.deviations[item]![item2] = 0.0
                        self.frequencies[item]![item2]! += 1
                        self.deviations[item]![item2]! += rating - rating2
                    }
                }
            }
        }//end for

        //calculate the average deviations of item i to j
        for (item,ratings) in self.deviations {
            for item2 in ratings.keys {
                let dev = ratings[item2]! / Double(self.frequencies[item]![item2]!)
                //ratings.updateValue(dev, forKey: item2)
                self.deviations[item]![item2] = dev
            }
        }
    }//end func computeDeviations

    func slopeOneRecommendations( userRatings:[String:Double] ) -> [String:Double]{
        var recommendations: [String:Double] = [:]
        var frequencies: [String:Int] = [:]

        //for every item and rating in the user's recommendations
        for (userItem,rating) in userRatings {
            //for every item in dataset that the user didnt rate
            for (diffItem,diffRatings) in self.deviations {
                if userRatings[diffItem] == nil && self.deviations[diffItem]![userItem] != nil {
                    let freq = self.frequencies[diffItem]![userItem]!
                    recommendations[diffItem] = 0.0
                    frequencies[diffItem] = 0
                    //add the running sum representing the numerator of the formula
                    recommendations[diffItem]! += (diffRatings[userItem]! + rating) * Double(freq)
                    frequencies[diffItem]! += freq
                }
            }
        }

        for (key,value) in recommendations {
            recommendations[key] = value / Double(frequencies[key]!)
        }
        return recommendations
    }
}
