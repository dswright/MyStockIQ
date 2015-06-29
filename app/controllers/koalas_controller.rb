class KoalasController < ApplicationController

	def index
		@koalas = Koala.all
	end

	
	def new
		@koala = Koala.new(color: "blue")
	end

	def create
		params = koala_params
		@source = params[:source]
		koala_input = {name: params[:name], color: params[:color]}
		@koala = Koala.new(koala_input)
		@koala.save

		puts "Page source type is #{@source}"
		redirect_to new_koala_path
	end

	def show 
	end

	private

	def koala_params
		params.require(:koala).permit(:name,:color,:source)
	end

end