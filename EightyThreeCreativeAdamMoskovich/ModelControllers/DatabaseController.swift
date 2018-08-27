//
//  DatabaseController.swift
//  EightyThreeCreativeAdamMoskovich
//
//  Created by Adam on 24/08/2018.
//  Copyright © 2018 Adam Moskovich. All rights reserved.
//

import Foundation

class DatabaseController {
    
    //
    // MARK: - Properties
    //
    // Shared Instance
    static let shared = DatabaseController()
    // Load database
    //let database = NSArray(contentsOf: Bundle.main.url(forResource: "productDatabase", withExtension: "plist")!) as! [[String: Any]]
    var databaseDict: [String:[String]] = [:]
    var searchResults: [String] = []
    
    //
    // MARK: - Methods
    //
    /// Converts the database into a dictionary [keyWord:[ProductNames]], the will reduce BigO when searching
    func memoizationKeyWords() {
        let database = NSArray(contentsOf: Bundle.main.url(forResource: "productDatabase", withExtension: "plist")!) as! [[String: Any]]
        for product in database {
            if let productName = product["productName"] as? String,
                let keyWords = product["keywords"] as? [String] {
                for keyWord in keyWords {
                    if var entry = databaseDict[keyWord] {
                        entry.append(productName)
                        databaseDict[keyWord] = entry
                    } else {
                        databaseDict[keyWord] = [productName]
                    }
                }
            }
        }
    }
    
    /// Takes the searchPhrase and does the initial modifications before sending it through the filtering process to populate the searchResults Array inside this class
    ///
    /// - Parameter searchPhrase: The search terms entered in the searchBar
    func generateResultsWith(searchPhrase: String) {
        // Adding a "The" at the start of the string seems to fix a bug where the .lemma scheme can't assign a value to the tag with shorter strings e.g. searchPhrase = "A Hat"
        let modifiedSearchPhrase = "the \(searchPhrase.lowercased())"
        searchResults = []
        applyLemmatization(to: modifiedSearchPhrase)
    }
    
    /// Convertsvthe inflected forms of a word so they can be analysed as a single item when comparing them to the database later
    ///
    /// - Parameter searchPhrase: takes in the modified searchPhrase from generateResultsWith()
    func applyLemmatization(to searchPhrase: String) {
        print("lemmatization")
        var lemmatizedString: String = ""
        // 1. Options
        let lemmaOptions: NSLinguisticTagger.Options = [ .omitWhitespace, .omitPunctuation]
        // 2. Instance
        let lemmaTagger = NSLinguisticTagger(tagSchemes: [.lemma], options: Int(lemmaOptions.rawValue))
        // 3. Text
        lemmaTagger.string = searchPhrase
        // 4. Range
        let lemmaRange = NSRange(location: 0, length: searchPhrase.utf16.count)
        // 5. Enumerate
        lemmaTagger.enumerateTags(in: lemmaRange, scheme: .lemma, options: lemmaOptions, using: { tag, tokenRange, _, stop in
            let token = (searchPhrase as NSString).substring(with: tokenRange)
            
            if tag != nil {
                let textTag = String(tag!.rawValue)
                if textTag != token
                {
                    print("\(textTag): \(token)")
                }
                lemmatizedString += "\(textTag) "
            }
                // .lemma will only return english laungage words, products like '3M' will not be returned in the textTag so we can return the token itself
            else {
                lemmatizedString += "\(token) "
            }
        })
        identifyingTokens(in: lemmatizedString)
    }
    
    /// catagories the words into grammatical groups allowing use to extract only the groups most likely to contain useful information, it also applies a second filter of 'stop words' as discribed in the Filter file
    ///
    /// - Parameter lemmatizedString: Takes in the string that has already been filtered by the applyLemmatization()
    func identifyingTokens(in lemmatizedString: String) {
        print("identifyingTokens")
        var optimizedSearchArray: [String] = []
        // 1. Options
        let tokenOptions: NSLinguisticTagger.Options = [ .omitWhitespace, .omitPunctuation]
        // 2. Instance
        let tokenTagger = NSLinguisticTagger(tagSchemes: NSLinguisticTagger.availableTagSchemes(forLanguage: "en"), options: Int(tokenOptions.rawValue))
        // 3. Text
        tokenTagger.string = lemmatizedString
        // 4. Range
        let textRange = NSRange(location: 0, length: lemmatizedString.utf16.count)
        // 5. Enumerate
        tokenTagger.enumerateTags(in: textRange, scheme: .nameTypeOrLexicalClass, options: tokenOptions, using: { tag, tokenRange, _, stop in
            let word = ( lemmatizedString as NSString).substring(with: tokenRange)
            let convertTag = tag!.rawValue
            print(convertTag + ": " + word)
            // the identifyingTokens aren't very accurate so these tags tend to have the needed info
            if convertTag == "Noun" || convertTag == "Adjective" || convertTag == "Adverb" || convertTag == "Verb" || convertTag == "Number" || convertTag == "Conjunction"{
                // This is an extra fillter from common 'Stop words'
                if Filters.stopWordDict[word] == nil {
                    optimizedSearchArray.append(word)
                }
            }
        })
        print(optimizedSearchArray)
        searchDatabase(with: optimizedSearchArray)
    }
    
    /// Performs the actual search and populates the searchResults Array
    ///
    /// - Parameter optimizedSearchArray: The final filtered array
    func searchDatabase(with optimizedSearchArray: [String]) {
        searchResults = []
        for word in optimizedSearchArray {
            if let databaseResults = databaseDict[word] {
                searchResults += databaseResults
            }
            print(searchResults)
        }
        if searchResults.isEmpty {
            searchResults.append("No Products Match Your Search, Please Try Again")
        }
    }
}
