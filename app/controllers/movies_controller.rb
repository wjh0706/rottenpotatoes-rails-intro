class MoviesController < ApplicationController

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    
    @all_ratings = Movie.all_ratings

    if session[:order_by].nil?
      session[:order_by] = params[:order_by]
    end

    @ratings_to_show = []
    if params[:ratings].nil? && session[:ratings].nil?
      session[:ratings] = @all_ratings
    elsif !params[:ratings].nil?
      session[:ratings] = params[:ratings].keys
    else
      redirect_to movies_path(ratings: Hash[session[:ratings].collect{|i|[i, "1"]}], order_by: session[:order_by])
    end

    @ratings_to_show = Hash[session[:ratings].collect{|i|[i, "1"]}]

    @movies = Movie.with_ratings(@ratings_to_show.keys)
    if session[:order_by]
      @movies = @movies.order(session[:order_by])
    end
    
    if params[:order_by] == 'release_date'
      @release_date_style = 'bg-warning hilite'
    elsif params[:order_by] == 'title'
      @title_style = 'bg-warning hilite'
    end
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

  private
  # Making "internal" methods private is not required, but is a common practice.
  # This helps make clear which methods respond to requests, and which ones do not.
  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end
end
