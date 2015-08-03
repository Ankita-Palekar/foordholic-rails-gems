class RecipesController < ApplicationController
  # GET /recipes
  # GET /recipes.json
include SessionsHelper
include RecipesHelper

  before_filter :confirm_is_recipe_owner, :only=>[:edit]

  def confirm_is_recipe_owner
    @recipe = Recipe.find(params[:id])
    
    unless @recipe.creator_id == @current_user.id
      redirect_to '/caution'
      return false
    else
      return true
    end
  end


  def index
    @recipe_list = show_recipe_list(:status=> 'my_all_recipes', :page_nav => 1, :limit => 10)
    render 'recipe_list'
  end

  # GET /recipes/1
  # GET /recipes/1.json
  def show
    if params[:id].to_i > 0
      @recipe_details = Recipe.find(params[:id]).get_recipe_details
      @recipe = @recipe_details[:recipe_content]
      @recipe_ratings_histogram = @recipe_details[:ratings_histogram]


      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @recipe }
      end
    else
      @recipe_list = show_recipe_list(:status=> params[:id], :page_nav => 1, :limit => 10)
      render 'recipe_list'
    end   
  end

  # GET /recipes/new
  # GET /recipes/new.json
  def new
    @recipe = Recipe.new
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @recipe }
    end
  end

  # GET /recipes/1/edit
  def edit
    # @current_user = current_user
    # @existing_ingredients_list = Ingredient.getIngredients(@current_user)
    @recipe_details = Recipe.find(params[:id]).get_recipe_details
    @recipe = @recipe_details[:recipe_content]
  end

  # POST /recipes
  # POST /recipes.json
  # def create
  #   @current_user = current_user
  #   @recipe = Recipe.new(params[:recipe])
  #   @recipe.creator_id = @current_user.id
  #   ingredients_list = []
  #   if params[:ingredient]
  #     ingredients_list.push(*params[:ingredient].compact) 
  #   end
  #   if params[:existing_ingredient]
  #     ingredients_list.push(*params[:existing_ingredient].compact) 
  #   end
  #   photo_list  =  params[:avatar] ? params[:avatar] : []
  #   respond_to do |format|
  #     if (ingredients_list.empty? && photo_list.empty?)
  #       notice = ""
  #       notice += "ingredients list cannot be empty, " if ingredients_list.empty?
  #       notice += "should add images" if photo_list.empty?
  #       format.html { redirect_to new_recipe_path , notice: notice }
  #     else
  #       if @recipe.create_recipe(ingredients_list: ingredients_list, photo_list: photo_list)
  #         format.html { redirect_to @recipe, notice: 'Recipe was successfully created.' }
  #         format.json { render json: @recipe, status: :created, location: @recipe }
  #       else
  #         format.html { render action: "new" }
  #         # format.json { render json: @recipe.errors, status: :unprocessable_entity }
  #       end
  #     end
  #   end
  # end

  def create
    @current_user = current_user
    @recipe = Recipe.new(params[:recipe])
    ingredients_list = []
    ingredients_list.push(*params[:ingredient].compact)  if params[:ingredient] 
    ingredients_list.push(*params[:existing_ingredient].compact) if params[:existing_ingredient]
    @recipe.create_recipe(ingredients_list: ingredients_list,current_user: @current_user, photo_list: params[:avatar])
    respond_to do |format|
      if @recipe.persisted?
        format.html { redirect_to @recipe, notice: 'Recipe created successfully' }
        format.json { render json: @recipe, status: :created, location: @recipe }
      else
        format.html { render action: "new" }
        format.json { render json: @recipe.errors, status: :unprocessable_entity }
      end
    end
  end


  def approve_recipe
    @current_user = current_user
    @recipe = Recipe.find(params[:recipe][:id]) 
    respond_to do |format|
      begin
        notice = @recipe.approve_recipe(current_user: @current_user) ? 'successfully approved' : 'could not be approved'
        format.json { render json: @recipe , notice: notice} 
      end if params[:recipe][:approved] == "true"
    end
  end

  def reject_recipe
    @current_user = current_user
    @recipe = Recipe.find(params[:recipe][:id]) 
    respond_to do |format|
      begin
        notice = @recipe.reject_recipe(current_user: @current_user) ? 'successfully rejected' : 'could not be rejected'
        format.json { render json: @recipe , notice: notice} 
      end if(params[:recipe][:rejected] == "true")
    end
  end

  def rate_recipe
    @current_user = current_user
    puts params.inspect
    @recipe = Recipe.find(params[:recipe][:id]) 
    respond_to do |format|
      @rate = @recipe.rate_recipe(current_user: @current_user, ratings: params[:recipe][:ratings])
      @rate[:notice] = @rate.changed? ? "successfully rated" : @rate.errors.full_messages.first
      format.json {render json: @rate, status: :created, location: @recipe }
    end
  end

  # PUT /recipes/1
  # PUT /recipes/1.json
  def update
    @current_user = current_user
    @recipe =  Recipe.find(params[:id])
    ingredients_list = []
    ingredients_list.push(*params[:ingredient].compact)  if params[:ingredient] 
    ingredients_list.push(*params[:existing_ingredient].compact) if params[:existing_ingredient]
    @recipe.update_attributes(params[:recipe])
    respond_to do |format|  
      @recipe.update_recipe(ingredients_list: ingredients_list, photo_list:params[:avatar], current_user:@current_user)
      if @recipe.valid?
        format.html { redirect_to @recipe, notice: 'Recipe was successfully edited.'}
      else
        format.html { render action: "edit" }
        format.json { render json: @recipe.errors, status: :unprocessable_entity }
      end   
    end
end




  # DELETE /recipes/1
  # DELETE /recipes/1.json
  def destroy
    @recipe = Recipe.find(params[:id])
    @recipe.destroy
    respond_to do |format|
      format.html { redirect_to recipes_url }
      format.json { head :no_content }
    end
  end

  def searchrecipes
  # puts params.inspect
    @recipe_list =  Recipe.search(:flag => params[:flag], :query => params[:query])
    render 'search'
  end

  def rated_users_list
    @recipe = Recipe.find(params[:id])
    @users_list = @recipe.list_rated_users(:ratings => params[:ratings])
  end
end
