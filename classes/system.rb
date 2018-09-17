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
                    card = Card.new(hash["name"], hash["cost"], hash["type"])
                    @deck << card
                end
            rescue => e
                puts "エラー！エラー！デッキ枚数が足りないぞ！#{e}"
            end
        end
    end

    def shuffle_deck
        @deck.shuffle!
    end

    def draw_card
        card = @deck.shift
        return nil if @hand.size == 10
        @hand << card
        return card
    end

    def create_first_hand(cards = nil)
        shuffle_deck
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

    # マリガン時に残したいカード名と枚数をハッシュで指定(例:{"Wild Growth"=>2, "Nourish"=>1})
    # 5枚の候補のうちどれでもいいからマリガン時に欲しい！ってこともあるので指定枚数は何枚でもOKとしとく
    # マリガンの際にデッキの戻したカードは引かないので、デッキに戻すのはカードを入れ替えた後
    def mulligan(need_card_hash)
        change_card_list = []
        2.downto(0) do |i|
            if need_card_hash.keys.include?(@hand[i].name)
                # 1枚キープしたらhashから指定のカードの枚数を減らす
                need_card_hash[@hand[i].name] -= 1
                # 0枚になったらハッシュから除く
                need_card_hash.delete(@hand[i].name) if need_card_hash[@hand[i].name] == 0
                next
            end
            change_card_list << @hand[i]
            @hand.delete_at(i)
        end
        
        change_card_list.size.times do
            draw_card
        end

        # 変更したカードをデッキの底に戻してシャッフル
        @deck << change_card_list
        @deck.flatten!
        shuffle_deck
    end

    # ハンドにcard_infoのすべてを持っているかどうかを返す。持ってたらtrue
    def has_card?(card_info)
        @hand.each do |card|
            if card_info.has_key?(card.name)
                card_info[card.name] -= 1
            end
        end

        return true if card_info.values.all?{|elem| elem==0}
        return false
    end

    # ハンドにcard_infoのカードを持っているかを返す。上とは違い1枚指定で2枚持っててもOK。持ってたらtrue
    def has_card_at_least?(card_info)
        @hand.each do |card|
            if card_info.has_key?(card.name)
                card_info[card.name] -= 1
            end
        end

        return true if card_info.values.all?{|elem| elem<=0}
        return false
    end

    # ハンドからカードを使う
    def use_card(card_info)
        begin
            card_info.each do |card_name, num|
                if @hand.find_all{|card| card.name==card_name}.size >= num
                    num.times do
                        index = @hand.find_index{|card| card.name==card_name}
                        @hand.delete_at(index)
                    end
                else
                    raise CardNotFoundError
                end
            end
        rescue => e
            puts "エラー！エラー！指定のカードがないぞ！#{e}"
        end
    end

    # vsドルイドだとデッキ、ハンド、場の3マナ以下のミニオンがすべて除外される
    # 場は無視
    def remove_all_less_3_costs_minions
        @hand.delete_if{|card| card.cost <= 3 && card.type == Card::Type::MINION}
        @deck.delete_if{|card| card.cost <= 3 && card.type == Card::Type::MINION}
    end

    # プリズムレンズの効果でデッキからミニオンとスペルを1枚ずつ選んでドロー
    def draw_minion_and_spell
        begin
            minion = @deck.find{|card| card.type==Card::Type::MINION}
            spell = @deck.find{|card| card.type==Card::Type::SPELL}
            if minion != nil && spell != nil
                @hand << minion
                @hand << spell
                minion_index = @deck.find_index{|card| card == minion}
                @deck.delete_at(minion_index)
                spell_index = @deck.find_index{|card| card == spell}
                @deck.delete_at(spell_index)
                return minion, spell
            else
                raise CardNotFoundError
            end
        rescue => e
            puts "エラー！エラー！引こうとしたミニオンかスペルがないぞ！#{e}"
        end
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
