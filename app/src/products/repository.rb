class ProductsRepository
  
  def initialize
    @next_id = 0
    @data = {}
    @mutex = Mutex.new
  end

  def push(name)
    @data[@next_id] = { id: @next_id, name: name }
    @next_id += 1
  end

  def get(id)
    @data[id]
  end
  
  def get_all
    @data.values
  end

end
