# coding: utf-8
class Simulator
    def initialize
        @result = []
        @try_total_count = 0
        @try_total_time = 0
        @is_locked = false
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
