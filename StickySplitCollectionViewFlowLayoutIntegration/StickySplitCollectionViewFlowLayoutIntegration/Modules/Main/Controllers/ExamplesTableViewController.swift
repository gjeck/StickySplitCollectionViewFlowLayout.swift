//
//  ExamplesTableViewController.swift
//  StickySplitCollectionViewFlowLayoutIntegration
//
//  Created by Greg Jeckell on 6/5/17.
//

import UIKit

class ExamplesTableViewController: UITableViewController {
    static let cellIdentifier: String = "ExampleCell"
    
    let sections: [SectionModel<ExampleModel>] = [
        SectionModel(title: "Example View Controllers", items: [
            ExampleModel(identifier: "UserProfileCollectionViewController",
                         name: "User Profile ViewController"),
            ExampleModel(identifier: "MediaPlaylistCollectionViewController",
                         name: "Media Playlist ViewController"),
            ExampleModel(identifier: "\(ParallaxCollectionViewController.self)",
                         name: "Simple Parallax ViewController"),
            ExampleModel(identifier: "\(AvatarSlideCollectionViewController.self)",
                         name: "Avatar Slide ViewController")
        ]),
        SectionModel(title: "Integration Test View Contollers", items: [
            ExampleModel(identifier: "\(NoMainHeaderCollectionViewController.self)",
                         name: "No Main Header ViewController"),
            ExampleModel(identifier: "\(IntegrationTestCollectionViewController.self)",
                         name: "Integration Test ViewController")
        ])
    ]
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        return sections[section].items.count
    }
    
    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ExamplesTableViewController.cellIdentifier,
                                                 for: indexPath)
        let example = sections[indexPath.section].items[indexPath.row]
        cell.textLabel?.text = example.name
        cell.detailTextLabel?.text = example.identifier
        return cell
    }
    
    override func tableView(_ tableView: UITableView,
                            didSelectRowAt indexPath: IndexPath) {
        let item = sections[indexPath.section].items[indexPath.row]
        performSegue(withIdentifier: item.identifier, sender: item)
    }
    
    override func tableView(_ tableView: UITableView,
                            titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }
}
