//
//  ViewController.swift
//  CollectionTest
//
//  Created by Jeroen van Rijn on 27/10/2023.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var dataSource: UICollectionViewDiffableDataSource<Section, Label>!
    
    let labels = [
        Label(text: "Hello, World"),
        Label(text: "Hello, World! this is a longer text that should take multiple lines"),
        Label(text: "Hello, World! this is a longer text that should!"),
        Label(text: "Hello, Wor!"),
        Label(text: "Hello, Worl"),
        Label(text: "Hello!"),
        Label(text: "Hello!"),
        Label(text: "Hello, World"),
        Label(text: "Hello, World! this is a longer text that should take multiple lines"),
        Label(text: "Hello, World!"),
        Label(text: "Hello, World! this is a longer text that should!"),
        Label(text: "Hello, Wor!"),
        Label(text: "Hello, Wold!"),
        Label(text: "Hellod!"),
        Label(text: "Hello, World! this is a longer text that should take multiple lines"),
        Label(text: "Hello, World!"),
        Label(text: "Hello, World!")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        collectionView.setCollectionViewLayout(createLayout(), animated: false)
        collectionView.backgroundColor = .green
        configureDataSource()
    }
}

extension ViewController {
    func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout {
            (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection in

            var groups = [NSCollectionLayoutGroup]()
            let contentSize = layoutEnvironment.container.effectiveContentSize
            
            var rows = [[CGFloat]]()
            var currentRow = [CGFloat]()
            var currentRowWidth: CGFloat = 0
            let spacing: CGFloat = 10
            let maxRowWidth = contentSize.width - (2 * spacing)
            
            // Loop through the labels and add them to rows.
            for label in self.dataSource.snapshot(for: .main).items {
                let textWidth = self.width(for: label.text)
                let cellWidth = textWidth + 16
                
                if currentRowWidth > 0 {
                    currentRowWidth += spacing // spacing
                }
                
                currentRowWidth += cellWidth
                currentRow.append(cellWidth)
                
                if currentRowWidth > maxRowWidth {
                    let last = currentRow.last!
                    let withoutLast = Array(currentRow.dropLast())
                    
                    addRow(items: withoutLast)

                    currentRow = [last]
                    currentRowWidth = last
                }
            }
            
            // Remaining rows
            if !currentRow.isEmpty {
                addRow(items: currentRow)
            }
            
            // Needed to create a group per row to make the fully auto sizing tag layout work :(
            func addRow(items: [CGFloat]) {
                rows.append(items)
                
                // If a row contains only item that is larger that the group with we give it the width of the group.
                if items.count == 1 && items[0] >= maxRowWidth {
                    print("Add row: \(items.count) - FULL WIDTH")
                    
                    let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(44))
                    let layoutItem = NSCollectionLayoutItem(layoutSize: itemSize)
                    let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(44))
                    let innerGroup = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [layoutItem])
                    innerGroup.interItemSpacing = .fixed(spacing)
                    groups.append(innerGroup)
                    
                } else {
                    print("Add row: \(items.count)")
                    
                    let itemSize = NSCollectionLayoutSize(widthDimension: .estimated(44), heightDimension: .estimated(44))
                    let layoutItem = NSCollectionLayoutItem(layoutSize: itemSize)
                    let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(44))
                    let innerGroup = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [layoutItem])
                    innerGroup.interItemSpacing = .fixed(spacing)
                    groups.append(innerGroup)
                }
            }
            
            print("Number of groups: \(groups.count)")
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(44))
            let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: groups)
            group.interItemSpacing = .fixed(spacing)
            
            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = spacing
            section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
            
            return section
        }
        return layout
    }
    
    func width(for text: String) -> CGFloat {
        text.size(withAttributes:[.font: UIFont.systemFont(ofSize: 16)]).width
    }
}

extension ViewController {
    enum Section {
        case main
    }
    
    func configureDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<LabelCell, Label> { (cell, indexPath, item) in
            cell.label.text = item.text
        }
        
        dataSource = UICollectionViewDiffableDataSource<Section, Label>(collectionView: collectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, item: Label) -> UICollectionViewCell? in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
        }
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, Label>()
        snapshot.appendSections([.main])
        snapshot.appendItems(labels)
        dataSource.apply(snapshot, animatingDifferences: false)
    }
}
