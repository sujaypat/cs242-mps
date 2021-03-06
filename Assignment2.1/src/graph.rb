require 'test-unit'
require 'set'
require 'gruff'
class Graph

  attr_accessor :movies
  attr_accessor :actors
  attr_accessor :actor_set
  attr_accessor :movie_set
  attr_accessor :all_json

  def initialize(filename)
    @actor_set = Set.new
    @movie_set = Set.new
    @movies = Array.new
    @actors = Array.new
    read_json('/Users/Sujay/Documents/cs242/Assignment2.1/' + filename)
  end

  def get_actor_name(name)
    name = name.delete('"')
    result = Array.new
    actors.each do |actor|
      if actor.name.include? name.delete('"')
        result << actor
      end
    end
    return result
  end

  def get_actor_age(age)
    age = age.to_i
    result = Array.new
    actors.each do |actor|
      if actor.age == age
        puts "found match"
        result << actor
      end
    end
    return result
  end

  def get_actor_gross(gross)
    result = Array.new
    actors.each do |actor|
      if actor.gross == gross
        result << actor
      end
    end
    return result
  end

  def get_movie_name(title)
    result = Array.new
    movies.each do |movie|
      if movie.title.include? title.tr('"', '')
        result << movie
      end
    end
    return result
  end

  def get_movie_gross(gross)
    result = Array.new
    movies.each do |movie|
      if movie.gross == gross
        result << movie
      end
    end
    return result
  end

  def movies_year(year)
    # add all movies from year to list
    result = Array.new
    movies.each do |movie|
      if movie.year == year
        result << movie
      end
    end
    return result
  end

  def actor_insert(actor)
    actors << (actor)
    for m in movies # every movie, if actor in movie add actor to movie connections
        # and add movie to actor's connections
      if m.actor_connections.include? actor.name
        actor.movie_connections << m
      end
    end
  end

  def movie_insert(movie)
    movies << (movie)
    for a in actors # every movie, if actor in movie add actor to movie connections
      # and add movie to actor's connections
      if a.movie_connections.include? movie.title
        movie.actor_connections << a
      end
    end
  end

  # Iterate through list of movies, find matching name and return gross value
  def gross(movie_name)
    for m in movies
      if m.title == movie_name
        return m.gross
      end
    end
    return -1
  end

  def topn_gross(n)
    # sort by gross, slice top n
    movies.sort_by(&:gross).last(n)
  end

  def topn_old(n)
    # sort by age, slice top n
    actors.sort_by(&:age).last(n)
  end

  def actor_movies(actor_name)
    # return all movies connected by an edge to actor
    for a in actors
      if a.name == actor_name
        return a.movie_connections
      end
    end
    return nil
  end

  def movie_actors(movie_name)
    # same as above but the other way around
    for m in movies
      if m.title == movie_name
        return m.actor_connections
      end
    end
    return nil
  end

  def actors_year(year)
    movies_for_year = movies_year(year)
    result = Array.new
    for m in movies_for_year
      for a in m.actor_connections
        result << a
      end
    end
    # add all actors from each movie in movies_year to list
    return result
  end


  # counts the number of connections each actor has and sorts it, and filters the top 5
  def analyze_hub
    names = {}
    labels = {}

    actors.each do |actor|
      count = 0
      actor.movie_connections.each do |movie|
        count += movie.actor_connections.length
      end
      names[actor.name] = count
    end
    names = names.sort_by{|k,v| v}.reverse[0..5]

    iter = -1
    names.each do |k,v|
      labels[iter+=1] = k
    end

    g = Gruff::Bar.new('1600x900')
    g.label_stagger_height = 20
    g.sort = false
    g.title = 'hub actors'
    g.labels = labels
    g.data('data',names.collect { |k, v| v })
    g.write('hub.png')
  end

  # plots age vs gross
  def analyze_age_gross
    ages = Array.new
    grosses = Array.new

    actors.each do |actor|
      ages << actor.age
      grosses << actor.gross
    end

    g = Gruff::Scatter.new('1600x900')
    g.title = 'age vs gross'
    g.data('data', ages, grosses)
    g.write('trends.png')
  end



  def dump_json
    jsonified_movies = @graph.movies.to_json
    jsonified_actors = @graph.actors.to_json
    File.open('../movies.json', 'w'){ |f| f << jsonified_movies}
    File.open('../actors.json', 'w'){ |f| f << jsonified_actors}
  end


  def read_json(filename)
    @all_json = JSON.parse(File.read(filename))
    actors = all_json[0]
    movies = all_json[1]

    actors.each do |_, value|
      temp_actor = Actor.new(value["name"], value["total_gross"], value["age"])
      value["movies"].each do |movie_title|
        begin
        temp_movie = Movie.new(movies[movie_title]["name"], movies[movie_title]["box_office"], movies[movie_title]["year"])
        found_movie = @movies.find {|mov| mov.title == movies[movie_title]["name"]}
        if !found_movie
          @movies << temp_movie
          @movie_set << temp_movie
          temp_actor.movie_connections << temp_movie
          temp_movie.actor_connections << temp_actor
        else
          temp_actor.movie_connections << found_movie
          found_movie.actor_connections << temp_actor
        end
        rescue => error
        end
      end
      @actors << temp_actor
      @actor_set << temp_actor
    end
  end

end

class Movie
  attr_accessor :title
  attr_accessor :gross
  attr_accessor :year
  attr_accessor :actor_connections

  def initialize(title, gross, year)
    @title = title
    @gross = gross
    @year = year
    @actor_connections = Array.new
  end

  def to_json
    repr = {}
    repr['title'] = @title
    repr['year'] = @year
    repr['gross'] = @gross
    arr = Array.new
    @actor_connections.each do |actor|
      arr << actor.name
    end
    repr['cast'] = arr
    return repr.to_json
  end

end

class Actor
  attr_accessor :name
  attr_accessor :age
  attr_accessor :gross
  attr_accessor :movie_connections

  def initialize(name, gross, age)
    @name = name
    @age = age
    @gross = gross
    @movie_connections = Array.new
  end

  def to_json
    repr = {}
    repr['name'] = @name
    repr['age'] = @age
    repr['gross'] = @gross
    arr = Array.new
    @movie_connections.each do |movie|
      arr << movie.title
    end
    repr['movies'] = arr
    return repr.to_json
  end

end