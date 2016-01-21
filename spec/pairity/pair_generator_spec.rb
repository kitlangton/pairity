require 'spec_helper'

describe Pairity::PairGenerator do

  Pairity::PairGenerator.shuffle = false

  let(:matrix) { Pairity::AdjacencyMatrix.new }
  let(:han) { matrix.han_solo}
  let(:pg) { Pairity::PairGenerator.new(matrix) }
  let(:kit) { Pairity::Person.new(name: "Kit") }
  let(:barack) { Pairity::Person.new(name: "Barack") }
  let(:deepa) { Pairity::Person.new(name: "Deepa") }
  let(:xena) { Pairity::Person.new(name: "Xena") }
  let(:people) { [kit, barack, deepa, xena] }

  describe '#generate_pairs' do

    context '4 people' do

      before do
        people.each do |person|
          matrix.add_person(person)
        end
      end

      it 'generates pairs' do
        pg.generate_pairs
        expect(pg.pairs.size).to eq 2
      end

      it 'generates different pairings after saving' do
        original_pairs = pg.generate_pairs
        pg.save_pairs
        2.times do
          expect(pg.generate_pairs).to_not eq original_pairs
          pg.save_pairs
        end
      end

      # it 'generates different pairings after saving' do
      #   pg.abolish_pairing(barack, deepa)
      #   deepa.tier = 3
      #   kit.tier = 3
      #   simulate_pairings(pg, 155)
      #   pairs = pg.old_pairs
      #   branch_pairs = pg.branch_pairs
      #   puts "branch: #{matrix.weight_for_pairs(branch_pairs)}"
      #   puts "normal: #{matrix.weight_for_pairs(pairs)}"
      #   p matrix[xena, deepa].days
      #   p matrix[kit, deepa].days
      #   expect(pairs).to eq branch_pairs
      # end

      it 'is generally fair' do
        simulate_pairings(pg,600)
        average = matrix.without_solo.inject(0) { |sum, data| sum += data[1].weight } / matrix.without_solo.size
        matrix.without_solo.each do |pair, edge|
          expect(edge.weight).to be_within(1).of(average)
        end
      end

      it 'everyone is paired twice after 6 days' do
        simulate_pairings(pg, 6)
        people.combination(2) do |p1, p2|
          expect(pg.days_for_pair(p1, p2)).to eq 2
        end
      end

      it 'everyone is paired 4 times after 12 days' do
        simulate_pairings(pg, 12)
        people.combination(2) do |p1, p2|
          expect(pg.days_for_pair(p1, p2)).to eq 4
        end
      end

      it 'does not have Han Solo' do
        pg.generate_pairs
        expect(pg.pairs.flatten.include?(han)).to eq false
      end

      it 'never pairs the same two people twice in a row' do
        last_pairs = pg.generate_pairs
        pg.save_pairs
        simulate_pairings(pg, 800) do
          last_pairs.each do |pair|
            expect(pg.pairs).to_not include pair
          end
          last_pairs = pg.pairs
        end
      end
    end

    context '3 people' do

      before do
        people.first(3).each do |person|
          matrix.add_person(person)
        end
      end

      it 'generates pairs' do
        pg.generate_pairs
        expect(pg.pairs.size).to eq 2
      end

      it 'has Han Solo' do
        pg.generate_pairs
        expect(pg.pairs.flatten.include?(han)).to eq true
      end

      it 'everyone is paired 4 times after 12 days' do
        simulate_pairings(pg, 12)
        people.first(3).combination(2) do |p1, p2|
          expect(pg.days_for_pair(p1, p2)).to eq 4
        end
      end
    end

    context 'people at different tiers' do

        before do
          people.each do |person|
            matrix.add_person(person)
          end
        end

      it 'two tier threes are less likely to be paired' do
        barack.tier = 3
        kit.tier = 3
        simulate_pairings(pg,100)
        average = matrix.average_days
        expect(matrix[kit, barack].days).to be < average
      end

      it 'two tier ones are less likely to be paired' do
        xena.tier = 1
        deepa.tier = 1
        simulate_pairings(pg,100)
        average = matrix.average_days
        expect(matrix[xena, deepa].days).to be < average
      end

      it 'tier twos will be paired an average amount' do
        barack.tier = 2
        kit.tier = 2
        simulate_pairings(pg,100)
        average = matrix.average_days
        expect(matrix[kit, barack].days).to be_within(1).of(average)
      end
    end
  end

  describe "#possible_pairs" do
    before(:each) do
      people.each do |person|
        matrix.add_person(person)
      end
      # matrix.add_person(Pairity::Person.new(name: "Kyle"))
      # matrix.add_person(Pairity::Person.new(name: "Clark"))
      # matrix.add_person(Pairity::Person.new(name: "Bill"))
      # matrix.add_person(Pairity::Person.new(name: "Chill"))
      # matrix.add_person(Pairity::Person.new(name: "Mill"))
      # matrix.add_person(Pairity::Person.new(name: "Kill"))
      # matrix.add_person(Pairity::Person.new(name: "Zill"))
      # matrix.add_person(Pairity::Person.new(name: "Bobby"))
      # matrix.add_person(Pairity::Person.new(name: "Chobby"))
    end

    it 'generates an array of all possible pairings' do
      expect(pg.possible_pairs).to eq [[[barack, kit],[deepa, xena]], [[deepa, kit],[barack,xena]],[[kit,xena],[barack,deepa]]]
    end
  end

  describe '#condemn_pairing' do

    before(:each) do
      people.each do |person|
        matrix.add_person(person)
      end
    end

    it 'removes the chance of two people being paired' do
      pg.abolish_pairing(barack, xena)
      simulate_pairings(pg, 1000)
      expect(matrix[barack,xena].days).to eq 0
    end
  end

  describe '#resistance' do

    before do
      people.each do |person|
        matrix.add_person(person)
      end
    end

    context 'with 1' do
      it 'does not change the likelihood of pairing' do
        pg.resistance(kit, barack, 1)

        simulate_pairings(pg, 12)
        expect(pg.days_for_pair(kit, barack)).to eq 4
      end
    end

    context 'with greater than 1' do
      it 'decreases the likelihood of pairing' do
        pg.resistance(kit, barack, 2)

        simulate_pairings(pg, 12)
        expect(pg.days_for_pair(kit, barack)).to eq 3
      end

      it 'will reduce their pairings over time' do
        pg.resistance(kit, barack, 2)
        simulate_pairings(pg,300)
        average = matrix.average_days
        expect(matrix[kit, barack].days).to be < average
      end
    end

    context 'with less than 1' do
      it 'increases the likelihood of pairing' do
        pg.resistance(kit, barack, 0.5)

        simulate_pairings(pg, 12)
        expect(pg.days_for_pair(kit, barack)).to eq 5
      end

      it 'will increase their pairings over time' do
        pg.resistance(kit, barack, 0.5)
        simulate_pairings(pg,300)
        average = matrix.average_days
        expect(matrix[kit, barack].days).to be > average
      end
    end
  end

  describe '#equilibrium' do

    before do
      people.each do |person|
        matrix.add_person(person)
      end
    end

    it 'returns number of days for everyone to pair w/ everyone' do
      expect(pg.equilibrium).to eq 3
    end
  end
end

def simulate_pairings(generator, days)
  days.times do
    generator.generate_pairs
    generator.save_pairs
    yield if block_given?
  end
end
