class Spector
  #require File.expand_path("../../config/environment", __FILE__)
  attr_accessor :files, :data
  def initialize
    @paths = {
      :spec => 'rb',
      :features => 'feature'
    }
    #key is path, value is extention
    @files = {}
    #@initial_dir = Dir.getwd
  end

  def go
    list :features
    list :spec
    process_files
    process_data
    return @data
#    raise @data.inspect
    #Dir.chdir(@initial_dir)
  end

  #build a list of the files
  def list type
    @root = Rails.root
    Dir.chdir("#{@root}/#{type.to_s}")
    @files[type] = Dir.glob("**/*.#{@paths[type]}")
  end

  #loop throu files and read the contents into @data hash
  def process_files
    @data = {}
    @files.each do |t, files|
      @data[t] ||= {}
      files.each do |file|
        data = File.open("#{Rails.root}/#{t}/#{file}", "r"){|f| f.readlines}
        @data[t][file] = data
      end
    end
  end

  #for each type (:feature, rspec), for each file, examine file and update @data hash with results
  def process_data
    @data.each do |t, files|
      files.each do |path, file|
        @nd = {:main_tags => [], :feature => "", :scenarios => []}
        @add_tags_to_main = true
        @add_to_s = false
        file.each do |line|
          process_line(line)
        end
        @data[t][path] = {:file => "", :data  => @nd}
      end
    end

  end

  #Called on each line of each file.  Decide what action to take depending on the contents on the line
  def process_line line
    if line.include?("@") && @add_tags_to_main
      @nd[:main_tags] << line 
    elsif line.include?("Feature:")
      @nd[:feature] = line.sub("Feature:","")
      @add_tags_to_main = false
    elsif line.include?("Scenario:")
      @nd[:scenarios].push({:name => line.sub("Scenario:",""), :steps => []})
      @add_to_s = true
    elsif
      begin
      @nd[:scenarios].last[:steps].push(line) if @add_to_s
      @add_to_s = true  
      rescue
      end
    end


  end

  def pretty_step step

    step.sub!("Given", "<div class='spector-keyword'>Given</div>")
    step.sub!("When", "<div class='spector-keyword'>When</div>")    
    step.sub!("Then", "<div class='spector-keyword'>Then</div>")          
    step.sub!("And", "<div class='spector-keyword'>And</div>")
    if step.include?("#")
      step = "<div class='spector-comment'>#{step}</div>"
    end
    step = step.split("\"").in_groups_of(2).map{|a,b| b.nil? ? a : "#{a}<div class='spector-quote'>\"#{b}\"</div>"}.join
    step
  end

  #print to screen just the Features and Scenario headers
  def cuke
    cuke = []
    @data[:features].each do |p, d|
      cuke << d[:data][:feature]
      d[:data][:scenarios].each do |s|
        cuke << s[:name]
      end
    end
    puts cuke
    cuke
  end
end

=begin

s = Spector.new
s.go
s.process_files
s.process_data

=end
