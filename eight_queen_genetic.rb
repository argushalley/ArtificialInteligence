class EightQueenGenetic
  attr_reader :population, :population_size, :mutation_rate

  def initialize(mutation_rate, crossover_rate, population_size)
    @mutation_rate, @crossover_rate, @population_size = mutation_rate, crossover_rate, population_size
    @population = generate_initial_population
  end

  def generate_individual
    (0..7).to_a.shuffle
  end

  def generate_initial_population
    population = []
    while population.size < population_size do
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
    individual.each_with_object(0) do |gene, cost|
      cost += individual.count(gene) - 1
    end
  end

  def conflicts(value)
    (1..value-1).to_a.reduce(:+)
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
    conflicts
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

  def mutation(individual)
    if rand < mutation_rate
      first_pos = rand(0..7)
      last_pos = rand(0..7)
      temp = individual[first_pos]
      individual[first_pos] = individual[last_pos]
      individual[last_pos] = temp
      individual
    end
  end

  def sort_population
    population.sort { |x, y| fitness(x) <=> fitness(y) }
  end
end
