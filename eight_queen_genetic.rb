require 'rubygems'
require 'pry'

class EightQueenGenetic
  attr_reader :population, :population_size, :mutation_rate, :crossover_rate, :selected, :best

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
    individual.inject(0) do |cost, gene|
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

  def crossover(parent1, parent2)
    #children = []
    #mid = (parent1.length / 2) - 1
    #parent1_leftmost = parent1[0..mid]
    #parent1_rightmost = parent1[mid+1..-1]
    #parent2_leftmost = parent2[0..mid]
    #parent2_rightmost = parent2[mid+1..-1]
    #children << parent1_leftmost + parent2_rightmost
    #children << parent2_leftmost + parent1_rightmost
    #children
    parent1 if rand >= crossover_rate
    point = rand(parent1.length)
    parent1[0...point] + parent2[point...parent1.size]
  end

  def mutation(individual)
    if rand < mutation_rate
      first_pos = rand(0..7)
      last_pos = rand(0..7)
      temp = individual[first_pos]
      individual[first_pos] = individual[last_pos]
      individual[last_pos] = temp
    end
    individual
  end

  def sort_population
    population.sort { |x, y| fitness(x) <=> fitness(y) }
  end

  def tournament
    i, j = rand(population.size), rand(population.size)
    j = rand(population.size) while j == i

    return (fitness(population[i]) > fitness(population[j])) ? population[i] : population[j]
  end

  def selected_parents
    Array.new(population_size) { |i| tournament }
  end

  def simulate
    @population = sort_population
    @best = population.first

    10.times do |gen|
      @selected = selected_parents
      children = reproduce
      @population = children
      @population = sort_population
      @best = population.first if fitness(population.first) >= fitness(best)
      puts " > gen #{gen}, best: #{fitness(best)}, #{best}"
      break if fitness(best).zero?
    end

    return @best
  end

  def reproduce
    children = []
    selected.each_with_index do |p1, i|
      p2 = (i.modulo(2)==0) ? selected[i+1] : selected[i-1]
      p2 = selected[0] if i == selected.size-1
      child = crossover(p1, p2)
      child = mutation(child)
      children << child
      break if children.size >= population_size
    end
    return children
  end
end
