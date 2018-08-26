//
//  SearchViewController.swift
//  EightyThreeCreativeAdamMoskovich
//
//  Created by Adam on 24/08/2018.
//  Copyright © 2018 Adam Moskovich. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {

    //
    // MARK: - Outlets
    //
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchResultsTableView: UITableView!
    //
    // MARK: - Lifecycle Functions
    //
    override func viewDidLoad() {
        super.viewDidLoad()
        //DatabaseController.shared.printData()
        searchResultsTableView.delegate = self
        searchResultsTableView.dataSource = self
        searchBar.delegate = self
        DatabaseController.shared.memoizationKeyWords()
        hideKeyboard()
    }
    //
    // MARK: - Actions
    //
    // Currently isHidden till I figure out how to use speech
    @IBAction func speechBtnTapped(_ sender: UIButton) {
    }    
}
//
// MARK: - Extensions
//
extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    //
    // MARK: - Delegate @ Data Source Methods
    //
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DatabaseController.shared.searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "productCell", for: indexPath) as? SearchResultTableViewCell {
            let productName = DatabaseController.shared.searchResults[indexPath.row]
            cell.productNameLabel.text = productName
            return cell
        }
        return UITableViewCell()
    }
}

extension SearchViewController: UISearchBarDelegate {
    //
    // MARK: - Delegate @ Data Source Methods
    //
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        guard let searchPhrase = searchBar.text,
            !searchPhrase.isEmpty else { return }
        DatabaseController.shared.generateResultsWith(searchPhrase: searchPhrase)
        searchResultsTableView.reloadData()
    }
    //
    // MARK: - Methods
    //
    func hideKeyboard() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        searchBar.endEditing(true)
    }
}

































