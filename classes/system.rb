# coding: utf-8
require_relative './card.rb'
require 'json'
class CardsNumError < StandardError; end
class CardNotFoundError < StandardError; end
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
                puts "エラー！エラー！デッキ枚数が足りないぞ！#{e}"
            end
        end
    end

    def draw_card
        card = @deck.shift
        return nil if @hand.size == 10
        @hand << card
        return card
    end

    def create_first_hand(cards = nil)
        begin
            if cards == nil
                3.times do
                    draw_card
                end
            elsif cards.size == 3
                # 指定の3枚をデッキから探してハンドを作る
                cards.each do |card_name|
                    index = @deck.find_index{|deck_card| deck_card.is(card_name)}
                    if index != nil
                        @hand << @deck[index]
                        @deck.delete_at(index)
                    else
                        # 見つからなかった場合は指定のカードがデッキに無いということなので明らかにおかしい
                        raise CardNotFoundError
                    end
                end
            else
                raise CardsNumError
            end
        rescue => e
            puts "エラー！エラー！初期手札の指定がおかしいぞ！#{e}"
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
