# coding: utf-8
require_relative './classes/system.rb'
require_relative './classes/simulator.rb'
require 'thwait'
DECK_PATH = './data/mage_deck.json'

# 進行を定義する
def game_proc(simulator, system)
    # この対戦にかかった時間を記録
    time = Simulator::RunTime::TIME_RESTART

    # ロード済みのデッキ情報をまるっとコピー
    game_system = Marshal.load(Marshal.dump(system))

    # 初手の決定
    system.create_first_hand

    # マリガン
    system.mulligan({"Molten Giant"=>2,"Mana Bind"=>1,"Kabal Lackey"=>1})

    time += Simulator::RunTime::TIME_MULLIGAN

    # マリガン後の手札を確認、持ってちゃいけないものを持っていたらリセット
    # 持ってちゃいけないカードは別にない
    #system.show_hand
    #if !check_hand(system, 0)
    #    record_failed(simulator, time)
    #    return false
    #end
    time += Simulator::RunTime::TIME_DRAW_CARD

    # 1ターン目のカードドロー後のハンドを確認
    system.draw_card
    #system.show_hand
    if !check_hand(system, 1)
        record_failed(simulator, time)
        return false
    end

    # カバールの下っ端とマナ呪縛を使用
    system.use_card({"Kabal Lackey"=>1})
    system.use_card({"Mana Bind"=>1})

    time += Simulator::RunTime::TIME_PLAY_TURN_AND_ENEMY_TURN
    time += Simulator::RunTime::TIME_DRAW_CARD

    # 2ターン目のカードドローの後のハンドを確認
    system.draw_card
    #system.show_hand
    if !check_hand(system, 2)
        record_failed(simulator, time)
        return false
    end

    # 巨人を使用(1ターン目に奪ったスペルも使える時に使う)
    system.use_card({"Molten Giant"=>2})

    time += Simulator::RunTime::TIME_PLAY_TURN_AND_ENEMY_TURN
    time += Simulator::RunTime::TIME_DRAW_CARD

    # 3ターン目のカードドローの後のハンドを確認
    system.draw_card
    #system.show_hand
    if !check_hand(system, 3)
        record_failed(simulator, time)
        return false
    end

    # 足止めの凍結スペルとかを使う

    time += Simulator::RunTime::TIME_PLAY_TURN_AND_ENEMY_TURN
    time += Simulator::RunTime::TIME_DRAW_CARD

    # 4ターン目は殴って終わり
    simulator.record_result({"time"=>time})
    return true
end

# ハンドを確認。リセット案件ならfalseを返す
def check_hand(system, turn_no)
    case turn_no
    when 0
        return true
    when 1
        # 持ってなきゃいけない
        if !system.has_card?({"Mana Bind"=>1,"Kabal Lackey"=>1,"Molten Giant"=>1})
            return false
        end
    when 2
        # 持ってなきゃいけない
        if !system.has_card?({"Molten Giant"=>2})
            return false
        end
    when 3
        # 持ってなきゃいけない
        # 相手の足止めが可能なカード
        if system.has_card?({"Freezing Potion"=>1}) ||
        system.has_card?({"Breath of Sindragosa"=>1}) ||
        system.has_card?({"Ice Lance"=>1}) ||
        system.has_card?({"Mirror Image"=>1}) ||
        system.has_card?({"Flamecannon"=>1}) ||
        system.has_card?({"Frostbolt"=>1}) ||
        system.has_card?({"Snap Freeze"=>1}) ||
        system.has_card?({"Shieldbearer"=>1}) ||
        system.has_card?({"Wax Elemental"=>1}) ||
        system.has_card?({"Annoy-o-Tron"=>1}) ||
        system.has_card?({"Silverback Patriarch"=>1}) ||
        system.has_card?({"Tar Creeper"=>1})
            return true
        else
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
#simulator.puts_result_csv
