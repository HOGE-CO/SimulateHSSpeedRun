# coding: utf-8
class Simulator
    module RunTime
        TIME_RESTART = 20000 #リスタート所要時間
        TIME_MULLIGAN = 10000 #マリガンにかかる時間
        TIME_DRAW_CARD = 3000 #自分のターン開始からカードを引き終わるまでの時間
        TIME_PLAY_TURN_AND_ENEMY_TURN = 12000 #カードを引き終わってから次のターン開始までにかかる時間
        TIME_MECHATHUN = 8000 #メックトーンの死亡演出時間
    end

    module Test
        TEST_SUCCESS_COUNT_MAX = 1000 #この回数完走するまでやめない
    end

    def initialize
        @result = []
        @try_total_count = 0
        @try_total_time = 0
        @is_locked = false
    end

    def get_test_try_count
        return @result.size
    end

    def record_result(result)
        @is_locked = true
        result["try_total_count"] = @try_total_count + 1
        result["try_total_time"] = @try_total_time + result["time"]
        @result << result
        @try_total_count = 0
        @try_total_time = 0
        @is_locked = false
    end

    def is_locked
        return @is_locked
    end

    def add_total_count(try_count = 1)
        @try_total_count += try_count
    end

    def add_total_time(try_time)
        @try_total_time += try_time
    end

    def show_result
        @result.each do |result|
            puts result
        end
    end
end
