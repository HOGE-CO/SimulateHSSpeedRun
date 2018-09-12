# coding: utf-8
require_relative './classes/system.rb'
require_relative './classes/simulator.rb'
require 'thwait'
DECK_PATH = './data/sample_deck.json'

# 進行を定義する
def game_proc(simulator, system)
    # この対戦にかかった時間を記録
    time = Simulator::RunTime::TIME_RESTART

    # ロード済みのデッキ情報をまるっとコピー
    game_system = Marshal.load(Marshal.dump(system))

    # 初手の決定
    system.create_first_hand
    #system.create_first_hand(["Astral Communion","Biology Project","Runic Egg"])
    #system.create_first_hand(["Astral Communion","Snowflipper Penguin","Runic Egg"])

    # マリガン
    system.mulligan({"Astral Communion"=>1,"Biology Project"=>1,"Innervate"=>1,"Runic Egg"=>1})

    time += Simulator::RunTime::TIME_MULLIGAN

    # マリガン後の手札を確認、持ってちゃいけないものを持っていたらリセット
    #system.show_hand
    if !check_hand(system, 0)
        record_failed(simulator, time)
        return false
    end

    time += Simulator::RunTime::TIME_DRAW_CARD

    # 1ターン目のカードドロー後のハンドを確認
    system.draw_card
    #system.show_hand
    if !check_hand(system, 1)
        record_failed(simulator, time)
        return false
    end

    # 1ターン目に卵があって2ターン目に使うカードのうち2枚が手札になかったら卵を使う
    # リッチキングの効果もついでに発動
    if system.has_card?({"Runic Egg"=>1}) && (
        ( system.has_card?({"Astral Communion"=>1}) && !system.has_card?({"Biology Project"=>1}) && !system.has_card?({"Innervate"=>1}) ) ||
        ( !system.has_card?({"Astral Communion"=>1}) && system.has_card?({"Biology Project"=>1}) && !system.has_card?({"Innervate"=>1}) ) ||
        ( !system.has_card?({"Astral Communion"=>1}) && !system.has_card?({"Biology Project"=>1}) && system.has_card?({"Innervate"=>1}) )
    )
        system.use_card({"Runic Egg"=>1})
        system.remove_all_less_3_costs_minions
        system.draw_card # 卵の断末魔でカードを引く
    else
        system.remove_all_less_3_costs_minions
    end

    time += Simulator::RunTime::TIME_PLAY_TURN_AND_ENEMY_TURN
    time += Simulator::RunTime::TIME_DRAW_CARD

    # 2ターン目のカードドローの後のハンドを確認
    system.draw_card
    #system.show_hand
    if !check_hand(system, 2)
        record_failed(simulator, time)
        return false
    end

    # カードを全部使う
    system.use_card({"Astral Communion"=>1,"Biology Project"=>1,"Innervate"=>1})

    time += Simulator::RunTime::TIME_PLAY_TURN_AND_ENEMY_TURN
    time += Simulator::RunTime::TIME_DRAW_CARD

    # 3ターン目のカードドローの後のハンドを確認
    system.draw_card
    #system.show_hand
    if !check_hand(system, 3)
        record_failed(simulator, time)
        return false
    end

    time += Simulator::RunTime::TIME_PLAY_TURN_AND_ENEMY_TURN
    time += Simulator::RunTime::TIME_DRAW_CARD
    time += Simulator::RunTime::TIME_MECHATHUN

    # 4ターン目は揃ってるはずなので必要カードを使って終わり
    simulator.record_result({"time"=>time})
    return true
end

# ハンドを確認。リセット案件ならfalseを返す
def check_hand(system, turn_no)
    case turn_no
    when 0
        # 持ってちゃいけない
        if system.has_card?({"Mecha'thun"=>1}) ||
        system.has_card?({"Naturalize"=>1}) ||
        system.has_card?({"Nourish"=>1}) ||
        system.has_card?({"Innervate"=>2}) ||
        system.has_card?({"Astral Communion"=>1,"Biology Project"=>1,"Innervate"=>1}) # 2ターン目にパーツを引くから全部は持ってちゃダメ
            return false
        end
    when 1
        # 持ってちゃいけない
        if system.has_card?({"Mecha'thun"=>1}) ||
        system.has_card?({"Naturalize"=>1}) ||
        system.has_card?({"Nourish"=>1}) ||
        system.has_card?({"Innervate"=>2}) ||
        system.has_card?({"Astral Communion"=>1,"Biology Project"=>1,"Innervate"=>1}) # 2ターン目にパーツを引くから全部は持ってちゃダメ
            return false
        end
        # 持ってなきゃいけない
        if system.has_card?({"Astral Communion"=>1,"Biology Project"=>1}) ||
        system.has_card?({"Astral Communion"=>1,"Innervate"=>1}) ||
        system.has_card?({"Biology Project"=>1,"Innervate"=>1}) ||
        system.has_card?({"Astral Communion"=>1,"Runic Egg"=>1}) ||
        system.has_card?({"Astral Communion"=>1,"Runic Egg"=>2}) ||
        system.has_card?({"Biology Project"=>1,"Runic Egg"=>1}) ||
        system.has_card?({"Biology Project"=>1,"Runic Egg"=>2}) ||
        system.has_card?({"Innervate"=>1,"Runic Egg"=>1}) ||
        system.has_card?({"Innervate"=>1,"Runic Egg"=>2})
            return true
        else
            return false
        end
    when 2
        # 持ってなきゃいけない
        if !system.has_card?({"Astral Communion"=>1,"Biology Project"=>1,"Innervate"=>1})
            return false
        end
    when 3
        # 持ってなきゃいけない
        if !system.has_card?({"Nourish"=>1})
            return false
        end
    end
    return true
end

def record_failed(simulator, time)
    while true
        next if simulator.is_locked
        simulator.add_total_count
        simulator.add_total_time(time)
        break
    end
end

simulator = Simulator.new

system = System.new
system.import_deck(DECK_PATH)

proc = Proc.new do
    while true
        break if simulator.get_test_try_count >= Simulator::Test::TEST_SUCCESS_COUNT_MAX
        copy_system = Marshal.load(Marshal.dump(system))
        game_proc(simulator, copy_system)
    end
end

threads = []

#puts Time.now #シミュレーション開始時間

12.times do
    threads << Thread.new { proc.call }
end

ThreadsWait.all_waits(*threads)

#simulator.show_result

#puts Time.now #シミュレーション終了時間

simulator.show_statistics
