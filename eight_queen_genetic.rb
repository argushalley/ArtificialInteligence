class EightQueenGenetic
  attr_reader :population

  def initialize(mutation_rate, crossover_rate, population_size)
    @mutation_rate, @crossover_rate, @population_size = mutation_rate, crossover_rate, population_size
    @population = generate_initial_population
  end

  def generate_individual
    (0..7).to_a.shuffle
  end

  def generate_initial_population
    population = []
    while population.size < @generation_size do
      individual = generate_individual
      unless population.include?(individual)
        population << individual
      end
    end
    population
  end

  def fitness(individual)
    column_conflicts(individual) + diagonal_conflicts(individual)
  end

  def column_conflicts(individual)
    repeated_columns = Hash.new(0)

    individual.each do |column|
      repeated_columns.store(column, repeated_columns[column]+1)
    end

    repeated_columns.map do |key, value|
      value > 1 ? value : 0
    end.compact.reduce(:+)
  end

  def diagonal_conflicts(individual)
    conflicts = 0
    individual.each_with_index do |column1, line1|
      individual.each_with_index do |column2, line2|
        if line1 != line2 &&
          column1 != column2 &&
          (line1-line2).abs == (column1 - column2).abs
          conflicts += 1
        end
      end
    end
    conflicts / 2
  end

  def crossover(father, mother)
    children = []
    mid = (father.length / 2) - 1
    father_leftmost = father[0..mid]
    father_rightmost = father[mid+1..-1]
    mother_leftmost = mother[0..mid]
    mother_rightmost = mother[mid+1..-1]
    children << father_leftmost + mother_rightmost
    children << mother_leftmost + father_rightmost
    children
  end
end
