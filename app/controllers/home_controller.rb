class HomeController < ApplicationController
  # before_action :authenticate_user!, only: [:search]

  def index
    puts "\n\nuser_signed_in? --> #{user_signed_in?.inspect}\n\n"
    puts "current_user --> #{current_user.inspect}\n\n"
    puts "flash --> #{flash[:notice].inspect}\n\n"
  end

  # def search
  #   handler = GithubApiHandler.new('website', current_user.email)
  #   parsed_response = handler.search_repos
  #   if parsed_response
  #     @total_count = parsed_response['total_count']
  #     @items = parsed_response['items'].paginate(page: params[:page], per_page: 20)
  #   end
  # end

  def request_authentication
  end
end
