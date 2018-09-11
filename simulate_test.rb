# coding: utf-8
require_relative './classes/system.rb'
DECK_PATH = './data/sample_deck.json'

system = System.new
system.import_deck(DECK_PATH)

# 初手を決める。アドベンチャーは先行なので先行しか考えない
#system.create_first_hand
system.create_first_hand(["Innervate", "Biology Project", "Innervate"]) #配られる初期手札を指定
#system.create_first_hand(["Innervate", "Mecha'thun", "Deathwing"]) #デッキに無いカードを指定するとちゃんとエラーが返るかためす

# ハンドを表示
puts "*** show first hand ***"
system.show_hand

=begin
# デッキの中身を表示する
puts "*** show deck ***"
system.show_deck
=end

# マリガンする。生物学プロジェクトと星霊交信とねりけ1枚はキープ
system.mulligan({"Astral Communion"=>1,"Biology Project"=>1,"Innervate"=>1})

# マリガン後のハンドを表示
puts "*** show hand after mulligan ***"
system.show_hand

=begin
# マリガン後のデッキの中身を表示する
puts "*** show deck after mulligan ***"
system.show_deck
=end

# 適当にカードを引いてみる
system.draw_card
system.draw_card
system.draw_card

# ハンドを表示
puts "*** show hand ***"
system.show_hand

# もっとカードを引いてみる
system.draw_card
system.draw_card
system.draw_card
system.draw_card
system.draw_card
system.draw_card

# 10枚までしか持てないことを確認する
puts "*** show hand after drawing card too many ***"
system.show_hand
