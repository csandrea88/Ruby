class Blackjack 
    attr_accessor :deck, :player_Hand, :dealer_Hand

    def initialize
        #create a new deck and player and dealer hands
        @deck = Deck.new
        @player_Hand = Hand.new
        @dealer_Hand = Hand.new

        #game setup: deals two cards to both player and dealer. In the the add_2_cards and add_a_card methods
        #a player can immediately bust or blackjack
        @player_Hand.add_2_cards(deck.deal_card, deck.deal_card, "player")
        @dealer_Hand.add_2_cards(deck.deal_card, deck.deal_card, "dealer")
        
        @player_stands = false
        @dealer_stands = false
        
        until(@player_stands) 
        # First, the player gets a new card based on dealers face up card or stands. If dealer's faceup card
        # is 10 or 11, then player will add cards a little more agressively than when faceup card is 
        # value is less than 10.
            
            if dealer_Hand.faceupcard.value >= 10 
                if player_Hand.totvalue < 17
                    # puts "player hand less than 17"
                    puts "player: another card please"
                    @player_Hand.add_a_card(deck.deal_card, "player")
                    
                else
                    @player_stands = true
                    puts "player stands"
                end
            else 
                if player_Hand.totvalue < 15
                    # puts "player hand less than 19"
                    puts "player: another card please"
                    @player_Hand.add_a_card(deck.deal_card, "player")
                    
                else
                    @player_stands = true
                    puts "player stands"
                end
            end
        end

        #Then, when the player stands, which means no more cards are requested by the player, the dealer gets his turn.
        #The dealer will keep picking cards if total value of his cards are less than 17. 
        until(@dealer_stands)
            if dealer_Hand.totvalue < 17
                # puts "dealer < 17"
                puts "dealer: another card please"
                @dealer_Hand.add_a_card(deck.deal_card,"dealer")
                
            else
                @dealer_stands = true
                puts "dealer stands"
            end
        end

        puts "Ok show em; lets see who wins?"
        puts "player: #{player_Hand.totvalue}" 
        puts "dealer: #{dealer_Hand.totvalue}" 
        
        if player_Hand.totvalue > dealer_Hand.totvalue
            puts "Player wins game; Dealer lost"
            exit
        elsif dealer_Hand.totvalue > player_Hand.totvalue
            puts "Dealer wins game: Player lost"
            exit
        else    
            puts "Dealer and Player ties"
            exit
        end
    end        
end

class Card
  attr_accessor :suit, :name, :value

  def initialize(suit, name, value)
    @suit, @name, @value = suit, name, value
  end

end

class Deck
  attr_accessor :playable_cards
  SUITS = [:hearts, :diamonds, :spades, :clubs]
  NAME_VALUES = {
    :two   => 2,
    :three => 3,
    :four  => 4,
    :five  => 5,
    :six   => 6,
    :seven => 7,
    :eight => 8,
    :nine  => 9,
    :ten   => 10,
    :jack  => 10,
    :queen => 10,
    :king  => 10,
    :ace   => [11, 1]}

  def initialize
    shuffle
  end

  def deal_card
    random = rand(@playable_cards.size)
    @playable_cards.delete_at(random)
  end

  def shuffle
    @playable_cards = []
    SUITS.each do |suite|
      NAME_VALUES.each do |name, value|
        @playable_cards << Card.new(suite, name, value)
      end
    end
  end
end

class Hand
  attr_accessor :cards, :busted, :bjack, :totvalue, :faceupcard

  def initialize
    self.cards = []
    self.faceupcard = ""
    self.busted = false 
    self.bjack = false
  end

  def add_a_card (card, handtype)
    self.cards += [card]
    # puts "#{handtype.inspect} added 1 card to Hand: #{self.inspect}"
    self.check_busted(handtype)
  end

  def add_2_cards (card1,card2,handtype)
    self.cards += [card1,card2]

    # Creates the Dealer's faced up card
    if handtype == "dealer"
        self.faceupcard = card2
        # puts "dealer faceup: #{self.faceupcard.value}"
    end

    # puts "#{handtype.inspect} added 2 cards to Hand: #{self.inspect}"

    # Calls method to check if the hand got blackjack or bust
    self.check_bjack(handtype)
    self.check_busted(handtype)
  end

  def check_bjack(handtype)
  # blackjack is defined as an ace and a card with a 10 point value

    @gotace = false
    @got10 = false

    for card in self.cards
        if card.value.kind_of?(Array)
            @gotace = true
        elsif card.value == 10
            @got10 = true
        end
    end
    if @gotace && @got10 
        self.bjack = true
        puts "#{handtype} Won, got Blackjack"
        exit
    end
  end 

  def check_busted(handtype)
  # A Hand is busted when total point value of hand is greater than 21

    @gotace = 0

    self.totvalue = 0

    # a card that has an array for its value is an ace
    # the ace will always be worth 11 points unless the total point value is greater than 21
    for card in self.cards
        if card.value.kind_of?(Array) 
            self.totvalue += 11
            @gotace += 1
        else 
            self.totvalue += card.value
        end
    end

    
    # puts "#{handtype}'s total number of aces: #{@gotace}"
    # puts "#{handtype} has total points of: #{self.totvalue}"

    # if after adding up all the points and total point value is greater than 21. This logic
    # will make the ace/aces worth only one point. If there is more than one ace,it will change ace values
    # to 1 until total point value is greater than 21. 
    while (@gotace > 0)
        puts "in @gotace > 0"
        if self.totvalue > 21 
            self.totvalue -= 10
        end
        @gotace -= 1
    end

    # puts "#{handtype} has total points of: #{self.totvalue}"

    # Finally we check if the total point value is greater than 21, if it is the program ends.
    if self.totvalue > 21
        self.busted = true
        puts "#{handtype} Lost, busted"
        exit
    end
  end  
end

# This starts a game when not using test/unit
# @bj = Blackjack.new 

require 'test/unit'

class CardTest < Test::Unit::TestCase
  def setup
    @card = Card.new(:hearts, :ten, 10)
  end
  
  def test_card_suit_is_correct
    assert_equal @card.suit, :hearts
  end

  def test_card_name_is_correct
    assert_equal @card.name, :ten
  end

  def test_card_value_is_correct
    # assert_equal @card.value, 10
  end
end

class DeckTest < Test::Unit::TestCase
  def setup
    @deck = Deck.new
  end
  
  def test_new_deck_has_52_playable_cards
    assert_equal @deck.playable_cards.size, 52
  end
  
  def test_dealt_card_should_not_be_included_in_playable_cards
    card = @deck.deal_card
    assert_equal @deck.playable_cards.include?(card), false
  end

  def test_shuffled_deck_has_52_playable_cards
    @deck.shuffle
    assert_equal @deck.playable_cards.size, 52
  end
end
class HandTest < Test::Unit::TestCase
    
    def setup
      @hand = Hand.new
      @card1 = Card.new(:hearts, :ten, 10)
      @card2 = Card.new(:clubs, :king, 10)
      @card3 = Card.new(:hearts, :queen, 10)
      @card4 = Card.new(:clubs, :queen, 14)
      @card5 = Card.new(:diamonds, :queen, 14)
      @card6 = Card.new(:hearts, :jack, 10)
      @card7 = Card.new(:clubs, :ace, [11,1])
    end
    
    def test_add_a_card
      @hand.add_a_card(@card1, "player")
      assert_equal @hand.cards.size, 1
    end

    def test_add_2_cards
      @hand.add_2_cards(@card1, @card2, "dealer")
      assert_equal @hand.cards.size, 2
    end

    def test_add_2_cards_faceupcard 
      @hand.add_2_cards(@card2, @card3, "dealer")
      assert_equal @hand.faceupcard, @card3
    end

    def test_busted_lost 
        @hand.add_2_cards(@card1, @card2, "player")
        assert_equal "player Lost, busted", @hand.add_a_card(@card3, "player")
    end

end

