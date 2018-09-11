# coding: utf-8
require_relative './card.rb'
require 'json'
class CardsNumError < StandardError; end
class System
    attr_reader :hand, :deck

    def initialize
        @hand = Array.new
        @deck = Array.new
    end

    def import_deck(deck_path)
        File.open(deck_path) do |file|
            array = JSON.load(file)
            begin
                raise CardsNumError if array.size != 30
                array.each do |hash|
                    card = Card.new(hash['name'], hash['cost'], hash['type'])
                    @deck << card
                end
                @deck.shuffle!
            rescue => e
                puts "エラー！エラー！#{e}"
            end
        end
    end

    def draw_card
        card = @deck.shift
        return nil if @hand.size == 10
        @hand << card
        return card
    end

    def create_first_hand
        3.times do
            draw_card
        end
    end

    # マリガンの際にデッキの戻したカードは引かないので、デッキに戻すのはカードを入れ替えた後
    def mulligan(need_card_array)
        change_card_list = []
        2.downto(0) do |i|
            next if need_card_array.include?(@hand[i].name)
            change_card_list << @hand[i]
            @hand.delete_at(i)
        end
        
        change_card_list.size.times do
            draw_card
        end

        # 変更したカードをデッキの底に戻してシャッフル
        @deck << change_card_list
        @deck.flatten!
        @deck.shuffle!
    end

    def show_hand
        @hand.each do |card|
            puts "#{card.name} #{card.cost} #{card.type}"
        end
        puts "=== end of hand"
    end

    def show_deck
        @deck.each do |card|
            puts "#{card.name} #{card.cost} #{card.type}"
        end
        puts "=== end of deck"
    end
end
