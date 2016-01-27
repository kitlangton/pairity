require 'highline/import'
require 'terminal-table'
require 'rainbow'
require 'yaml'

module Pairity
  class CLI
    def initialize
      @matrix = AdjacencyMatrix.new
      @sync = GoogleSync.new(@matrix)
      @generator = PairGenerator.new(@matrix)
      @renderer = PairRenderer.new(@matrix)
      load_google
    end

    def start
      unless Config.configured?
        slack_config
      end

      action_menu
    end

    def action_menu
      puts
      puts Rainbow("==== PAIRITY ====").white
      choose do |menu|
        menu.prompt = "What would you like to do?"
        menu.choice("Generate Pairs") { generate_pairs }
        menu.choice("Edit People") { edit_people }
        menu.choice("Edit Pair") { edit_pair }
        menu.choice("Simulate Days") { simulate_pairs }
        menu.choice("Save Changes") { save_changes }
        menu.choice("Open Google Sheet") { open_google_sheet }
      end

    end

    def open_google_sheet
      `open "#{@sync.sheet_url}"`

      action_menu
    end

    def slack_config
      puts "Let's set up Slack Integration."
      Config.load
      slack_webhook = ask("Please enter your Slack Webhook URL (more information: https://vikingcodeschool.slack.com/apps/new/A0F7XDUAZ-incoming-webhooks)") do |q|
        q.validate = /hooks\.slack\.com\/services\//
      end

      channel = ask("What channel would you like to post to?")

      Config.add(url: slack_webhook, channel: channel)
      Config.save
    end

    def edit_people
      choose do |menu|
        menu.prompt = "Add or remove?"
        menu.choice("Add") { add_people }
        menu.choice("Remove") { remove_people }
        menu.choice("Rename") { rename }
        menu.choice("Change Tier") { change_tier }
      end
    end

    def save_changes
      @sync.save
      action_menu
    end

    def rename
      choice = choose_person

      new_name = ask "What name would you like to give #{Rainbow(choice.name).white}?"

      old_name = choice.name
      choice.name = new_name

      puts "#{Rainbow(old_name).white} shall henceforth be known as #{Rainbow(choice.name).white}!"

      action_menu
    end

    def change_tier
      choice = choose_person(tier: true)

      tier = 2
      choose do |menu|
        menu.prompt = "Set #{Rainbow(choice.name).white} to what tier?"
        menu.choice("Tier 1") { tier = 1 }
        menu.choice("Tier 2") { tier = 2 }
        menu.choice("Tier 3") { tier = 3 }
      end

      choice.tier = tier

      puts "#{Rainbow(choice.name).white} is now tier #{tier}."

      action_menu
    end

    def remove_people
      choice = choose_person

      answer = ask "Are you sure you would like to remove #{Rainbow(choice).white}?" do |q|
        q.validate = /y|n/
      end

      if answer =~ /y/
        @matrix.remove_person(choice)
      end

      puts "#{Rainbow(choice).white} has been removed."

      action_menu
    end

    def choose_person(tier: false)
      people = @matrix.people(true)
      choice = nil
      choose do |menu|
        menu.prompt = "Select a person."
        people.each_with_index do |person, index|
          menu.choice(display_person(person, tier: tier)) { choice = people[index] }
        end
      end
      choice
    end

    def display_person(person, tier: false)
      output = []
      output << "#{Rainbow(person.name).white}"
      output << "-- Tier #{person.tier}" if tier
      output.join(" ")
    end

    def add_people
      names = ask "What are their names? (enter names separated by commas)"
      names = names.split(",")
      names.each do |name|
        person = Person.new(name: name.strip)
        @matrix.add_person(person)
        puts "Added #{name.strip}!"
      end
      action_menu
    end

    def nope_pair
      pair = choose_from_generated_pair

      answer = ask "Are you sure you would like to nope today's #{display_pair_names(pair)} pairing?" do |q|
        q.validate = /y|n/
      end

      if answer =~ /y/
        p1, p2 = pair
        @generator.nope(p1, p2)
        puts "#{display_pair_names(pair)} have been 'Noped'!"
      end

      @generator.generate_pairs
      pairs_menu
    end

    def choose_from_generated_pair
      choice = nil

      choose do |menu|
        menu.prompt = "Who would you like to edit?"
        @generator.pairs.each_with_index do |pair, index|
          menu.choice(display_pair_names(pair)) { choice = index }
        end
      end

      choice = @generator.pairs[choice]
    end

    def choose_pair
      choice = nil

      choose do |menu|
        menu.prompt = "Who would you like to edit?"
        all_combos.with_index do |pair, index|
          menu.choice(display_pair_names(pair)) { choice = index }
        end
      end

      choice = all_combos.to_a[choice]
    end


    def edit_pair
      choice = choose_pair

      choose do |menu|
        menu.prompt = "How would you like to edit #{display_pair_names(choice)}"
        menu.choice("Increase Pair Chance") { increase_chance(choice) }
        menu.choice("Decrease Pair Chance") { decrease_chance(choice) }
        menu.choice("Abolish Pair Chance") { condemn_pair(choice) }
      end

    end

    def increase_chance(pair)
      answer = ask "Are you sure you would like to increase the odds of #{display_pair_names(pair)} pairing?" do |q|
        q.validate = /y|n/
      end

      if answer =~ /y/
        p1, p2 = pair
        @generator.resistance(p1, p2, 0.5)
        puts "#{display_pair_names(pair)} are more likely to be paired."
      end

      action_menu
    end

    def decrease_chance(pair)
      answer = ask "Are you sure you would like to decrease the odds of #{display_pair_names(pair)} pairing?" do |q|
        q.validate = /y|n/
      end

      if answer =~ /y/
        p1, p2 = pair
        @generator.resistance(p1, p2, 2)
        puts "#{display_pair_names(pair)} are less likely to be paired."
      end

      action_menu
    end

    def condemn_pair(pair)

      answer = ask "Are you sure you would like to condemn #{display_pair_names(pair)}?" do |q|
        q.validate = /y|n/
      end

      if answer =~ /y/
        @generator.abolish_pairing(*pair)
        puts "#{display_pair_names(pair)} will no longer be paired."
      end

      action_menu
    end

    def generate_pairs
      @generator.generate_pairs
      puts
      pairs_menu
    end

    def pairs_menu
      display_pairs
      puts
      choose do |menu|
        menu.prompt = "What would you like to do?"
        menu.choice("Save & Slack") { save_pairs }
        menu.choice("'Nope' a Pair") { nope_pair }
        menu.choice("Main Menu") { action_menu }
      end
    end

    def save_pairs
      @generator.save_pairs
      puts
      PairSaver.new(@generator.pairs).post_to_slack
      say "Posted pairings to slack!"
      @sync.save
      action_menu
    end

    def simulate_pairs
      times = ask("How many days should we to travel?")

      times.to_i.times do
        @generator.generate_pairs
        @generator.save_pairs
      end

      display_pair_stats

      action_menu
    end

    def all_combos
      @matrix.people.combination(2)
    end

    def display_pair_stats
      rows = []
      all_combos.each do |person1, person2|
        display_pair(rows, person1, person2)
      end
      table = Terminal::Table.new headings: ["Pair","Times"], rows: rows
      puts table
    end

    def display_pairs
      rows = []
      @generator.pairs.each do |person1, person2|
        display_pair(rows, person1, person2)
      end
      table = Terminal::Table.new headings: ["Pair","Times"], rows: rows
      puts table
    end

    def display_pair_names(pair)
      person1, person2 = pair
      Rainbow(person1).white + " & " + Rainbow(person2).white
    end

    def display_pair(rows, person1, person2)
      cols = []
      cols << display_pair_names([person1, person2])
      cols << @renderer.stats_for_pair(person1, person2)
      rows << cols
    end

    def load_google
      @sync.load
    end
  end
end
