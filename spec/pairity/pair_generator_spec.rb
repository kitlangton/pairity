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

      it 'generates the same pairings without saving' do
        original_pairs = pg.generate_pairs
        expect(pg.generate_pairs.sort).to eq original_pairs.sort
      end

      it 'generates different pairings after saving' do
        original_pairs = pg.generate_pairs
        pg.save_pairs
        2.times do
          expect(pg.generate_pairs).to_not eq original_pairs
          pg.save_pairs
        end
      end

      it 'repeats pairings after each pairing has been made' do
        original_pairs = pg.generate_pairs
        pg.save_pairs
        2.times do
          pg.generate_pairs
          pg.save_pairs
        end
        expect(pg.generate_pairs).to eq original_pairs
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
  end

  describe '#condemn_pairing' do

    before do
      people.each do |person|
        matrix.add_person(person)
      end
    end

    it 'removes the chance of two people being paired' do
      pg.abolish_pairing(barack, xena)

      pairs = pg.generate_pairs # !> assigned but unused variable - pairs

      simulate_pairings(pg, 300) do
        expect(pg.include?(barack, xena)).to eq false
      end
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
    end

    context 'with less than 1' do
      it 'increases the likelihood of pairing' do
        pg.resistance(kit, barack, 0.5)

        simulate_pairings(pg, 12)
        expect(pg.days_for_pair(kit, barack)).to eq 5
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
