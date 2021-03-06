%w(rubygems sinatra dm-core dm-timestamps RedCloth).each { |x| require x  }

configure do 
  DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/slides.sqlite3")

  class Slide
    include DataMapper::Resource
    property :id,       Serial
    property :title,    String,   :nullable=>false, :lazy=>false
    property :body,     Text,     :nullable=>false, :lazy=>false
    property :position, Integer,  :nullable=>false
    timestamps :at
    
    before :create do
      self.position = Slide.all.size + 1
    end 
    
    def self.sort(ids)
      ids.each_with_index do |id, index| 
        Slide.get(id).update_attributes(:position=>index)
      end
    end 
  end

  DataMapper.auto_upgrade!
end 

# ur presentation
get '/' do
  @slides = Slide.all(:order=>[:position])
  erb :index
end

# edit form for a slide
get '/:id/edit' do
  @slide = Slide.get(params[:id])
  erb :edit
end 

# confirmation page for deleting a slide
get '/:id/destroy' do
  @slide = Slide.get(params[:id])
  erb :destroy
end 

# creates a slide
post '/' do
  redirect "/#{ Slide.create(params[:slide]).id }/edit"
end

# updates a presentation (the slide collection)
# only via ajax
put '/' do
  Slide.sort(params[:ids].split(','))
  status 200
end 

# updates a slide
put '/:id' do
  Slide.get(params[:id]).update_attributes(params[:slide])
  redirect "/#slide_#{ params[:id] }"
end 

# destroys a slide
delete '/:id' do
  Slide.get(params[:id]).destroy
  redirect '/'
end