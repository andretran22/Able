//
//  FilterClass.swift
//  Able
//
//  Created by Andre Tran on 11/15/20.
//

import Foundation

//global filter object. Represents current filter state
var globalFilterState: CurrentFilters?

class CurrentFilters {
    var sort:String
    var location:String
    var tags: [String]
    var categories:[String]
    
    init(sort:String, location:String, tags:[String], categories:[String]){
        self.sort = sort
        self.location = location
        self.tags = tags
        self.categories = categories
       
    }

    func printInfo(){
        print()
        print("Current Filter State:")
        print("     Sort: \(sort)")
        print("     Location: \(location)")
        print("     Tags: \(tags)")
        print("     Categories: \(categories)")
        print()

    }
    
    func sortAndFilter(postType:String, posts:[Post]) -> [Post]{
        print("Currently filtering \(postType)")
        printInfo()
        var tempPosts = [Post]()
        let filterTags = tags + categories
        
        //filter
        if !isDefaultState(){
            for post in posts {
                if location.isEmpty{
                    if arrayContainsString(filter: filterTags, postWords: post.tags ?? []) {
                        tempPosts.append(post)
                    }
                }else{
                    if post.location.lowercased().contains(location.lowercased()) &&
                        arrayContainsString(filter: filterTags, postWords: post.tags ?? []) {
                        tempPosts.append(post)
                    }
                }
            }
        }else{
            tempPosts = posts
        }
        
        // sort
        if sort == "Most Recent"{
            tempPosts = tempPosts.sorted(by: { $0.createdAt > $1.createdAt })
        }else{
            tempPosts = tempPosts.sorted(by: { $0.createdAt < $1.createdAt })
        }
        
        return tempPosts
    }
    
    // check if any word in filter is in poseWords
    func arrayContainsString(filter:[String], postWords:[String]) -> Bool{
        for filterWord in filter {
            for postWord in postWords {
                if filterWord.lowercased() == postWord.lowercased() {
                    print("true, found word")
                    return true
                }
            }
        }
        print()
        return false
    }
    
    /// check if current filter state is default state. i.e all fields are empty excpet the sort field
    func isDefaultState() ->  Bool{
        if location.isEmpty &&
            tags.count == 0 &&
            categories.count == 0 {
            return true
        }
        return false
    }
 
}
