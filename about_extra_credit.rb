# frozen_string_literal: true

require './about_dice_project'
require './about_scoring_project'

# Class that represents Player of the Greed Game
class Player
  attr_reader :name
  attr_accessor :score

  def initialize(name)
    @name = name
    @score = 0
  end

  def roll(dices_amount)
    dice_set = DiceSet.new
    dice_set.roll(dices_amount)

    dice_set.values
  end

  def to_s
    @name
  end
end

# Class that represents Greed Game from GREED_RULES.txt
class GreedGame
  FINISH_SCORE = 3000
  START_DICES_AMOUNT = 5
  DICE_MAX_VALUE = 6
  attr_reader :players

  def initialize
    @players = []
  end

  def print_players
    @players.each { |player| puts "#{player.name}: #{player.score}" }
  end

  def create_player(player_number)
    print "Player #{player_number} name: "
    name = gets.chomp
    name = "Player #{player_number}" if name.empty?

    Player.new(name)
  end

  def add_players
    amount = read_players_amount

    puts 'Enter players names (use "" for default name):'
    amount.times do |index|
      player = create_player(index + 1)
      @players.push(player)
    end
  end

  def play
    say_welcome
    add_players
    print_players

    start_game
  end

  private

  def start_game
    (1..nil).each do |round|
      puts "Round #{round}!\n\n"

      @players.each do |player|
        puts "#{player} turn!\n\n"
        make_turn(player)
      end
    end
  end

  def say_welcome
    puts 'GREED GAME'
    puts '-----------------------------------------------------------------\n\n'
  end

  def make_turn(player)
    score = 0
    dices = START_DICES_AMOUNT

    (1..nil).each do
      roll_score, dices = ask_to_roll(player, dices)
      score, stop_rolling = manage_turn_actions(player, score, roll_score)
      break if stop_rolling
    end

    player.score += score
    puts "#{player} earned #{score}. #{player} total score: #{player.score}\n\n"
  end

  def manage_turn_actions(player, score, roll_score)
    if roll_score != 0 && roll_score + score >= 300
      question = "#{player}, You accumulate #{score + roll_score} points,"\
      ' do you want to continue rolling?\n\n'

      return [score + roll_score, !ask_yes_or_no?(question)]
    elsif roll_score != 0 && roll_score + score < 300
      puts "#{player}, You must roll (turn points: #{score + roll_score} < 300)\n\n"
      return [score + roll_score, false]
    end

    puts "#{player}, You lost accumulated score: #{score} (rolled 0 points)\n\n"
    [0, true]
  end

  def ask_yes_or_no?(message)
    puts "#{message} (Y/y - yes, N\n - no)\n\n"
    answer = gets.chomp.upcase

    answer == 'Y'
  end

  def count_non_scoring_dices(diceset)
    dices_amount = diceset.count
    (1..DICE_MAX_VALUE).each do |dice_value|
      value_count = diceset.count { |rolled_value| dice_value == rolled_value }

      if [1, 5].include?(dice_value)
        dices_amount -= value_count
      elsif value_count >= 3
        dices_amount -= 3
      end
    end

    dices_amount
  end

  def ask_to_roll(player, dices_amount)
    puts "#{player}, press \"Enter\" to roll...\n"
    gets.chomp

    roll_result = player.roll(dices_amount)
    puts "#{player} rolled #{roll_result}!\n\n"

    score = score(roll_result)
    non_scoring_dices = count_non_scoring_dices(roll_result)

    [score, non_scoring_dices]
  end

  def read_players_amount
    (1..nil).each do
      begin
        print 'Enter players amount: '
        amount = Integer(gets.chomp)

        raise ArgumentError if amount <= 1

        return amount
      rescue ArgumentError
        puts 'You have entered wrong players amount (2 or more). Try again...\n\n'
      end
    end
  end
end

game = GreedGame.new
game.play
