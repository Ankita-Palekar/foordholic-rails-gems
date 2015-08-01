module RecipesHelper
	def show_admin_pending_recipes(page_nav:, limit:)
		admin_pending_recipes =  Recipe.list_pending_recipes(page_nav: page_nav, limit: limit)
	 	html_code = make_admin_html_code(admin_pending_recipes)
	 	html_code
	end

	def get_existing_ingredient_list
		@current_user = current_user
		Ingredient.getIngredients(@current_user)		
	end

	def make_admin_html_code(object_list = [])
		html_code = '' 
	  object_list.each_slice(2) do |rec_block|
	  	html_code += '<div class="row">  ' 
	  	rec_block.each do |rec|
	  		rec_id = rec.id.to_s
				html_code += '<div class="span6"><div class="well"><button type="button" class="btn btn-medium btn-success disabled pull-right" disabled="disabled">' + rec.meal_class + '</button><h4 class="text-center">' + link_to(rec.name.capitalize, rec) + '</h4><hr><div class="image-div">'
				html_code += (!rec.photos.empty? ? link_to(image_tag(rec.photos.first.avatar.url(:thumb), :class => "center-block img-responsive image-rounded")) : "") 
				html_code += '</div><p class="text-center">' + rec.description.truncate(60) + '</p> <hr><div class="inline"> <span > created about ' + time_ago_in_words(rec.created_at) +' ago </span></div><div class="inline pull-right"> <button class="btn btn-mini btn-success approve-recipe" type="button" data-rec-id="'+ rec_id +'">approve</button>
					<button class="btn btn-mini btn-danger reject-recipe" type="button" data-rec-id="'+ rec_id +'">reject</button></div>
				 </div></div>'
	  	end
	 		html_code += "</div> "
	 	end if object_list != nil
	 	html_code
	end


	def make_html_code(object_list=[])
	html_code = '' 
  object_list.each_slice(2) do |rec_block|
  	html_code += '<div class="row"> ' 
  	rec_block.each do |rec|
  		html_star = "<span>"
  		  (0..(rec.aggregate_ratings.to_i)).inject { html_star += '<i class="icon-star"></i>'} 
  		html_star += '</span>'

			html_code += '<div class="span6"><div class="well recipe-container">'+html_star
			html_code+= '<a class="btn btn-warning btn-small disabled">approval pending</a>' if (!rec.approved && !rec.rejected)
			html_code+= '<a class="btn btn-danger btn-small disabled">rejected</a>' if rec.rejected 
			html_code+='<button type="button" class="btn btn-medium btn-success disabled pull-right" disabled="disabled">' + rec.meal_class + '</button><h4 class="text-center">' + link_to(rec.name.capitalize, rec) + '</h4><hr><div class="row"><div class="span3 image-div">'
			html_code += (!rec.photos.empty? ? link_to(image_tag(rec.photos.first.avatar.url(:thumb), :class => "center-block img-responsive image-rounded")) : "") 
			html_code += '</div><div class="span2"><p class="text-justify">' + rec.description.truncate(60) + '</p> </div></div><hr><span> created about ' + time_ago_in_words(rec.created_at) +' ago </span><button class="btn btn-mini btn-primary pull-right rate-recipe" type="button" data-rec-id="' + rec.id.to_s + '">Rate</button>'
				if rec.creator_id == @current_user.id
					html_code+= link_to('', edit_recipe_path(rec), :class => 'icon-pencil pull-right edit-recipe')
				end
				html_code+= '</div></div>'

  	end 
 		html_code += "</div>"
 	end if object_list != nil
 	html_code
	end


# type will be my recipes or general recipes
	def show_recipe_list(status:, page_nav:, limit:)
		creator_id = nil
		status_call = nil
		case status
			when "my_pending_recipes"
				status_call = status
				list_type = "order_by_date"
				creator_id = @current_user.id
	    when  "my_rejected_recipes"
	    	status_call = status
	    	list_type = "order_by_date"
	    	creator_id = @current_user.id
	    when  "my_approved_recipes"
	    	status_call = status
	    	list_type = "order_by_date"
	    	creator_id = @current_user.id
	    when  "my_top_rated_recipes"
	    	status_call = "my_approved_recipes"
	    	list_type = "order_by_aggregate_ratings"
	    when  "my_most_rated_recipes"
	    	status_call = "my_approved_recipes"
	    	list_type = "order_by_most_rated"
	    when "top_rated_recipes"
	    	list_type = "order_by_aggregate_ratings"
	    when "most_rated_recipes"
	    	list_type = "order_by_most_rated"
	    when "my_all_recipes"
	    	list_type = "order_by_date"
	    						
		end

		recipe_list = Recipe.list_recipes(status: status_call, list_type: list_type, page_nav: page_nav, limit: limit, creator_id: creator_id)
		recipe_list 
		# html_code =  make_html_code(recipe_list)
		# html_code
	end
end
