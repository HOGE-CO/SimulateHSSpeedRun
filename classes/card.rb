# coding: utf-8
class Card
    attr_reader :name, :cost, :type

    module Type
        MINION = 0
        SPELL = 1
        WEAPON = 2
        HERO = 3
    end

    def initialize(name, cost, type)
        @name = name
        @cost = cost
        @type = type
    end

    def is(name)
        return @name==name
    end
    alias :should_be :is
end
