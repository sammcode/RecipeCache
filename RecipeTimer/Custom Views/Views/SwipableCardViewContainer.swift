//
//  SwipableCardViewContainer.swift
//  RecipeTimer
//
//  Created by Sam McGarry on 7/25/20.
//  Copyright © 2020 Sam McGarry. All rights reserved.
//

import UIKit

class SwipeableCardViewContainer: UIView {

    static let horizontalInset: CGFloat = 12.0

    static let verticalInset: CGFloat = 12.0

    var dataSource: WalkthroughCardViewDataSource? {
        didSet {
            reloadData()
        }
    }

    var delegate: WalkthroughCardViewDelegate?

    private var cardViews: [WalkthroughCardView] = []

    private var visibleCardViews: [WalkthroughCardView] {
        return subviews as? [WalkthroughCardView] ?? []
    }

    fileprivate var remainingCards: Int = 0
    
    fileprivate var previousCards: Int = -1

    static let numberOfVisibleCards: Int = 3

    override func awakeFromNib() {
        super.awakeFromNib()

        backgroundColor = .clear
        translatesAutoresizingMaskIntoConstraints = false
    }

    /// Reloads the data used to layout card views in the
    /// card stack. Removes all existing card views and
    /// calls the dataSource to layout new card views.
    func reloadData() {
        removeAllCardViews()
        guard let dataSource = dataSource else {
            return
        }

        let numberOfCards = dataSource.numberOfCards()
        remainingCards = numberOfCards

        for index in 0..<min(numberOfCards, SwipeableCardViewContainer.numberOfVisibleCards) {
            addCardView(cardView: dataSource.card(forItemAtIndex: index), atIndex: index)
        }

        if let emptyView = dataSource.viewForEmptyCards() {
            addEdgeConstrainedSubView(view: emptyView)
        }

        setNeedsLayout()
    }

    private func addCardView(cardView: WalkthroughCardView, atIndex index: Int) {
        setFrame(forCardView: cardView, atIndex: index)
        insertSubview(cardView, at: 0)
        remainingCards -= 1
    }
    
    private func addCardViewAtFront(cardView: WalkthroughCardView, atIndex index: Int, removeCard: Bool){
        setFrame(forCardView: cardView, atIndex: index)
        insertSubview(cardView, at: 2)
        if removeCard { remainingCards += 1 }
    }

    private func removeAllCardViews() {
        for cardView in visibleCardViews {
            cardView.removeFromSuperview()
        }
        cardViews = []
    }

    /// Sets the frame of a card view provided for a given index. Applies a specific
    /// horizontal and vertical offset relative to the index in order to create an
    /// overlay stack effect on a series of cards.
    ///
    /// - Parameters:
    ///   - cardView: card view to update frame on
    ///   - index: index used to apply horizontal and vertical insets
    private func setFrame(forCardView cardView: WalkthroughCardView, atIndex index: Int) {
        var cardViewFrame = bounds
        let horizontalInset = (CGFloat(index) * SwipeableCardViewContainer.horizontalInset)
        let verticalInset = (CGFloat(index) * SwipeableCardViewContainer.verticalInset)

        cardViewFrame.size.width -= 2 * horizontalInset
        cardViewFrame.origin.x += horizontalInset
        cardViewFrame.origin.y += verticalInset

        cardView.frame = cardViewFrame
    }
    
    func nextCard(onCard card: WalkthroughCardView) {
        guard let dataSource = dataSource else {
            return
        }

        // Remove swiped card
        card.removeFromSuperview()
        previousCards += 1

        // Only add a new card if there are cards remaining
        if remainingCards > 0 {

            // Calculate new card's index
            let newIndex = dataSource.numberOfCards() - remainingCards
            
            print("new index is: ")
            print(newIndex)
            
            print("remaining cards is: ")
            print(remainingCards)
            // Add new card as Subview
            addCardView(cardView: dataSource.card(forItemAtIndex: newIndex), atIndex: 2)

            // Update all existing card's frames based on new indexes, animate frame change
            // to reveal new card from underneath the stack of existing cards.
            for (cardIndex, cardView) in visibleCardViews.reversed().enumerated() {
                UIView.animate(withDuration: 0.2, animations: {
                    cardView.center = self.center
                    self.setFrame(forCardView: cardView, atIndex: cardIndex)
                    self.layoutIfNeeded()
                })
            }

        }
    }
    
    func previousCard(onCard card: WalkthroughCardView) {
        guard let dataSource = dataSource else {
            return
        }
        
        card.removeFromSuperview()
        
        let newIndex = previousCards
        
        previousCards -= 1
        
        addCardViewAtFront(cardView: dataSource.card(forItemAtIndex: newIndex), atIndex: 0, removeCard: true)
        
        for (cardIndex, cardView) in visibleCardViews.enumerated() {
            UIView.animate(withDuration: 0.2, animations: {
                cardView.center = self.center
                self.setFrame(forCardView: cardView, atIndex: cardIndex)
                self.layoutIfNeeded()
            })
        }
    }
    
    func previousCardWithoutRemoving() {
        
        guard let dataSource = dataSource else {
            return
        }
        
        let newIndex = previousCards
        
        previousCards -= 1
        
        addCardViewAtFront(cardView: dataSource.card(forItemAtIndex: newIndex), atIndex: 0, removeCard: false)
        
        for (cardIndex, cardView) in visibleCardViews.enumerated() {
            UIView.animate(withDuration: 0.2, animations: {
                cardView.center = self.center
                self.setFrame(forCardView: cardView, atIndex: cardIndex)
                self.layoutIfNeeded()
            })
        }
    }
}
