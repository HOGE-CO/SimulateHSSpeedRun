# coding: utf-8
require_relative './classes/system.rb'
DECK_PATH = './data/sample_deck.json'

system = System.new
system.import_deck(DECK_PATH)

=begin
# デッキの中身を表示する
puts "*** show deck ***"
system.show_deck
=end

# 初手を決める。アドベンチャーは先行なので先行しか考えない
system.create_first_hand

# ハンドを表示
puts "*** show first hand ***"
system.show_hand

# マリガンする。生物学プロジェクトと星霊交信とねりけはキープ
system.mulligan(["Astral Communion","Biology Project","Innervate"])

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
