# coding: utf-8
# リセットポイントを4ターン目までにしておく
require_relative './classes/system.rb'
require_relative './classes/simulator.rb'
require 'thwait'
DECK_PATH = './data/paladin_deck.json'

# 進行を定義する
def game_proc(simulator, system)
    # この対戦にかかった時間を記録
    time = Simulator::RunTime::TIME_RESTART

    # ロード済みのデッキ情報をまるっとコピー
    game_system = Marshal.load(Marshal.dump(system))

    # 初手の決定
    system.create_first_hand

    # マリガン
    system.mulligan({"Doomsayer"=>1,"Prismatic Lens"=>2})

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

    time += Simulator::RunTime::TIME_PLAY_TURN_AND_ENEMY_TURN
    time += Simulator::RunTime::TIME_DRAW_CARD

    # 2ターン目のカードドローの後のハンドを確認
    system.draw_card
    #system.show_hand
    if !check_hand(system, 2)
        record_failed(simulator, time)
        return false
    end
    time += Simulator::RunTime::TIME_PLAY_TURN_AND_ENEMY_TURN
    time += Simulator::RunTime::TIME_DRAW_CARD

    # 3ターン目のカードドローの後のハンドを確認
    system.draw_card
    #system.show_hand
    if !check_hand(system, 3)
        record_failed(simulator, time)
        return false
    end

    # 終末預言者を使用
    system.use_card({"Doomsayer"=>1})

    time += Simulator::RunTime::TIME_PLAY_TURN_AND_ENEMY_TURN
    time += Simulator::RunTime::TIME_DRAW_CARD

    # 4ターン目のカードドローの後のハンドを確認
    system.draw_card
    #system.show_hand
    if !check_hand(system, 4)
        record_failed(simulator, time)
        return false
    end

    # プリズムレンズを使用
    system.use_card({"Prismatic Lens"=>1})
    minion, spell = system.draw_minion_and_spell
    time += Simulator::RunTime::TIME_DRAW_CARD * 2
    if !minion.is("Skulking Geist") || spell.is("Equality")
        record_failed(simulator, time)
        return false
    end

    time += Simulator::RunTime::TIME_PLAY_TURN_AND_ENEMY_TURN
    time += Simulator::RunTime::TIME_DRAW_CARD

    # 5ターン目のカードドローの後のハンドを確認
    system.draw_card
    #system.show_hand
    if !check_hand(system, 5)
        record_failed(simulator, time)
        return false
    end

    # プリズムレンズを使用
    system.use_card({"Prismatic Lens"=>1})
    minion, spell = system.draw_minion_and_spell
    time += Simulator::RunTime::TIME_DRAW_CARD * 2
    if !minion.is("Mecha'thun") || spell.is("Equality")
        record_failed(simulator, time)
        return false
    end

    time += Simulator::RunTime::TIME_PLAY_TURN_AND_ENEMY_TURN
    time += Simulator::RunTime::TIME_DRAW_CARD
    time += Simulator::RunTime::TIME_MECHATHUN

    # 6ターン目は揃ってるはずなので必要カードを使って終わり
    simulator.record_result({"time"=>time})
    return true
end

# ハンドを確認。リセット案件ならfalseを返す
def check_hand(system, turn_no)
    case turn_no
    when 0..2
        # 持ってちゃいけない
        if system.has_card?({"Mecha'thun"=>1}) ||
        system.has_card?({"Skulking Geist"=>1})
            return false
        end
    when 3
        # 持ってちゃいけない
        if system.has_card?({"Mecha'thun"=>1}) ||
        system.has_card?({"Skulking Geist"=>1})
            return false
        end
        # 持ってなきゃいけない
        if !system.has_card?({"Doomsayer"=>1, "Prismatic Lens"=>1})
            return false
        end
    when 4
        # 持ってちゃいけない
        if system.has_card?({"Mecha'thun"=>1}) ||
        system.has_card?({"Skulking Geist"=>1})
            return false
        end
        # 持ってなきゃいけない
        if !system.has_card?({"Prismatic Lens"=>2})
            return false
        end
    when 5
        # 持ってちゃいけない
        if system.has_card?({"Mecha'thun"=>1})
            return false
        end
        # 持ってなきゃいけない
        if !system.has_card?({"Skulking Geist"=>1, "Prismatic Lens"=>1})
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

1.times do
    threads << Thread.new { proc.call }
end

ThreadsWait.all_waits(*threads)

#simulator.show_result

#puts Time.now #シミュレーション終了時間

simulator.show_statistics
